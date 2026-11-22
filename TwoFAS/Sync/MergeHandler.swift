//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
#elseif os(watchOS)
import CommonWatch
#endif

final class MergeHandler {
    private var timeOffset: Int = 0
    /// See `SyncAccess`: only the services the cloud already has are sent, changed – nothing is created or deleted
    var onlyUpdatesServices = SyncAccess.onlyUpdatesServices

    private let logHandler: LogHandler
    private let commonItemHandler: CommonItemHandler
    private let itemHandler: ItemHandler
    private let zoneManager: ZoneManaging
    
    init(
        logHandler: LogHandler,
        commonItemHandler: CommonItemHandler,
        itemHandler: ItemHandler,
        zoneManager: ZoneManaging
    ) {
        self.logHandler = logHandler
        self.commonItemHandler = commonItemHandler
        self.itemHandler = itemHandler
        self.zoneManager = zoneManager
    }
}

extension MergeHandler {
    func discardChangesNeverSent() {
        guard onlyUpdatesServices else { return }
        for (action, entries) in logHandler.listAllActions() {
            for entry in entries where !(action == .modified && Self.isService(entry.kind)) {
                logHandler.delete(identifiedBy: entry.entityID)
            }
        }
    }
    
    private static func isService(_ kind: String) -> Bool {
        switch RecordType(rawValue: kind) {
        case .service1, .service2, .service3, .service4: true
        default: false
        }
    }
    
    var hasChanges: Bool {
        logHandler.countChanges() > 0
    }
    
    // swiftlint:disable line_length
    func merge() -> (recordIDsToDeleteOnServer: [CKRecord.ID]?, recordsToModifyOnServer: [CKRecord]?) {
        LogZoneStart()
        Log("MergeHandler: Starting sync", module: .cloudSync)
        
        discardChangesNeverSent()
        let changes = logHandler.listAllActions()
        let current = commonItemHandler.getAllItems()
        
        let currentCache = itemHandler.listAllCommonItems()
        var listToSend = currentCache
        
        var deleteRecordsIDs: [CKRecord.ID] = []
        var recordsToModify: [CKRecord] = []
        
        if let deleted = changes[.deleted] {
            let deletedEntities: [EntityOfKind] = deleted.compactMap { item in
                guard let type = RecordType(rawValue: item.kind) else { return nil }
                // Only what the cloud has is removed from it. The record may be gone already – another device
                // deleted the same item, or the record of a deletion is removed "in case there is one" whenever
                // its item exists again – and asking the cloud to delete a record it doesn't have may fail the
                // whole operation, again and again.
                guard itemHandler.findItemForEntryID(item.entityID, type: type, in: currentCache) != nil
                else { return nil }
                return (entityID: item.entityID, type: type)
            }
            deleteRecordsIDs += itemHandler.findItemsRecordIDs(for: deletedEntities, zoneID: zoneManager.currentZoneID)
            Log("MergeHandler: Deletition: Removing services logged: \(deleted.count), existing in cloud: \(deleteRecordsIDs.count)", module: .cloudSync)
            listToSend = itemHandler.filterDeleted(from: currentCache, deleted: deletedEntities)
        }
        
        if let created = changes[.created] {
            created.forEach { newLogEntry in
                if let type = RecordType(rawValue: newLogEntry.kind) {
                    if let cloudEntry = itemHandler.findItemForEntryID(newLogEntry.entityID, type: type, in: currentCache) {
                        Log("MergeHandler: Creation: Item already exists - merging", module: .cloudSync)
                        guard let currentEntry = itemHandler.findItemForEntryID(newLogEntry.entityID, type: type, in: current) else {
                            Log("MergeHandler - Creation: Can't find new entry in local database!", module: .cloudSync)
                            return
                        }
                        guard currentEntry != cloudEntry else {
                            Log("MergeHandler: Creation: Item already in place and identical to the one in the cloud", module: .cloudSync)
                            return
                        }
                        if dateOffsetet(for: newLogEntry) > cloudEntry.comparisionDate {
                            Log("MergeHandler: Creation: New entry newer than the cloud one", module: .cloudSync)
                            var list = listToSend[type] ?? []
                            if type.isDeletion {
                                replaceDeletion(newLogEntry.entityID, with: currentEntry.item, in: &list)
                            } else if currentEntry.index == cloudEntry.index {
                                Log("MergeHandler: Creation: Inserting in the same order", module: .cloudSync)
                                list[cloudEntry.index] = currentEntry.item
                            } else {
                                Log("MergeHandler: Creation: Moving to new order", module: .cloudSync)
                                list.safeRemoval(at: cloudEntry.index)
                                list.safeInsert(currentEntry.item, at: currentEntry.index)
                            }
                            listToSend[type] = list
                        } else {
                            Log("MergeHandler: Creation: Item exists in cloud and it's newer", module: .cloudSync)
                        }
                    } else {
                        Log("MergeHandler: Creation: Couldn't find entity \(type) in current cache - trying to create one to send to cloud", module: .cloudSync)
                        guard let entry = itemHandler.findItemForEntryID(newLogEntry.entityID, type: type, in: current) else {
                            Log("MergeHandler - Creation: Can't find new entry in local database which should be added!", module: .cloudSync, severity: .error)
                            return
                        }
                        Log("MergeHandler: Creation: Creating new item at index: \(entry.index)", module: .cloudSync)
                        #if DEBUG
                        Log("MergeHandler: the item: \(entry.item)", module: .cloudSync, save: false)
                        #endif
                        var list = listToSend[type] ?? []
                        list.safeInsert(entry.item, at: entry.index)
                        listToSend[type] = list
                    }
                }
            }
        }
        
        if let modified = changes[.modified] {
            modified.forEach { modifiedLogEntry in
                if let type = RecordType(rawValue: modifiedLogEntry.kind) {
                    if let cloudEntry = itemHandler.findItemForEntryID(modifiedLogEntry.entityID, type: type, in: listToSend) {
                        guard let currentEntry = itemHandler.findItemForEntryID(modifiedLogEntry.entityID, type: type, in: current) else {
                            Log("MergeHandler: Modification: Can't find modified entry in local database!", module: .cloudSync)
                            return
                        }
                        if onlyUpdatesServices {
                            guard let cloudService = cloudEntry.item as? ServiceData,
                                  let localService = currentEntry.item as? ServiceData,
                                  cloudService.tokenType == .hotp else { return }
                            let counter = max(
                                cloudService.counter ?? TokenType.hotpDefaultValue,
                                localService.counter ?? TokenType.hotpDefaultValue
                            )
                            guard counter != cloudService.counter else { return }
                            var updated = cloudService
                            updated.updateCounter(counter)
                            var list = listToSend[type] ?? []
                            list[cloudEntry.index] = updated
                            listToSend[type] = list
                            return
                        }
                        guard currentEntry != cloudEntry else {
                            Log("MergeHandler: Modification: Items already in place", module: .cloudSync)
                            return
                        }
                        if dateOffsetet(for: modifiedLogEntry) > cloudEntry.comparisionDate {
                            var list = listToSend[type] ?? []
                            if type.isDeletion {
                                replaceDeletion(modifiedLogEntry.entityID, with: currentEntry.item, in: &list)
                            } else if currentEntry.index == cloudEntry.index {
                                Log("MergeHandler: Modification: Item in place but overriding with local one", module: .cloudSync)
                                list[cloudEntry.index] = currentEntry.item
                            } else {
                                Log("MergeHandler: Modification: Item overrided with local one", module: .cloudSync)
                                list.safeRemoval(at: cloudEntry.index)
                                list.safeInsert(currentEntry.item, at: currentEntry.index)
                            }
                            listToSend[type] = list
                        } else {
                            Log("MergeHandler: Modification: Items in cloud are newer", module: .cloudSync)
                        }
                    } else {
                        Log("MergeHandler: Modification: Item already removed from cloud", module: .cloudSync)
                    }
                }
            }
        }
        
        for (type, items) in listToSend {
            for (index, item) in items.enumerated() {
                if let elementInCache = itemHandler.findItem(for: item, type: type, in: currentCache) {
                    Log("MergeHandler: Preparation: element in cache", module: .cloudSync)
                    // The position of a deletion in its list says nothing – only what it holds counts
                    let hasMoved = !type.isDeletion && index != elementInCache.index
                    if hasMoved || !elementInCache.isEqual(to: item) {
                        Log("MergeHandler: Preparation: element has diffrent content or index. Creating from exisiting one", module: .cloudSync)
                        
                        let source = onlyUpdatesServices ? listToSend : current
                        guard let record = itemHandler.record(for: type, item: item, modifiedData: source) else {
                            Log("MergeHandler: Preparation:MergeHandler: Preparation: element has diffrent content or index. Creating from exisiting one couldn't create record from exisiting service", module: .cloudSync)
                            continue
                        }
                        recordsToModify.append(record)
                    } else {
                        Log("MergeHandler: Preparation: content and index is the same", module: .cloudSync)
                    }
                } else {
                    Log("MergeHandler: Preparation: new item", module: .cloudSync)
                    
                    guard let record = itemHandler.record(
                        for: type,
                        item: item,
                        index: index,
                        zoneID: zoneManager.currentZoneID,
                        allItems: items
                    ) else {
                        continue
                    }
                    recordsToModify.append(record)
                }
            }
        }
        
        Log("MergeHandler: Marking all as applied", module: .cloudSync)
        logHandler.markAllAsApplied()
        
        let recordIDsToDeleteOnServer = deleteRecordsIDs.isEmpty ? nil : deleteRecordsIDs
        let recordsToModifyOnServer = recordsToModify.isEmpty ? nil : recordsToModify
        
        Log("MergeHandler: Change records: deletition: \(String(describing: recordIDsToDeleteOnServer?.count)), modification: \(String(describing: recordsToModifyOnServer?.count))", module: .cloudSync)
        LogZoneEnd()
        
        return (recordIDsToDeleteOnServer: recordIDsToDeleteOnServer, recordsToModifyOnServer: recordsToModifyOnServer)
    }
    // swiftlint:enable line_length
    
    /// Puts `item` in the place of the deletion whose record is named `recordName`. Deletions aren't found by an
    /// index – every one of them reports 0.
    private func replaceDeletion(_ recordName: String, with item: Any, in list: inout [Any]) {
        if let index = list.firstIndex(where: { ($0 as? SyncDeletion)?.recordName == recordName }) {
            list[index] = item
        } else {
            list.append(item)
        }
    }
    
    func setTimeOffset(_ offset: Int) {
        timeOffset = offset
    }
    
    private func dateOffsetet(for logEntity: LogEntity) -> Date {
        logEntity.date.addingTimeInterval(TimeInterval(timeOffset))
    }
}
