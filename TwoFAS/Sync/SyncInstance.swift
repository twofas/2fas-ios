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

public enum SyncInstance {
    private static var cloudHandler: CloudHandlerType!
    private static var logDataChangeImpl: LogDataChangeImpl!
    private static var syncMigrationHandler: SyncMigrationHandling!
    
    public static func initialize(
        commonSectionHandler: CommonSectionHandler,
        commonServiceHandler: CommonServiceHandler,
        reference: Data,
        errorLog: @escaping (String) -> Void
    ) {
        coreDataStack.logError = { errorLog($0) }
        
        let cloudKit = CloudKit()
        let syncEncryptionHandler = SyncEncryptionHandler(reference: reference)
        let serviceRecordEncryptionHandler = ServiceRecordEncryptionHandler(
            zoneID: cloudKit.zoneID,
            encryptionHandler: syncEncryptionHandler
        )
        let logHandler = LogHandler(coreDataStack: coreDataStack)
        let sectionHandler = SectionHandler(coreDataStack: coreDataStack)
        let serviceHandler = ServiceHandler(
            coreDataStack: coreDataStack,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler
        )
        let infoHandler = InfoHandler(
            zoneID: cloudKit.zoneID,
            syncEncryptionHandler: syncEncryptionHandler
        )
        let commonItemHandler = CommonItemHandler(
            commonSectionHandler: commonSectionHandler,
            commonServiceHandler: commonServiceHandler,
            infoHandler: infoHandler,
            logHandler: logHandler
        )
        
        let itemHandler = ItemHandler(
            sectionHandler: sectionHandler,
            serviceHandler: serviceHandler,
            infoHandler: infoHandler,
            logHandler: logHandler,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler,
            syncEncryptionHandler: syncEncryptionHandler
        )
        let mergeHandler = MergeHandler(
            logHandler: logHandler,
            commonItemHandler: commonItemHandler,
            itemHandler: itemHandler,
            cloudKit: cloudKit
        )
        let modificationQueue = ModificationQueue()
        let requirementCheck = RequirementCheckHandler(
            encryptionHandler: syncEncryptionHandler,
            infoHandler: infoHandler
        )
        let migrationHandler = MigrationHandler(
            serviceHandler: serviceHandler,
            zoneID: cloudKit.zoneID,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler,
            infoHandler: infoHandler,
            syncEncryptionHandler: syncEncryptionHandler
        )
        let syncHandler = SyncHandler(
            itemHandler: itemHandler,
            commonItemHandler: commonItemHandler,
            logHandler: logHandler,
            cloudKit: cloudKit,
            modificationQueue: modificationQueue,
            mergeHandler: mergeHandler,
            migrationHandler: migrationHandler,
            requirementCheck: requirementCheck
        )
        let cloudAvailability = CloudAvailability(container: syncHandler.container)
        cloudHandler = CloudHandler(
            cloudAvailability: cloudAvailability,
            syncHandler: syncHandler,
            itemHandler: itemHandler,
            cloudKit: cloudKit,
            mergeHandler: mergeHandler,
            migrationHandler: migrationHandler,
            requirementCheckHandler: requirementCheck
        )
        let syncMigrationHandlerInstance = SyncMigrationHandler(
            migrationHandler: migrationHandler,
            syncEncryptionHandler: syncEncryptionHandler
        )
        cloudHandler.registerForStateChange({ cloudState in
            syncMigrationHandlerInstance.cloudStateChange(cloudState)
        }, with: "syncMigrationHandler")
        syncMigrationHandlerInstance.synchronize = { syncHandler.synchronize() }
        syncMigrationHandlerInstance.enable = { cloudHandler.enable() }
        cloudHandler.purgeUserEncryptionKey = { syncEncryptionHandler.purge() }
        syncEncryptionHandler.initialize()
        
        syncMigrationHandler = syncMigrationHandlerInstance
        logDataChangeImpl = LogDataChangeImpl(logHandler: logHandler)
    }
    public static func getCloudHandler() -> CloudHandlerType { cloudHandler }
    public static func getSyncMigrationHandler() -> SyncMigrationHandling { syncMigrationHandler }
    
    public static func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        cloudHandler.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    public static var logDataChange: LogDataChange {
        logDataChangeImpl
    }
    
    public static func migrateStoreIfNeeded() {
        coreDataStack.performInBackground { context in
            Log("Migrating if needed. Trigger value \(context.hasChanges)", module: .cloudSync)
        }
    }
    
    private static let coreDataStack = CoreDataStack(
        readOnly: false,
        name: "Sync",
        bundle: Bundle(for: SyncHandler.self),
        migrator: CoreDataMigrator(
            momdSubdirectory: "Sync",
            versions: [
                CoreDataMigrationVersion(rawValue: "Sync"),
                CoreDataMigrationVersion(rawValue: "Sync2"),
                CoreDataMigrationVersion(rawValue: "Sync3"),
                CoreDataMigrationVersion(rawValue: "Sync4"),
                CoreDataMigrationVersion(rawValue: "Sync5")
            ]) { _, toVersion in
                if toVersion.rawValue == "Sync5" {
                    Log("Migrating to Sync5!", module: .cloudSync)
                    SyncInstance.cloudHandler.resetStateBeforeSync()
                }
            }
    )
}
