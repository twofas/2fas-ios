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
    /// - Parameter completion: `false` when the backup couldn't be erased – nothing was changed then.
    func eraseBackupAndCreateNewKeys(completion: @escaping (Bool) -> Void)
    /// - Parameter completion: `false` when the password isn't the one the iCloud backup is protected with.
    func recoverWithPassword(_ password: String, completion: @escaping (Bool) -> Void)
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
    func eraseBackupAndCreateNewKeys(completion: @escaping (Bool) -> Void) {
        cloudBackup.erase { [weak self] result in
            guard case .success = result else {
                // The backup is still there, sealed with the keys that are missing – new keys wouldn't open it
                completion(false)
                return
            }
            self?.cloudBackup.createEncryptionElements()
            completion(true)
        }
    }

    func recoverWithPassword(_ password: String, completion: @escaping (Bool) -> Void) {
        syncMigrationInteractor.recoverMissingUserKey(password, completion: completion)
    }
}
