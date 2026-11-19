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
import CommonWatch

final class WatchVaultSelector: MigrationHandling {
    var clearCloudState: Callback?
    var isMigratingToV3: Callback?
    var setFirstStart: Callback?
    var finishedMigratingToV3: Callback?
    
    var isMigrating: Bool { false }
    var isMigratingInV1Zone: Bool { false }
    
    private let zoneManager: ZoneManager
    private let cloudProbe: CloudProbing
    
    init(zoneManager: ZoneManager, cloudProbe: CloudProbing) {
        self.zoneManager = zoneManager
        self.cloudProbe = cloudProbe
    }
    
    /// The vault to read, by what was found in the cloud
    static func zoneName(found: [VaultVersion]) -> String {
        found.contains(.v4) ? Config.vaultV3 : Config.vaultV2
    }
    
    func checkIfMigrationNeeded() async {
        guard !ConstStorage.cloudMigratedToV4 else {
            zoneManager.setCurrentZoneID(Config.vaultV3)
            return
        }
        Log("WatchVaultSelector: probing cloud", module: .cloudSync)
        do {
            let found = try await withCheckedThrowingContinuation { continuation in
                cloudProbe.checkForVaults { result in
                    continuation.resume(with: result)
                }
            }
            let zoneName = Self.zoneName(found: found)
            guard zoneName == Config.vaultV3 else {
                // The phone didn't migrate yet – probed again with the next sync
                Log("WatchVaultSelector: the current vault isn't there yet", module: .cloudSync)
                zoneManager.setCurrentZoneID(zoneName)
                return
            }
            Log("WatchVaultSelector: switching to the current vault", module: .cloudSync)
            zoneManager.setCurrentZoneID(zoneName)
            ConstStorage.cloudMigratedToV4 = true
            // What was cached belongs to the previous vault
            await MainActor.run {
                clearCloudState?()
            }
        } catch {
            // The vault used so far – probed again with the next sync
            Log("WatchVaultSelector - can't probe cloud", module: .cloudSync, severity: .error)
        }
    }
    
    func migrateIfNeeded() -> Bool { false }
}
