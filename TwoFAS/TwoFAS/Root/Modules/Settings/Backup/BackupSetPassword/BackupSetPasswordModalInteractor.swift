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

protocol BackupSetPasswordModalInteracting: AnyObject {
    var syncSuccess: (() -> Void)? { get set }
    var syncFailure: ((CloudState.NotAvailableReason) -> Void)? { get set }
    
    func setPassword(_ password: String)
    func setApplayinChanges()
}

final class BackupSetPasswordModalInteractor {
    var syncSuccess: (() -> Void)?
    var syncFailure: ((CloudState.NotAvailableReason) -> Void)?
    
    private let syncMigrationInteractor: SyncMigrationInteracting
    private let notificationCenter: NotificationCenter
    
    private var applyingChanges = false
    
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

extension BackupSetPasswordModalInteractor: BackupSetPasswordModalInteracting {
    func setPassword(_ password: String) {
        syncMigrationInteractor.changePassword(password)
    }
    
    @objc
    private func syncStateChanged() {
        guard applyingChanges else { return }
        
        switch syncMigrationInteractor.currentCloudState {
        case .disabledNotAvailable(let reason):
            applyingChanges = false
            syncFailure?(reason)
        case .enabled(let sync):
            switch sync {
            case .synced:
                applyingChanges = false
                syncSuccess?()
            default: break
            }
        default: break
        }
    }
    
    func setApplayinChanges() {
        applyingChanges = true
    }
}
