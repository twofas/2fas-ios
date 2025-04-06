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
    private let itemHandler: ItemHandler
    private let commonItemHandler: CommonItemHandler
    private let cloudKit: CloudKit
    private let modificationQueue: ModificationQueue
    private let mergeHandler: MergeHandler
    private let migrationHandler: MigrationHandling
    private let requirementCheck: RequirementCheckHandler
    
    private var isSyncing = false
    private var applyingChanges = false
        
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
        itemHandler: ItemHandler,
        commonItemHandler: CommonItemHandler,
        logHandler: LogHandler,
        cloudKit: CloudKit,
        modificationQueue: ModificationQueue,
        mergeHandler: MergeHandler,
        migrationHandler: MigrationHandling,
        requirementCheck: RequirementCheckHandler
    ) {
        self.itemHandler = itemHandler
        self.commonItemHandler = commonItemHandler
        self.logHandler = logHandler
        self.cloudKit = cloudKit
        self.modificationQueue = modificationQueue
        self.mergeHandler = mergeHandler
        self.migrationHandler = migrationHandler
        self.requirementCheck = requirementCheck
        
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
            guard self?.isSyncing == true else { return }
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
        modificationQueue.clear()
        
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
        
        modificationQueue.clear()
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
        guard isSyncing else { return }
        Log("SyncHandler - method: fetch finished successfuly", module: .cloudSync)
        
        guard !requirementCheck.checkIfStopSync(
            using: itemHandler.updatedCreated,
            migrationPending: migrationHandler.isMigrating
        ) else {
            clearCacheAndDisable()
            return
        }
        
        Log("SyncHandler - commiting iCloud state into item handler", module: .cloudSync)
        itemHandler.commit(ignoreRemovals: migrationHandler.isMigrating)
        migrationHandler.itemsCommited()
        
        if !itemHandler.isCacheEmpty && migrationHandler.checkIfMigrationNeeded() { // if pending - send changes to server and break cycle
            Log("SyncHandler - migration needed", module: .cloudSync)
            let (recordIDsToDeleteOnServer, recordsToModifyOnServer) = migrationHandler.migrate()
            itemHandler.cleanUp()
            
            Log("SyncHandler - Sending migrated changes", module: .cloudSync)
            applyingChanges = true
            
            modificationQueue.setRecordsToModifyOnServer(recordsToModifyOnServer, deleteIDs: recordIDsToDeleteOnServer)
            let current = modificationQueue.currentBatch()
            cloudKit.modifyRecord(recordsToSave: current.modify, recordIDsToDelete: current.delete)

            return
        }
        
        itemHandler.cleanUp()
    
        Log("SyncHandler -  method: fetch finished successfuly - is syncing now", module: .cloudSync)
        guard mergeHandler.hasChanges else {
            Log("SyncHandler - No logs with changes. Exiting", module: .cloudSync)
            applyingChanges = false
            syncCompleted()
            return
        }
        
        let (recordIDsToDeleteOnServer, recordsToModifyOnServer) = mergeHandler.merge()
        
        guard recordIDsToDeleteOnServer != nil || recordsToModifyOnServer != nil else {
            Log("SyncHandler - Nothing to delete or modify", module: .cloudSync)
            logHandler.deleteAll()
            applyingChanges = false
            syncCompleted()
            return
        }
        Log("SyncHandler - Sending changes", module: .cloudSync)
        applyingChanges = true
        
        modificationQueue.setRecordsToModifyOnServer(recordsToModifyOnServer, deleteIDs: recordIDsToDeleteOnServer)
        let current = modificationQueue.currentBatch()
        cloudKit.modifyRecord(recordsToSave: current.modify, recordIDsToDelete: current.delete)
    }
    
    private func changesSavedSuccessfuly() {
        guard isSyncing, applyingChanges else { return }
        modificationQueue.prevBatchProcessed()
        
        if modificationQueue.finished {
            Log("SyncHandler - All Changes Saved Successfuly", module: .cloudSync)
            logHandler.deleteAllApplied()
            syncCompleted()
        } else {
            Log("SyncHandler - Batch Changes Saved Successfuly. Preparing next batch", module: .cloudSync)
            let current = modificationQueue.currentBatch()
            cloudKit.modifyRecord(recordsToSave: current.modify, recordIDsToDelete: current.delete)
        }
    }
    
    private func syncCompleted() {
        guard isSyncing else { return }
        Log("SyncHandler - Sync completed, clearing changes for sending", module: .cloudSync)
        isSyncing = false
        
        if logHandler.countNotApplied() > 0 || applyingChanges || migrationHandler.isMigrating {
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
        modificationQueue.clear()
        logHandler.deleteAll()
        itemHandler.purge()
        ConstStorage.clearZone()
    }
    
    private func abortSync() {
        isSyncing = false
        applyingChanges = false
    }
    
    // swiftlint:enable line_length
}
