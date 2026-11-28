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

import UIKit
import CloudKit
import Common
import CoreData

public enum SyncInstance {
    public static let storeName = "Sync"
    
    private static var coreDataStack: CoreDataStack!
    private static var cloudHandler: CloudHandlerType!
    private static var isStateResetPending = false
    private static var logDataChangeImpl: LogDataChangeImpl!
    private static var syncMigrationHandler: SyncMigrationHandling!
    private static var watchPairHandler: WatchPairHandling!
    private static var syncEncryptionHandler: SyncEncryptionHandler!
    
    /// - Parameter storageMigrationDeferred: The Storage stack was opened in memory because its migration was deferred
    ///   (`Storage.isMigrationDeferred`) – Sync doesn't run in this launch then.
    public static func initialize(
        commonSectionHandler: CommonSectionHandler,
        commonServiceHandler: CommonServiceHandler,
        reference: Data,
        localEncryptionKeyData: Data,
        cipher: LocalStorageCipher,
        allowsMigration: Bool,
        storageMigrationDeferred: Bool,
        errorLog: @escaping (String) -> Void
    ) {
        let coreDataStack = makeCoreDataStack(cipher: cipher, allowsMigration: allowsMigration)
        Self.coreDataStack = coreDataStack
        coreDataStack.logError = { errorLog($0) }
        let zoneManager = ZoneManager()
        let cloudKit = CloudKit(zoneManager: zoneManager)
        let syncEncryptionHandler = SyncEncryptionHandler(
            reference: reference,
            localEncryptionKeyData: localEncryptionKeyData
        )
        let serviceRecordEncryptionHandler = ServiceRecordEncryptionHandler(
            zoneManager: zoneManager,
            encryptionHandler: syncEncryptionHandler
        )
        let logHandler = LogHandler(coreDataStack: coreDataStack)
        let sectionHandler = SectionHandler(coreDataStack: coreDataStack)
        let serviceHandler = ServiceHandler(
            coreDataStack: coreDataStack,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler
        )
        let infoHandler = InfoHandler(
            zoneManager: zoneManager,
            syncEncryptionHandler: syncEncryptionHandler
        )
        let commonItemHandler = CommonItemHandler(
            commonSectionHandler: commonSectionHandler,
            commonServiceHandler: commonServiceHandler,
            infoHandler: infoHandler,
            logHandler: logHandler,
            zoneManager: zoneManager
        )
        
        let itemHandler = ItemHandler(
            sectionHandler: sectionHandler,
            serviceHandler: serviceHandler,
            infoHandler: infoHandler,
            logHandler: logHandler,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler,
            syncEncryptionHandler: syncEncryptionHandler,
            zoneManager: zoneManager
        )
        let mergeHandler = MergeHandler(
            logHandler: logHandler,
            commonItemHandler: commonItemHandler,
            itemHandler: itemHandler,
            cloudKit: cloudKit,
            zoneManager: zoneManager
        )
        let modificationQueue = ModificationQueue()
        let requirementCheck = RequirementCheckHandler(
            encryptionHandler: syncEncryptionHandler,
            infoHandler: infoHandler
        )
        let migrationHandler = MigrationHandler(
            zoneManager: zoneManager,
            cloudProbe: CloudProbe()
        )
        let reencryptionHandler = ReencryptionHandler(
            serviceHandler: serviceHandler,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler,
            syncEncryptionHandler: syncEncryptionHandler,
            infoHandler: infoHandler
        )
        let localReset = SyncLocalReset(
            store: coreDataStack,
            clearInfoCache: infoHandler.purge,
            clearCheckpoints: ConstStorage.clearZone,
            clearPendingTokens: cloudKit.clear,
            clearQueue: modificationQueue.clear,
            logFirstImport: commonItemHandler.logFirstImport
        )
        let syncHandler = SyncHandler(
            itemHandler: itemHandler,
            commonItemHandler: commonItemHandler,
            logHandler: logHandler,
            cloudKit: cloudKit,
            modificationQueue: modificationQueue,
            mergeHandler: mergeHandler,
            migrationHandler: migrationHandler,
            requirementCheck: requirementCheck,
            reencryptionHandler: reencryptionHandler,
            localReset: localReset,
            isSyncDeferred: isSyncDeferred(
                storageMigrationDeferred: storageMigrationDeferred,
                syncStack: coreDataStack
            ),
            syncContext: coreDataStack.context
        )
        let watchPairHandlerInstance = WatchPairHandler(
            syncEncryptionHandler: syncEncryptionHandler,
            infoHandler: infoHandler
        )
        syncEncryptionHandler.keyDidChange = { watchPairHandlerInstance.clearList() }
        
        let cloudAvailability = CloudAvailability(container: syncHandler.container)
        cloudHandler = CloudHandler(
            cloudAvailability: cloudAvailability,
            syncHandler: syncHandler,
            itemHandler: itemHandler,
            cloudKit: cloudKit,
            mergeHandler: mergeHandler,
            migrationHandler: migrationHandler,
            requirementCheckHandler: requirementCheck,
            zoneManager: zoneManager,
            infoHandler: infoHandler
        )
        let syncMigrationHandlerInstance = SyncMigrationHandler(
            migrationHandler: migrationHandler,
            reencryptionHandler: reencryptionHandler,
            syncEncryptionHandler: syncEncryptionHandler
        )
        watchPairHandlerInstance.synchronize = { cloudHandler.synchronize() }
        watchPairHandlerInstance.logInfoModification = { logHandler.log(
            entityID: Info.id,
            actionType: .modified,
            kind: .info
        ) }
        cloudHandler.registerForStateChange({ cloudState in
            syncMigrationHandlerInstance.cloudStateChange(cloudState)
        }, with: "syncMigrationHandler")
        syncMigrationHandlerInstance.synchronize = { syncHandler.synchronize() }
        syncMigrationHandlerInstance.enable = { cloudHandler.enable() }
        cloudHandler.purgeUserEncryptionKey = { syncEncryptionHandler.purge() }
        cloudHandler.setSystemEncryption = { syncEncryptionHandler.setSystemKey() }
        syncEncryptionHandler.initialize()
        
        syncMigrationHandler = syncMigrationHandlerInstance
        logDataChangeImpl = LogDataChangeImpl(logHandler: logHandler)
        watchPairHandler = watchPairHandlerInstance
        Self.syncEncryptionHandler = syncEncryptionHandler
        
        if isStateResetPending {
            isStateResetPending = false
            cloudHandler.resetStateBeforeSync()
        }
    }
    public static func getCloudHandler() -> CloudHandlerType { cloudHandler }
    public static func getSyncMigrationHandler() -> SyncMigrationHandling { syncMigrationHandler }
    public static func getWatchPairHandler() -> WatchPairHandling { watchPairHandler }
    
    public static func debugReloadAllKeys() {
        syncEncryptionHandler.debugReloadAllKeys()
    }
    
    public static func exportKeys() -> (salt: Data, systemKey: Data)? {
        syncEncryptionHandler.exportKeys()
    }
    
    public static func importKeys(salt: Data, systemKey: Data, password: String?) {
        syncEncryptionHandler.importKeys(salt: salt, systemKey: systemKey, password: password)
    }
    
    public static func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        cloudHandler.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    public static var logDataChange: LogDataChange {
        logDataChangeImpl
    }
    
    /// The local Sync cache is reset from scratch before the next sync (also after a restart)
    public static func scheduleResetFromScratch() {
        ConstStorage.syncResetRequired = true
    }
    
    public static func migrateStoreIfNeeded() {
        coreDataStack.performInBackground { context in
            Log("Migrating if needed. Trigger value \(context.hasChanges)", module: .cloudSync)
        }
    }
    
    /// Whether the default store needs a migration (also while a `.premigration` file exists).
    public static func storeRequiresMigration() -> Bool {
        let migrator = makeMigrator(cipher: nil)
        migrator.bundle = Bundle(for: SyncHandler.self)
        return migrator.requiresMigrationToCurrentVersion(at: CoreDataStack.storeURL(name: storeName, directory: nil))
    }
    
    /// Resolves an interrupted migration of the default store and migrates it when it needs it – the main app does
    /// it before `initialize`.
    /// - Returns: Whether the store was migrated.
    /// - Throws: `CoreDataMigrationError` – the store is left as it was.
    @discardableResult
    public static func prepareStore(cipher: LocalStorageCipher) throws -> Bool {
        let migrator = makeMigrator(cipher: cipher)
        migrator.bundle = Bundle(for: SyncHandler.self)
        return try migrator.prepareStore(at: CoreDataStack.storeURL(name: storeName, directory: nil))
    }
    
    /// Sync doesn't run in a launch in which the Storage or the Sync stack was opened in memory because its migration
    /// was deferred: the empty store synced with the saved change tokens would diverge from the cloud (and an empty
    /// cache merged into a file-backed Storage would trash its services).
    static func isSyncDeferred(storageMigrationDeferred: Bool, syncStack: CoreDataStack) -> Bool {
        // The Sync stack is in memory only when its migration was deferred
        storageMigrationDeferred || syncStack.storeKind == .inMemory
    }

    /// - Parameter storeDirectory: Directory of `Sync.sqlite`. `nil` – the app group container.
    /// - Parameter allowsMigration: When `false` and the store requires migration, it isn't touched – an empty
    ///   in-memory store is used instead (Sync is deferred for the launch then, see `isSyncDeferred`).
    static func makeCoreDataStack(
        cipher: LocalStorageCipher,
        storeDirectory: URL? = nil,
        allowsMigration: Bool = true
    ) -> CoreDataStack {
        let bundle = Bundle(for: SyncHandler.self)
        let migrator = makeMigrator(cipher: cipher)
        var storeKind = CoreDataStack.StoreKind.file
        if !allowsMigration {
            // Only asking – a migrator passed to the stack would migrate the store in this process
            migrator.bundle = bundle
            if migrator.requiresMigrationToCurrentVersion(
                at: CoreDataStack.storeURL(name: storeName, directory: storeDirectory)
            ) {
                Log("Sync - store requires migration, using an in-memory store", module: .cloudSync, severity: .warning)
                storeKind = .inMemory
            }
        }
        return CoreDataStack(
            readOnly: false,
            name: storeName,
            bundle: bundle,
            migrator: allowsMigration ? migrator : nil,
            storeDirectory: storeDirectory,
            storeKind: storeKind,
            // Every sync checks that the whole cache can be decrypted and then reads it – the objects keep what
            // was opened, so each entry is decrypted once, not twice per sync
            retainsViewContextObjects: true,
            configureContext: { $0.setLocalStorageCipher(cipher) }
        )
    }
    
    static func makeMigrator(cipher: LocalStorageCipher?) -> CoreDataMigrator {
        let migrator = CoreDataMigrator(
            momdSubdirectory: storeName,
            versions: [
                CoreDataMigrationVersion(rawValue: "Sync"),
                CoreDataMigrationVersion(rawValue: "Sync2"),
                CoreDataMigrationVersion(rawValue: "Sync3"),
                CoreDataMigrationVersion(rawValue: "Sync4"),
                CoreDataMigrationVersion(rawValue: "Sync5"),
                CoreDataMigrationVersion(rawValue: "Sync6")
            ]) { fromVersion, _ in
                // Called once per migration with the current version as the destination, so only the source matters
                if requiresStateResetAfterMigration(from: fromVersion) {
                    Log("Migrating to Sync5!", module: .cloudSync)
                    if let cloudHandler = SyncInstance.cloudHandler {
                        cloudHandler.resetStateBeforeSync()
                    } else {
                        // Migrated before `initialize` – applied there
                        SyncInstance.isStateResetPending = true
                    }
                }
            }
        // Core Data creates migration policies by class name – they get the cipher from the manager
        if let cipher { migrator.migrationUserInfo = [LocalStorageUserInfoKey.cipher: cipher] }
        migrator.customizeMapping = addContentEncryptionPolicies
        return migrator
    }
    
    /// Stores older than Sync5 need the sync state reset (the migration passes through Sync5)
    static func requiresStateResetAfterMigration(from source: CoreDataMigrationVersion) -> Bool {
        ["Sync", "Sync2", "Sync3", "Sync4"].contains(source.rawValue)
    }
    
    /// Source entity name → policy moving its sensitive fields into sealed content (Sync5 → Sync6)
    private static let contentEncryptionPolicies = [
        "ServiceCacheEntity": NSStringFromClass(EncryptServiceCacheContentMigrationPolicy.self),
        "LogEntity": NSStringFromClass(EncryptLogEntityMigrationPolicy.self),
        "SectionCacheEntity": NSStringFromClass(EncryptSectionCacheContentMigrationPolicy.self)
    ]
    
    private static func addContentEncryptionPolicies(
        source: CoreDataMigrationVersion,
        destination: CoreDataMigrationVersion,
        mapping: NSMappingModel
    ) -> NSMappingModel {
        guard source.rawValue == "Sync5", destination.rawValue == "Sync6" else { return mapping }
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
            Log("Sync Migration - no entity mapping for: \(unmapped.sorted())", module: .cloudSync, severity: .error)
            // Before the migration starts – the old store is kept. Migrating without the policy would drop the entity.
            fatalError("Sync Migration - no entity mapping for an encrypted entity")
        }
        return mapping
    }
}
