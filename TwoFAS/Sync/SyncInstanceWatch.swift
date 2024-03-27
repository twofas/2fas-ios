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
    private static var cloudHandler: CloudHandlerType!
    private static var logDataChangeImpl: LogDataChangeImpl!
    
    public static func initialize(
        commonSectionHandler: CommonSectionHandler,
        commonServiceHandler: CommonServiceHandler,
        errorLog: @escaping (String) -> Void
    ) {
        coreDataStack.logError = { errorLog($0) }
        
        let logHandler = LogHandler(coreDataStack: coreDataStack)
        let sectionHandler = SectionHandler(coreDataStack: coreDataStack)
        let serviceHandler = ServiceHandler(coreDataStack: coreDataStack)
        let infoHandler = InfoHandler()
        let commonItemHandler = CommonItemHandler(
            commonSectionHandler: commonSectionHandler,
            commonServiceHandler: commonServiceHandler,
            logHandler: logHandler
        )
        let cloudKit = CloudKit()
        
        let itemHandler = ItemHandler(
            sectionHandler: sectionHandler,
            serviceHandler: serviceHandler,
            infoHandler: infoHandler,
            logHandler: logHandler
        )
        let itemHandlerMigrationProxy = ItemHandlerMigrationProxy(
            itemHandler: itemHandler
        )
        let syncHandler = SyncHandler(
            itemHandler: itemHandlerMigrationProxy,
            commonItemHandler: commonItemHandler,
            logHandler: logHandler,
            cloudKit: cloudKit
        )
        let cloudAvailability = CloudAvailability(container: syncHandler.container)
        cloudHandler = CloudHandler(
            cloudAvailability: cloudAvailability,
            syncHandler: syncHandler,
            itemHandler: itemHandler,
            itemHandlerMigrationProxy: itemHandlerMigrationProxy,
            cloudKit: cloudKit
        )
        
        logDataChangeImpl = LogDataChangeImpl(logHandler: logHandler)
    }
    public static func getCloudHandler() -> CloudHandlerType { cloudHandler }

    public static func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (BackgroundFetchResult) -> Void
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
        migrator: nil
    )
}
