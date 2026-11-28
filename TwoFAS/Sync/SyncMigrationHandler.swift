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

import Common

public protocol SyncMigrationHandling: AnyObject {
    var showMigrationToNewestVersion: (() -> Void)? { get set }
    var migrationEndedSuccessfuly: (() -> Void)? { get set }
    
    var reencryptionEndedSuccessfuly: (() -> Void)? { get set }
    
    var showiCloudIsEncryptedByUser: (() -> Void)? { get set }
    var showiCloudIsEncryptedBySystem: (() -> Void)? { get set }
    var showNeverVersionOfiCloud: (() -> Void)? { get set }
    var currentEncryption: CloudEncryptionType? { get }
    var showiCloudOverQuota: (() -> Void)? { get set }
    var showMigrationGeneralError: (() -> Void)? { get set }
    var showiCloudDisabledByUser: (() -> Void)? { get set }
    var showiCloudUserProblem: (() -> Void)? { get set }
    var showiCloudError: ((NSError?) -> Void)? { get set }
    var showiCloudIncorrectSerice: ((String) -> Void)? { get set }
    
    func changePassword(_ password: String)
    func migrateToSystemPassword()
    func switchLocallyToUseSystemPassword()
    func setMissingUserPassword(_ password: String)
    
    func verifyUserPassword(_ password: String, completion: @escaping (Bool) -> Void)
}

final class SyncMigrationHandler {
    private enum SyncMigrationChangeType {
        case system
        /// The key of the new password, already derived
        case userKey(Data)
    }
    
    var showMigrationToNewestVersion: (() -> Void)?
    var migrationEndedSuccessfuly: (() -> Void)?
    
    var reencryptionEndedSuccessfuly: (() -> Void)?
    
    var showiCloudIsEncryptedByUser: (() -> Void)?
    var showiCloudIsEncryptedBySystem: (() -> Void)?
    var showNeverVersionOfiCloud: (() -> Void)?
    var showiCloudOverQuota: (() -> Void)?
    var showMigrationGeneralError: (() -> Void)?
    var showiCloudDisabledByUser: (() -> Void)?
    var showiCloudUserProblem: (() -> Void)?
    var showiCloudError: ((NSError?) -> Void)?
    var showiCloudIncorrectSerice: ((String) -> Void)?
    var synchronize: (() -> Void)?
    var enable: (() -> Void)?
    
    var currentEncryption: CloudEncryptionType? {
        switch syncEncryptionHandler.encryptionType {
        case .system: .system
        case .user: .user
        }
    }
    
    private var canChangePassword = false
    private var passwordChangePending: SyncMigrationChangeType?
    private var isMigrating = false
    private var isReencrypting = false
    /// The key of a new password is being derived – the change of the password has started, but isn't pending yet
    private var isDerivingUserKey = false
    private var isiCloudEncryptedByDifferentUserPass = false
    private var enableIfSuccess = false
    
    private let migrationHandler: MigrationHandling
    private let reencryptionHandler: ReencryptionHandling
    private let syncEncryptionHandler: SyncEncryptionHandler

    init(
        migrationHandler: MigrationHandling,
        reencryptionHandler: ReencryptionHandling,
        syncEncryptionHandler: SyncEncryptionHandler
    ) {
        self.migrationHandler = migrationHandler
        self.reencryptionHandler = reencryptionHandler
        self.syncEncryptionHandler = syncEncryptionHandler
        
        reencryptionHandler.isReencryptionPending = { [weak self] () -> Bool in
            guard let self, let passwordChangePending else { return false }
            switch passwordChangePending {
            case .system:
                self.syncEncryptionHandler.setSystemKey()
            case .userKey(let key):
                self.syncEncryptionHandler.setUserKey(key)
            }
            self.passwordChangePending = nil
            return true
        }
        reencryptionHandler.didFinishReencryption = { [weak self] in
            self?.reencryptionEndedSuccessfuly?()
        }
        
        migrationHandler.isMigratingToV3 = { [weak self] in
            self?.isMigrating = true
            self?.showMigrationToNewestVersion?()
        }
        
        migrationHandler.finishedMigratingToV3 = { [weak self] in
            self?.isMigrating = false
            self?.migrationEndedSuccessfuly?()
        }
    }
}

extension SyncMigrationHandler: SyncMigrationHandling {
    func changePassword(_ password: String) {
        guard passwordChangePending == nil, !isMigrating, !isReencrypting else {
            return
        }
        isReencrypting = true
        isDerivingUserKey = true
        // Derived before the change is queued, off the main thread – the sync that applies it only swaps the keys
        syncEncryptionHandler.deriveUserKey(for: password) { [weak self] key in
            guard let self else { return }
            isDerivingUserKey = false
            guard let key else {
                Log("SyncMigrationHandler: Can't create user key!", module: .cloudSync, severity: .error)
                isReencrypting = false
                return
            }
            passwordChangePending = .userKey(key)
            changePasswordOrQueue()
        }
    }
    
    func migrateToSystemPassword() {
        guard passwordChangePending == nil, !isMigrating, !isReencrypting else {
            return
        }
        isReencrypting = true
        passwordChangePending = .system
        changePasswordOrQueue()
    }
    
    func setMissingUserPassword(_ password: String) {
        guard isiCloudEncryptedByDifferentUserPass, !isDerivingUserKey else {
            return
        }
        isDerivingUserKey = true
        syncEncryptionHandler.deriveUserKey(for: password) { [weak self] key in
            guard let self else { return }
            isDerivingUserKey = false
            if let key {
                syncEncryptionHandler.setUserKey(key)
            } else {
                Log("SyncMigrationHandler: Can't create user key!", module: .cloudSync, severity: .error)
            }
            isiCloudEncryptedByDifferentUserPass = false
            enableIfSuccess = true
            synchronize?()
        }
    }
    
    // locally user, but iCloud is using system
    func switchLocallyToUseSystemPassword() {
        guard passwordChangePending == nil, !isMigrating, !isReencrypting else {
            return
        }
        syncEncryptionHandler.setSystemKey()
        enableIfSuccess = true
        synchronize?()
    }
    
    func cloudStateChange(_ state: CloudCurrentState) {
        switch state {
        case .unknown:
            canChangePassword = false
        case .disabledNotAvailable(let reason):
            switch reason {
            case .newerVersion:
                canChangePassword = false
                showNeverVersionOfiCloud?()
            case .cloudEncryptedUser:
                canChangePassword = false
                isiCloudEncryptedByDifferentUserPass = true
                showiCloudIsEncryptedByUser?()
            case .cloudEncryptedSystem:
                canChangePassword = true
                showiCloudIsEncryptedBySystem?()
            case .overQuota:
                canChangePassword = false
                showiCloudOverQuota?()
            case .disabledByUser:
                canChangePassword = false
                showiCloudDisabledByUser?()
            case .useriCloudProblem:
                canChangePassword = false
                showiCloudUserProblem?()
            case .error(let error):
                canChangePassword = false
                showiCloudError?(error)
            case .incorrectService(let serviceName):
                canChangePassword = false
                showiCloudIncorrectSerice?(serviceName)
            default:
                canChangePassword = false
                showMigrationGeneralError?()
            }
        case .disabledAvailable:
            canChangePassword = false
        case .enabled(let sync):
            switch sync {
            case .syncing:
                canChangePassword = false
            case .synced:
                canChangePassword = true
                if passwordChangePending == nil && !isDerivingUserKey {
                    isReencrypting = false
                }
                if !changePasswordOrQueue() {
                    if enableIfSuccess {
                        enable?()
                        enableIfSuccess = false
                    }
                 }
            }
        }
    }
    
    func verifyUserPassword(_ password: String, completion: @escaping (Bool) -> Void) {
        syncEncryptionHandler.verifyUserPassword(password, completion: completion)
    }
}

private extension SyncMigrationHandler {
    @discardableResult
    func changePasswordOrQueue() -> Bool {
        guard canChangePassword, passwordChangePending != nil else {
            return false
        }
        synchronize?()
        return true
    }
}
