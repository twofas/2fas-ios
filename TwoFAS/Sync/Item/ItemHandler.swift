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
    private let serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler
    private let syncEncryptionHandler: SyncEncryptionHandling
    
    private let encryption = ExchangeFileEncryption()
    private let embedded = Keys.Sync.key.decrypt()
    
    private var deletedEntries: [EntityOfKind] = []
    private(set) var updatedCreated: [CKRecord] = []
    
    init(
        sectionHandler: SectionHandler,
        serviceHandler: ServiceHandler,
        infoHandler: InfoHandler,
        logHandler: LogHandler,
        serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler,
        syncEncryptionHandler: SyncEncryptionHandling
    ) {
        self.sectionHandler = sectionHandler
        self.serviceHandler = serviceHandler
        self.infoHandler = infoHandler
        self.logHandler = logHandler
        self.serviceRecordEncryptionHandler = serviceRecordEncryptionHandler
        self.syncEncryptionHandler = syncEncryptionHandler
        
        serviceHandler.encryption = encryption
        serviceHandler.embedded = embedded
    }
}

extension ItemHandler {
    var isCacheEmpty: Bool {
        sectionHandler.listAllCommonSection().isEmpty &&
        serviceHandler.listAll().isEmpty &&
        infoHandler.metadata == nil
    }
    
    func commit(ignoreRemovals: Bool = false) {
        if !ignoreRemovals {
            queuedDeleteEntries(deletedEntries)
        }
        queuedUpdateOrCreate(with: updatedCreated)
    }
    
    func cleanUp() {
        deletedEntries = []
        updatedCreated = []
    }
    
    func deleteEntries(_ entries: [EntityOfKind]) {
        deletedEntries = entries
    }
    
    func updateOrCreate(with entries: [CKRecord]) {
        updatedCreated = entries
    }
    
    func purge() {
        Log("ItemHandler - Purging section handler and service handler", module: .cloudSync)
        sectionHandler.purge()
        serviceHandler.purge()
        infoHandler.purge()
    }
    
    func listAllCommonItems() -> [RecordType: [Any]] {
        var value = [RecordType: [Any]]()
        value[RecordType.section] = sectionHandler.listAllCommonSection()
        value[RecordType.service3] = serviceHandler.listAll()
        value[RecordType.info] = infoHandler.prepareForSendoff()
        return value
    }
    
    func findItemsRecordIDs(for items: [EntityOfKind], zoneID: CKRecordZone.ID) -> [CKRecord.ID] {
        items.map({ $0.type.recordIDGenerator.recordID(with: $0.entityID, zoneID: zoneID) })
    }
    
    func filterDeleted(from items: [RecordType: [Any]], deleted: [EntityOfKind]) -> [RecordType: [Any]] {
        var items = items
        
        let deletedSections = deleted.filter({ $0.type == .section }).map({ $0.entityID })
        let deletedServices = deleted.filter({ $0.type == .service3 }).map({ $0.entityID })
        
        items[.section] = (items[.section] as? [CommonSectionData])?.filter({ !deletedSections.contains($0.sectionID) })
        items[.service3] = (items[.service3] as? [ServiceData])?.filter({ !deletedServices.contains($0.secret) })
        
        return items
    }
    
    func findItem(for item: Any, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex? {
        guard let entityID = { () -> String? in
            switch type {
            case .section: return (item as? CommonSectionData)?.sectionID
            case .service2: return (item as? ServiceData)?.secret
            case .service3: return (item as? ServiceData)?.secret
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
        case .service3:
            guard
                let list = (items[.service3] as? [ServiceData]),
                let item = list.first(where: { $0.secret == entryID }),
                let index = list.firstIndex(where: { $0.secret == entryID })
            else { return nil }
            return .init(index: index, item: item, type: .service3)
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
            case .service3: return (item as? ServiceData)?.secret
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
            
        case .service3:
            guard let current = serviceHandler.findService(by: entityID),
                  let list = (from[.service3] as? [ServiceData]),
                  let modified = list.first(where: { $0.secret == entityID })
            else {
                Log("ItemHandler - Can't create CKRecord with ServiceData", module: .cloudSync)
                Log("ItemHandler - Can't create CKRecord with ServiceData: \(item)", module: .cloudSync, save: false)
                return nil
            }
            
            return serviceRecordEncryptionHandler.createServiceRecord3(
                from: modified,
                metadata: current.metadata,
                list: list
            )
        case .info:
            return infoHandler.recreate()
        default: return nil
        }
    }
    
    func record(for type: RecordType, item: Any, index: Int, zoneID: CKRecordZone.ID, allItems: [Any]) -> CKRecord? {
        switch type {
        case .section:
            guard let new = item as? CommonSectionData else { return nil }
            return SectionRecord.create(sectionID: new.sectionID, title: new.name, order: index, zoneID: zoneID)
            
        case .service3:
            guard let new = item as? ServiceData,
                  let list = (allItems as? [ServiceData]) else {
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
            
            return serviceRecordEncryptionHandler.createServiceRecord3(from: new, metadata: nil, list: list)
        case .info:
            return infoHandler.createNew(encryptionReference: syncEncryptionHandler.encryptionReference ?? Data())
        default: return nil
        }
    }
}

private extension ItemHandler {
    func queuedDeleteEntries(_ entries: [EntityOfKind]) {
        entries.forEach { entryID, type in
            switch type {
            case .section: sectionHandler.delete(identifiedBy: entryID)
            case .service2: serviceHandler.delete(identifiedBy: entryID)
            case .service3: serviceHandler.delete(identifiedBy: entryID)
            case .info: infoHandler.purge()
            default: break
            }
        }
    }
    
    func queuedUpdateOrCreate(with entries: [CKRecord]) {
        entries.forEach { record in
            if let recordType = RecordType(rawValue: record.recordType) {
                switch recordType {
                case .section: sectionHandler.updateOrCreate(with: SectionRecord(record: record), save: false)
                case .service2: serviceHandler.updateOrCreate(with: ServiceRecord2(record: record), save: false)
                case .service3: serviceHandler.updateOrCreate(with: ServiceRecord3(record: record), save: false)
                case .info: infoHandler.updateUsingRecord(InfoRecord(record: record))
                default: break
                }
            }
        }
        sectionHandler.saveAfterBatch()
        serviceHandler.saveAfterBatch()
    }
}

extension ItemHandler {
    func allEntityRecordIDs(zoneID: CKRecordZone.ID) -> [CKRecord.ID] {
        sectionHandler.listAll().map({ SectionRecord.recordID(with: $0.sectionID, zoneID: zoneID) }) +
        serviceHandler.listAll().map({ ServiceRecord3.recordID(with: $0.secret, zoneID: zoneID) }) +
        [InfoRecord.recordID(with: "", zoneID: zoneID)]
    }
}
