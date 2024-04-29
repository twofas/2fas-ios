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
}
