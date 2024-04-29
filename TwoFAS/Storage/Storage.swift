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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public final class Storage {
    private let coreDataStack: CoreDataStack
    private let serviceHandler: ServiceHandler
    private let sectionHandler: SectionHandler
    private let categoryHandler: CategoryHandler
    private let logHandler: LogHandler
    private let storageRepositoryImpl: StorageRepositoryImpl
    
    public init(readOnly: Bool = false, logError: ((String) -> Void)?) {
        let packageName = "TwoFAS"
        let bundle = Bundle(for: Storage.self)
        let migrator: CoreDataMigratorProtocol? = {
            #if os(iOS)
            CoreDataMigrator(
                momdSubdirectory: packageName,
                versions: [
                    CoreDataMigrationVersion(rawValue: "TwoFAS"),
                    CoreDataMigrationVersion(rawValue: "TwoFAS2"),
                    CoreDataMigrationVersion(rawValue: "TwoFAS3"),
                    CoreDataMigrationVersion(rawValue: "TwoFAS4"),
                    CoreDataMigrationVersion(rawValue: "TwoFAS5"),
                    CoreDataMigrationVersion(rawValue: "TwoFAS6"),
                    CoreDataMigrationVersion(rawValue: "TwoFAS7")
                ]
            )
            #elseif os(watchOS)
            return nil
            #endif
        }()
        coreDataStack = CoreDataStack(
            readOnly: readOnly,
            name: packageName,
            bundle: bundle,
            migrator: migrator
        )
        coreDataStack.logError = logError
        
        serviceHandler = ServiceHandler(coreDataStack: coreDataStack)
        sectionHandler = SectionHandler(coreDataStack: coreDataStack)
        categoryHandler = CategoryHandler(sectionHandler: sectionHandler, serviceHandler: serviceHandler)
        storageRepositoryImpl = StorageRepositoryImpl(coreDataStack: coreDataStack)
        
        let logStorage = CoreDataStack(readOnly: false, name: "LogStorage", bundle: bundle, migrator: nil)
        logHandler = LogHandler(coreDataStack: logStorage)
    }
    
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
