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
    private let cloudKit: CloudKitSyncing
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
    /// Called after a completed sync with the current vault while the older vaults, migrated by this device,
    /// weren't retired yet
    var retireOldVaults: Callback?
    
    /// See `SyncAccess`
    var onlyUpdatesServices = SyncAccess.onlyUpdatesServices {
        didSet {
            mergeHandler.onlyUpdatesServices = onlyUpdatesServices
            commonItemHandler.mirrorsTheVault = onlyUpdatesServices
        }
    }
    
    /// The identifier key of the sealed records can't be opened and none can be created – nothing can be merged
    var identifierKeyUnavailable: Callback?
    /// Records of the vault couldn't be opened with the keys of this device – the backup stopped
    var unreadableRecordsFound: Callback?
    
    private var isSyncing = false
    private var applyingChanges = false
    /// Checks of the vaults that failed in a row – the next one waits longer
    private var failedVaultChecks = 0
    /// Identifies the retry that is scheduled after a failed check. `nil` – none, or it was called off (the
    /// backup was turned off in the meantime).
    private var vaultCheckRetry: UUID?
        
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
        cloudKit: CloudKitSyncing,
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
        cloudKit.abortSync = { [weak self] in
            self?.abortSync()
            // A sync started by a push has to say that it ended, also when it ended with nothing
            self?.completeNotification(with: .failed)
        }
        
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
            self?.logFirstImport()
        }
        migrationHandler.setFirstStart = { [weak self] in
            self?.resetStack()
            self?.isSyncing = true
            self?.logFirstImport()
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
            cloudKit.resetTokens()
            modificationQueue.clear()
            
            logFirstImport()
        }
    }
    
    /// - Returns: `false` when the sync didn't start and won't on its own: the key of the local storage isn't
    ///   available, or the cache couldn't be reset. A sync that is already in progress counts as started.
    @discardableResult
    func synchronize() -> Bool {
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
            return false
        case .inProgress:
            Log("SyncHandler - Can't start sync. Already in progress. Exiting", module: .cloudSync)
            return true
        case .resetFirst:
            guard resetCache() else {
                completeNotification(with: .failed)
                return false
            }
        case .proceed:
            break
        }
        Log("SyncHandler - Sync Handler: synchronizing", module: .cloudSync)
        // This sync checks the vaults itself
        vaultCheckRetry = nil
        isSyncing = true
        startedSync?()
        
        // The sync is started where it was asked for – on the main queue
        Task { @MainActor in
            guard await migrationHandler.checkIfMigrationNeeded() else {
                vaultCheckFailed()
                return
            }
            failedVaultChecks = 0
            modificationQueue.clear()
            if infoHandler.metadata == nil {
                // Nothing is known about the vault: only a fetch of everything may say that it's empty. With
                // tokens left from before, the fetch would bring "nothing new" and an empty cache would be taken
                // for a clean cloud – everything would be sent as new, over what is there.
                cloudKit.resetTokens()
            }
            cloudKit.cloudSync()
        }
        return true
    }
    
    /// The iCloud account changed – what was known about its vaults doesn't apply any more
    func accountChanged() {
        migrationHandler.accountChanged()
    }
    
    /// Which vault has the data couldn't be checked (no network, the service unavailable): this sync ends here,
    /// with nothing read and nothing written, and is tried again later – like any other error that passes on
    /// its own. The backup isn't turned off and nothing is cleared.
    private func vaultCheckFailed() {
        abortSync()
        completeNotification(with: .failed)
        let delay = CloudKitRetryBackoff.delay(for: 2, consecutiveRetries: failedVaultChecks)
        failedVaultChecks += 1
        Log("SyncHandler - the vaults couldn't be checked. Trying again in \(delay)", module: .cloudSync, severity: .error)
        let retry = UUID()
        vaultCheckRetry = retry
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, vaultCheckRetry == retry else { return }
            vaultCheckRetry = nil
            synchronize()
        }
    }
    
    func clearCacheAndDisable(skipItemsPurge: Bool = false) {
        Log("SyncHandler - Sync Handler: clearCacheAndDisable", module: .cloudSync)
        vaultCheckRetry = nil
        isSyncing = false
        applyingChanges = false
        logHandler.deleteAll()
        if !skipItemsPurge {
            itemHandler.purge()
        }
        cloudKit.resetTokens()
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
        
        if migrationHandler.isMigrating, isFetchedVaultRetired {
            // Another device migrated this vault and retired it while this one was about to do the same. Not a
            // newer version of the app: the data is in the current vault, which the next check finds.
            Log("SyncHandler - the vault being migrated was retired, starting over", module: .cloudSync)
            migrationHandler.restartAfterVaultWasRetired()
            resetStack()
            logFirstImport()
            synchronize()
            return
        }
        
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
        
        guard itemHandler.unreadableRecords == 0 else {
            // What was read isn't all the vault has (another device is changing the password, a record is
            // damaged or isn't this user's): taken for the whole of it, the records that couldn't be read would
            // look deleted, or be sent again over what is there. The backup stops, with nothing changed.
            Log(
                "SyncHandler - \(itemHandler.unreadableRecords) records of the vault can't be read. Stopping",
                module: .cloudSync,
                severity: .error
            )
            itemHandler.cleanUp()
            handleNotificationCompletionHandlerError()
            clearCacheAndDisable()
            unreadableRecordsFound?()
            return
        }

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
            // Stopped the way a missing key stops it: with a state the user sees, instead of a sync left as
            // "in progress" that ends the same way every time
            handleNotificationCompletionHandlerError()
            clearCacheAndDisable(skipItemsPurge: true)
            identifierKeyUnavailable?()
            return
        }
        
        Log("SyncHandler -  method: fetch finished successfuly - continuing to sync with data", module: .cloudSync)
        mergeHandler.discardChangesNeverSent()
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
            logFirstImport()
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
        // Created only by a device that may start a vault
        guard !onlyUpdatesServices else { return true }
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
        mergeHandler.discardChangesNeverSent()
        
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
        if zoneManager.usesSealedRecords, ConstStorage.oldVaultsRetirementPending {
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
        cloudKit.resetTokens()
    }
    
    /// The Info record that was just fetched says its vault was retired
    private var isFetchedVaultRetired: Bool {
        itemHandler.updatedCreated.contains { record in
            RecordType(rawValue: record.recordType) == .info
                && record[InfoEntryKey.version.rawValue] as? Int == Info.retiredVersion
        }
    }
    
    /// The local data is announced to the cloud as new – never by a device that only reads the vault
    private func logFirstImport() {
        guard !onlyUpdatesServices else { return }
        commonItemHandler.logFirstImport()
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
