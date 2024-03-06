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
import Common

// sourcery: Mock
public protocol CloudBackupStateInteracting: AnyObject {
    var secretSyncError: ((String) -> Void)? { get set }
    
    func startMonitoring()
    func stopMonitoring()
    
    var isBackupEnabled: Bool { get }
    var isBackupAvailable: Bool { get }
    var error: CloudState.NotAvailableReason? { get }
    
    var stateChanged: Callback? { get set }
    
    func toggleBackup()
    
    func enableBackup()
    func disableBackup()
    
    func clearBackup()
    
    func synchronizeBackup()
    
    var successSyncDate: Date? { get }
    func saveSuccessSyncDate()
    func clearSaveSuccessSync()
}

/// Use one instance per use case
final class CloudBackupStateInteractor {
    private let mainRepository: MainRepository
    private let listenerID: CloudStateListenerID
    
    private var previousState: CloudState = .unknown
    private var isEnabled = false
    private var isAvailable = false
    
    private(set) var error: CloudState.NotAvailableReason?
    
    var stateChanged: Callback?
    
    init(mainRepository: MainRepository, listenerID: CloudStateListenerID) {
        self.mainRepository = mainRepository
        self.listenerID = listenerID
    }
    
    deinit {
        stopMonitoring()
    }
}

extension CloudBackupStateInteractor: CloudBackupStateInteracting {
    var secretSyncError: ((String) -> Void)? {
        get {
            mainRepository.secretSyncError
        }
        set {
            mainRepository.secretSyncError = newValue
        }
    }
    
    var isBackupEnabled: Bool { isEnabled }
    var isBackupAvailable: Bool { isAvailable }
    
    var successSyncDate: Date? {
        mainRepository.successSyncDate
    }
    
    func startMonitoring() {
        Log("CloudBackupStateInteractor - start monitoring, listenerID: \(listenerID)", module: .interactor)
        saveStates()
        stateChanged?()
        
        mainRepository.registerForCloudStateChanges({ [weak self] cloudState in
            Log(
                "CloudBackupStateInteractor - registerForCloudStateChanges, cloudState: \(cloudState)",
                module: .interactor
            )
            self?.stateUpdate(cloudState)
        }, id: listenerID)
    }
    
    func stopMonitoring() {
        Log("CloudBackupStateInteractor - stop monitoring, listenerID: \(listenerID)", module: .interactor)
        mainRepository.unregisterForCloudStageChanges(with: listenerID)
    }
    
    func toggleBackup() {
        Log("CloudBackupStateInteractor - toggleBackup", module: .interactor)
        if isEnabled {
            disableBackup()
        } else {
            enableBackup()
        }
    }
    
    func enableBackup() {
        Log("CloudBackupStateInteractor - enableBackup", module: .interactor)
        isAvailable = false
        stateChanged?()
        
        AppEventLog(.backupOn)
        mainRepository.enableCloudBackup()
    }
    
    func disableBackup() {
        Log("CloudBackupStateInteractor - disableBackup", module: .interactor)
        isAvailable = false
        stateChanged?()
        
        AppEventLog(.backupOff)
        mainRepository.disableCloudBackup()
    }
    
    func clearBackup() {
        Log("CloudBackupStateInteractor - clearBackup", module: .interactor)
        isEnabled = false
        stateChanged?()
        
        mainRepository.clearBackup()
    }
    
    func synchronizeBackup() {
        Log("CloudBackupStateInteractor - synchronizeBackup", module: .interactor)
        mainRepository.synchronizeBackup()
    }
    
    func saveSuccessSyncDate() {
        Log("CloudBackupStateInteractor - saveSuccessSync", module: .interactor)
        mainRepository.saveSuccessSyncDate(Date())
    }
    
    func clearSaveSuccessSync() {
        Log("CloudBackupStateInteractor - clearSavesuccessSync", module: .interactor)
        mainRepository.saveSuccessSyncDate(nil)
    }
}

private extension CloudBackupStateInteractor {
    func stateUpdate(_ cloudState: CloudState) {
        Log("""
            "CloudBackupStateInteractor - cloudState, cloudState: \(cloudState), previousState: \(previousState)
            """, module: .interactor)
        guard cloudState != previousState else { return }
        
        saveStates()
        stateChanged?()
    }
    
    func saveStates() {
        isEnabled = mainRepository.isCloudBackupConnected
        isAvailable = isAvailableCheck()
        previousState = mainRepository.cloudCurrentState
        error = checkError()
        Log("""
            CloudBackupStateInteractor - saveStates:
            isEnable: \(isEnabled)
            isAvailable: \(isAvailable)
            previousStat: \(previousState)
            error: \(String(describing: error))
            """, module: .interactor)
    }
    
    func isAvailableCheck() -> Bool {
        switch mainRepository.cloudCurrentState {
        case .unknown, .disabledNotAvailable: return false
        default: return true
        }
    }
    
    func checkError() -> CloudState.NotAvailableReason? {
        switch mainRepository.cloudCurrentState {
        case .disabledNotAvailable(let reason):
            return reason
        default: return nil
        }
    }
}
