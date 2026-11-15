//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import Foundation
import CoreData

/// A migration that couldn't be finished. The store is left as it was before the migration (or restored to it),
/// so the migration can be tried again.
public struct CoreDataMigrationError: Error {
    public enum Stage: String {
        case unknownStoreVersion
        case checkpoint
        case stepStoreDirectory
        case step
        case storeSwap
    }

    public let stage: Stage
    public let underlying: Error?

    /// Safe for logs: the stage with the domain and the code of the underlying error only
    public var logDescription: String {
        guard let underlying else { return stage.rawValue }
        let error = underlying as NSError
        return "\(stage.rawValue) (\(error.domain) \(error.code))"
    }
}

public protocol CoreDataMigratorProtocol: AnyObject {
    typealias Migrating = ((CoreDataMigrationVersion, CoreDataMigrationVersion) -> Void)
    typealias CustomizeMapping = (
        _ source: CoreDataMigrationVersion,
        _ destination: CoreDataMigrationVersion,
        _ mapping: NSMappingModel
    ) -> NSMappingModel
    
    /// Resolves what an interrupted migration left behind – call it before the store is checked or opened.
    func recoverInterruptedMigration(at storeURL: URL)
    func requiresMigrationToCurrentVersion(at storeURL: URL) -> Bool
    /// - Throws: `CoreDataMigrationError` – the store is left as it was (or restored), nothing is lost.
    func migrateStoreToCurrentVersion(at storeURL: URL) throws
    var bundle: Bundle? { get set }
    var migrating: Migrating? { get set }
    /// Set as `userInfo` of every `NSMigrationManager`.
    var migrationUserInfo: [AnyHashable: Any] { get set }
    /// Called once per migration step with the mapping the step would use; the returned mapping is used instead.
    var customizeMapping: CustomizeMapping? { get set }
}

public extension CoreDataMigratorProtocol {
    /// Resolves an interrupted migration and migrates the store to the current version when it needs it.
    /// - Returns: Whether the store was migrated.
    /// - Throws: `CoreDataMigrationError` – the store is left as it was, so the call can be repeated.
    @discardableResult
    func prepareStore(at storeURL: URL) throws -> Bool {
        recoverInterruptedMigration(at: storeURL)
        guard requiresMigrationToCurrentVersion(at: storeURL) else { return false }
        try migrateStoreToCurrentVersion(at: storeURL)
        return true
    }
}

public final class CoreDataMigrator: CoreDataMigratorProtocol {
    public var bundle: Bundle?
    public var migrating: Migrating?
    public var migrationUserInfo: [AnyHashable: Any] = [:]
    public var customizeMapping: CustomizeMapping?
    private let momdSubdirectory: String
    private let versions: CoreDataMigrationVersionList
    private let temporaryDirectory: URL
    
    // MARK: - Init
    
    /// - Parameter temporaryDirectory: Where the stores of migration steps are written. `nil` –
    ///   `NSTemporaryDirectory()`.
    public init(
        momdSubdirectory: String,
        versions: [CoreDataMigrationVersion],
        temporaryDirectory: URL? = nil,
        migrating: Migrating? = nil
    ) {
        self.momdSubdirectory = "\(momdSubdirectory).momd"
        self.versions = CoreDataMigrationVersionList(versions: versions)
        self.temporaryDirectory = temporaryDirectory ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        self.migrating = migrating
    }
    
    // MARK: - Check
    
    public func requiresMigrationToCurrentVersion(at storeURL: URL) -> Bool {
        if PersistentStoreFiles(store: storeURL).hasPremigrationStore {
            // An interrupted store swap. Only `recoverInterruptedMigration(at:)` resolves it – the store must not
            // be opened (or created anew) before that.
            Log("Store has files left by an interrupted migration", module: .storage)
            return true
        }
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return false
        }
        guard let bundle else {
            fatalError("Cant migrate without passed bundle")
        }
        
        let storedVersion = CoreDataMigrationVersion.compatibleVersionForStoreMetadata(
            metadata,
            versions: versions,
            momdSubdirectory: momdSubdirectory,
            bundle: bundle
        )
        let needsToMigrate = (storedVersion != versions.current)
        if needsToMigrate {
            // swiftlint:disable line_length
            Log("Need to migrate Core Data to current version: \(versions.current.rawValue) from \(String(describing: storedVersion?.rawValue))", module: .storage)
            // swiftlint:enable line_length
        }
        
        return needsToMigrate
    }
    
    // MARK: - Migration
    
    public func migrateStoreToCurrentVersion(at storeURL: URL) throws {
        removeStepStores(of: storeURL)
        removeLegacyStepStores()
        try forceWALCheckpointingForStore(at: storeURL)
        
        var currentURL = storeURL
        let migrationSteps = try self.migrationStepsForStore(at: storeURL, toVersion: versions.current)
        guard !migrationSteps.isEmpty else { return }
        
        let stepStoreDirectory = stepStoreDirectory(of: storeURL)
        do {
            try FileManager.default.createDirectory(at: stepStoreDirectory, withIntermediateDirectories: true)
        } catch {
            throw CoreDataMigrationError(stage: .stepStoreDirectory, underlying: error)
        }
        
        do {
            for migrationStep in migrationSteps {
                Log(
                    "Migrating from \(migrationStep.sourceModel) to \(migrationStep.destinationModel)",
                    module: .storage
                )
                let manager = NSMigrationManager(
                    sourceModel: migrationStep.sourceModel,
                    destinationModel: migrationStep.destinationModel
                )
                manager.userInfo = migrationUserInfo
                // A store-specific (in-place SQL) migration of an inferred mapping may skip entity migration policies
                manager.usesStoreSpecificMigrationManager = !migrationStep.usesEntityMigrationPolicies
                let destinationURL = stepStoreDirectory.appendingPathComponent(UUID().uuidString)
                
                do {
                    try manager.migrateStore(
                        from: currentURL,
                        sourceType: NSSQLiteStoreType,
                        options: nil,
                        with: migrationStep.mappingModel,
                        toDestinationURL: destinationURL,
                        destinationType: NSSQLiteStoreType,
                        destinationOptions: Self.protectionOptions
                    )
                } catch {
                    throw CoreDataMigrationError(stage: .step, underlying: error)
                }
                
                if currentURL != storeURL {
                    // Destroy intermediate step's store
                    NSPersistentStoreCoordinator.destroyStore(at: currentURL)
                }
                
                currentURL = destinationURL
            }
            
            try Self.replaceStore(at: storeURL, withMigratedStoreAt: currentURL)
        } catch {
            // The store at `storeURL` is still (or again) the one from before the migration
            removeStepStores(of: storeURL, leftover: false)
            throw error
        }
        NSPersistentStoreCoordinator.destroyStore(at: currentURL)
        removeStepStores(of: storeURL, leftover: false)
    }
    
    // MARK: - Recovery
    
    public func recoverInterruptedMigration(at storeURL: URL) {
        PersistentStoreFiles(store: storeURL).recoverInterruptedSwap()
        removeStepStores(of: storeURL)
    }
    
    // MARK: - Step stores
    
    /// `<temporary directory>/<store file name>.migration` – one directory per store, so the migrations of two stores
    /// never remove each other's step stores.
    func stepStoreDirectory(of storeURL: URL) -> URL {
        temporaryDirectory.appendingPathComponent(storeURL.lastPathComponent + ".migration", isDirectory: true)
    }
    
    /// - Parameter leftover: Whether the stores were left by an interrupted migration (only logged then).
    private func removeStepStores(of storeURL: URL, leftover: Bool = true) {
        let directory = stepStoreDirectory(of: storeURL)
        guard FileManager.default.fileExists(atPath: directory.path) else { return }
        if leftover {
            Log("Removing stores left by an interrupted migration", module: .storage)
        }
        do {
            try FileManager.default.removeItem(at: directory)
        } catch {
            Log(
                "Failed to remove stores of migration steps, code: \((error as NSError).code)",
                module: .storage,
                severity: .error
            )
        }
    }
    
    private func removeLegacyStepStores() {
        let fileManager = FileManager.default
        guard let names = try? fileManager.contentsOfDirectory(atPath: temporaryDirectory.path) else { return }
        let groups = Dictionary(grouping: names.compactMap(LegacyStepStoreFile.init(name:)), by: \.storeName)
        for files in groups.values {
            let urls = files.map { temporaryDirectory.appendingPathComponent($0.name) }
                .filter { url in
                    var isDirectory: ObjCBool = false
                    return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && !isDirectory.boolValue
                }
            guard urls.contains(where: Self.isSQLiteFile(at:)) else { continue }
            Log("Removing a store left by an interrupted migration of an earlier app version", module: .storage)
            for url in urls {
                do {
                    try fileManager.removeItem(at: url)
                } catch CocoaError.fileNoSuchFile {
                    continue
                } catch {
                    Log(
                        "Failed to remove a legacy migration step store, code: \((error as NSError).code)",
                        module: .storage,
                        severity: .error
                    )
                }
            }
        }
    }
    
    /// Starts with the SQLite database header or a WAL header
    private static func isSQLiteFile(at url: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
        defer { try? handle.close() }
        guard let header = try? handle.read(upToCount: 16) else { return false }
        let databaseHeader = Data("SQLite format 3\u{0}".utf8)
        let walHeaders = [Data([0x37, 0x7F, 0x06, 0x82]), Data([0x37, 0x7F, 0x06, 0x83])]
        return header.starts(with: databaseHeader) || walHeaders.contains { header.starts(with: $0) }
    }
    
    // MARK: - Store swap
    
    private static var protectionOptions: [AnyHashable: Any] {
        [NSPersistentStoreFileProtectionKey: CoreDataStack.fileProtection as NSObject]
    }
    
    private static func replaceStore(at storeURL: URL, withMigratedStoreAt migratedURL: URL) throws {
        let files = PersistentStoreFiles(store: storeURL)
        // Leftovers of an earlier swap – the store was just migrated from, so it is the one to keep. A stale marker
        // goes too: left in place, it would make recovery discard the files set aside next.
        guard files.removePremigrationFiles() else {
            throw CoreDataMigrationError(stage: .storeSwap, underlying: nil)
        }
        do {
            try files.setAside()
        } catch {
            files.restorePremigrationFiles()
            throw CoreDataMigrationError(stage: .storeSwap, underlying: error)
        }
        do {
            try files.replace(withStoreAt: migratedURL, options: protectionOptions)
        } catch {
            files.rollBackFailedReplacement()
            throw CoreDataMigrationError(stage: .storeSwap, underlying: error)
        }
        do {
            try files.markSwapCompleted()
        } catch {
            // Without the marker recovery would restore the old store – it's restored now, before the new one is used
            files.removeSwapMarker()
            files.rollBackFailedReplacement()
            throw CoreDataMigrationError(stage: .storeSwap, underlying: error)
        }
        // On failure, recovery finishes it at the next start
        files.removePremigrationFiles()
    }
    
    private func migrationStepsForStore(
        at storeURL: URL,
        toVersion destinationVersion: CoreDataMigrationVersion
    ) throws -> [CoreDataMigrationStep] {
        guard let bundle else {
            fatalError("Cant migrate without passed bundle")
        }
        guard
            let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL),
            let sourceVersion = CoreDataMigrationVersion.compatibleVersionForStoreMetadata(
                metadata,
                versions: versions,
                momdSubdirectory: momdSubdirectory,
                bundle: bundle
            )
        else {
            // No metadata or a store of a model this app version doesn't know (e.g. written by a newer one)
            throw CoreDataMigrationError(stage: .unknownStoreVersion, underlying: nil)
        }
        
        migrating?(sourceVersion, destinationVersion)
        
        return migrationSteps(fromSourceVersion: sourceVersion, toDestinationVersion: destinationVersion)
    }

    private func migrationSteps(
        fromSourceVersion sourceVersion: CoreDataMigrationVersion,
        toDestinationVersion destinationVersion: CoreDataMigrationVersion
    ) -> [CoreDataMigrationStep] {
        guard let bundle else {
            fatalError("Cant migrate without passed bundle")
        }
        var sourceVersion = sourceVersion
        var migrationSteps = [CoreDataMigrationStep]()

        while sourceVersion != destinationVersion, let nextVersion = versions.nextVersion(for: sourceVersion) {
            let migrationStep = CoreDataMigrationStep(
                sourceVersion: sourceVersion,
                destinationVersion: nextVersion,
                momdSubdirectory: momdSubdirectory,
                bundle: bundle,
                customizeMapping: customizeMapping
            )
            migrationSteps.append(migrationStep)

            sourceVersion = nextVersion
        }

        return migrationSteps
    }
    
    // MARK: - WAL

    private func forceWALCheckpointingForStore(at storeURL: URL) throws {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL),
              let currentModel = NSManagedObjectModel.compatibleModelForStoreMetadata(metadata) else {
            return
        }
        
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: currentModel)
            
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = try persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: options
            )
            try persistentStoreCoordinator.remove(store)
        } catch {
            throw CoreDataMigrationError(stage: .checkpoint, underlying: error)
        }
    }
}

private extension CoreDataMigrationVersion {
    static func compatibleVersionForStoreMetadata(
        _ metadata: [String: Any],
        versions: CoreDataMigrationVersionList,
        momdSubdirectory: String,
        bundle: Bundle
    ) -> CoreDataMigrationVersion? {
        let compatibleVersion = versions.first {
            let model = NSManagedObjectModel.managedObjectModel(
                forResource: $0.rawValue,
                momdSubdirectory: momdSubdirectory,
                bundle: bundle
            )
            
            return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        return compatibleVersion
    }
}

private extension NSManagedObjectModel {
    static func compatibleModelForStoreMetadata(_ metadata: [String: Any]) -> NSManagedObjectModel? {
        let mainBundle = Bundle.main
        return NSManagedObjectModel.mergedModel(from: [mainBundle], forStoreMetadata: metadata)
    }
}

private extension NSPersistentStoreCoordinator {
    static func destroyStore(at storeURL: URL) {
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        } catch {
            // Only a step store – the directory of step stores is removed anyway
            Log(
                "Failed to destroy a migration step store, code: \((error as NSError).code)",
                module: .storage,
                severity: .error
            )
        }
    }
    
    static func metadata(at storeURL: URL) -> [String: Any]? {
        try? NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL,
            options: nil
        )
    }
}

/// A file named like a step store of an earlier app version: `<UUID>`, optionally with an SQLite sidecar suffix.
private struct LegacyStepStoreFile {
    let name: String
    let storeName: String
    
    init?(name: String) {
        let suffix = ["-wal", "-shm", "-journal"].first { name.hasSuffix($0) }
        let storeName = suffix.map { String(name.dropLast($0.count)) } ?? name
        guard let uuid = UUID(uuidString: storeName), uuid.uuidString == storeName else { return nil }
        self.name = name
        self.storeName = storeName
    }
}

struct PersistentStoreFiles {
    private static let premigrationSuffix = ".premigration"
    private static let swapMarkerSuffix = ".swapped"
    
    let store: URL
    
    var premigrationStore: URL { premigration(of: store) }
    var hasPremigrationStore: Bool { FileManager.default.fileExists(atPath: premigrationStore.path) }
    var swapMarker: URL { sibling(of: store, suffix: Self.swapMarkerSuffix) }
    var hasSwapMarker: Bool { FileManager.default.fileExists(atPath: swapMarker.path) }
    
    private var sidecars: [URL] { ["-wal", "-shm"].map { sibling(of: store, suffix: $0) } }
    /// Only removed at the store location – a store in WAL mode is never set aside with one
    private var journal: URL { sibling(of: store, suffix: "-journal") }
    /// Main file first
    private var premigrationFiles: [URL] { ([store] + sidecars).map(premigration(of:)) }
    
    // MARK: - Swap
    
    /// Step (1): the store files are moved aside as `.premigration`.
    func setAside() throws {
        let fileManager = FileManager.default
        for url in [store] + sidecars where fileManager.fileExists(atPath: url.path) {
            try fileManager.moveItem(at: url, to: premigration(of: url))
        }
    }
    
    /// Step (2): the store at `migratedURL` is copied to the (cleared) store location.
    func replace(withStoreAt migratedURL: URL, options: [AnyHashable: Any]) throws {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
        try persistentStoreCoordinator.replacePersistentStore(
            at: store,
            destinationOptions: options,
            withPersistentStoreFrom: migratedURL,
            sourceOptions: nil,
            ofType: NSSQLiteStoreType
        )
    }
    
    /// Step (3): records that the store at the store location is complete. From now on recovery keeps it – also when
    /// it can't be read for a while (before the first unlock) – and discards the set-aside files. The new store is
    /// flushed before the marker is written, and the marker before anything set aside is removed.
    func markSwapCompleted() throws {
        for url in [store] + sidecars where FileManager.default.fileExists(atPath: url.path) {
            Self.flush(url)
        }
        guard FileManager.default.createFile(
            atPath: swapMarker.path,
            contents: nil,
            attributes: [.protectionKey: CoreDataStack.fileProtection]
        ) else {
            throw CocoaError(.fileWriteUnknown, userInfo: [NSFilePathErrorKey: swapMarker.path])
        }
        flushDirectory()
    }
    
    /// Step (4): removes the set-aside files – main file first – and then the marker. The removal is flushed before
    /// the marker goes, so set-aside files are never found without it once the store was replaced. `false` when a
    /// file can't be removed (the marker is kept then).
    @discardableResult
    func removePremigrationFiles() -> Bool {
        guard removeLoggingFailure(premigrationFiles) else { return false }
        if hasSwapMarker {
            flushDirectory()
            return removeSwapMarker()
        }
        return true
    }
    
    @discardableResult
    func removeSwapMarker() -> Bool {
        removeLoggingFailure([swapMarker])
    }
    
    // MARK: - Recovery
    
    /// Brings back a consistent store after a store swap was interrupted:
    /// - the marker exists → the replacement completed: the set-aside files and the marker are removed. Store
    ///   contents aren't checked – they may be unreadable for a while (before the first unlock),
    /// - a set-aside main file without the marker → the replacement didn't complete: the set-aside files are
    ///   restored, replacing what the replacement left at the store location,
    /// - set-aside sidecars without their main file → removed: they can't be restored and hold old data (unencrypted
    ///   before `TwoFAS8`/`Sync6`),
    /// - nothing set aside → nothing to do.
    func recoverInterruptedSwap() {
        let fileManager = FileManager.default
        if hasSwapMarker {
            if hasPremigrationStore && !fileManager.fileExists(atPath: store.path) {
                // Not left by the swap – the marker is written after the store. The set-aside store is the only one.
                Log("Restoring the store set aside before a replacement whose store is missing", module: .storage)
                restorePremigrationFiles()
                removeSwapMarker()
            } else {
                Log("Removing files left by a completed store replacement", module: .storage)
                removePremigrationFiles()
            }
        } else if hasPremigrationStore {
            Log("Restoring the store set aside by an interrupted migration", module: .storage)
            restorePremigrationFiles()
        } else if premigrationFiles.contains(where: { fileManager.fileExists(atPath: $0.path) }) {
            Log("Removing set-aside sidecar files left without their store", module: .storage)
            removeLoggingFailure(premigrationFiles)
        }
    }
    
    /// Moves the `.premigration` files back, replacing what an unfinished replacement left at the store location.
    func restorePremigrationFiles() {
        guard hasPremigrationStore else { return }
        let fileManager = FileManager.default
        do {
            if fileManager.fileExists(atPath: store.path) {
                // The main file is set aside before anything is written, so all files here belong to the new store
                try remove(sidecars + [store])
            }
            for sidecar in sidecars where fileManager.fileExists(atPath: premigration(of: sidecar).path) {
                try remove([sidecar])
                try fileManager.moveItem(at: premigration(of: sidecar), to: sidecar)
            }
            try fileManager.moveItem(at: premigrationStore, to: store)
        } catch {
            Log(
                "Failed to restore the store set aside before migration, code: \((error as NSError).code)",
                module: .storage,
                severity: .error
            )
        }
    }
    
    /// Moves the `.premigration` files back after a replacement failed. All files of the old store were set aside
    /// before the replacement started, so everything at the store location belongs to the unfinished new store and is
    /// removed first – also when its main file is missing. Does nothing without a set-aside main file.
    func rollBackFailedReplacement() {
        guard hasPremigrationStore else { return }
        // Restored anyway when a file can't be removed – the restore replaces what is left of the new store
        removeLoggingFailure(sidecars + [journal, store])
        restorePremigrationFiles()
    }
    
    func removeAll() {
        removeLoggingFailure(premigrationFiles + [swapMarker] + sidecars + [store])
    }
    
    // MARK: - Private
    
    private func premigration(of url: URL) -> URL {
        sibling(of: url, suffix: Self.premigrationSuffix)
    }
    
    private func sibling(of url: URL, suffix: String) -> URL {
        url.deletingLastPathComponent().appendingPathComponent(url.lastPathComponent + suffix)
    }
    
    /// Missing files are ignored.
    private func remove(_ urls: [URL]) throws {
        for url in urls where FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
    
    @discardableResult
    private func removeLoggingFailure(_ urls: [URL]) -> Bool {
        do {
            try remove(urls)
            return true
        } catch {
            Log("Failed to remove store files, code: \((error as NSError).code)", module: .storage, severity: .error)
            return false
        }
    }
    
    /// Makes the files created and removed in the store directory durable
    private func flushDirectory() {
        Self.flush(store.deletingLastPathComponent())
    }
    
    /// Writes the file (or directory entries) to permanent storage; `fsync` alone may leave them in the drive's cache.
    /// A failure is only logged – the swap goes on as it did without the flush.
    private static func flush(_ url: URL) {
        let descriptor = open(url.path, O_RDONLY)
        guard descriptor >= 0 else {
            Log("Failed to open a store file to flush it, errno: \(errno)", module: .storage, severity: .error)
            return
        }
        defer { close(descriptor) }
        if fcntl(descriptor, F_FULLFSYNC) == -1 && fsync(descriptor) == -1 {
            Log("Failed to flush a store file, errno: \(errno)", module: .storage, severity: .error)
        }
    }
}
