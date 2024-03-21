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

final class CommonItemHandler {
    private let commonSectionHandler: CommonSectionHandler
    private let commonServiceHandler: CommonServiceHandler
    private let logHandler: LogHandler
    
    private var itemsToAppend: [ServiceData] = []
    
    init(
        commonSectionHandler: CommonSectionHandler,
        commonServiceHandler: CommonServiceHandler,
        logHandler: LogHandler
    ) {
        self.commonSectionHandler = commonSectionHandler
        self.commonServiceHandler = commonServiceHandler
        self.logHandler = logHandler
        
        commonSectionHandler.commonDidCreate = { [weak self] sectionID in
            Log("CommonItemHandler - commonSectionHandler - commonDidCreate", module: .cloudSync)
            self?.logHandler.log(entityID: sectionID, actionType: .created, kind: .section)
        }
        commonSectionHandler.commonDidModify = { [weak self] sectionIDs in
            Log("CommonItemHandler - commonSectionHandler - commonDidModify", module: .cloudSync)
            sectionIDs.forEach {
                self?.logHandler.log(entityID: $0, actionType: .modified, kind: .section)
            }
        }
        commonSectionHandler.commonDidDelete = { [weak self] sectionID in
            Log("CommonItemHandler - commonSectionHandler - commonDidDelete", module: .cloudSync)
            self?.logHandler.log(entityID: sectionID, actionType: .deleted, kind: .section)
        }
        
        commonServiceHandler.commonDidCreate = { [weak self] secret in
            Log("CommonItemHandler - commonServiceHandler - commonDidCreate", module: .cloudSync)
            self?.logHandler.log(entityID: secret, actionType: .created, kind: .service2)
        }
        commonServiceHandler.commonDidModify = { [weak self] secrets in
            Log("CommonItemHandler - commonServiceHandler - commonDidModify", module: .cloudSync)
            secrets.forEach {
                self?.logHandler.log(entityID: $0, actionType: .modified, kind: .service2)
            }
        }
        commonServiceHandler.commonDidDelete = { [weak self] secret in
            Log("CommonItemHandler - commonServiceHandler - commonDidDelete", module: .cloudSync)
            self?.logHandler.log(entityID: secret, actionType: .deleted, kind: .service2)
        }
    }
    
    func logFirstImport() {
        logHandler.logFirstImport(entityIDs: commonSectionHandler.getAllSections().map { $0.sectionID }, kind: .section)
        logHandler.logFirstImport(entityIDs: commonServiceHandler.getAllServices().map { $0.secret }, kind: .service2)
        logHandler.logFirstImport(entityIDs: [Info.id], kind: .info)
    }
    
    func setItems(_ items: [RecordType: [Any]]) -> Bool {
        var newDataWasSet = false
        
        if let sections = items[.section] as? [CommonSectionData] {
            Log("CommonItemHandler: sections (\(sections.count))")
            let value = commonSectionHandler.setSections(sections)
            newDataWasSet = newDataWasSet || value
        }
        
        if let services = items[.service2] as? [ServiceData] {
            Log("CommonItemHandler: services (\(services.count))")
            let value = commonServiceHandler.setServices(services)
            newDataWasSet = newDataWasSet || value
        }
        
        return newDataWasSet
    }
    
    func setItemsFromMigration(_ serviceDataToAppend: [ServiceData]) {
        Log("CommonItemHandler: setting items from migration (\(serviceDataToAppend.count))")
        itemsToAppend = serviceDataToAppend
    }
    
    func getAllItems() -> [RecordType: [Any]] {
        let sections = commonSectionHandler.getAllSections()
        let services = commonServiceHandler.getAllServices() + itemsToAppend
        itemsToAppend = []
        var value = [RecordType: [Any]]()
        value[.section] = sections
        value[.service2] = services
        value[.info] = [Info()]
        return value
    }
}
