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
    
    public static func initialize() {
        let logHandler = LogHandler(coreDataStack: coreDataStack)
        let sectionHandler = SectionHandler(coreDataStack: coreDataStack)
        let serviceHandler = ServiceHandler(coreDataStack: coreDataStack)
        let infoHandler = InfoHandler()
        let commonItemHandler = CommonItemHandler()
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
        
        coreDataStack.performInBackground { context in
            Log("Migrating if needed. Trigger value \(context.hasChanges)", module: .cloudSync)
        }
    }
    public static func getCloudHandler() -> CloudHandlerType { cloudHandler }

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
                    SyncInstanceWatch.cloudHandler.resetStateBeforeSync()
                }
            }
    )
}

private final class CommonServiceHandlerImpl: CommonServiceHandler {
    var commonDidDelete: CommonDidDelete?
    var commonDidModify: CommonDidModify?
    var commonDidCreate: CommonDidCreate?
        
    func setServices(_ servicesservices: [ServiceData]) -> Bool {
        false
    }
    func getAllServices() -> [ServiceData] {
        []
    }
}
