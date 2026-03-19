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
import Sync
import Common

extension MainRepositoryImpl {
    var successSyncDate: Date? {
        userDefaultsRepository.successSyncDate
    }
    
    var secretSyncError: ((String) -> Void)? {
        get {
            cloudHandler.secretSyncError
        }
        set {
            cloudHandler.secretSyncError = newValue
        }
    }
    var isCloudBackupConnected: Bool { cloudHandler.isConnected }
    var isCloudBackupSynced: Bool { cloudHandler.isSynced }
    var cloudCurrentState: CloudState { cloudHandler.currentState.toCloudState }
    
    func registerForCloudStateChanges(_ listener: @escaping CloudStateListener, id: CloudStateListenerID) {
        cloudHandler.registerForStateChange({ listener($0.toCloudState) }, with: id)
        cloudHandler.checkState()
    }
    
    func unregisterForCloudStageChanges(with id: CloudStateListenerID) {
        cloudHandler.unregisterForStateChange(id: id)
    }
    
    func enableCloudBackup() {
        cloudHandler.enable()
    }
    
    func disableCloudBackup() {
        cloudHandler.disable(notify: true)
    }
    
    func clearBackup() {
        cloudHandler.clearBackup()
    }
    
    func debugEraseCloudBackup() {
        cloudHandler.debugErase()
    }
    
    func synchronizeBackup() {
        cloudHandler.synchronize()
    }
    
    func syncDidReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        SyncInstance.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func saveSuccessSyncDate(_ date: Date?) {
        userDefaultsRepository.saveSuccessSyncDate(date)
    }
    
    func syncDebugReloadAllKeys() {
        SyncInstance.debugReloadAllKeys()
    }
    
    // Migration
    
    var cloudShowMigrationToNewestVersion: (() -> Void)? {
        get {
            syncMigration.showMigrationToNewestVersion
        }
        set {
            syncMigration.showMigrationToNewestVersion = newValue
        }
    }
    
    var cloudMigrationEndedSuccessfuly: (() -> Void)? {
        get {
            syncMigration.migrationEndedSuccessfuly
        }
        set {
            syncMigration.migrationEndedSuccessfuly = newValue
        }
    }
    
    var cloudReencryptionEndedSuccessfuly: (() -> Void)? {
        get {
            syncMigration.reencryptionEndedSuccessfuly
        }
        set {
            syncMigration.reencryptionEndedSuccessfuly = newValue
        }
    }
    
    var cloudShowiCloudIsEncryptedByUser: (() -> Void)? {
        get {
            syncMigration.showiCloudIsEncryptedByUser
        }
        set {
            syncMigration.showiCloudIsEncryptedByUser = newValue
        }
    }
    
    var cloudShowiCloudIsEncryptedBySystem: (() -> Void)? {
        get {
            syncMigration.showiCloudIsEncryptedBySystem
        }
        set {
            syncMigration.showiCloudIsEncryptedBySystem = newValue
        }
    }
    
    var cloudShowNeverVersionOfiCloud: (() -> Void)? {
        get {
            syncMigration.showNeverVersionOfiCloud
        }
        set {
            syncMigration.showNeverVersionOfiCloud = newValue
        }
    }
    
    var cloudShowiCloudOverQuota: (() -> Void)? {
        get {
            syncMigration.showiCloudOverQuota
        }
        set {
            syncMigration.showiCloudOverQuota = newValue
        }
    }
    
    var cloudShowMigrationGeneralError: (() -> Void)? {
        get {
            syncMigration.showMigrationGeneralError
        }
        set {
            syncMigration.showMigrationGeneralError = newValue
        }
    }
    
    var cloudShowiCloudDisabledByUser: (() -> Void)? {
        get {
            syncMigration.showiCloudDisabledByUser
        }
        set {
            syncMigration.showiCloudDisabledByUser = newValue
        }
    }
    
    var cloudShowiCloudUserProblem: (() -> Void)? {
        get {
            syncMigration.showiCloudUserProblem
        }
        set {
            syncMigration.showiCloudUserProblem = newValue
        }
    }
    
    var cloudShowiCloudError: ((NSError?) -> Void)? {
        get {
            syncMigration.showiCloudError
        }
        set {
            syncMigration.showiCloudError = newValue
        }
    }
    
    var cloudShowiCloudIncorrectService: ((String) -> Void)? {
        get {
            syncMigration.showiCloudIncorrectSerice
        }
        set {
            syncMigration.showiCloudIncorrectSerice = newValue
        }
    }
    
    func cloudChangePassword(_ password: String) {
        syncMigration.changePassword(password)
    }
    
    func cloudMigrateToSystemPassword() {
        syncMigration.migrateToSystemPassword()
    }
    
    func cloudSwitchLocallyToUseSystemPassword() {
        syncMigration.switchLocallyToUseSystemPassword()
    }
    
    func cloudSetMissingUserPassword(_ password: String) {
        syncMigration.setMissingUserPassword(password)
    }
    
    var cloudCurrentEncryption: CloudEncryptionType? {
        syncMigration.currentEncryption
    }
    
    func cloudVerifyUserPassword(_ password: String) -> Bool {
        syncMigration.verifyUserPassword(password)
    }
    
    // Encryption
    
    func cloudExportKeys() -> (salt: Data, systemKey: Data)? {
        SyncInstance.exportKeys()
    }
    
    func cloudImportKeys(salt: Data, systemKey: Data, password: String?) {
        SyncInstance.importKeys(salt: salt, systemKey: systemKey, password: password)
    }
    
    func cloudPackKeys(salt: Data, systemKey: Data) -> Data? {
        let exchange = CloudKeysExchange(salt: salt, systemKey: systemKey)
        guard let jsonData = try? JSONEncoder().encode(exchange) else {
            Log("Can't create CloudKeysExchange json format", severity: .error)
            return nil
        }
        return jsonData
    }
    
    func cloudUnpackKeys(from jsonData: Data) -> (salt: Data, systemKey: Data)? {
        guard let exchange = try? JSONDecoder().decode(CloudKeysExchange.self, from: jsonData) else {
            Log("Can't unpack CloudKeysExchange from data file", severity: .error)
            return nil
        }
        return (salt: exchange.salt, systemKey: exchange.systemKey)
    }
}
