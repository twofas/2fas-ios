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
import Data
import Common

protocol EncryptedByUserPasswordSyncModuleInteracting: AnyObject {
    var syncSuccess: (() -> Void)? { get set }
    var syncFailure: ((CloudState.NotAvailableReason) -> Void)? { get set }
    
    func setPassword(_ password: String)
    func verifyPassword(_ password: String) -> Bool
    func removePassword()
}

final class EncryptedByUserPasswordSyncModuleInteractor {
    private let syncMigrationInteractor: SyncMigrationInteracting
    private let notificationCenter: NotificationCenter
    
    var syncSuccess: (() -> Void)?
    var syncFailure: ((CloudState.NotAvailableReason) -> Void)?
    
    init(syncMigrationInteractor: SyncMigrationInteracting) {
        self.syncMigrationInteractor = syncMigrationInteractor
        notificationCenter = .default
        notificationCenter.addObserver(
            self,
            selector: #selector(syncStateChanged),
            name: .syncStateChanged,
            object: nil
        )
    }
}

extension EncryptedByUserPasswordSyncModuleInteractor: EncryptedByUserPasswordSyncModuleInteracting {
    func setPassword(_ password: String) {
        syncMigrationInteractor.setMissingUserPassword(password)
    }
    
    func verifyPassword(_ password: String) -> Bool {
        syncMigrationInteractor.verifyPassword(password)
    }
    
    func removePassword() {
        syncMigrationInteractor.migrateToSystemPassword()
    }
}

private extension EncryptedByUserPasswordSyncModuleInteractor {
    @objc
    func syncStateChanged() {
        switch syncMigrationInteractor.currentCloudState {
        case .disabledNotAvailable(let reason): syncFailure?(reason)
        case .enabled(let sync):
            switch sync {
            case .synced: syncSuccess?()
            default: break
            }
        default: break
        }
    }
}
