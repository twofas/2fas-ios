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

import XCTest
import CoreData
@testable import Common
@testable import Storage
@testable import Protection

@objc(UserInfoRecordingMigrationPolicy)
final class UserInfoRecordingMigrationPolicy: NSEntityMigrationPolicy {
    static var recordedUserInfo: [AnyHashable: Any]?
    static var recordedCipher: LocalStorageCipher?

    override func begin(_ mapping: NSEntityMapping, with manager: NSMigrationManager) throws {
        Self.recordedUserInfo = manager.userInfo
        Self.recordedCipher = manager.localStorageCipher
        try super.begin(mapping, with: manager)
    }
}

final class CoreDataMigratorTests: XCTestCase {
    private static let currentVersionName = "TwoFAS8"
    private static let versionNames = [
        "TwoFAS", "TwoFAS2", "TwoFAS3", "TwoFAS4", "TwoFAS5", "TwoFAS6", "TwoFAS7", currentVersionName
    ]

    /// Title of the sections that are only in the uncheckpointed WAL of `makeStoreWithUncheckpointedWAL`
    private static let walOnlyTitle = "WALOnlySectionMarker"

    private var directory: URL!
    /// Temporary directory of the migrator (stores of migration steps)
    private var temporaryDirectory: URL!
    private var storeURL: URL { CoreDataStack.storeURL(name: twoFASStoreName, directory: directory) }
    private var files: PersistentStoreFiles { PersistentStoreFiles(store: storeURL) }

    override func setUp() {
        super.setUp()
        directory = makeTemporaryDirectory()
        temporaryDirectory = makeTemporaryDirectory()
        UserInfoRecordingMigrationPolicy.recordedUserInfo = nil
        UserInfoRecordingMigrationPolicy.recordedCipher = nil
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.removeItem(at: temporaryDirectory)
        directory = nil
        temporaryDirectory = nil
        UserInfoRecordingMigrationPolicy.recordedUserInfo = nil
        UserInfoRecordingMigrationPolicy.recordedCipher = nil
        super.tearDown()
    }

    private func makeMigrator() -> CoreDataMigrator {
        let migrator = CoreDataMigrator(
            momdSubdirectory: twoFASStoreName,
            versions: Self.versionNames.map { CoreDataMigrationVersion(rawValue: $0) },
            temporaryDirectory: temporaryDirectory
        )
        migrator.bundle = twoFASModelBundle
        return migrator
    }

    private func recover() {
        makeMigrator().recoverInterruptedMigration(at: storeURL)
    }

    private func makeStack(migrator: CoreDataMigratorProtocol?) -> CoreDataStack {
        CoreDataStack(
            readOnly: false,
            name: twoFASStoreName,
            bundle: twoFASModelBundle,
            migrator: migrator,
            storeDirectory: directory
        )
    }

    private func premigrationFiles() throws -> [String] {
        try storeDirectoryContents(directory).filter { $0.hasSuffix(".premigration") }
    }

    /// Step (1) of the store swap: the store files are set aside as `.premigration`.
    @discardableResult
    private func setStoreFilesAside() throws -> [String] {
        var moved: [String] = []
        for suffix in ["", "-wal", "-shm"] {
            let url = URL(fileURLWithPath: storeURL.path + suffix)
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            try FileManager.default.moveItem(at: url, to: URL(fileURLWithPath: url.path + ".premigration"))
            moved.append(url.lastPathComponent)
        }
        return moved
    }

    private func fileNumber(of url: URL) throws -> Int {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        return try XCTUnwrap(attributes[.systemFileNumber] as? Int)
    }

    private func storeFile(_ suffix: String) -> URL {
        URL(fileURLWithPath: storeURL.path + suffix)
    }

    private func exists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    private func model(version: String) throws -> NSManagedObjectModel {
        let url = try XCTUnwrap(
            twoFASModelBundle.url(forResource: version, withExtension: "mom", subdirectory: "TwoFAS.momd")
        )
        return try XCTUnwrap(NSManagedObjectModel(contentsOf: url))
    }

    /// A store of the current version with `sectionCount` sections in a directory of its own – what a migration
    /// writes before the swap.
    private func makeMigratedStore(sectionCount: Int) throws -> URL {
        let url = temporaryDirectory.appendingPathComponent("migrated").appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try makeTwoFASStore(version: Self.currentVersionName, at: url, sectionCount: sectionCount)
        return url
    }

    /// A store of `version` at `storeURL` with `sectionCount` sections in its main file and `walSectionCount` more
    /// (titled `walOnlyTitle`) only in its uncheckpointed `-wal` file.
    private func makeStoreWithUncheckpointedWAL(version: String, sectionCount: Int, walSectionCount: Int) throws {
        let source = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: source) }
        let sourceURL = source.appendingPathComponent(storeURL.lastPathComponent)
        try makeTwoFASStore(version: version, at: sourceURL, sectionCount: sectionCount)

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try model(version: version))
        let store = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: sourceURL,
            options: nil
        )
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        try context.performAndWait {
            for _ in 0..<walSectionCount {
                insertTestSection(into: context)
            }
            for object in context.insertedObjects {
                object.setValue(Self.walOnlyTitle, forKey: "title")
            }
            try context.save()
        }
        // Copied while the store is open, so the last transaction isn't checkpointed into the main file. SQLite
        // rebuilds the wal-index (`-shm`) from the WAL.
        try FileManager.default.copyItem(at: sourceURL, to: storeURL)
        try FileManager.default.copyItem(at: URL(fileURLWithPath: sourceURL.path + "-wal"), to: storeFile("-wal"))
        try coordinator.remove(store)

        let marker = Data(Self.walOnlyTitle.utf8)
        XCTAssertNil(try Data(contentsOf: storeURL).range(of: marker), "WAL fixture is checkpointed")
        XCTAssertNotNil(try Data(contentsOf: storeFile("-wal")).range(of: marker), "WAL fixture has no WAL data")
    }

    /// Sections (all, and those titled `walOnlyTitle`) of the store at `storeURL` opened by a stack that recovers and
    /// migrates it
    private func sectionCountsAfterMigration() throws -> (all: Int, walOnly: Int) {
        let stack = makeStack(migrator: makeMigrator())
        defer { closeStores(of: stack) }
        let context = stack.context
        let walOnly = try context.performAndWait {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SectionEntity")
            request.predicate = NSPredicate(format: "title == %@", Self.walOnlyTitle)
            return try context.count(for: request)
        }
        return (try countSections(in: context), walOnly)
    }

    private func assertNoSwapFiles(file: StaticString = #filePath, line: UInt = #line) throws {
        XCTAssertEqual(try premigrationFiles(), [], file: file, line: line)
        XCTAssertFalse(exists(files.swapMarker), "swap marker left", file: file, line: line)
    }

    func testMigrationLeavesNoPremigrationFiles() throws {
        try makeTwoFASStore(version: "TwoFAS6", at: storeURL, sectionCount: 1)
        let oldFileNumber = try fileNumber(of: storeURL)
        let migrator = makeMigrator()
        XCTAssertTrue(migrator.requiresMigrationToCurrentVersion(at: storeURL))

        let stack = makeStack(migrator: migrator)

        XCTAssertEqual(try countSections(in: stack.context), 1)
        // A new file, not the old one overwritten in place
        XCTAssertNotEqual(try fileNumber(of: storeURL), oldFileNumber)
        XCTAssertFalse(migrator.requiresMigrationToCurrentVersion(at: storeURL))
        XCTAssertTrue(
            CoreDataStack.isStoreCompatible(name: twoFASStoreName, bundle: twoFASModelBundle, directory: directory)
        )
        try assertNoSwapFiles()
        XCTAssertEqual(try storeDirectoryContents(temporaryDirectory), [])
    }

    func testInterruptedMigrationIsRecovered() throws {
        try makeTwoFASStore(version: Self.currentVersionName, at: storeURL, sectionCount: 1)
        XCTAssertTrue(try setStoreFilesAside().contains("TwoFAS.sqlite"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: storeURL.path))
        XCTAssertTrue(CoreDataStack.storeFilesExist(name: twoFASStoreName, directory: directory))

        recover()

        XCTAssertTrue(FileManager.default.fileExists(atPath: storeURL.path))
        XCTAssertEqual(try premigrationFiles(), [])
        XCTAssertEqual(try countSections(in: makeStack(migrator: nil).context), 1)
    }

    func testRecoveryWithoutPremigrationFilesIsNoop() throws {
        recover()
        XCTAssertEqual(try storeDirectoryContents(directory), [])

        try makeTwoFASStore(version: Self.currentVersionName, at: storeURL, sectionCount: 1)
        let contents = try storeDirectoryContents(directory)
        recover()
        XCTAssertEqual(try storeDirectoryContents(directory), contents)
    }

    func testIncompleteReplacementIsDiscarded() throws {
        try makeTwoFASStore(version: Self.currentVersionName, at: storeURL, sectionCount: 2)
        try setStoreFilesAside()
        XCTAssertTrue(FileManager.default.createFile(atPath: storeURL.path, contents: Data()))
        XCTAssertTrue(FileManager.default.createFile(atPath: storeURL.path + "-wal", contents: Data([1])))

        recover()

        XCTAssertEqual(try premigrationFiles(), [])
        XCTAssertEqual(try countSections(in: makeStack(migrator: nil).context), 2)
    }

    func testRollbackOfFailedReplacementClearsStoreLocation() throws {
        try makeTwoFASStore(version: Self.currentVersionName, at: storeURL, sectionCount: 2)
        var setAside = try setStoreFilesAside()
        XCTAssertTrue(setAside.contains("TwoFAS.sqlite"))
        // A shared-memory index that wasn't set aside – SQLite rebuilds it
        let premigrationShm = URL(fileURLWithPath: storeURL.path + "-shm.premigration")
        if FileManager.default.fileExists(atPath: premigrationShm.path) {
            try FileManager.default.removeItem(at: premigrationShm)
            setAside.removeAll { $0 == "TwoFAS.sqlite-shm" }
        }
        // What a failed replacement may leave – without the main file
        for suffix in ["-wal", "-shm", "-journal"] {
            XCTAssertTrue(FileManager.default.createFile(atPath: storeURL.path + suffix, contents: Data([1, 2, 3])))
        }

        PersistentStoreFiles(store: storeURL).rollBackFailedReplacement()

        // Only the files set aside, restored – nothing of the failed replacement
        XCTAssertEqual(try storeDirectoryContents(directory), setAside.sorted())
        XCTAssertEqual(try countSections(in: makeStack(migrator: nil).context), 2)
    }

    func testRollbackWithoutPremigrationStoreKeepsStoreLocation() throws {
        try makeTwoFASStore(version: Self.currentVersionName, at: storeURL, sectionCount: 1)
        let contents = try storeDirectoryContents(directory)

        PersistentStoreFiles(store: storeURL).rollBackFailedReplacement()

        XCTAssertEqual(try storeDirectoryContents(directory), contents)
        XCTAssertEqual(try countSections(in: makeStack(migrator: nil).context), 1)
    }

    func testPendingPremigrationRequiresMigration() throws {
        try makeTwoFASStore(version: Self.currentVersionName, at: storeURL, sectionCount: 1)
        let migrator = makeMigrator()
        XCTAssertFalse(migrator.requiresMigrationToCurrentVersion(at: storeURL))

        try setStoreFilesAside()

        XCTAssertTrue(migrator.requiresMigrationToCurrentVersion(at: storeURL))
    }

    func testStackRecoversInterruptedMigrationBeforeLoading() throws {
        try makeTwoFASStore(version: "TwoFAS6", at: storeURL, sectionCount: 1)
        try setStoreFilesAside()

        let stack = makeStack(migrator: makeMigrator())

        XCTAssertEqual(try countSections(in: stack.context), 1)
        XCTAssertEqual(try premigrationFiles(), [])
        XCTAssertFalse(makeMigrator().requiresMigrationToCurrentVersion(at: storeURL))
    }

    // MARK: - Interruptions of the store swap
    //
    // Steps: (1) set aside, (2) replaced, (3) marked completed, (4) set-aside main file removed, (5) set-aside sidecars
    // removed, (6) marker removed.

    func testInterruptionAfterSetAsideRestoresStoreWithItsWAL() throws {
        try makeStoreWithUncheckpointedWAL(version: "TwoFAS7", sectionCount: 2, walSectionCount: 1)
        try files.setAside()
        XCTAssertTrue(exists(storeFile("-wal.premigration")))

        recover()

        try assertNoSwapFiles()
        XCTAssertTrue(exists(storeFile("-wal")))
        let counts = try sectionCountsAfterMigration()
        XCTAssertEqual(counts.all, 3)
        XCTAssertEqual(counts.walOnly, 1)
    }

    func testInterruptionBeforeMarkerRestoresOldStore() throws {
        // (2) done, (3) not – the new store is complete and readable, but only the marker proves it
        try makeStoreWithUncheckpointedWAL(version: "TwoFAS7", sectionCount: 2, walSectionCount: 1)
        try files.setAside()
        try files.replace(withStoreAt: try makeMigratedStore(sectionCount: 5), options: [:])
        XCTAssertEqual(
            CoreDataStack.storeCompatibility(name: twoFASStoreName, bundle: twoFASModelBundle, directory: directory),
            .compatible
        )
        XCTAssertTrue(makeMigrator().requiresMigrationToCurrentVersion(at: storeURL))

        recover()

        try assertNoSwapFiles()
        let counts = try sectionCountsAfterMigration()
        XCTAssertEqual(counts.all, 3)
        XCTAssertEqual(counts.walOnly, 1)
    }

    func testInterruptionAfterMarkerKeepsNewStore() throws {
        // (3) done, (4) not
        try makeStoreWithUncheckpointedWAL(version: "TwoFAS7", sectionCount: 2, walSectionCount: 1)
        try files.setAside()
        try files.replace(withStoreAt: try makeMigratedStore(sectionCount: 5), options: [:])
        try files.markSwapCompleted()
        XCTAssertTrue(exists(files.swapMarker))

        recover()

        try assertNoSwapFiles()
        XCTAssertFalse(makeMigrator().requiresMigrationToCurrentVersion(at: storeURL))
        let counts = try sectionCountsAfterMigration()
        XCTAssertEqual(counts.all, 5)
        XCTAssertEqual(counts.walOnly, 0)
    }

    func testMarkedReplacementIsKeptWhileItsContentsAreUnreadable() throws {
        // Before the first unlock a complete store can't be read – the marker alone decides
        try makeTwoFASStore(version: "TwoFAS7", at: storeURL, sectionCount: 2)
        try files.setAside()
        let unreadable = Data("contents not readable now".utf8)
        XCTAssertTrue(FileManager.default.createFile(atPath: storeURL.path, contents: unreadable))
        try files.markSwapCompleted()

        recover()

        try assertNoSwapFiles()
        XCTAssertEqual(try Data(contentsOf: storeURL), unreadable)
    }

    func testInterruptionAfterMainBackupRemovalDiscardsSidecarBackups() throws {
        // (4) done, (5) not – the set-aside WAL holds old data and can't be restored without its main file
        try makeStoreWithUncheckpointedWAL(version: "TwoFAS7", sectionCount: 2, walSectionCount: 1)
        try files.setAside()
        try files.replace(withStoreAt: try makeMigratedStore(sectionCount: 5), options: [:])
        try files.markSwapCompleted()
        try FileManager.default.removeItem(at: files.premigrationStore)
        XCTAssertTrue(exists(storeFile("-wal.premigration")))

        recover()

        try assertNoSwapFiles()
        let counts = try sectionCountsAfterMigration()
        XCTAssertEqual(counts.all, 5)
        XCTAssertEqual(counts.walOnly, 0)
    }

    func testInterruptionBeforeMarkerRemovalKeepsStore() throws {
        // (5) done, (6) not
        try makeTwoFASStore(version: "TwoFAS7", at: storeURL, sectionCount: 2)
        try files.setAside()
        try files.replace(withStoreAt: try makeMigratedStore(sectionCount: 5), options: [:])
        try files.markSwapCompleted()
        for name in try premigrationFiles() {
            try FileManager.default.removeItem(at: directory.appendingPathComponent(name))
        }
        XCTAssertTrue(exists(files.swapMarker))

        recover()

        try assertNoSwapFiles()
        XCTAssertEqual(try sectionCountsAfterMigration().all, 5)
    }

    func testCompletedSwapCleanupRemovesMainBackupFirstAndKeepsMarkerOnFailure() throws {
        try makeStoreWithUncheckpointedWAL(version: "TwoFAS7", sectionCount: 2, walSectionCount: 1)
        try files.setAside()
        try files.replace(withStoreAt: try makeMigratedStore(sectionCount: 5), options: [:])
        try files.markSwapCompleted()
        let walBackup = storeFile("-wal.premigration")
        try FileManager.default.setAttributes([.immutable: true], ofItemAtPath: walBackup.path)
        defer { try? FileManager.default.setAttributes([.immutable: false], ofItemAtPath: walBackup.path) }

        XCTAssertFalse(files.removePremigrationFiles())

        XCTAssertFalse(exists(files.premigrationStore))
        XCTAssertTrue(exists(walBackup))
        XCTAssertTrue(exists(files.swapMarker))

        try FileManager.default.setAttributes([.immutable: false], ofItemAtPath: walBackup.path)
        recover()

        try assertNoSwapFiles()
        XCTAssertEqual(try sectionCountsAfterMigration().all, 5)
    }

    func testOrphanedSidecarBackupsWithoutMarkerAreRemoved() throws {
        // Set-aside sidecars without their main file can't be restored and hold old WAL data
        try makeStoreWithUncheckpointedWAL(version: "TwoFAS7", sectionCount: 2, walSectionCount: 1)
        try files.setAside()
        try FileManager.default.removeItem(at: files.premigrationStore)
        XCTAssertTrue(FileManager.default.createFile(atPath: storeFile("-shm.premigration").path, contents: Data([1])))
        try makeTwoFASStore(version: Self.currentVersionName, at: storeURL, sectionCount: 5)
        XCTAssertFalse(makeMigrator().requiresMigrationToCurrentVersion(at: storeURL))

        recover()

        try assertNoSwapFiles()
        let counts = try sectionCountsAfterMigration()
        XCTAssertEqual(counts.all, 5)
        XCTAssertEqual(counts.walOnly, 0)
    }

    func testMarkerWithoutStoreRestoresSetAsideStore() throws {
        // Never left by the swap – the set-aside store is the only one, so it isn't discarded
        try makeTwoFASStore(version: "TwoFAS7", at: storeURL, sectionCount: 2)
        try files.setAside()
        try files.markSwapCompleted()
        XCTAssertFalse(exists(storeURL))

        recover()

        try assertNoSwapFiles()
        XCTAssertEqual(try sectionCountsAfterMigration().all, 2)
    }

    func testRemovingLeftoversOfEarlierSwapRemovesStaleMarker() throws {
        // `replaceStore` does this before setting the store aside – a stale marker would make recovery discard the
        // set-aside store
        try makeTwoFASStore(version: "TwoFAS7", at: storeURL, sectionCount: 2)
        XCTAssertTrue(FileManager.default.createFile(atPath: files.swapMarker.path, contents: nil))
        XCTAssertTrue(FileManager.default.createFile(atPath: storeFile("-wal.premigration").path, contents: Data([1])))

        XCTAssertTrue(files.removePremigrationFiles())

        try assertNoSwapFiles()
        XCTAssertTrue(exists(storeURL))
    }

    func testMigrationKeepsDataOfUncheckpointedWAL() throws {
        try makeStoreWithUncheckpointedWAL(version: "TwoFAS7", sectionCount: 2, walSectionCount: 1)

        let counts = try sectionCountsAfterMigration()

        XCTAssertEqual(counts.all, 3)
        XCTAssertEqual(counts.walOnly, 1)
        try assertNoSwapFiles()
        XCTAssertEqual(try storeDirectoryContents(temporaryDirectory), [])
    }

    // MARK: - Stores of migration steps

    func testRecoveryRemovesStepStoresOfInterruptedMigration() throws {
        try makeTwoFASStore(version: "TwoFAS5", at: storeURL, sectionCount: 1)
        let migrator = makeMigrator()
        let stepStores = migrator.stepStoreDirectory(of: storeURL)
        // An intermediate step's store, with old unencrypted data
        try FileManager.default.createDirectory(at: stepStores, withIntermediateDirectories: true)
        try makeTwoFASStore(
            version: "TwoFAS6",
            at: stepStores.appendingPathComponent(UUID().uuidString),
            sectionCount: 1
        )
        // Step stores of another store aren't touched
        let otherStepStores = migrator.stepStoreDirectory(of: directory.appendingPathComponent("Sync.sqlite"))
        try FileManager.default.createDirectory(at: otherStepStores, withIntermediateDirectories: true)

        migrator.recoverInterruptedMigration(at: storeURL)

        XCTAssertFalse(exists(stepStores))
        XCTAssertTrue(exists(otherStepStores))
        XCTAssertTrue(migrator.requiresMigrationToCurrentVersion(at: storeURL))
    }

    func testMigrationRemovesLeftoverStepStoresFirst() throws {
        try makeTwoFASStore(version: "TwoFAS6", at: storeURL, sectionCount: 1)
        let migrator = makeMigrator()
        let leftover = migrator.stepStoreDirectory(of: storeURL).appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: leftover.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try makeTwoFASStore(version: "TwoFAS7", at: leftover, sectionCount: 1)

        migrator.migrateStoreToCurrentVersion(at: storeURL)

        XCTAssertEqual(try storeDirectoryContents(temporaryDirectory), [])
        XCTAssertEqual(try countSections(in: makeStack(migrator: nil).context), 1)
    }

    func testMigrationRemovesLegacyStepStores() throws {
        try makeTwoFASStore(version: "TwoFAS6", at: storeURL, sectionCount: 1)
        func temporaryFile(_ name: String) -> URL { temporaryDirectory.appendingPathComponent(name) }
        func write(_ data: Data, to name: String) {
            XCTAssertTrue(FileManager.default.createFile(atPath: temporaryFile(name).path, contents: data))
        }
        let walHeader = Data([0x37, 0x7F, 0x06, 0x82] + [UInt8](repeating: 0, count: 28))
        // A step store of an earlier app version, with sidecars
        let legacy = UUID().uuidString
        try makeTwoFASStore(version: "TwoFAS6", at: temporaryFile(legacy), sectionCount: 1)
        write(walHeader, to: legacy + "-wal")
        write(Data([1]), to: legacy + "-shm")
        // A WAL left without its main file
        let orphanedWAL = UUID().uuidString
        write(walHeader, to: orphanedWAL + "-wal")
        write(Data([1]), to: orphanedWAL + "-shm")
        // Not step stores
        let notSQLite = UUID().uuidString
        write(Data("not a store".utf8), to: notSQLite)
        let directoryName = UUID().uuidString
        try FileManager.default.createDirectory(at: temporaryFile(directoryName), withIntermediateDirectories: true)
        try makeTwoFASStore(
            version: "TwoFAS6",
            at: temporaryFile(directoryName).appendingPathComponent("store"),
            sectionCount: 1
        )
        let lowercased = UUID().uuidString.lowercased()
        try makeTwoFASStore(version: "TwoFAS6", at: temporaryFile(lowercased), sectionCount: 1)
        try makeTwoFASStore(version: "TwoFAS6", at: temporaryFile("other.sqlite"), sectionCount: 1)

        makeMigrator().migrateStoreToCurrentVersion(at: storeURL)

        for name in [legacy, legacy + "-wal", legacy + "-shm", orphanedWAL + "-wal", orphanedWAL + "-shm"] {
            XCTAssertFalse(exists(temporaryFile(name)), name)
        }
        for name in [notSQLite, directoryName, directoryName + "/store", lowercased, "other.sqlite"] {
            XCTAssertTrue(exists(temporaryFile(name)), name)
        }
        XCTAssertEqual(try countSections(in: makeStack(migrator: nil).context), 1)
    }

    func testMigrationUserInfoReachesManager() throws {
        try makeTwoFASStore(version: "TwoFAS6", at: storeURL, sectionCount: 1)
        let cipher = makeTestCipher()
        let migrator = makeMigrator()
        migrator.migrationUserInfo = [LocalStorageUserInfoKey.cipher: cipher, "test.marker": "marker"]
        migrator.customizeMapping = { _, _, mapping in
            let sectionMapping = mapping.entityMappings.first { $0.sourceEntityName == "SectionEntity" }
            sectionMapping?.entityMigrationPolicyClassName = "UserInfoRecordingMigrationPolicy"
            return mapping
        }

        migrator.migrateStoreToCurrentVersion(at: storeURL)

        XCTAssertEqual(UserInfoRecordingMigrationPolicy.recordedUserInfo?["test.marker"] as? String, "marker")
        XCTAssertIdentical(UserInfoRecordingMigrationPolicy.recordedCipher, cipher)
        XCTAssertEqual(try countSections(in: makeStack(migrator: nil).context), 1)
        XCTAssertEqual(try premigrationFiles(), [])
    }

    func testCustomizeMappingIsCalledPerStep() throws {
        try makeTwoFASStore(version: "TwoFAS5", at: storeURL, sectionCount: 1)
        let migrator = makeMigrator()
        var steps: [String] = []
        migrator.customizeMapping = { source, destination, mapping in
            XCTAssertFalse(mapping.entityMappings.isEmpty)
            steps.append("\(source.rawValue)->\(destination.rawValue)")
            return mapping
        }

        migrator.migrateStoreToCurrentVersion(at: storeURL)

        XCTAssertEqual(steps, ["TwoFAS5->TwoFAS6", "TwoFAS6->TwoFAS7", "TwoFAS7->TwoFAS8"])
        XCTAssertEqual(try countSections(in: makeStack(migrator: nil).context), 1)
    }
}
