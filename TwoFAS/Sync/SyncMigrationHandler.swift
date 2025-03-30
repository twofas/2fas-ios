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

#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public protocol SyncMigrationHandling: AnyObject {
    var showMigrationToNewestVersion: (() -> Void)? { get set }
    var showiCloudIsEncryptedByUser: (() -> Void)? { get set }
    var showiCloudIsEncryptedBySystem: (() -> Void)? { get set }
    var showNeverVersionOfiCloud: (() -> Void)? { get set }
    var currentEncryption: CloudEncryptionType? { get }
    
    func changePassword(_ password: String)
    func migrateToSystemPassword()
    func switchLocallyToUseSystemPassword()
    func setMissingUserPassword(_ password: String)
}

final class SyncMigrationHandler {
    private enum SyncMigrationChangeType {
        case system
        case password(String)
    }
    
    var showMigrationToNewestVersion: (() -> Void)?
    var showiCloudIsEncryptedByUser: (() -> Void)?
    var showiCloudIsEncryptedBySystem: (() -> Void)?
    var showNeverVersionOfiCloud: (() -> Void)?
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
    private var isiCloudEncryptedByDifferentUserPass = false
    private var enableIfSuccess = false
    
    private let migrationHandler: MigrationHandling
    private let syncEncryptionHandler: SyncEncryptionHandler

    init(migrationHandler: MigrationHandling, syncEncryptionHandler: SyncEncryptionHandler) {
        self.migrationHandler = migrationHandler
        self.syncEncryptionHandler = syncEncryptionHandler
        
        migrationHandler.isReencryptionPending = { [weak self] () -> Bool in
            guard let self, let passwordChangePending else { return false }
            switch passwordChangePending {
            case .system:
                self.syncEncryptionHandler.setSystemKey()
            case .password(let password):
                self.syncEncryptionHandler.setUserPassword(password)
            }
            self.passwordChangePending = nil
            return true
        }
        migrationHandler.isMigratingToV3 = { [weak self] in
            self?.isMigrating = true
            self?.showMigrationToNewestVersion?()
        }
    }
}

extension SyncMigrationHandler: SyncMigrationHandling {
    func changePassword(_ password: String) {
        guard passwordChangePending == nil, !isMigrating else {
            return
        }
        isMigrating = true
        passwordChangePending = .password(password)
        changePasswordOrQueue()
    }
    
    func migrateToSystemPassword() {
        guard passwordChangePending == nil, !isMigrating else {
            return
        }
        isMigrating = true
        passwordChangePending = .system
        changePasswordOrQueue()
    }
    
    func setMissingUserPassword(_ password: String) {
        guard isiCloudEncryptedByDifferentUserPass else {
            return
        }
        syncEncryptionHandler.setUserPassword(password)
        isiCloudEncryptedByDifferentUserPass = false
        enableIfSuccess = true
        synchronize?()
    }
    
    // locally user, but iCloud is using system
    func switchLocallyToUseSystemPassword() {
        guard passwordChangePending == nil, !isMigrating else {
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
            default: break
            }
        case .disabledAvailable:
            canChangePassword = false
        case .enabled(let sync):
            switch sync {
            case .syncing:
                canChangePassword = false
            case .synced:
                canChangePassword = true
                if passwordChangePending == nil {
                    isMigrating = false
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
