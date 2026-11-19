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
import CloudKit
import CommonWatch

public enum SyncInstanceWatch {
    public static let storeName = "Sync"
    
    private static var coreDataStack: CoreDataStack!
    private static var cloudHandler: CloudHandlerType!
    private static var logDataChangeImpl: LogDataChangeImpl!
    private static var syncEncryptionHandler: SyncEncryptionWatchHandler!
    
    public static func initialize(
        commonSectionHandler: CommonSectionHandler,
        commonServiceHandler: CommonServiceHandler,
        reference: Data,
        localEncryptionKeyData: Data,
        cipher: LocalStorageCipher,
        errorLog: @escaping (String) -> Void
    ) {
        let coreDataStack = makeCoreDataStack(cipher: cipher)
        Self.coreDataStack = coreDataStack
        coreDataStack.logError = { errorLog($0) }
        let zoneManager = ZoneManager()
        let cloudKit = CloudKit(zoneManager: zoneManager)
        let logHandler = LogHandler(coreDataStack: coreDataStack)
        let syncEncryptionHandler = SyncEncryptionWatchHandler(
            reference: reference,
            localEncryptionKeyData: localEncryptionKeyData
        )
        self.syncEncryptionHandler = syncEncryptionHandler
        let sectionHandler = SectionHandler(coreDataStack: coreDataStack)
        let serviceRecordEncryptionHandler = ServiceRecordEncryptionHandler(
            zoneManager: zoneManager,
            encryptionHandler: syncEncryptionHandler
        )
        let serviceHandler = ServiceHandler(
            coreDataStack: coreDataStack,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler
        )
        let infoHandler = InfoHandler(
            zoneManager: zoneManager,
            syncEncryptionHandler: syncEncryptionHandler
        )
        let deletionLogger = DeletionLogger(
            logHandler: logHandler,
            zoneManager: zoneManager,
            syncEncryptionHandler: syncEncryptionHandler
        )
        let commonItemHandler = CommonItemHandler(
            commonSectionHandler: commonSectionHandler,
            commonServiceHandler: commonServiceHandler,
            infoHandler: infoHandler,
            logHandler: logHandler,
            zoneManager: zoneManager,
            syncEncryptionHandler: syncEncryptionHandler,
            deletionLogger: deletionLogger
        )
        
        let itemHandler = ItemHandler(
            sectionHandler: sectionHandler,
            serviceHandler: serviceHandler,
            infoHandler: infoHandler,
            logHandler: logHandler,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler,
            syncEncryptionHandler: syncEncryptionHandler,
            zoneManager: zoneManager,
            deletionHandler: DeletionCacheHandler(coreDataStack: coreDataStack)
        )
        let mergeHandler = MergeHandler(
            logHandler: logHandler,
            commonItemHandler: commonItemHandler,
            itemHandler: itemHandler,
            cloudKit: cloudKit,
            zoneManager: zoneManager
        )
        let modificationQueue = ModificationQueue()
        let migrationHandler = WatchVaultSelector(zoneManager: zoneManager, cloudProbe: CloudProbe())
        let requirementCheckHandler = RequirementCheckWatchHandler(
            encryptionHandler: syncEncryptionHandler,
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
            requirementCheck: requirementCheckHandler,
            reencryptionHandler: ReencryptionHandlerWatchPlaceholder(),
            localReset: localReset,
            // The watch never migrates – its stores are never opened in memory
            isSyncDeferred: false,
            syncContext: coreDataStack.context,
            infoHandler: infoHandler,
            zoneManager: zoneManager,
            syncEncryptionHandler: syncEncryptionHandler
        )
        syncEncryptionHandler.initialize()
        // What the Info record carried when it was last fetched – the salt, the parameters and the identifier key
        syncEncryptionHandler.cloudEncryptionInfoFetched(infoHandler.encryptionInfo)
        let cloudAvailability = CloudAvailability(container: syncHandler.container)
        cloudHandler = CloudHandler(
            cloudAvailability: cloudAvailability,
            syncHandler: syncHandler,
            itemHandler: itemHandler,
            cloudKit: cloudKit,
            mergeHandler: mergeHandler,
            migrationHandler: migrationHandler,
            requirementCheckHandler: requirementCheckHandler,
            zoneManager: zoneManager,
            infoHandler: infoHandler
        )
        
        logDataChangeImpl = LogDataChangeImpl(logHandler: logHandler, deletionLogger: deletionLogger)
    }
    public static func getCloudHandler() -> CloudHandlerType { cloudHandler }
    public static func getDeviceCode() -> DeviceCode { syncEncryptionHandler.deviceCode }

    public static func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (BackgroundFetchResult) -> Void
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
    
    /// `true` only when a readable store of another model version exists. Not for a missing or unreadable store.
    public static func isStoreIncompatibleWithCurrentModel() -> Bool {
        CoreDataStack.storeCompatibility(name: storeName, bundle: Bundle(for: SyncHandler.self)) == .incompatible
    }
    
    public static func migrateStoreIfNeeded() {
        coreDataStack.performInBackground { context in
            Log("Migrating if needed. Trigger value \(context.hasChanges)", module: .cloudSync)
        }
    }
    
    /// - Parameter storeDirectory: Directory of `Sync.sqlite`. `nil` – the app group container.
    static func makeCoreDataStack(cipher: LocalStorageCipher, storeDirectory: URL? = nil) -> CoreDataStack {
        CoreDataStack(
            readOnly: false,
            name: storeName,
            bundle: Bundle(for: SyncHandler.self),
            migrator: nil,
            storeDirectory: storeDirectory,
            // The objects keep what was opened – each entry is decrypted once, not on every sync
            retainsViewContextObjects: true,
            configureContext: { $0.setLocalStorageCipher(cipher) }
        )
    }
}
