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
import CloudKit
import Common

final class MigrationHandler {
    var isMigratingToV3: Callback?
    var setFirstStart: Callback?
    var finishedMigratingToV3: Callback?
    var clearCloudState: Callback?
    
    private(set) var isMigrating = false
    
    private let zoneManager: ZoneManager
    private let cloudProbe: CloudProbing
   
    init(
        zoneManager: ZoneManager,
        cloudProbe: CloudProbing
    ) {
        self.zoneManager = zoneManager
        self.cloudProbe = cloudProbe
    }
}

extension MigrationHandler: MigrationHandling {
    var isMigratingInV1Zone: Bool {
        zoneManager.currentZoneID.zoneName == Config.vaultV1 && isMigrating
    }
    
    func checkIfMigrationNeeded() async {
        guard !ConstStorage.cloudMigratedToV3 else {
            Log("MigrationHandler: cached value - already migrated", module: .cloudSync)
            zoneManager.setCurrentZoneID(Config.vaultV2)
            return
        }
        if isMigrating { return }
        Log("MigrationHandler: probing cloud", module: .cloudSync)
        do {
            let result = try await withCheckedThrowingContinuation { continuation in
                cloudProbe.checkForVaults { result in
                    continuation.resume(with: result)
                }
            }
            if result.contains(where: { $0 == .v3 }) {
                Log("MigrationHandler: probed value - already migrated", module: .cloudSync)
                zoneManager.setCurrentZoneID(Config.vaultV2)
                ConstStorage.cloudMigratedToV3 = true
                Task { @MainActor in
                    clearCloudState?()
                }
                return
            }
            if result.isEmpty {
                Log("MigrationHandler: probed value - clean iCloud", module: .cloudSync)
                zoneManager.setCurrentZoneID(Config.vaultV2)
                ConstStorage.cloudMigratedToV3 = true
                return
            }
            
            Log("MigrationHandler: awaiting migration to v3", module: .cloudSync)
            zoneManager.setCurrentZoneID(Config.vaultV1)
            isMigrating = true
            Task { @MainActor in
                setFirstStart?()
                isMigratingToV3?()
            }
        } catch {
            Log("MigrationHandler - can't probe cloud", module: .cloudSync, severity: .error)
            zoneManager.setCurrentZoneID(Config.vaultV2)
            Task { @MainActor in
                clearCloudState?()
            }
            return
        }
    }
        
    func migrateIfNeeded() -> Bool {
        guard isMigrating else { return false }
        if zoneManager.inOldVault {
            Log("MigrationHandler: migration to v3 from older Vault", module: .cloudSync)
            zoneManager.setCurrentZoneID(Config.vaultV2)
            return true
        } else {
            Log("MigrationHandler: migrated", module: .cloudSync)
            isMigrating = false
            ConstStorage.cloudMigratedToV3 = true
            Task { @MainActor in
                finishedMigratingToV3?()
                NotificationCenter.default.post(name: .vaultWasMigrated, object: nil)
            }
            return false
        }
    }
}
