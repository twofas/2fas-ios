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
    private let zoneManager: ZoneManaging
    private let deletionHandler: DeletionCacheHandler
    
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
        syncEncryptionHandler: SyncEncryptionHandling,
        zoneManager: ZoneManaging,
        deletionHandler: DeletionCacheHandler
    ) {
        self.deletionHandler = deletionHandler
        self.sectionHandler = sectionHandler
        self.serviceHandler = serviceHandler
        self.infoHandler = infoHandler
        self.logHandler = logHandler
        self.serviceRecordEncryptionHandler = serviceRecordEncryptionHandler
        self.syncEncryptionHandler = syncEncryptionHandler
        self.zoneManager = zoneManager
        
        serviceHandler.encryption = encryption
        serviceHandler.embedded = embedded
    }
}

extension ItemHandler {
    var isCacheEmpty: Bool {
        sectionHandler.listAllCommonSection().isEmpty &&
        serviceHandler.listAll().isEmpty &&
        infoHandler.metadata == nil &&
        deletionHandler.isEmpty
    }
    
    func commit() {
        queuedDeleteEntries(deletedEntries)
        queuedUpdateOrCreate(with: updatedCreated)
    }
    
    func cleanUp() {
        deletedEntries = []
        updatedCreated = []
    }
    
    func commitInfo() {
        if let infoRecord = updatedCreated.first(where: { $0.recordType == RecordType.info.rawValue }) {
            infoHandler.updateUsingRecord(InfoRecord(record: infoRecord))
        }
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
        deletionHandler.purge()
    }
    
    func listAllCommonItems() -> [RecordType: [Any]] {
        var value = [RecordType: [Any]]()
        value[RecordType.section] = sectionHandler.listAllCommonSection()
        let recordType: RecordType = zoneManager.inOldVault ? .service2 : .service3
        value[recordType] = serviceHandler.listAll()
        value[RecordType.info] = infoHandler.prepareForSendoffCachedVersion()
        if zoneManager.usesSealedRecords {
            value[RecordType.deletedService] = deletionHandler.listServices()
            value[RecordType.deletedSection] = cachedSectionDeletions()
        }
        return value
    }
    
    func findItemsRecordIDs(for items: [EntityOfKind], zoneID: CKRecordZone.ID) -> [CKRecord.ID] {
        guard zoneManager.usesSealedRecords else {
            return items.map({ $0.type.recordIDGenerator.recordID(with: $0.entityID, zoneID: zoneID) })
        }
        return items.compactMap { item in
            guard let recordName = sealedRecordName(entityID: item.entityID, type: item.type) else {
                Log("ItemHandler - no record name for an item of \(item.type)", module: .cloudSync, severity: .error)
                return nil
            }
            return CKRecord.ID(recordName: recordName, zoneID: zoneID)
        }
    }
    
    func filterDeleted(from items: [RecordType: [Any]], deleted: [EntityOfKind]) -> [RecordType: [Any]] {
        var items = items
        let recordType: RecordType = zoneManager.inOldVault ? .service2 : .service3
        
        let deletedSections = deleted.filter({ $0.type == .section }).map({ $0.entityID })
        let deletedServices = deleted.filter({ $0.type == recordType }).map({ $0.entityID })
        
        items[.section] = (items[.section] as? [CommonSectionData])?.filter({ !deletedSections.contains($0.sectionID) })
        items[recordType] = (items[recordType] as? [ServiceData])?.filter({ !deletedServices.contains($0.secret) })
        for type in [RecordType.deletedService, .deletedSection] {
            let names = deleted.filter({ $0.type == type }).map({ $0.entityID })
            items[type] = (items[type] as? [SyncDeletion])?.filter({ !names.contains($0.recordName) })
        }
        
        return items
    }
    
    func findItem(for item: Any, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex? {
        guard let entityID = { () -> String? in
            switch type {
            case .section: return (item as? CommonSectionData)?.sectionID
            case .service2: return (item as? ServiceData)?.secret
            case .service3: return (item as? ServiceData)?.secret
            case .info: return ""
            case .deletedService, .deletedSection: return (item as? SyncDeletion)?.recordName
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
        case .deletedService, .deletedSection:
            // A deletion is found by the name of its record. Deletions have no order of their own – the index
            // is always 0, so that a list that grows or shrinks never looks like a change of the others.
            guard let item = (items[type] as? [SyncDeletion])?.first(where: { $0.recordName == entryID })
            else { return nil }
            return .init(index: 0, item: item, type: type)
        default: return nil
        }
    }
    
    func record(for type: RecordType, item: Any, modifiedData from: [RecordType: [Any]]) -> CKRecord? {
        guard let entityID = { () -> String? in
            switch type {
            case .section: return (item as? CommonSectionData)?.sectionID
            case .service2: return (item as? ServiceData)?.secret
            case .service3: return (item as? ServiceData)?.secret
            case .info: return ""
            case .deletedService, .deletedSection: return (item as? SyncDeletion)?.recordName
            default: return nil
            }
        }() else { return nil }
        
        if zoneManager.usesSealedRecords, type != .info {
            return sealedRecord(for: type, entityID: entityID, item: item, modifiedData: from)
        }
        
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
                #if DEBUG
                Log("ItemHandler - Can't create CKRecord with ServiceData: \(item)", module: .cloudSync, save: false)
                #endif
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

        case .service3:
            guard let current = serviceHandler.findService(by: entityID),
                  let list = (from[.service3] as? [ServiceData]),
                  let modified = list.first(where: { $0.secret == entityID })
            else {
                Log("ItemHandler - Can't create CKRecord with ServiceData", module: .cloudSync)
                #if DEBUG
                Log("ItemHandler - Can't create CKRecord with ServiceData: \(item)", module: .cloudSync, save: false)
                #endif
                return nil
            }
            
            return serviceRecordEncryptionHandler.createServiceRecord3(
                from: modified,
                metadata: current.metadata,
                list: list
            )
        case .info:
            return infoHandler.recreate() // already contains changes
        default: return nil
        }
    }
    
    func record(for type: RecordType, item: Any, index: Int, zoneID: CKRecordZone.ID, allItems: [Any]) -> CKRecord? {
        if zoneManager.usesSealedRecords, type != .info {
            return newSealedRecord(for: type, item: item, index: index, zoneID: zoneID, allItems: allItems)
        }
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
                #if DEBUG
                Log("ItemHandler - Can't create CKRecord with ServiceData: \(item)", module: .cloudSync, save: false)
                #endif
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
                .firstIndex(where: { $0.secret == new.secret }) ?? 0
            
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

        case .service3:
            guard let new = item as? ServiceData,
                  let list = (allItems as? [ServiceData]) else {
                Log("ItemHandler - Can't create CKRecord with ServiceData", module: .cloudSync)
                #if DEBUG
                Log("ItemHandler - Can't create CKRecord with ServiceData: \(item)", module: .cloudSync, save: false)
                #endif
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
            case .service4:
                guard let identifierKey = syncEncryptionHandler.identifierKey else { return }
                serviceHandler.delete(recordName: entryID, identifierKey: identifierKey)
            case .section2:
                guard let identifierKey = syncEncryptionHandler.identifierKey else { return }
                sectionHandler.delete(recordName: entryID, identifierKey: identifierKey)
            case .deletedService:
                guard let identifier = SyncDeletion.identifier(recordName: entryID) else { return }
                deletionHandler.deleteService(identifier: identifier)
            case .deletedSection:
                cachedSectionDeletions().filter({ $0.recordName == entryID }).compactMap(\.sectionID)
                    .forEach { deletionHandler.deleteSection(sectionID: $0) }
            default: break
            }
        }
        deletionHandler.save()
    }
    
    func queuedUpdateOrCreate(with entries: [CKRecord]) {
        // The Info record first: it carries the identifier key the sealed records of the same fetch are checked
        // with
        let isInfo: (CKRecord) -> Bool = { $0.recordType == RecordType.info.rawValue }
        (entries.filter(isInfo) + entries.filter { !isInfo($0) }).forEach { record in
            if let recordType = RecordType(rawValue: record.recordType) {
                switch recordType {
                case .section: sectionHandler.updateOrCreate(with: SectionRecord(record: record), save: false)
                case .service2: serviceHandler.updateOrCreate(with: ServiceRecord2(record: record), save: false)
                case .service3: serviceHandler.updateOrCreate(with: ServiceRecord3(record: record), save: false)
                case .info: infoHandler.updateUsingRecord(InfoRecord(record: record))
                case .service4, .section2, .deletedService, .deletedSection:
                    updateOrCreate(sealed: record, type: recordType)
                default: break
                }
            }
        }
        sectionHandler.saveAfterBatch()
        serviceHandler.saveAfterBatch()
        deletionHandler.save()
    }
}

extension ItemHandler {
    func allEntityRecordIDs(zoneID: CKRecordZone.ID) -> [CKRecord.ID] { // minus Info - it should stay, but empty
        var cached: [EntityOfKind] = sectionHandler.listAll().map({ (entityID: $0.sectionID, type: .section) })
        cached += serviceHandler.listAll().map({ (entityID: $0.secret, type: .service3) })
        if zoneManager.usesSealedRecords {
            cached += deletionHandler.listServices().map({ (entityID: $0.recordName, type: .deletedService) })
            cached += cachedSectionDeletions().map({ (entityID: $0.recordName, type: .deletedSection) })
        }
        let completeList: [CKRecord.ID] = findItemsRecordIDs(for: cached, zoneID: zoneID)
        + updatedCreated.filter({ $0.recordType != RecordType.info.rawValue }).map({ $0.recordID })
        let set = Set(completeList)
        return Array(set)
    }
}

// MARK: - Sealed records (Config.vaultV3)

extension ItemHandler {
    /// Every record of the vault except the Info one, sealed again with the current sync key – for a change of
    /// the key. The records keep their names: the identifier key doesn't change with the sync key.
    func allSealedRecordsRecreated() -> [CKRecord] {
        let cached = listAllCommonItems()
        var records: [CKRecord] = []
        for type in [RecordType.section, .service3, .deletedService, .deletedSection] {
            for item in cached[type] ?? [] {
                if let record = record(for: type, item: item, modifiedData: cached) {
                    records.append(record)
                } else {
                    Log("ItemHandler - can't seal a record of \(type) again", module: .cloudSync, severity: .error)
                }
            }
        }
        return records
    }
}

private extension ItemHandler {
    func cachedSectionDeletions() -> [SyncDeletion] {
        guard let identifierKey = syncEncryptionHandler.identifierKey else { return [] }
        return deletionHandler.listSections { identifierKey.identifier(of: $0, kind: .deletedSection) }
    }
    
    /// The name of the sealed record of an item. `entityID` is what the item is known by in the log: the secret of
    /// a service, the ID of a section, the name of the record of a deletion.
    func sealedRecordName(entityID: String, type: RecordType) -> String? {
        switch type {
        case .info: return Info.id
        case .deletedService, .deletedSection: return entityID
        case .section, .section2:
            return syncEncryptionHandler.identifierKey?.recordName(of: entityID, kind: .section)
        case .service1, .service2, .service3, .service4:
            return syncEncryptionHandler.identifierKey?.recordName(of: entityID.uppercased(), kind: .service)
        }
    }
    
    func sectionOrder(of service: ServiceData, in list: [ServiceData]) -> Int {
        service.order ?? list.sortedBySection[service.sectionID]?
            .firstIndex(where: { $0.secret == service.secret }) ?? 0
    }
    
    /// The record of an item that is in the cloud already, with its new content
    func sealedRecord(for type: RecordType, entityID: String, item: Any, modifiedData from: [RecordType: [Any]]) -> CKRecord? {
        guard let syncKey = syncEncryptionHandler.recordKey else { return nil }
        do {
            switch type {
            case .section:
                guard let current = sectionHandler.findSection(by: entityID),
                      let list = (from[.section] as? [CommonSectionData]),
                      let modified = list.first(where: { $0.sectionID == entityID }),
                      let index = list.firstIndex(where: { $0.sectionID == entityID }) else { return nil }
                return try SealedRecord.recreate(
                    with: current.metadata,
                    type: .section2,
                    content: SectionRecordContent(
                        sectionID: modified.sectionID,
                        title: modified.name,
                        order: index,
                        modifiedAt: modified.modificationDate
                    ),
                    syncKey: syncKey
                )
            case .service2, .service3:
                guard let current = serviceHandler.findService(by: entityID),
                      let list = (from[type] as? [ServiceData]),
                      let modified = list.first(where: { $0.secret == entityID }) else { return nil }
                return try SealedRecord.recreate(
                    with: current.metadata,
                    type: .service4,
                    content: ServiceRecordContent(
                        serviceData: modified,
                        sectionOrder: sectionOrder(of: modified, in: list)
                    ),
                    syncKey: syncKey
                )
            case .deletedService:
                guard let deletion = item as? SyncDeletion,
                      let metadata = deletionHandler.serviceMetadata(identifier: deletion.identifier)
                else { return nil }
                return try SealedRecord.recreate(
                    with: metadata,
                    type: .deletedService,
                    content: DeletedServiceRecordContent(deletedAt: deletion.deletedAt),
                    syncKey: syncKey
                )
            case .deletedSection:
                guard let deletion = item as? SyncDeletion, let sectionID = deletion.sectionID,
                      let metadata = deletionHandler.sectionMetadata(sectionID: sectionID) else { return nil }
                return try SealedRecord.recreate(
                    with: metadata,
                    type: .deletedSection,
                    content: DeletedSectionRecordContent(sectionID: sectionID, deletedAt: deletion.deletedAt),
                    syncKey: syncKey
                )
            default:
                return nil
            }
        } catch {
            Log("ItemHandler - can't seal a record of \(type)", module: .cloudSync, severity: .error)
            return nil
        }
    }
    
    /// The record of an item that isn't in the cloud yet
    func newSealedRecord(for type: RecordType, item: Any, index: Int, zoneID: CKRecordZone.ID, allItems: [Any]) -> CKRecord? {
        guard let syncKey = syncEncryptionHandler.recordKey else { return nil }
        do {
            switch type {
            case .section:
                guard let new = item as? CommonSectionData,
                      let recordName = sealedRecordName(entityID: new.sectionID, type: .section) else { return nil }
                return try SealedRecord.create(
                    type: .section2,
                    recordName: recordName,
                    zoneID: zoneID,
                    content: SectionRecordContent(
                        sectionID: new.sectionID,
                        title: new.name,
                        order: index,
                        modifiedAt: new.modificationDate
                    ),
                    syncKey: syncKey
                )
            case .service2, .service3:
                guard let new = item as? ServiceData, let list = (allItems as? [ServiceData]),
                      let recordName = sealedRecordName(entityID: new.secret, type: .service3) else { return nil }
                return try SealedRecord.create(
                    type: .service4,
                    recordName: recordName,
                    zoneID: zoneID,
                    content: ServiceRecordContent(serviceData: new, sectionOrder: sectionOrder(of: new, in: list)),
                    syncKey: syncKey
                )
            case .deletedService:
                guard let deletion = item as? SyncDeletion else { return nil }
                return try SealedRecord.create(
                    type: .deletedService,
                    recordName: deletion.recordName,
                    zoneID: zoneID,
                    content: DeletedServiceRecordContent(deletedAt: deletion.deletedAt),
                    syncKey: syncKey
                )
            case .deletedSection:
                guard let deletion = item as? SyncDeletion, let sectionID = deletion.sectionID else { return nil }
                return try SealedRecord.create(
                    type: .deletedSection,
                    recordName: deletion.recordName,
                    zoneID: zoneID,
                    content: DeletedSectionRecordContent(sectionID: sectionID, deletedAt: deletion.deletedAt),
                    syncKey: syncKey
                )
            default:
                return nil
            }
        } catch {
            Log("ItemHandler - can't seal a new record of \(type)", module: .cloudSync, severity: .error)
            return nil
        }
    }
    
    /// A sealed record that was fetched. A record that can't be opened, or whose content isn't what its name was
    /// derived from, is ignored – it's not this user's data.
    func updateOrCreate(sealed record: CKRecord, type: RecordType) {
        guard let syncKey = syncEncryptionHandler.recordKey,
              let identifierKey = syncEncryptionHandler.identifierKey else {
            Log("ItemHandler - no key for a sealed record of \(type)", module: .cloudSync, severity: .error)
            return
        }
        let recordName = record.recordID.recordName
        let metadata = record.encodeSystemFields()
        do {
            switch type {
            case .service4:
                let content = try SealedRecord.content(of: record, as: ServiceRecordContent.self, syncKey: syncKey)
                guard identifierKey.recordName(of: content.secret.uppercased(), kind: .service) == recordName else {
                    Log("ItemHandler - a service record with a foreign name", module: .cloudSync, severity: .error)
                    return
                }
                serviceHandler.updateOrCreate(
                    serviceData: content.serviceData(
                        createdAt: record.creationDate ?? Date(),
                        modifiedAt: record.modificationDate ?? Date()
                    ),
                    sectionOrder: content.sectionOrder,
                    metadata: metadata,
                    save: false
                )
            case .section2:
                let content = try SealedRecord.content(of: record, as: SectionRecordContent.self, syncKey: syncKey)
                guard identifierKey.recordName(of: content.sectionID, kind: .section) == recordName else {
                    Log("ItemHandler - a section record with a foreign name", module: .cloudSync, severity: .error)
                    return
                }
                sectionHandler.updateOrCreate(
                    content: content,
                    metadata: metadata,
                    creationDate: record.creationDate ?? Date(),
                    modificationDate: content.modifiedAt ?? record.modificationDate,
                    save: false
                )
            case .deletedService:
                let content = try SealedRecord.content(
                    of: record,
                    as: DeletedServiceRecordContent.self,
                    syncKey: syncKey
                )
                guard let identifier = SyncDeletion.identifier(recordName: recordName) else { return }
                deletionHandler.updateOrCreateService(
                    SyncDeletion(identifier: identifier, deletedAt: content.deletedAt),
                    metadata: metadata
                )
            case .deletedSection:
                let content = try SealedRecord.content(
                    of: record,
                    as: DeletedSectionRecordContent.self,
                    syncKey: syncKey
                )
                guard identifierKey.recordName(of: content.sectionID, kind: .deletedSection) == recordName else {
                    Log("ItemHandler - a deletion record with a foreign name", module: .cloudSync, severity: .error)
                    return
                }
                deletionHandler.updateOrCreateSection(
                    sectionID: content.sectionID,
                    deletedAt: content.deletedAt,
                    metadata: metadata
                )
            default:
                break
            }
        } catch {
            Log("ItemHandler - can't open a sealed record of \(type)", module: .cloudSync, severity: .error)
        }
    }
}
