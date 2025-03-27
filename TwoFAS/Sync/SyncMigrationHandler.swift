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
    
    func changePassword(_ password: String)
    func useSystemPassword()
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
    
    private var canChangePassword = false
    private var passwordChangePending: SyncMigrationChangeType?
    private var isMigrating = false
    private var isiCloudEncryptedByDiffrentUserPass = false
    
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
    
    func useSystemPassword() {
        guard passwordChangePending == nil, !isMigrating else {
            return
        }
        isMigrating = true
        passwordChangePending = .system
        changePasswordOrQueue()
    }
    
    func setMissingUserPassword(_ password: String) {
        guard isiCloudEncryptedByDiffrentUserPass else {
            return
        }
        syncEncryptionHandler.setUserPassword(password)
        isiCloudEncryptedByDiffrentUserPass = false
        synchronize?()
    }
    
    func cloudStateChange(_ state: CloudCurrentState) {
        switch state {
        case .unknown:
            canChangePassword = false
        case .disabledNotAvailable(let reason):
            switch reason {
            case .newerVersion:
                showNeverVersionOfiCloud?()
            case .cloudEncryptedUser:
                isiCloudEncryptedByDiffrentUserPass = true
                showiCloudIsEncryptedByUser?()
            case .cloudEncryptedSystem:
                showiCloudIsEncryptedBySystem?()
            default: break
            }
            canChangePassword = false
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
                changePasswordOrQueue()
            }
        }
    }
}

private extension SyncMigrationHandler {
    func changePasswordOrQueue() {
        guard canChangePassword, passwordChangePending != nil else {
            return
        }
        synchronize?()
    }
}
