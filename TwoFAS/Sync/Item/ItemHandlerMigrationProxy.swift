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
import Common
import Content

final class ItemHandlerMigrationProxy {
    var newerVersion: (() -> Void)?
    var cloudEncrypted: (() -> Void)?
    
    private let itemHandler: ItemHandler
    private let commonServiceHandler: CommonServiceHandler
    private let logHandler: LogHandler
    
    private var isFirstStart = false
    private var isMigrating = false
    
    private var deletedEntries: [EntityOfKind] = []
    private var updatedCreated: [CKRecord] = []
    
    private var itemsToDelete: [CKRecord.ID] = []
    private var itemsToAdd: [ServiceData] = []
    
    init(itemHandler: ItemHandler, commonServiceHandler: CommonServiceHandler, logHandler: LogHandler) {
        self.itemHandler = itemHandler
        self.commonServiceHandler = commonServiceHandler
        self.logHandler = logHandler
    }
    
    func firstStart() {
        Log("Migration proxy - first start!", module: .cloudSync)
        isFirstStart = true
    }
}

extension ItemHandlerMigrationProxy: ItemHandling {
    func commit() {
        Log("Migration proxy - commit", module: .cloudSync)
        if isFirstStart {
            Log("Migration proxy - checking migration", module: .cloudSync)
            
            if let infoRecord = updatedCreated.first(where: { RecordType(rawValue: $0.recordType) == .info }) {
                let info = InfoRecord(record: infoRecord)
                if info.version > Info().version {
                    Log("Migration proxy - newer version! Aborting...", module: .cloudSync)
                    newerVersion?()
                    return
                }
                if let encryption = Info.Encryption(rawValue: info.encryption), encryption == .user {
                    Log("Migration proxy - cloud encrypted! Aborting...", module: .cloudSync)
                    cloudEncrypted?()
                    return
                }
            } else {
                isMigrating = true
                
                Log("Migration proxy - no Info - migrating", module: .cloudSync)
                
                let list = updatedCreated
                    .filter { RecordType(rawValue: $0.recordType) == .service1 }
                                
                itemsToDelete = list.map { $0.recordID }
                
                Log("Migration proxy - items to delete.count: \(itemsToDelete.count)", module: .cloudSync)
                
                let existing = commonServiceHandler.getAllServices().map { $0.secret }
                let listToAdd = list.map { ServiceRecord(record: $0) }.filter { !existing.contains($0.secret) }
                
                Log("Migration proxy - items to listToAdd.count: \(listToAdd.count)", module: .cloudSync)
                
                listToAdd.forEach { sr in
                    logHandler.log(entityID: sr.secret, actionType: .created, kind: .service2)
                }
                
                addService1(listToAdd)
            }
            
            isFirstStart = false
        }
        itemHandler.deleteEntries(deletedEntries)
        itemHandler.updateOrCreate(with: updatedCreated)
        deletedEntries = []
        updatedCreated = []
    }
    
    func purge() {
        itemHandler.purge()
    }
    
    func itemsToDeleteAfterMigration() -> [CKRecord.ID] {
        let list = itemsToDelete
        itemsToDelete = []
        return list
    }
    
    func servicesToAppend() -> [ServiceData] {
        let services = itemsToAdd
        itemsToAdd = []
        return services
    }
    
    func listAllCommonItems() -> [RecordType: [Any]] {
        if isMigrating {
            Log("Migration proxy - modifying listAllCommonItems", module: .cloudSync)
            
            let list = itemHandler.listAllCommonItems()
                .filter({ $0.key != .service2 })
            
            isMigrating = false
            
            return list
        }
        return itemHandler.listAllCommonItems()
    }
    
    func findItemsRecordIDs(for items: [EntityOfKind], zoneID: CKRecordZone.ID) -> [CKRecord.ID] {
        itemHandler.findItemsRecordIDs(for: items, zoneID: zoneID)
    }
    
    func filterDeleted(from items: [RecordType: [Any]], deleted: [EntityOfKind]) -> [RecordType: [Any]] {
        itemHandler.filterDeleted(from: items, deleted: deleted)
    }
    
    func findItem(for item: Any, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex? {
        itemHandler.findItem(for: item, type: type, in: items)
    }
    
    func findItemForEntryID(_ entryID: String, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex? {
        itemHandler.findItemForEntryID(entryID, type: type, in: items)
    }
    
    func record(for type: RecordType, item: Any, modifiedData from: [RecordType: [Any]]) -> CKRecord? {
        itemHandler.record(for: type, item: item, modifiedData: from)
    }
    
    func record(for type: RecordType, item: Any, index: Int, zoneID: CKRecordZone.ID, allItems: [Any]) -> CKRecord? {
        itemHandler.record(for: type, item: item, index: index, zoneID: zoneID, allItems: allItems)
    }
    
    func deleteEntries(_ entries: [EntityOfKind]) {
        deletedEntries = entries
    }
    
    func updateOrCreate(with entries: [CKRecord]) {
        updatedCreated = entries
    }
}

private extension ItemHandlerMigrationProxy {
    func addService1(_ service1List: [ServiceRecord]) {
        let date = Date()
        let serviceDefinitionDatabase: ServiceDefinitionDatabase = ServiceDefinitionDatabaseImpl()
        
        itemsToAdd = service1List.map { record in
            create(with: record, date: date, serviceDefinitionDatabase: serviceDefinitionDatabase)
        }
    }
    
    func create(
        with record: ServiceRecord,
        date: Date,
        serviceDefinitionDatabase: ServiceDefinitionDatabase
    ) -> ServiceData {
        let serviceTypeID: ServiceTypeID? = { () -> ServiceTypeID? in
            guard let serviceTypeID = serviceDefinitionDatabase.findLegacyService(using: record.service)
            else { return nil }
            return serviceTypeID
        }()
        
        let iconTypeID: IconTypeID = {
            let icon = serviceDefinitionDatabase.findLegacyIcon(using: record.service)
            if let brandIcon = record.brandIcon,
               let iconType = record.iconType,
               let iconTypeValue = IconType(rawValue: iconType),
               let iconTypeID = serviceDefinitionDatabase.findLegacyIcon(using: brandIcon), iconTypeValue == .brand {
                return iconTypeID
            }
            return icon ?? .default
        }()
        
        let labelColorValue: TintColor = {
            guard let labelColor = record.labelColor, let color = TintColor(rawValue: labelColor)
            else { return .lightBlue }
            return color
        }()
        
        let labelTitleValue: String = {
            if let labelTitle = record.labelTitle {
                return labelTitle
            }
            if let serviceTypeID,
               let serviceDef = serviceDefinitionDatabase.service(using: serviceTypeID) {
                return serviceDef.name.twoLetters
            }
            return ServiceDefinition.defaultLabelTitleTwoLetters
        }()
        
        let serviceSource: ServiceSource = {
            if record.service == "manual" {
                return .manual
            }
            return .link
        }()
        
        return ServiceData(
            name: record.name,
            secret: record.secret.decrypt(),
            serviceTypeID: serviceTypeID,
            additionalInfo: record.additionalInfo,
            rawIssuer: record.rawIssuer,
            modifiedAt: record.modificationDate ?? date,
            createdAt: record.creationDate ?? date,
            tokenPeriod: Period.create(record.secretPeriod),
            tokenLength: Digits.create(record.secretLength),
            badgeColor: TintColor(optionalRawValue: record.badgeColor),
            iconType: IconType(optionalWithDefaultRawValue: record.iconType),
            iconTypeID: iconTypeID,
            labelColor: labelColorValue,
            labelTitle: labelTitleValue,
            algorithm: Algorithm.create(record.algorithm),
            isTrashed: false,
            trashingDate: nil,
            counter: record.counter,
            tokenType: TokenType.create(record.tokenType),
            source: serviceSource,
            otpAuth: nil,
            order: record.order,
            sectionID: {
                if let sectionID = record.sectionID {
                    return SectionID(uuidString: sectionID)
                }
                return nil
            }()
        )
    }
}
