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

public final class CoreDataStack {
    public enum StoreKind {
        case file
        case inMemory
    }

    /// Set explicitly so that a process with another default data protection (e.g. the Intent with
    /// `NSFileProtectionComplete`) never creates a store that is unreadable on the lock screen.
    static let fileProtection = FileProtectionType.completeUntilFirstUserAuthentication

    private let migrator: CoreDataMigratorProtocol?

    public var logError: ((String) -> Void)?
    public var presentErrorToUser: ((String) -> Void)?

    private let readOnly: Bool
    private let name: String
    private let bundle: Bundle
    private let storeDirectory: URL?
    public let storeKind: StoreKind
    private let retainsViewContextObjects: Bool
    private let configureContext: ((NSManagedObjectContext) -> Void)?

    private(set) lazy var storeDescription: NSPersistentStoreDescription = {
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = false
        description.shouldMigrateStoreAutomatically = false
        description.isReadOnly = readOnly

        switch storeKind {
        case .file:
            description.type = NSSQLiteStoreType
            description.url = Self.storeURL(name: name, directory: storeDirectory)
            description.setOption(Self.fileProtection as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        case .inMemory:
            description.type = NSInMemoryStoreType
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        return description
    }()

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: name, bundle: bundle)

        container.persistentStoreDescriptions = [storeDescription]

        migrateStoreIfNeeded { [weak self] in
            container.loadPersistentStores { [weak self] _, error in
                if let error = error as NSError? {
                    self?.handleLoadError(error)
                }
                container.viewContext.automaticallyMergesChangesFromParent = true
            }
        }
        container.viewContext.retainsRegisteredObjects = retainsViewContextObjects
        configureContext?(container.viewContext)
        return container
    }()

    /// - Parameters:
    ///   - storeDirectory: Directory of the `<name>.sqlite` file. `nil` – the app group container.
    ///   - storeKind: `.inMemory` creates no files and skips the migrator.
    ///   - configureContext: Called for the view context and for every background context.
    public init(
        readOnly: Bool,
        name: String,
        bundle: Bundle,
        migrator: CoreDataMigratorProtocol? = nil,
        storeDirectory: URL? = nil,
        storeKind: StoreKind = .file,
        retainsViewContextObjects: Bool = false,
        configureContext: ((NSManagedObjectContext) -> Void)? = nil
    ) {
        self.name = name
        self.bundle = bundle
        self.readOnly = readOnly
        self.migrator = migrator
        self.storeDirectory = storeDirectory
        self.storeKind = storeKind
        self.retainsViewContextObjects = retainsViewContextObjects
        self.configureContext = configureContext
        migrator?.bundle = bundle
    }

    public var context: NSManagedObjectContext { persistentContainer.viewContext }

    /// Opens the store now – migrating it first when needed – instead of on first use
    public func loadStore() {
        _ = persistentContainer
    }

    public func save() {
        let context = persistentContainer.viewContext
        save(onContext: context)
    }

    public func performInBackground(_ closure: @escaping (NSManagedObjectContext) -> Void) {
        let context = makeBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.perform { [weak self] in
            closure(context)
            self?.save(onContext: context)
        }
    }

    public func performAndWaitInBackground(_ closure: @escaping (NSManagedObjectContext) -> Void) {
        let context = makeBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.performAndWait { [weak self] in
            closure(context)
            self?.save(onContext: context)
        }
    }

    public func createBackgroundContext() -> NSManagedObjectContext {
        makeBackgroundContext()
    }

    /// Empties the store: resets the view context, destroys the store and adds it again with the same description
    /// (synchronously).
    ///
    /// Caller obligations:
    /// - Call it on the thread (queue) the view context is used on – the view context is reset directly.
    /// - Contexts made by `createBackgroundContext()`/`performInBackground` and objects fetched before the call aren't
    ///   invalidated: none of them may be in use during or after the call. Fetch again from `context`.
    public func destroyAndRecreateStore() {
        let container = persistentContainer
        let coordinator = container.persistentStoreCoordinator

        container.viewContext.reset()
        for store in coordinator.persistentStores {
            do {
                try coordinator.remove(store)
            } catch {
                logError?("Error while removing store for stack: \(name), code: \((error as NSError).code)")
            }
        }
        if storeKind == .file, let storeURL = storeDescription.url {
            do {
                try coordinator.destroyPersistentStore(at: storeURL, type: .sqlite, options: storeDescription.options)
            } catch {
                logError?("Error while destroying store for stack: \(name), code: \((error as NSError).code)")
            }
        }
        coordinator.addPersistentStore(with: storeDescription) { [weak self] _, error in
            if let error = error as NSError? {
                self?.handleLoadError(error)
            }
        }
    }

    // MARK: - Store files

    /// `<directory>/<name>.sqlite`; `directory == nil` – the app group container.
    public static func storeURL(name: String, directory: URL? = nil) -> URL {
        let directory = directory ?? {
            guard let container = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: Config.groupIdentifier
            ) else {
                fatalError("App group container is not available")
            }
            return container
        }()
        return directory.appendingPathComponent("\(name).sqlite")
    }

    /// `true` when the store file or its copy set aside by an interrupted migration exists.
    public static func storeFilesExist(name: String, directory: URL? = nil) -> Bool {
        let files = PersistentStoreFiles(store: storeURL(name: name, directory: directory))
        return FileManager.default.fileExists(atPath: files.store.path) || files.hasPremigrationStore
    }

    /// Removes `.sqlite`, `-wal`, `-shm` and their `.premigration` copies. Missing files are ignored.
    public static func destroyStoreFiles(name: String, directory: URL? = nil) {
        PersistentStoreFiles(store: storeURL(name: name, directory: directory)).removeAll()
    }

    /// Whether the store can be opened with the current model without migration. `true` when there is no store.
    public static func isStoreCompatible(name: String, bundle: Bundle, directory: URL? = nil) -> Bool {
        switch storeCompatibility(name: name, bundle: bundle, directory: directory) {
        case .noStore, .compatible: true
        case .incompatible, .unreadable: false
        }
    }

    /// Distinguishes a store of another model version from a store whose metadata cannot be read (for example
    /// before the first unlock).
    public static func storeCompatibility(name: String, bundle: Bundle, directory: URL? = nil) -> StoreCompatibility {
        let url = storeURL(name: name, directory: directory)
        guard FileManager.default.fileExists(atPath: url.path) else { return .noStore }
        let model = NSManagedObjectModel.currentModel(name: name, bundle: bundle)
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: url,
            options: nil
        ) else { return .unreadable }
        return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) ? .compatible : .incompatible
    }

    // MARK: - Private

    private func makeBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        configureContext?(context)
        return context
    }

    private func save(onContext context: NSManagedObjectContext) {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            // swiftlint:disable line_length
            let err = "Unresolved error while saving data: \(nserror), \(nserror.userInfo), for stack: \(String(describing: name))"
            // swiftlint:enable line_length
            logError?(err)
            assertionFailure(err)
        }
    }

    private func handleLoadError(_ error: NSError) {
        let err = "Unresolved error while loadPersistentStores: \(error), \(error.userInfo), for stack: \(name)"
        logError?(err)
        parseError(with: error.userInfo)
        fatalError(err)
    }

    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        guard storeKind == .file, let migrator else {
            completion()
            return
        }
        guard let storeURL = storeDescription.url else {
            fatalError("persistentContainer was not set up properly")
        }

        migrator.recoverInterruptedMigration(at: storeURL)
        if migrator.requiresMigrationToCurrentVersion(at: storeURL) {
            migrator.migrateStoreToCurrentVersion(at: storeURL)
        }
        completion()
    }

    private func parseError(with dict: [String: Any]) {
        guard let value = dict["NSSQLiteErrorDomain"] as? Int, value == 13 else { return }
        // swiftlint:disable line_length
        presentErrorToUser?("It appears that either you've run out of disk space now or the database was damaged by such event in the past") // TODO: Add translation!
        // swiftlint:enable line_length
    }
}

public extension NSPersistentContainer {
    @nonobjc convenience init(name: String, bundle: Bundle) {
        self.init(name: name, managedObjectModel: NSManagedObjectModel.currentModel(name: name, bundle: bundle))
    }
}

public extension NSManagedObject {
    @nonobjc func delete() {
        managedObjectContext?.delete(self)
    }
}

private extension NSManagedObjectModel {
    static func currentModel(name: String, bundle: Bundle) -> NSManagedObjectModel {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                Log("Unable to located Core Data model", module: .storage)
                fatalError("Unable to located Core Data model")
            }
        return mom
    }
}

public enum StoreCompatibility {
    case noStore
    case compatible
    case incompatible
    case unreadable
}
