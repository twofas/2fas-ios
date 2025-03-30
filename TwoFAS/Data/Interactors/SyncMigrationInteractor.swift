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

import Foundation
import Common
import Sync

public protocol SyncMigrationInteracting: AnyObject {
    var showMigrationToNewestVersion: (() -> Void)? { get set }
    var showiCloudIsEncryptedByUser: (() -> Void)? { get set }
    var showiCloudIsEncryptedBySystem: (() -> Void)? { get set }
    var showNeverVersionOfiCloud: (() -> Void)? { get set }
    
    var migrationEndedSuccessfuly: (() -> Void)? { get set }
    var migrationError: ((CloudState.NotAvailableReason) -> Void)? { get set }
    
    var currentEncryption: CloudEncryptionType { get }
    var currentCloudState: CloudState { get }
    
    func changePassword(_ password: String)
    func switchLocallyToUseSystemPassword()
    func migrateToSystemPassword()
    func setMissingUserPassword(_ password: String)
}

final class SyncMigrationInteractor {
    var currentEncryption: CloudEncryptionType {
        if let encryption = mainRepository.cloudCurrentEncryption {
            return encryption
        }
        Log("SyncMigrationInteractor: No current encryption", module: .interactor, severity: .error)
        return .system
    }
    
    var currentCloudState: CloudState {
        mainRepository.cloudCurrentState
    }
    
    var showMigrationToNewestVersion: (() -> Void)? {
        get {
            mainRepository.cloudShowMigrationToNewestVersion
        }
        set {
            mainRepository.cloudShowMigrationToNewestVersion = newValue
        }
    }
    var showiCloudIsEncryptedByUser: (() -> Void)? {
        get {
            mainRepository.cloudShowiCloudIsEncryptedByUser
        }
        set {
            mainRepository.cloudShowiCloudIsEncryptedByUser = newValue
        }
    }
    var showiCloudIsEncryptedBySystem: (() -> Void)? {
        get {
            mainRepository.cloudShowiCloudIsEncryptedBySystem
        }
        set {
            mainRepository.cloudShowiCloudIsEncryptedBySystem = newValue
        }
    }
    var showNeverVersionOfiCloud: (() -> Void)? {
        get {
            mainRepository.cloudShowNeverVersionOfiCloud
        }
        set {
            mainRepository.cloudShowNeverVersionOfiCloud = newValue
        }
    }
    
    var migrationEndedSuccessfuly: (() -> Void)?
    var migrationError: ((CloudState.NotAvailableReason) -> Void)?
    
    private let mainRepository: MainRepository
    private let notificationCenter: NotificationCenter
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
        self.notificationCenter = .default
        notificationCenter.addObserver(
            self,
            selector: #selector(syncStateChanged),
            name: .syncStateChanged,
            object: nil
        )
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

extension SyncMigrationInteractor: SyncMigrationInteracting {
    func changePassword(_ password: String) {
        mainRepository.cloudChangePassword(password)
    }
    
    func switchLocallyToUseSystemPassword() {
        mainRepository.cloudSwitchLocallyToUseSystemPassword()
    }
    
    func migrateToSystemPassword() {
        mainRepository.cloudMigrateToSystemPassword()
    }
    
    func setMissingUserPassword(_ password: String) {
        mainRepository.cloudSetMissingUserPassword(password)
    }
    
    @objc
    func syncStateChanged() {
        switch mainRepository.cloudCurrentState {
        case .disabledNotAvailable(let reason): migrationError?(reason)
        case .enabled(let sync):
            switch sync {
            case .synced: migrationEndedSuccessfuly?()
            default: break
            }
        default: break
        }
    }
}
