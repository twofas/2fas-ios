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

protocol BackupManageEncryptionModuleInteracting: AnyObject {
    var isSyncing: Bool { get }
    var reload: Callback? { get set }
    var canDelete: Bool { get }
    var isCloudBackupSynced: Bool { get }
    var encryptionTypeIsUser: Bool { get }
}

final class BackupManageEncryptionModuleInteractor {
    private let syncMigrationInteractor: SyncMigrationInteracting
    private let cloudBackup: CloudBackupStateInteracting
    private let notificationCenter: NotificationCenter
    
    var reload: Callback?
    
    init(syncMigrationInteractor: SyncMigrationInteracting, cloudBackup: CloudBackupStateInteracting) {
        self.syncMigrationInteractor = syncMigrationInteractor
        self.cloudBackup = cloudBackup
        notificationCenter = .default
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

extension BackupManageEncryptionModuleInteractor: BackupManageEncryptionModuleInteracting {
    var isSyncing: Bool {
        syncMigrationInteractor.currentCloudState == .enabled(sync: .syncing)
    }
    
    var canDelete: Bool {
        cloudBackup.canDelete
    }
    
    var isCloudBackupSynced: Bool {
        cloudBackup.isCloudBackupSynced
    }
    
    var encryptionTypeIsUser: Bool {
        cloudBackup.encryptionTypeIsUser
    }
}

private extension BackupManageEncryptionModuleInteractor {
    @objc
    func syncStateChanged() {
        reload?()
    }
}
