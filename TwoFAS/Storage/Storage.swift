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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public final class Storage {
    public static let storeName = "TwoFAS"
    
    let coreDataStack: CoreDataStack
    private let cipher: LocalStorageCipher
    private let serviceHandler: ServiceHandler
    private let sectionHandler: SectionHandler
    private let categoryHandler: CategoryHandler
    private let logHandler: LogHandler
    private let storageRepositoryImpl: StorageRepositoryImpl
    
    /// - Parameter allowsMigration: `true` only in the main app. Otherwise a store that needs migration isn't
    ///   touched – an empty in-memory store is used instead.
    public convenience init(
        readOnly: Bool = false,
        initializeLogStorage: Bool = true,
        cipher: LocalStorageCipher,
        allowsMigration: Bool,
        logError: ((String) -> Void)?
    ) {
        self.init(
            storeDirectory: nil,
            readOnly: readOnly,
            initializeLogStorage: initializeLogStorage,
            cipher: cipher,
            allowsMigration: allowsMigration,
            logError: logError
        )
    }
    
    init(
        storeDirectory: URL?,
        readOnly: Bool = false,
        initializeLogStorage: Bool = true,
        cipher: LocalStorageCipher,
        allowsMigration: Bool,
        logError: ((String) -> Void)?
    ) {
        let bundle = Bundle(for: Storage.self)
        let migrator = Self.makeMigrator(cipher: cipher)
        let storeKind: CoreDataStack.StoreKind = {
            guard !allowsMigration, let migrator else { return .file }
            // Only asking – a migrator passed to the stack would recover or migrate the store in this process
            migrator.bundle = bundle
            let storeURL = CoreDataStack.storeURL(name: Self.storeName, directory: storeDirectory)
            guard migrator.requiresMigrationToCurrentVersion(at: storeURL) else { return .file }
            Log("Storage - store requires migration, using an in-memory store", module: .storage, severity: .warning)
            return .inMemory
        }()
        coreDataStack = CoreDataStack(
            readOnly: readOnly,
            name: Self.storeName,
            bundle: bundle,
            migrator: allowsMigration ? migrator : nil,
            storeDirectory: storeDirectory,
            storeKind: storeKind,
            retainsViewContextObjects: true,
            configureContext: { $0.setLocalStorageCipher(cipher) }
        )
        coreDataStack.logError = logError
        self.cipher = cipher

        serviceHandler = ServiceHandler(coreDataStack: coreDataStack)
        sectionHandler = SectionHandler(coreDataStack: coreDataStack)
        categoryHandler = CategoryHandler(sectionHandler: sectionHandler, serviceHandler: serviceHandler)
        storageRepositoryImpl = StorageRepositoryImpl(coreDataStack: coreDataStack)
        
        logHandler = LogHandler()
        
        if initializeLogStorage {
            Task {
                let logStorage = CoreDataStack(
                    readOnly: false,
                    name: "LogStorage",
                    bundle: bundle,
                    migrator: nil,
                    storeDirectory: storeDirectory
                )
                await logHandler.initializeStorage(coreDataStack: logStorage)
            }
        }
    }
    
    /// - Parameter cipher: `nil` only to ask whether a migration is required.
    static func makeMigrator(cipher: LocalStorageCipher?) -> CoreDataMigratorProtocol? {
        #if os(iOS)
        let migrator = CoreDataMigrator(
            momdSubdirectory: Self.storeName,
            versions: [
                CoreDataMigrationVersion(rawValue: "TwoFAS"),
                CoreDataMigrationVersion(rawValue: "TwoFAS2"),
                CoreDataMigrationVersion(rawValue: "TwoFAS3"),
                CoreDataMigrationVersion(rawValue: "TwoFAS4"),
                CoreDataMigrationVersion(rawValue: "TwoFAS5"),
                CoreDataMigrationVersion(rawValue: "TwoFAS6"),
                CoreDataMigrationVersion(rawValue: "TwoFAS7"),
                CoreDataMigrationVersion(rawValue: "TwoFAS8")
            ]
        )
        // Core Data creates migration policies by class name – they get the cipher from the manager
        if let cipher { migrator.migrationUserInfo = [LocalStorageUserInfoKey.cipher: cipher] }
        migrator.customizeMapping = Self.addContentEncryptionPolicies
        return migrator
        #elseif os(watchOS)
        return nil
        #endif
    }
    
    /// Whether the default store needs a migration (also while a `.premigration` file exists).
    public static func storeRequiresMigration() -> Bool {
        guard let migrator = makeMigrator(cipher: nil) else { return false }
        migrator.bundle = Bundle(for: Storage.self)
        return migrator.requiresMigrationToCurrentVersion(at: CoreDataStack.storeURL(name: storeName, directory: nil))
    }
    
    /// Resolves an interrupted migration of the default store and migrates it when it needs it – the main app does
    /// it before anything opens the store.
    /// - Returns: Whether the store was migrated.
    /// - Throws: `CoreDataMigrationError` – the store is left as it was.
    @discardableResult
    public static func prepareStore(cipher: LocalStorageCipher) throws -> Bool {
        guard let migrator = makeMigrator(cipher: cipher) else { return false }
        migrator.bundle = Bundle(for: Storage.self)
        return try migrator.prepareStore(at: CoreDataStack.storeURL(name: storeName, directory: nil))
    }
    
    /// Whether the default store holds services or auth requests sealed with the local storage key. `false` for a
    /// missing store and for one that still waits for the migration (nothing is sealed there). A store that can't
    /// be read counts as holding sealed data.
    public static func storeContainsSealedData(directory: URL? = nil) -> Bool {
        let bundle = Bundle(for: Storage.self)
        switch CoreDataStack.storeCompatibility(name: storeName, bundle: bundle, directory: directory) {
        case .noStore, .incompatible:
            return false
        case .unreadable:
            return true
        case .compatible:
            let count = CoreDataStack.countObjects(
                ofEntities: ["ServiceEntity", "AuthRequestEntity"],
                name: storeName,
                bundle: bundle,
                directory: directory
            )
            return (count ?? 1) > 0
        }
    }
    
    /// `true` only when a readable store of another model version exists. Not for a missing or unreadable store.
    public static func isStoreIncompatibleWithCurrentModel() -> Bool {
        CoreDataStack.storeCompatibility(name: storeName, bundle: Bundle(for: Storage.self)) == .incompatible
    }
    
    /// `true` when the store requires a migration that wasn't allowed in this process – an empty in-memory store is used
    /// instead, so Sync must not run against it (its emptiness would look like deletions)
    public var isMigrationDeferred: Bool { coreDataStack.storeKind == .inMemory }

    /// `true` when the user's data can't be shown now: the store waits for a migration this process wasn't allowed
    /// to do, or the local storage key can't be used (unavailable, or lost before the main app rebuilds the stores)
    public var isLocalDataUnavailable: Bool {
        if isMigrationDeferred { return true }
        return switch cipher.state {
        case .keyUnavailable, .keyLost: true
        case .noKey, .available: false
        }
    }

    /// Opens the store now – migrating it first when needed – instead of on first use
    public func loadStore() { coreDataStack.loadStore() }

    public func addUserPresentableError(presentErrorToUser: @escaping ((String) -> Void)) {
        coreDataStack.presentErrorToUser = presentErrorToUser
    }
    
    public func save() { coreDataStack.save()}
    
    public var service: ServiceHandler { serviceHandler }
    public var section: SectionHandler { sectionHandler }
    public var category: CategoryHandler { categoryHandler }
    public var log: LogHandler { logHandler }
    public var widgetService: WidgetServiceHandlerType { categoryHandler }
    public var storageRepository: StorageRepository { storageRepositoryImpl }
    
    public func reset() {
        Log("Storage - remove all!", module: .storage)
        sectionHandler.removeAll()
        serviceHandler.removeAll()
        storageRepositoryImpl.removeAllPairings()
        storageRepositoryImpl.removeAllAuthRequests()
    }
}

#if os(iOS)
private extension Storage {
    /// Source entity name → policy moving its sensitive fields into sealed content (TwoFAS7 → TwoFAS8)
    static let contentEncryptionPolicies = [
        "ServiceEntity": NSStringFromClass(EncryptServiceContentMigrationPolicy.self),
        "AuthRequestEntity": NSStringFromClass(EncryptAuthRequestContentMigrationPolicy.self)
    ]
    
    static func addContentEncryptionPolicies(
        source: CoreDataMigrationVersion,
        destination: CoreDataMigrationVersion,
        mapping: NSMappingModel
    ) -> NSMappingModel {
        guard source.rawValue == "TwoFAS7", destination.rawValue == "TwoFAS8" else { return mapping }
        var unmapped = Set(contentEncryptionPolicies.keys)
        for entityMapping in mapping.entityMappings {
            guard let entityName = entityMapping.sourceEntityName,
                  let policyClassName = contentEncryptionPolicies[entityName] else { continue }
            entityMapping.entityMigrationPolicyClassName = policyClassName
            // The policy creates the destination instances itself
            entityMapping.mappingType = .customEntityMappingType
            unmapped.remove(entityName)
        }
        if !unmapped.isEmpty {
            Log("Storage - no entity mapping for: \(unmapped.sorted())", module: .storage, severity: .error)
            // Before the migration starts – the old store is kept. Migrating without the policy would drop the entity.
            fatalError("Storage - no entity mapping for an encrypted entity")
        }
        return mapping
    }
}
#endif
