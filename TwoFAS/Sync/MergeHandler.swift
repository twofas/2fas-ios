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

    private let logHandler: LogHandler
    private let commonItemHandler: CommonItemHandler
    private let itemHandler: ItemHandler
    private let cloudKit: CloudKit
    
    init(
        logHandler: LogHandler,
        commonItemHandler: CommonItemHandler,
        itemHandler: ItemHandler,
        cloudKit: CloudKit
    ) {
        self.logHandler = logHandler
        self.commonItemHandler = commonItemHandler
        self.itemHandler = itemHandler
        self.cloudKit = cloudKit
    }
}

extension MergeHandler {
    var hasChanges: Bool {
        logHandler.countChanges() > 0
    }
    
    // swiftlint:disable line_length
    func merge() -> (recordIDsToDeleteOnServer: [CKRecord.ID]?, recordsToModifyOnServer: [CKRecord]?) {
        LogZoneStart()
        Log("MergeHandler: Starting sync", module: .cloudSync)
        
        let changes = logHandler.listAllActions()
        let current = commonItemHandler.getAllItems()
        
        let currentCache = itemHandler.listAllCommonItems()
        var listToSend = currentCache
        
        var deleteRecordsIDs: [CKRecord.ID] = []
        var recordsToModify: [CKRecord] = []
        
        if let deleted = changes[.deleted] {
            let deletedEntities: [EntityOfKind] = deleted.compactMap { item in
                guard let type = RecordType(rawValue: item.kind) else { return nil }
                return (entityID: item.entityID, type: type)
            }
            deleteRecordsIDs += itemHandler.findItemsRecordIDs(for: deletedEntities, zoneID: cloudKit.zoneID)
            Log("MergeHandler: Deletition: Removing services logged: \(deleted.count), existing in cloud: \(deleteRecordsIDs.count)", module: .cloudSync)
            listToSend = itemHandler.filterDeleted(from: currentCache, deleted: deletedEntities)
        }
        
        if let created = changes[.created] {
            created.forEach { newLogEntry in
                if let type = RecordType(rawValue: newLogEntry.kind) {
                    if let cloudEntry = itemHandler.findItemForEntryID(newLogEntry.entityID, type: type, in: currentCache) {
                        Log("MergeHandler: Creation: Item already exists - merging", module: .cloudSync)
                        guard let currentEntry = itemHandler.findItemForEntryID(newLogEntry.entityID, type: type, in: current) else {
                            Log("SyncHandler - Creation: Can't find new entry in local database!", module: .cloudSync)
                            return
                        }
                        guard currentEntry != cloudEntry else {
                            Log("MergeHandler: Creation: Item already in place and identical to the one in the cloud", module: .cloudSync)
                            return
                        }
                        if dateOffsetet(for: newLogEntry) > cloudEntry.comparisionDate {
                            Log("MergeHandler: Creation: New entry newer than the cloud one", module: .cloudSync)
                            var list = listToSend[type] ?? []
                            if currentEntry.index == cloudEntry.index {
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
                        Log("MergeHandler: Creation: Couldn't find service in current cache - trying to create one to send to cloud", module: .cloudSync)
                        guard let entry = itemHandler.findItemForEntryID(newLogEntry.entityID, type: type, in: current) else {
                            Log("SyncHandler - Creation: Can't find new entry in local database which should be added!", module: .cloudSync)
                            return
                        }
                        Log("MergeHandler: Creation: Creating new item at index: \(entry.index)", module: .cloudSync)
                        Log("MergeHandler: the item: \(entry.item)", module: .cloudSync, save: false)
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
                        guard currentEntry != cloudEntry else {
                            Log("MergeHandler: Modification: Items already in place", module: .cloudSync)
                            return
                        }
                        if dateOffsetet(for: modifiedLogEntry) > cloudEntry.comparisionDate {
                            var list = listToSend[type] ?? []
                            if currentEntry.index == cloudEntry.index {
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
                    if index != elementInCache.index || !elementInCache.isEqual(to: item) {
                        Log("MergeHandler: Preparation: element has diffrent content or index. Creating from exisiting one", module: .cloudSync)
                        
                        guard let record = itemHandler.record(for: type, item: item, modifiedData: current) else {
                            Log("MergeHandler: Preparation: couldn't create record from exisiting service", module: .cloudSync)
                            continue
                        }
                        recordsToModify.append(record)
                    } else {
                        Log("MergeHandler: Preparation: content and index is the same", module: .cloudSync)
                    }
                } else {
                    Log("MergeHandler: Preparation: new service", module: .cloudSync)
                    
                    guard let record = itemHandler.record(for: type, item: item, index: index, zoneID: cloudKit.zoneID, allItems: items) else { continue }
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
    
    func setTimeOffset(_ offset: Int) {
        timeOffset = offset
    }
    
    private func dateOffsetet(for logEntity: LogEntity) -> Date {
        logEntity.date.addingTimeInterval(TimeInterval(timeOffset))
    }
}
