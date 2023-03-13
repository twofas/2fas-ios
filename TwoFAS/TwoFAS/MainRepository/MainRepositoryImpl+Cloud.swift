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
import Sync

enum CloudState: Equatable {
    enum NotAvailableReason: Equatable {
        case overQuota
        case disabledByUser
        case error(error: NSError?)
        case useriCloudProblem
        case other
        case newerVersion
        case incorrectService(serviceName: String)
        case cloudEncrypted
    }
    
    enum Sync: Equatable {
        case syncing
        case synced
    }
    
    case unknown
    case disabledNotAvailable(reason: NotAvailableReason)
    case disabledAvailable
    case enabled(sync: Sync)
}

extension MainRepositoryImpl {
    var secretSyncError: ((String) -> Void)? {
        get {
            sync.secretSyncError
        }
        set {
            sync.secretSyncError = newValue
        }
    }
    var isCloudBackupConnected: Bool { cloudHandler.isConnected }
    var cloudCurrentState: CloudState { cloudCurrentStateToCloudState(cloudHandler.currentState) }
    
    func registerForCloudStateChanges(_ listener: @escaping CloudStateListener, id: CloudStateListenerID) {
        cloudHandler.registerForStateChange({ [weak self] cloudCurrentState in
            guard let cloudState = self?.cloudCurrentStateToCloudState(cloudCurrentState) else { return }
            listener(cloudState)
        }, with: id)
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
}

private extension MainRepositoryImpl {
    func cloudCurrentStateToCloudState(_ cloudCurrentState: CloudCurrentState) -> CloudState {
        switch cloudCurrentState {
        case .unknown:
            return .unknown
        case .disabledNotAvailable(let reason):
            switch reason {
            case .overQuota:
                return .disabledNotAvailable(reason: .overQuota)
            case .disabledByUser:
                return .disabledNotAvailable(reason: .disabledByUser)
            case .error(let error):
                return .disabledNotAvailable(reason: .error(error: error))
            case .useriCloudProblem:
                return .disabledNotAvailable(reason: .useriCloudProblem)
            case .other:
                return .disabledNotAvailable(reason: .other)
            case .incorrectService(let serviceName):
                return .disabledNotAvailable(reason: .incorrectService(serviceName: serviceName))
            case .newerVersion:
                return .disabledNotAvailable(reason: .newerVersion)
            case .cloudEncrypted:
                return .disabledNotAvailable(reason: .cloudEncrypted)
            }
        case .disabledAvailable:
            return .disabledAvailable
        case .enabled(let sync):
            switch sync {
            case .syncing:
                return .enabled(sync: .synced)
            case .synced:
                return .enabled(sync: .synced)
            }
        }
    }
}
