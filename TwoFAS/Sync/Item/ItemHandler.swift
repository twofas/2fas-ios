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
#if os(iOS)
import Common
import Protection
#elseif os(watchOS)
import CommonWatch
import ProtectionWatch
#endif

final class ItemHandler {
    typealias SecretError = (String) -> Void
    var secretError: SecretError?
    
    private let sectionHandler: SectionHandler
    private let serviceHandler: ServiceHandler
    private let infoHandler: InfoHandler
    private let logHandler: LogHandler
    
    private let encryption = ExchangeFileEncryption()
    private let embedded = Keys.Sync.key.decrypt()
    private let allowedDevicesNone = "none"
    
    init(
        sectionHandler: SectionHandler,
        serviceHandler: ServiceHandler,
        infoHandler: InfoHandler,
        logHandler: LogHandler
    ) {
        self.sectionHandler = sectionHandler
        self.serviceHandler = serviceHandler
        self.infoHandler = infoHandler
        self.logHandler = logHandler
        
        serviceHandler.encryption = encryption
        serviceHandler.embedded = embedded
    }
}

extension ItemHandler: ItemHandling {
    func purge() {
        Log("ItemHandler - Purging section handler and service handler", module: .cloudSync)
        sectionHandler.purge()
        serviceHandler.purge()
        infoHandler.purge()
    }
    
    func deleteEntries(_ entries: [EntityOfKind]) {
        entries.forEach { entryID, type in
            switch type {
            case .section: sectionHandler.delete(identifiedBy: entryID)
            case .service2: serviceHandler.delete(identifiedBy: entryID)
            default: break
            }
        }
    }
    
    func updateOrCreate(with entries: [CKRecord]) {
        entries.forEach { record in
            if let recordType = RecordType(rawValue: record.recordType) {
                switch recordType {
                case .section: sectionHandler.updateOrCreate(with: SectionRecord(record: record), save: false)
                case .service2: serviceHandler.updateOrCreate(with: ServiceRecord2(record: record), save: false)
                case .info: infoHandler.saveMetadata(InfoRecord(record: record).encodeSystemFields())
                default: break
                }
            }
        }
        sectionHandler.saveAfterBatch()
        serviceHandler.saveAfterBatch()
    }
    
    func listAllCommonItems() -> [RecordType: [Any]] {
        var value = [RecordType: [Any]]()
        value[RecordType.section] = sectionHandler.listAllCommonSection()
        value[RecordType.service2] = serviceHandler.listAll()
        value[RecordType.info] = infoHandler.infoIfExists()
        return value
    }
    
    func findItemsRecordIDs(for items: [EntityOfKind], zoneID: CKRecordZone.ID) -> [CKRecord.ID] {
        items.map({ $0.type.recordIDGenerator.recordID(with: $0.entityID, zoneID: zoneID) })
    }
    
    func filterDeleted(from items: [RecordType: [Any]], deleted: [EntityOfKind]) -> [RecordType: [Any]] {
        var items = items
        
        let deletedSections = deleted.filter({ $0.type == .section }).map({ $0.entityID })
        let deletedServices = deleted.filter({ $0.type == .service2 }).map({ $0.entityID })
        
        items[.section] = (items[.section] as? [CommonSectionData])?.filter({ !deletedSections.contains($0.sectionID) })
        items[.service2] = (items[.service2] as? [ServiceData])?.filter({ !deletedServices.contains($0.secret) })
        
        return items
    }
    
    func findItem(for item: Any, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex? {
        guard let entityID = { () -> String? in
            switch type {
            case .section: return (item as? CommonSectionData)?.sectionID
            case .service2: return (item as? ServiceData)?.secret
            case .info: return ""
            default: return nil
            }
        }() else { return nil }
        return findItemForEntryID(entityID, type: type, in: items)
    }
    
    func findItemForEntryID(_ entryID: String, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex? {
        switch type {
        case .section:
            guard
                let list = (items[.section] as? [CommonSectionData]),
                let item = list.first(where: { $0.sectionID == entryID }),
                let index = list.firstIndex(where: { $0.sectionID == entryID })
            else { return nil }
            return .init(index: index, item: item, type: .section)
        case .service2:
            guard
                let list = (items[.service2] as? [ServiceData]),
                let item = list.first(where: { $0.secret == entryID }),
                let index = list.firstIndex(where: { $0.secret == entryID })
            else { return nil }
            return .init(index: index, item: item, type: .service2)
        case .info:
            guard let item = items[.info]?.first else { return nil }
            return .init(index: 0, item: item, type: .info)
        default: return nil
        }
    }
    
    func record(for type: RecordType, item: Any, modifiedData from: [RecordType: [Any]]) -> CKRecord? {
        guard let entityID = { () -> String? in
            switch type {
            case .section: return (item as? CommonSectionData)?.sectionID
            case .service2: return (item as? ServiceData)?.secret
            case .info: return ""
            default: return nil
            }
        }() else { return nil }
        
        switch type {
        case .section:
            guard let current = sectionHandler.findSection(by: entityID),
                  let list = (from[.section] as? [CommonSectionData]),
                  let modified = list.first(where: { $0.sectionID == entityID }),
                  let index = list.firstIndex(where: { $0.sectionID == entityID }) else { return nil }
            return SectionRecord.create(
                with: current.metadata,
                sectionID: modified.sectionID,
                title: modified.name,
                order: index
            )
            
        case .service2:
            guard let current = serviceHandler.findService(by: entityID),
                  let list = (from[.service2] as? [ServiceData]),
                  let modified = list.first(where: { $0.secret == entityID }),
                  let data = modified.secret.data(using: .utf8),
                  let ref = encryption.encrypt(with: embedded, data: data)
            else {
                Log("ItemHandler - Can't create CKRecord with ServiceData", module: .cloudSync)
                Log("ItemHandler - Can't create CKRecord with ServiceData: \(item)", module: .cloudSync, save: false)
                return nil
            }
            
            let sectionOrder = Dictionary(grouping: list, by: { $0.sectionID })[modified.sectionID]?
                .firstIndex(where: { $0.secret == entityID }) ?? 0
            
            return ServiceRecord2.create(
                with: current.metadata,
                name: modified.name,
                secret: ref.data,
                serviceTypeID: modified.serviceTypeID?.uuidString,
                additionalInfo: modified.additionalInfo,
                rawIssuer: modified.rawIssuer,
                otpAuth: modified.otpAuth,
                tokenPeriod: modified.tokenPeriod?.rawValue,
                tokenLength: modified.tokenLength.rawValue,
                badgeColor: modified.badgeColor?.rawValue,
                iconType: modified.iconType.rawValue,
                iconTypeID: modified.iconTypeID.uuidString,
                labelColor: modified.labelColor.rawValue,
                labelTitle: modified.labelTitle,
                sectionID: modified.sectionID?.uuidString,
                sectionOrder: sectionOrder,
                algorithm: modified.algorithm.rawValue,
                counter: modified.counter,
                tokenType: modified.tokenType.rawValue,
                source: modified.source.rawValue,
                reference: ref.reference
            )
        case .info:
            guard let info = (from[.info] as? [Info])?.first, let metadata = infoHandler.metadata() else { return nil }
            return InfoRecord.create(
                with: metadata,
                version: info.version,
                encryption: info.encyption.rawValue,
                allowedDevices: [allowedDevicesNone],
                enableWatch: false
            )
        default: return nil
        }
    }
    
    func record(for type: RecordType, item: Any, index: Int, zoneID: CKRecordZone.ID, allItems: [Any]) -> CKRecord? {
        guard let entityID = { () -> String? in
            switch type {
            case .section: return (item as? CommonSectionData)?.sectionID
            case .service2: return (item as? ServiceData)?.secret
            case .info: return ""
            default: return nil
            }
        }() else { return nil }
        
        switch type {
        case .section:
            guard let new = item as? CommonSectionData else { return nil }
            return SectionRecord.create(sectionID: new.sectionID, title: new.name, order: index, zoneID: zoneID)
            
        case .service2:
            guard let new = item as? ServiceData,
                  let list = (allItems as? [ServiceData]),
                  let data = new.secret.data(using: .utf8),
                  let ref = encryption.encrypt(with: embedded, data: data) else {
                Log("ItemHandler - Can't create CKRecord with ServiceData", module: .cloudSync)
                Log("ItemHandler - Can't create CKRecord with ServiceData: \(item)", module: .cloudSync, save: false)
                return nil
            }
            guard new.secret.isValidSecret() else {
                // swiftlint:disable line_length
                Log("ItemHandler - Preparation: new service - can't create - can't be used as recordId", module: .cloudSync)
                logHandler.delete(identifiedBy: new.secret)
                // swiftlint:enable line_length
                secretError?(new.name)
                return nil
            }
            let sectionOrder = Dictionary(grouping: list, by: { $0.sectionID })[new.sectionID]?
                .firstIndex(where: { $0.secret == entityID }) ?? 0
            
            return ServiceRecord2.create(
                zoneID: zoneID,
                name: new.name,
                secret: ref.data,
                unencryptedSecret: new.secret,
                serviceTypeID: new.serviceTypeID?.uuidString,
                additionalInfo: new.additionalInfo,
                rawIssuer: new.rawIssuer,
                otpAuth: new.otpAuth,
                tokenPeriod: new.tokenPeriod?.rawValue,
                tokenLength: new.tokenLength.rawValue,
                badgeColor: new.badgeColor?.rawValue,
                iconType: new.iconType.rawValue,
                iconTypeID: new.iconTypeID.uuidString,
                labelColor: new.labelColor.rawValue,
                labelTitle: new.labelTitle,
                sectionID: new.sectionID?.uuidString,
                sectionOrder: sectionOrder,
                algorithm: new.algorithm.rawValue,
                counter: new.counter,
                tokenType: new.tokenType.rawValue,
                source: new.source.rawValue,
                reference: ref.reference
            )
        case .info:
            guard let new = item as? Info else { return nil }
            return InfoRecord.create(
                zoneID: zoneID,
                version: new.version,
                encryption: new.encyption.rawValue,
                allowedDevices: [allowedDevicesNone],
                enableWatch: false
            )
        default: return nil
        }
    }
}

extension ItemHandler {
    func allEntityRecordIDs(zoneID: CKRecordZone.ID) -> [CKRecord.ID] {
        sectionHandler.listAll().map({ SectionRecord.recordID(with: $0.sectionID, zoneID: zoneID) }) +
        serviceHandler.listAll().map({ ServiceRecord2.recordID(with: $0.secret, zoneID: zoneID) }) +
        [InfoRecord.recordID(with: "", zoneID: zoneID)]
    }
}
