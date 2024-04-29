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

import UIKit
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif
import CloudKit

final class SyncHandler {
    private let logHandler: LogHandler
    private let itemHandler: ItemHandlerMigrationProxy
    private let commonItemHandler: CommonItemHandler
    private let cloudKit: CloudKit
    
    private var isSyncing = false
    private var applyingChanges = false
    
    private var timeOffset: Int = 0
    
    private var fromNotificationCompletionHandler: ((BackgroundFetchResult) -> Void)?
    
    typealias OtherError = (NSError) -> Void
    
    var startedSync: Callback?
    var finishedSync: Callback?
    var otherError: OtherError?
    var quotaExceeded: Callback?
    var userDisabledCloud: Callback?
    var useriCloudProblem: Callback?
    
    var container: CKContainer { cloudKit.container }
    
    init(
        itemHandler: ItemHandlerMigrationProxy,
        commonItemHandler: CommonItemHandler,
        logHandler: LogHandler,
        cloudKit: CloudKit
    ) {
        self.itemHandler = itemHandler
        self.commonItemHandler = commonItemHandler
        self.logHandler = logHandler
        self.cloudKit = cloudKit
        
        cloudKit.initialize()
        
        cloudKit.deletedEntries = { [weak self] entries in self?.deleteEntries(entries) }
        cloudKit.updatedEntries = { [weak self] entries in self?.updateEntries(entries) }
        cloudKit.fetchFinishedSuccessfuly = { [weak self] in
            #if os(watchOS)
            Log("SyncHandler - WatchOS doesn't modify iCloud - returning", module: .cloudSync)
            self?.itemHandler.commit()
            self?.logHandler.deleteAll()
            self?.applyingChanges = false
            self?.syncCompleted()
            #else
            self?.fetchFinishedSuccessfuly()
            #endif
        }
        cloudKit.changesSavedSuccessfuly = { [weak self] in self?.changesSavedSuccessfuly() }
        cloudKit.abortSync = { [weak self] in self?.abortSync() }
        
        cloudKit.resetStack = { [weak self] in
            Log("SyncHandler - resetStack", module: .cloudSync)
            self?.resetStack()
        }
        cloudKit.userLoggedOut = { [weak self] in
            Log("SyncHandler - userLoggedOut based on error", module: .cloudSync)
            self?.handleNotificationCompletionHandlerError()
            self?.useriCloudProblem?()
        }
        cloudKit.quotaExceeded = { [weak self] in
            Log("SyncHandler - Quota exceeded!", module: .cloudSync)
            self?.handleNotificationCompletionHandlerError()
            self?.quotaExceeded?()
        }
        cloudKit.userDisablediCloud = { [weak self] in
            Log("SyncHandler - User disabled iCloud!", module: .cloudSync)
            self?.handleNotificationCompletionHandlerError()
            self?.userDisabledCloud?()
        }
        cloudKit.useriCloudProblem = { [weak self] in
            Log("SyncHandler - User has problem with iCloud - check settings!", module: .cloudSync)
            self?.handleNotificationCompletionHandlerError()
            self?.useriCloudProblem?()
        }
        cloudKit.deleteAllEntries = { [weak self] in self?.itemHandler.purge() }
    }
    
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (BackgroundFetchResult) -> Void
    ) {
        #if os(iOS)
        let dict = userInfo as! [String: NSObject]
        guard let notification: CKDatabaseNotification = CKNotification(
            fromRemoteNotificationDictionary: dict
        ) as? CKDatabaseNotification else {
            completionHandler(.noData)
            return
        }
        Log("SyncHandler - We have a notification! \(notification)", module: .cloudSync)
        #elseif os(watchOS)
        Log("SyncHandler - We have a notification!", module: .cloudSync)
        #endif
        
        fromNotificationCompletionHandler = completionHandler
        synchronize()
    }
    
    func firstStart() {
        Log("SyncHandler - first start!", module: .cloudSync)
        
        logHandler.deleteAll()
        itemHandler.purge()
        ConstStorage.clearZone()
        
        commonItemHandler.logFirstImport()
    }
    
    func synchronize() {
        guard !isSyncing else {
            Log("SyncHandler - Can't start sync. Already in progress. Exiting", module: .cloudSync)
            return
        }
        Log("SyncHandler - Sync Handler: synchronizing", module: .cloudSync)
        isSyncing = true
        startedSync?()
        
        cloudKit.cloudSync()
    }
    
    func clearCacheAndDisable() {
        Log("SyncHandler - Sync Handler: clearCacheAndDisable", module: .cloudSync)
        isSyncing = false
        applyingChanges = false
        logHandler.deleteAll()
        itemHandler.purge()
        ConstStorage.clearZone()
        cloudKit.clear()
    }
    
    func clearSimulateFirstStart() {
        Log("SyncHandler - Sync Handler: clearSimulateFirstStart", module: .cloudSync)
        ConstStorage.clearZone()
    }
    
    func setTimeOffset(_ offset: Int) {
        timeOffset = offset
    }
    
    // MARK: - Private
    
    private func updateEntries(_ entries: [CKRecord]) {
        Log("SyncHandler - Sync Handler: update entries: \(entries.count)", module: .cloudSync)
        itemHandler.updateOrCreate(with: entries)
    }
    
    private func deleteEntries(_ entries: [(name: String, type: String)]) {
        Log("SyncHandler - Sync Handler: delete entries: \(entries.count)", module: .cloudSync)
        let entries: [EntityOfKind] = entries.compactMap { entityID, type in
            guard let type = RecordType(rawValue: type) else { return nil }
            return (entityID: entityID, type: type)
        }
        itemHandler.deleteEntries(entries)
    }
    
    // swiftlint:disable line_length
    private func fetchFinishedSuccessfuly() {
        itemHandler.commit()
        
        Log("SyncHandler - method: fetch finished successfuly", module: .cloudSync)
        guard isSyncing else { return }
        Log("SyncHandler -  method: fetch finished successfuly - is syncing now", module: .cloudSync)
        guard logHandler.countChanges() > 0 else {
            Log("SyncHandler - No logs with changes. Exiting", module: .cloudSync)
            applyingChanges = false
            syncCompleted()
            return
        }
        
        LogZoneStart()
        Log("Starting sync", module: .cloudSync)
        
        // Add items from migration before we get all items
        commonItemHandler.setItemsFromMigration(itemHandler.servicesToAppend())
        
        let changes = logHandler.listAllActions()
        let current = commonItemHandler.getAllItems()
        
        // If in migration then we're removing from current cache Service2, otherwise they'll be removed -> same entityID as Service1
        // They will be force-added as Service2
        let currentCache = itemHandler.listAllCommonItems()
        var listToSend = currentCache
        
        var deleteRecordsIDs: [CKRecord.ID] = itemHandler.itemsToDeleteAfterMigration()
        var recordsToModify: [CKRecord] = []
        
        if let deleted = changes[.deleted] {
            let deletedEntities: [EntityOfKind] = deleted.compactMap { item in
                guard let type = RecordType(rawValue: item.kind) else { return nil }
                return (entityID: item.entityID, type: type)
            }
            deleteRecordsIDs += itemHandler.findItemsRecordIDs(for: deletedEntities, zoneID: cloudKit.zoneID)
            Log("SyncHandler - Deletition: Removing services logged: \(deleted.count), existing in cloud: \(deleteRecordsIDs.count)", module: .cloudSync)
            listToSend = itemHandler.filterDeleted(from: currentCache, deleted: deletedEntities)
        }
        
        if let created = changes[.created] {
            created.forEach { newLogEntry in
                if let type = RecordType(rawValue: newLogEntry.kind) {
                    if let cloudEntry = itemHandler.findItemForEntryID(newLogEntry.entityID, type: type, in: currentCache) {
                        Log("SyncHandler - Creation: Item already exists - merging", module: .cloudSync)
                        guard let currentEntry = itemHandler.findItemForEntryID(newLogEntry.entityID, type: type, in: current) else {
                            Log("SyncHandler - Creation: Can't find new entry in local database!", module: .cloudSync)
                            return
                        }
                        guard currentEntry != cloudEntry else {
                            Log("SyncHandler - Creation: Item already in place and identical to the one in the cloud", module: .cloudSync)
                            return
                        }
                        if dateOffsetet(for: newLogEntry) > cloudEntry.comparisionDate {
                            Log("SyncHandler - Creation: New entry newer than the cloud one", module: .cloudSync)
                            var list = listToSend[type] ?? []
                            if currentEntry.index == cloudEntry.index {
                                Log("SyncHandler - Creation: Inserting in the same order", module: .cloudSync)
                                list[cloudEntry.index] = currentEntry.item
                            } else {
                                Log("SyncHandler - Creation: Moving to new order", module: .cloudSync)
                                list.safeRemoval(at: cloudEntry.index)
                                list.safeInsert(currentEntry.item, at: currentEntry.index)
                            }
                            listToSend[type] = list
                        } else {
                            Log("SyncHandler - Creation: Item exists in cloud and it's newer", module: .cloudSync)
                        }
                    } else {
                        Log("SyncHandler - Creation: Couldn't find service in current cache - trying to create one to send to cloud", module: .cloudSync)
                        guard let entry = itemHandler.findItemForEntryID(newLogEntry.entityID, type: type, in: current) else {
                            Log("SyncHandler - Creation: Can't find new entry in local database which should be added!", module: .cloudSync)
                            return
                        }
                        Log("SyncHandler - Creation: Creating new item at index: \(entry.index)", module: .cloudSync)
                        Log("SyncHandler - the item: \(entry.item)", module: .cloudSync, save: false)
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
                            Log("SyncHandler - Modification: Can't find modified entry in local database!", module: .cloudSync)
                            return
                        }
                        guard currentEntry != cloudEntry else {
                            Log("SyncHandler - Modification: Items already in place", module: .cloudSync)
                            return
                        }
                        if dateOffsetet(for: modifiedLogEntry) > cloudEntry.comparisionDate {
                            var list = listToSend[type] ?? []
                            if currentEntry.index == cloudEntry.index {
                                Log("SyncHandler - Modification: Item in place but overriding with local one", module: .cloudSync)
                                list[cloudEntry.index] = currentEntry.item
                            } else {
                                Log("SyncHandler - Modification: Item overrided with local one", module: .cloudSync)
                                list.safeRemoval(at: cloudEntry.index)
                                list.safeInsert(currentEntry.item, at: currentEntry.index)
                            }
                            listToSend[type] = list
                        } else {
                            Log("SyncHandler - Modification: Items in cloud are newer", module: .cloudSync)
                        }
                    } else {
                        Log("SyncHandler - Modification: Item already removed from cloud", module: .cloudSync)
                    }
                }
            }
        }
        
        for (type, items) in listToSend {
            for (index, item) in items.enumerated() {
                if let elementInCache = itemHandler.findItem(for: item, type: type, in: currentCache) {
                    Log("SyncHandler - Preparation: element in cache", module: .cloudSync)
                    if index != elementInCache.index || !elementInCache.isEqual(to: item) {
                        Log("SyncHandler - Preparation: element has diffrent content or index. Creating from exisiting one", module: .cloudSync)
                        
                        guard let record = itemHandler.record(for: type, item: item, modifiedData: current) else {
                            Log("SyncHandler - Preparation: couldn't create record from exisiting service", module: .cloudSync)
                            continue
                        }
                        recordsToModify.append(record)
                    } else {
                        Log("SyncHandler - Preparation: content and index is the same", module: .cloudSync)
                    }
                } else {
                    Log("SyncHandler - Preparation: new service", module: .cloudSync)
                    
                    guard let record = itemHandler.record(for: type, item: item, index: index, zoneID: cloudKit.zoneID, allItems: items) else { continue }
                    recordsToModify.append(record)
                }
            }
        }
        
        Log("SyncHandler - Marking all as applied", module: .cloudSync)
        logHandler.markAllAsApplied()
        
        let recordIDsToDeleteOnServer = deleteRecordsIDs.isEmpty ? nil : deleteRecordsIDs
        let recordsToModifyOnServer = recordsToModify.isEmpty ? nil : recordsToModify
        
        Log("SyncHandler - Change records: deletition: \(String(describing: recordIDsToDeleteOnServer?.count)), modification: \(String(describing: recordsToModifyOnServer?.count))", module: .cloudSync)
        LogZoneEnd()
        
        guard recordIDsToDeleteOnServer != nil || recordsToModifyOnServer != nil else {
            Log("SyncHandler - Nothing to delete or modify", module: .cloudSync)
            logHandler.deleteAll()
            applyingChanges = false
            syncCompleted()
            return
        }
        Log("SyncHandler - Sending changes", module: .cloudSync)
        applyingChanges = true
        cloudKit.modifyRecord(recordsToSave: recordsToModifyOnServer, recordIDsToDelete: recordIDsToDeleteOnServer)
    }
    
    private func changesSavedSuccessfuly() {
        Log("SyncHandler - Changes Saved Successfuly", module: .cloudSync)
        logHandler.deleteAllApplied()
        syncCompleted()
    }
    
    private func syncCompleted() {
        guard isSyncing else { return }
        Log("SyncHandler - Sync completed, clearing changes for sending", module: .cloudSync)
        isSyncing = false
        
        if logHandler.countNotApplied() > 0 || applyingChanges {
            Log("SyncHandler - New sync on it way. Not applied changes: \(logHandler.countNotApplied()) or need to apply changes: \(applyingChanges)", module: .cloudSync)
            synchronize()
            return
        }
        
        Log("SyncHandler - Sending current cloud state to local database", module: .cloudSync)
        let cloudData = itemHandler.listAllCommonItems()
        let didSetNewData = commonItemHandler.setItems(cloudData)
        Log("SyncHandler - Sync completed! Did set new data: \(didSetNewData)", module: .cloudSync)
        Log("SyncHandler - The data: \(cloudData)", module: .cloudSync, save: false)
        
        if logHandler.countNotApplied() > 0 {
            applyingChanges = true
            Log("SyncHandler - New sync after setting data. Not applied changes: \(logHandler.countNotApplied())", module: .cloudSync)
            synchronize()
            return
        }
        
        if let fromNotificationCompletionHandler {
            if didSetNewData {
                fromNotificationCompletionHandler(.newData)
            } else {
                fromNotificationCompletionHandler(.noData)
            }
            self.fromNotificationCompletionHandler = nil
        }
        
        finishedSync?()
    }
    
    private func handleNotificationCompletionHandlerError() {
        Log("Sync Handler: handleNotificationCompletionHandlerError", module: .cloudSync)
        fromNotificationCompletionHandler?(.failed)
        fromNotificationCompletionHandler = nil
    }
    
    private func resetStack() {
        Log("SyncHandler - Sync Handler: resetStack", module: .cloudSync)
        isSyncing = false
        applyingChanges = false
        logHandler.deleteAll()
        itemHandler.purge()
        ConstStorage.clearZone()
    }
    
    private func dateOffsetet(for logEntity: LogEntity) -> Date {
        logEntity.date.addingTimeInterval(TimeInterval(timeOffset))
    }
    
    private func abortSync() {
        isSyncing = false
        applyingChanges = false
    }
    
    // swiftlint:enable line_length
}
