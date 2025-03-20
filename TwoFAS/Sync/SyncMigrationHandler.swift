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
    func changePassword(_ password: String)
    func useSystemPassword()
}

final class SyncMigrationHandler {
    private let migrationToV3Key = "migrationToV3"
    private let userDefaults: UserDefaults
    
    
    // add connection to UI
    // add migration process handling
    // check if synced, otherwise wait
    // after that sync
    // handle incorrect password error

}

private extension SyncMigrationHandler {
    var migratedToNewestVersion: Bool {
        userDefaults.bool(forKey: migrationToV3Key)
    }
    
    func setMigratedToNewestVersion() {
        userDefaults.set(true, forKey: migrationToV3Key)
        userDefaults.synchronize()
    }
}
