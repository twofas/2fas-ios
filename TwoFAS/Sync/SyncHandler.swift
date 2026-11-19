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
import CoreData

final class SyncHandler {
    private let logHandler: LogHandler
    private let itemHandler: ItemHandler
    private let commonItemHandler: CommonItemHandler
    private let cloudKit: CloudKit
    private let modificationQueue: ModificationQueue
    private let mergeHandler: MergeHandler
    private let migrationHandler: MigrationHandling
    private let requirementCheck: RequirementCheckHandling
    private let reencryptionHandler: ReencryptionHandling
    private let localReset: SyncLocalReset
    private let isSyncDeferred: Bool
    private let syncContext: () -> NSManagedObjectContext
    private let infoHandler: InfoHandler
    private let zoneManager: ZoneManaging
    private let syncEncryptionHandler: SyncEncryptionHandling
    
    /// Called when this device starts writing a vault of sealed records it migrated the data to
    var willStartSealedVault: Callback?
    /// Called after a completed sync with the current vault while the older vaults weren't retired yet
    var retireOldVaults: Callback?
    
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
    
    /// - Parameter isSyncDeferred: Sync doesn't run in this launch – a stack was opened in memory because its migration
    ///   was deferred. `firstStart()` only schedules a reset then.
    /// - Parameter syncContext: The context of the Sync store. Evaluated lazily – the store is loaded (and migrated)
    ///   only on first use.
    init(
        itemHandler: ItemHandler,
        commonItemHandler: CommonItemHandler,
        logHandler: LogHandler,
        cloudKit: CloudKit,
        modificationQueue: ModificationQueue,
        mergeHandler: MergeHandler,
        migrationHandler: MigrationHandling,
        requirementCheck: RequirementCheckHandling,
        reencryptionHandler: ReencryptionHandling,
        localReset: SyncLocalReset,
        isSyncDeferred: Bool,
        syncContext: @autoclosure @escaping () -> NSManagedObjectContext,
        infoHandler: InfoHandler,
        zoneManager: ZoneManaging,
        syncEncryptionHandler: SyncEncryptionHandling
    ) {
        self.infoHandler = infoHandler
        self.zoneManager = zoneManager
        self.syncEncryptionHandler = syncEncryptionHandler
        self.itemHandler = itemHandler
        self.commonItemHandler = commonItemHandler
        self.logHandler = logHandler
        self.cloudKit = cloudKit
        self.modificationQueue = modificationQueue
        self.mergeHandler = mergeHandler
        self.migrationHandler = migrationHandler
        self.requirementCheck = requirementCheck
        self.reencryptionHandler = reencryptionHandler
        self.localReset = localReset
        self.isSyncDeferred = isSyncDeferred
        self.syncContext = syncContext
        
        cloudKit.initialize()
        
        cloudKit.deletedEntries = { [weak self] entries in self?.deleteEntries(entries) }
        cloudKit.updatedEntries = { [weak self] entries in self?.updateEntries(entries) }
        cloudKit.fetchFinishedSuccessfuly = { [weak self] in self?.fetchFinishedSuccessfuly() }
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
            // Sync stays enabled and is tried again later: it mustn't be left as still in progress, and the log of
            // the changes waiting to be sent is kept
            self?.isSyncing = false
            self?.applyingChanges = false
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
        migrationHandler.clearCloudState = { [weak self] in
            self?.resetStack()
            self?.commonItemHandler.logFirstImport()
        }
        migrationHandler.setFirstStart = { [weak self] in
            self?.resetStack()
            self?.isSyncing = true
            self?.commonItemHandler.logFirstImport()
        }
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
        SyncStoreIntegrity.startFromScratch(on: syncContext(), isDeferred: isSyncDeferred) {
            logHandler.deleteAll()
            itemHandler.purge()
            ConstStorage.clearZone()
            modificationQueue.clear()
            
            commonItemHandler.logFirstImport()
        }
    }
    
    func synchronize() {
        let cipherState = SyncStoreIntegrity.cipherState(of: syncContext())
        // Before anything reads the cache – never while a sync is in progress, as that one still uses the cache
        let preflight = SyncPreflight.decide(
            cipherState: cipherState,
            isDeferred: isSyncDeferred,
            isSyncing: isSyncing,
            resetRequired: ConstStorage.syncResetRequired,
            isCacheReadable: { SyncStoreIntegrity.verify(context: syncContext()) }
        )
        if let result = preflight.notificationResult {
            completeNotification(with: result)
        }
        switch preflight {
        case .notAllowed:
            Log(
                "SyncHandler - Can't start sync. Local storage key state: \(cipherState), "
                + "deferred for this launch: \(isSyncDeferred). Exiting",
                module: .cloudSync
            )
            return
        case .inProgress:
            Log("SyncHandler - Can't start sync. Already in progress. Exiting", module: .cloudSync)
            return
        case .resetFirst:
            guard resetCache() else {
                completeNotification(with: .failed)
                return
            }
        case .proceed:
            break
        }
        Log("SyncHandler - Sync Handler: synchronizing", module: .cloudSync)
        isSyncing = true
        startedSync?()
        
        Task { @MainActor in
            await migrationHandler.checkIfMigrationNeeded()
            modificationQueue.clear()
            cloudKit.cloudSync()
        }
    }
    
    func clearCacheAndDisable(skipItemsPurge: Bool = false) {
        Log("SyncHandler - Sync Handler: clearCacheAndDisable", module: .cloudSync)
        isSyncing = false
        applyingChanges = false
        logHandler.deleteAll()
        if !skipItemsPurge {
            itemHandler.purge()
        }
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
            migrationPending: migrationHandler.isMigrating,
            encryptionPending: reencryptionHandler.willReencrypt
        ) else {
            itemHandler.commitInfo()
            clearCacheAndDisable(skipItemsPurge: true)
            return
        }
        
        Log("SyncHandler - commiting iCloud state into item handler", module: .cloudSync)
        itemHandler.commit()

        if !itemHandler.isCacheEmpty && !migrationHandler.isMigrating && reencryptionHandler.willReencrypt {
            Log("SyncHandler - reencryption needed", module: .cloudSync)
            let (recordIDsToDeleteOnServer, recordsToModifyOnServer) = reencryptionHandler.listForReencryption()
            itemHandler.cleanUp()
            
            Log("SyncHandler - Sending reencrypted changes", module: .cloudSync)
            applyingChanges = true
            
            modificationQueue.setRecordsToModifyOnServer(recordsToModifyOnServer, deleteIDs: recordIDsToDeleteOnServer)
            let current = modificationQueue.currentBatch()
            cloudKit.modifyRecord(recordsToSave: current.modify, recordIDsToDelete: current.delete)

            return
        }
        
        itemHandler.cleanUp()
        
        guard prepareIdentifierKey() else {
            abortSync()
            handleNotificationCompletionHandlerError()
            return
        }
        
        Log("SyncHandler -  method: fetch finished successfuly - continuing to sync with data", module: .cloudSync)
        guard mergeHandler.hasChanges else {
            Log("SyncHandler - No logs with changes. Exiting", module: .cloudSync)
            migrateIfNeeded()
            return
        }
        
        let (recordIDsToDeleteOnServer, recordsToModifyOnServer) = mergeHandler.merge()
        
        guard recordIDsToDeleteOnServer != nil || recordsToModifyOnServer != nil else {
            Log("SyncHandler - Nothing to delete or modify", module: .cloudSync)
            logHandler.deleteAll()
            migrateIfNeeded()
            return
        }
        Log("SyncHandler - Sending changes", module: .cloudSync)
        applyingChanges = true
        
        modificationQueue.setRecordsToModifyOnServer(recordsToModifyOnServer, deleteIDs: recordIDsToDeleteOnServer)
        let current = modificationQueue.currentBatch()
        cloudKit.modifyRecord(recordsToSave: current.modify, recordIDsToDelete: current.delete)
    }
    
    private func migrateIfNeeded() {
        applyingChanges = false
        if migrationHandler.migrateIfNeeded() {
            // The old vault was read – everything it had is set here and then sent to the new one as new items.
            saveCloudDataToLocalDatabase()
            let carriedOver = infoHandler.carriedOver
            resetStack()
            infoHandler.prepareForNewVault(carriedOver)
            willStartSealedVault?()
            commonItemHandler.logFirstImport()
            synchronize()
        } else {
            syncCompleted()
        }
    }
    
    /// In a vault of sealed records every record is named with the identifier key. The cloud gets its first one
    /// from the device that starts the vault (clean, or migrated to) – with the Info record that carries it.
    /// - Returns: `false` when there's no key and none could be created – nothing can be merged then.
    private func prepareIdentifierKey() -> Bool {
        guard zoneManager.usesSealedRecords else { return true }
        if syncEncryptionHandler.identifierKey != nil { return true }
        guard syncEncryptionHandler.createIdentifierKeyIfNeeded() else {
            Log("SyncHandler - No identifier key for the sealed records", module: .cloudSync, severity: .error)
            return false
        }
        Log("SyncHandler - Created the identifier key", module: .cloudSync)
        if infoHandler.metadata != nil {
            // The Info record is in the cloud already – it has to be sent again, with the key
            logHandler.log(entityID: Info.id, actionType: .modified, kind: .info)
        }
        return true
    }
    
    private func changesSavedSuccessfuly() {
        guard isSyncing, applyingChanges else { return }
        modificationQueue.prevBatchProcessed()
        
        if modificationQueue.finished {
            Log("SyncHandler - All Changes Saved Successfuly", module: .cloudSync)
            logHandler.deleteAllApplied()
            reencryptionHandler.changesApplied()
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
        
        if logHandler.countNotApplied() > 0 || applyingChanges {
            Log("SyncHandler - New sync on it way. Not applied changes: \(logHandler.countNotApplied()) or need to apply changes: \(applyingChanges)", module: .cloudSync)
            synchronize()
            return
        }
        
        let didSetNewData = saveCloudDataToLocalDatabase()
        
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
        
        reencryptionHandler.syncSucceded()
        finishedSync?()
        
        // The data is in the current vault and this device is in sync with it – the older vaults can go
        if zoneManager.usesSealedRecords, !ConstStorage.oldVaultsRetired {
            retireOldVaults?()
        }
    }
    
    private func handleNotificationCompletionHandlerError() {
        Log("Sync Handler: handleNotificationCompletionHandlerError", module: .cloudSync)
        fromNotificationCompletionHandler?(.failed)
        fromNotificationCompletionHandler = nil
    }
    
    private func completeNotification(with result: BackgroundFetchResult) {
        fromNotificationCompletionHandler?(result)
        fromNotificationCompletionHandler = nil
    }
    
    /// Resets the cache from scratch (a reset is scheduled or the cache can't be decrypted). `false` when the first
    /// import couldn't be logged or the cache still can't be decrypted afterwards – it mustn't be synced then.
    private func resetCache() -> Bool {
        Log("SyncHandler - Resetting the cache from scratch", module: .cloudSync)
        guard localReset.perform() else { return false }
        guard SyncStoreIntegrity.verify(context: syncContext()) else {
            Log(
                "SyncHandler - Can't start sync. The cache can't be decrypted after a reset",
                module: .cloudSync,
                severity: .error
            )
            ConstStorage.syncResetRequired = true
            return false
        }
        return true
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
    
    @discardableResult
    private func saveCloudDataToLocalDatabase() -> Bool {
        Log("SyncHandler - Sending current cloud state to local database", module: .cloudSync)
        let cloudData = itemHandler.listAllCommonItems()
        // A part of the cache couldn't be decrypted while it was read – it would look like deletions in the cloud
        guard !ConstStorage.syncResetRequired else {
            Log("SyncHandler - The cache can't be decrypted. Not setting data, reset scheduled", module: .cloudSync)
            return false
        }
        let didSetNewData = commonItemHandler.setItems(cloudData)
        Log("SyncHandler - Sync completed! Did set new data: \(didSetNewData)", module: .cloudSync)
        #if DEBUG
        Log("SyncHandler - The data: \(cloudData)", module: .cloudSync, save: false)
        #endif
        return didSetNewData
    }
    
    // swiftlint:enable line_length
}
