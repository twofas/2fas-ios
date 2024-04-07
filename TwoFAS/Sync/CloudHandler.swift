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

public enum CloudCurrentState: Equatable {
    public enum NotAvailableReason: Equatable {
        case overQuota
        case disabledByUser
        case useriCloudProblem
        case error(error: NSError?)
        case other
        case newerVersion
        case incorrectService(serviceName: String)
        case cloudEncrypted
    }
    
    public enum Sync: Equatable {
        case syncing // in progress
        case synced // all done
        // case error(error: NSError) <- not used. Sync restarts itself
    }
    
    case unknown
    case disabledNotAvailable(reason: NotAvailableReason)
    case disabledAvailable
    case enabled(sync: Sync)
    
    public var toCloudState: CloudState {
        switch self {
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

public typealias CloudHandlerStateListener = (CloudCurrentState) -> Void

public protocol CloudHandlerType: AnyObject {
    typealias StateChange = (CloudCurrentState) -> Void
    typealias UserToggledState = (Bool) -> Void
    typealias SecretSyncError = (String) -> Void
    
    func registerForStateChange(_ listener: @escaping CloudHandlerStateListener, with id: String)
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (BackgroundFetchResult) -> Void
    )
    func unregisterForStateChange(id: String)
    
    var userToggledState: UserToggledState? { get set }
    var currentState: CloudCurrentState { get }
    var isConnected: Bool { get }
    var secretSyncError: SecretSyncError? { get set }
    
    func checkState()
    func synchronize()
    func enable()
    func disable(notify: Bool)
    func clearBackup()
    func setTimeOffset(_ offset: Int)
    func resetStateBeforeSync()
    
    func resetBeforeMigration()
}

final class CloudHandler: CloudHandlerType {
    var stateChange: StateChange?
    var secretSyncError: SecretSyncError?
    
    private let cloudAvailability: CloudAvailability
    private let syncHandler: SyncHandler
    private let clearHandler: ClearHandler
    private let itemHandler: ItemHandler
    private let itemHandlerMigrationProxy: ItemHandlerMigrationProxy
    private let cloudKit: CloudKit
    
    private let notificationCenter = NotificationCenter.default
    
    private var isClearing = false
    
    private var listeners: [String: CloudHandlerStateListener] = [:]
    private var shouldResetState = false
    
    private(set) var currentState: CloudCurrentState = .unknown {
        didSet {
            Log("Cloud Handler - state change \(currentState)", module: .cloudSync)
            DispatchQueue.main.async {
                self.listeners.forEach { $0.value(self.currentState) }
            }
        }
    }
    
    var userToggledState: UserToggledState?
    
    init(
        cloudAvailability: CloudAvailability,
        syncHandler: SyncHandler,
        itemHandler: ItemHandler,
        itemHandlerMigrationProxy: ItemHandlerMigrationProxy,
        cloudKit: CloudKit
    ) {
        self.cloudAvailability = cloudAvailability
        self.syncHandler = syncHandler
        self.itemHandler = itemHandler
        self.itemHandlerMigrationProxy = itemHandlerMigrationProxy
        self.cloudKit = cloudKit
        clearHandler = ClearHandler()
        
        itemHandlerMigrationProxy.newerVersion = { [weak self] in self?.newerVersionOfCloud() }
        itemHandlerMigrationProxy.cloudEncrypted = { [weak self] in self?.cloudIsEncrypted() }
        
        cloudAvailability.availabilityCheckResult = { [weak self] resultStatus in
            self?.availabilityCheckResult(resultStatus)
        }
        
        syncHandler.startedSync = { [weak self] in self?.startedSync() }
        syncHandler.finishedSync = { [weak self] in self?.finishedSync() }
        syncHandler.otherError = { [weak self] error in self?.otherError(error) }
        syncHandler.quotaExceeded = { [weak self] in self?.quotaError() }
        syncHandler.userDisabledCloud = { [weak self] in self?.disabledByUser() }
        syncHandler.useriCloudProblem = { [weak self] in self?.useriCloudProblem() }
        itemHandler.secretError = { [weak self] in
            self?.incorrectService(serviceName: $0)
            self?.secretSyncError?($0)
        }
        
        clearHandler.didClear = { [weak self] in self?.didClear() }
    }
    
    func registerForStateChange(_ listener: @escaping CloudHandlerStateListener, with id: String) {
        listeners[id] = listener
    }
    
    func unregisterForStateChange(id: String) {
        listeners.removeValue(forKey: id)
    }
    
    func checkState() {
        Log("Cloud Handler - checking state", module: .cloudSync)
        cloudAvailability.checkAvailability()
    }
    
    func synchronize() {
        Log("Cloud Handler -  Got Synchronize action", module: .cloudSync)
        if shouldResetState {
            Log("Cloud Handler - Reseting state", module: .cloudSync)
            shouldResetState = false
            resetBeforeMigration()
        }
        switch currentState {
        case .unknown, .disabledNotAvailable:
            Log("Cloud Handler -  unknown state on synchronize", module: .cloudSync)
            checkState()
        case .enabled:
            Log("Cloud Handler -  is enabled - syncing", module: .cloudSync)
            sync()
        case .disabledAvailable:
            Log("Cloud Handler -  Can't synchronize if cloud is disabled", module: .cloudSync)
        }
    }
    
    func enable() {
        Log("Cloud Handler - Got Enable action", module: .cloudSync)
        switch currentState {
        case .enabled:
            Log("Cloud Handler - Can't enable again!", module: .cloudSync)
        case .disabledAvailable:
            Log("Cloud Handler - enable and state is disabledAvailable - enabling!", module: .cloudSync)
            setEnabled()
            userToggledState?(true)
            sync()
        case .disabledNotAvailable:
            Log("Cloud Handler - Can't enable if cloud is not available", module: .cloudSync)
        case .unknown:
            Log("Cloud Handler - Can't enable - state unknown", module: .cloudSync)
        }
    }
    
    func disable(notify: Bool = true) {
        Log("Cloud Handler - Got Disable action", module: .cloudSync)
        switch currentState {
        case .enabled, .unknown:
            Log("Cloud Handler - is enabled - disabling", module: .cloudSync)
            clearAll()
            if notify {
                userToggledState?(false)
            }
            currentState = .disabledAvailable
        case .disabledAvailable:
            Log("Cloud Handler - Can't disable again!", module: .cloudSync)
        case .disabledNotAvailable:
            Log("Cloud Handler - Can't disable not available", module: .cloudSync)
        }
    }
    
    func clearBackup() {
        isClearing = true
        if isSynced {
            clearBackupForSyncedState()
        }
    }
    
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (BackgroundFetchResult) -> Void
    ) {
        switch currentState {
        case .enabled:
            Log("Cloud Handler - we have a notification and we're in enabled state!", module: .cloudSync)
            syncHandler.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
        default:
            Log("Cloud Handler - we have a notification but we're in a state \(currentState)", module: .cloudSync)
            return
        }
    }
    
    var isConnected: Bool {
        switch currentState {
        case .enabled: return true
        default: return false
        }
    }
    
    func resetStateBeforeSync() {
        shouldResetState = true
    }
    
    var isSynced: Bool {
        switch currentState {
        case .enabled(let sync):
            switch sync {
            case .synced: return true
            default: return false
            }
        default: return false
        }
    }
    
    func setTimeOffset(_ offset: Int) {
        syncHandler.setTimeOffset(offset)
    }
    
    // MARK: - Private
    func resetBeforeMigration() {
        Log("Cloud Handler - resetBeforeMigration", module: .cloudSync)
        itemHandlerMigrationProxy.firstStart()
        syncHandler.firstStart()
    }
    
    private func availabilityCheckResult(_ resultStatus: CloudAvailabilityStatus) {
        Log("Cloud Handler - availabilityCheckResult \(resultStatus)", module: .cloudSync)
        switch resultStatus {
        case .available:
            if isEnabled {
                sync()
            } else {
                currentState = .disabledAvailable
            }
        case .accountChanged:
            if isEnabled {
                Log("Cloud Handler - account changed - clearing all, first start", module: .cloudSync)
                clearCache()
                itemHandlerMigrationProxy.firstStart()
                syncHandler.firstStart()
                sync()
            } else {
                currentState = .disabledAvailable
            }
        case .error(let error):
            otherError(error)
            
        case .notAvailable:
            clearAll()
            currentState = .disabledNotAvailable(reason: .other)
        }
    }
    
    private func sync() {
        Log("Cloud Handler - Sync", module: .cloudSync)
        syncHandler.synchronize()
    }
    
    private func clearCache() {
        Log("Cloud Handler - clear cache", module: .cloudSync)
        cloudAvailability.clear()
        syncHandler.clearCacheAndDisable()
    }
    
    private func clearAll() {
        Log("Cloud Handler - clear all", module: .cloudSync)
        setDisabled()
        clearCache()
    }
    
    // MARK: -
    
    private func setEnabled() {
        Log("Cloud Handler - Set Enabled", module: .cloudSync)
        ConstStorage.cloudEnabled = true
        itemHandlerMigrationProxy.firstStart()
        syncHandler.firstStart()
    }
    
    private func setDisabled() {
        Log("Cloud Handler - Set Disabled", module: .cloudSync)
        ConstStorage.cloudEnabled = false
        notificationCenter.post(name: .clearSyncCompletedSuccessfuly, object: nil)
    }
    
    private var isEnabled: Bool { ConstStorage.cloudEnabled }
    
    // MARK: - Clearing
    
    private func didClear() {
        Log("Cloud Handler - didClear", module: .cloudSync)
        isClearing = false
    }
    
    private func clearBackupForSyncedState() {
        Log("Cloud Handler - clearBackupForSyncedState", module: .cloudSync)
        let recordIDs = itemHandler.allEntityRecordIDs(zoneID: cloudKit.zoneID)
        disable(notify: false)
        clearHandler.clear(recordIDs: recordIDs)
    }
    
    // MARK: -
    
    private func startedSync() {
        Log("Cloud Handler - Started Sync", module: .cloudSync)
        currentState = .enabled(sync: .syncing)
    }
    
    private func finishedSync() {
        Log("Cloud Handler - Finished Sync", module: .cloudSync)
        currentState = .enabled(sync: .synced)
        
        if isClearing {
            clearBackup()
        } else {
            notificationCenter.post(name: .syncCompletedSuccessfuly, object: nil)
        }
    }
    
    private func quotaError() {
        Log("Cloud Handler - Quota Error", module: .cloudSync)
        clearAll()
        currentState = .disabledNotAvailable(reason: .overQuota)
    }
    
    private func disabledByUser() {
        Log("Cloud Handler - Disabled by User", module: .cloudSync)
        clearAll()
        currentState = .disabledNotAvailable(reason: .disabledByUser)
    }
    
    private func useriCloudProblem() {
        Log("Cloud Handler - User has iCloud problem", module: .cloudSync)
        clearAll()
        currentState = .disabledNotAvailable(reason: .useriCloudProblem)
    }
    
    private func otherError(_ error: NSError?) {
        Log("Cloud Handler - Other Error \(String(describing: error))", module: .cloudSync)
        clearAll()
        currentState = .disabledNotAvailable(reason: .error(error: error))
    }
    
    private func incorrectService(serviceName: String) {
        Log("Cloud Handler - Incorrect Service Error", module: .cloudSync)
        clearAll()
        currentState = .disabledNotAvailable(reason: .incorrectService(serviceName: serviceName))
    }
    
    private func newerVersionOfCloud() {
        Log("Cloud Handler - newer version of cloud", module: .cloudSync)
        clearAll()
        currentState = .disabledNotAvailable(reason: .newerVersion)
    }
    
    private func cloudIsEncrypted() {
        Log("Cloud Handler - cloud is encrypted", module: .cloudSync)
        clearAll()
        currentState = .disabledNotAvailable(reason: .cloudEncrypted)
    }
}
