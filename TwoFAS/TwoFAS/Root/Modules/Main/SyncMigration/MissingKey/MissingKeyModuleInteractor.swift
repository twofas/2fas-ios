//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

protocol MissingKeyModuleInteracting: AnyObject {
    func eraseBackupAndCreateNewKeys(completion: @escaping () -> Void)
    /// - Returns: `false` when the password isn't the one the iCloud backup is protected with.
    func recoverWithPassword(_ password: String) -> Bool
}

final class MissingKeyModuleInteractor {
    private let cloudBackup: CloudBackupStateInteracting
    private let syncMigrationInteractor: SyncMigrationInteracting

    init(cloudBackup: CloudBackupStateInteracting, syncMigrationInteractor: SyncMigrationInteracting) {
        self.cloudBackup = cloudBackup
        self.syncMigrationInteractor = syncMigrationInteractor
    }
}

extension MissingKeyModuleInteractor: MissingKeyModuleInteracting {
    func eraseBackupAndCreateNewKeys(completion: @escaping () -> Void) {
        cloudBackup.erase { [weak self] _ in
            self?.cloudBackup.createEncryptionElements()
            completion()
        }
    }

    func recoverWithPassword(_ password: String) -> Bool {
        syncMigrationInteractor.recoverMissingUserKey(password)
    }
}
