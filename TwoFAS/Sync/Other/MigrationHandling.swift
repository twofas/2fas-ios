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

import CloudKit
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

protocol MigrationHandling: AnyObject {
    var clearCloudState: Callback? { get set }
    var setFirstStart: Callback? { get set }
    var isMigratingToV3: Callback? { get set }
    var finishedMigratingToV3: Callback? { get set }
    /// Whether this device has anything cached of the vault it syncs with (its Info record). `false` – nothing
    /// is known, and which vault has the data is asked from the cloud again, whatever was remembered.
    var isVaultKnown: (() -> Bool)? { get set }
    var migrationAbandoned: ((_ dataIsInCurrentVault: Bool) -> Void)? { get set }
    
    var isMigrating: Bool { get }
    var isMigratingInV1Zone: Bool { get }
    
    /// Finds out which vault to sync with.
    /// - Returns: `false` when what is in the cloud couldn't be checked: nothing was decided and nothing was
    ///   changed – this sync must not go on. The next one checks again.
    ///
    /// On the main queue, like everything else that reads what it decides (the vault in use, the migration).
    @MainActor
    func checkIfMigrationNeeded() async -> Bool
    func migrateIfNeeded() -> Bool
    /// The vault that was being read for the migration was retired by another device (which migrated it):
    /// forgets the migration, so the cloud is checked again
    func restartAfterVaultWasRetired()
    /// The iCloud account changed: what this device knew about the vaults belongs to the other account
    func accountChanged()
}
