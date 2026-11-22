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

/// What to do with the vaults found in the cloud
enum VaultMigrationDecision: Equatable {
    /// The current vault is there (migrated by another device, or by this one earlier) – it's used as it is
    case useCurrentVault
    /// Nothing in the cloud – the current vault is started clean
    case startClean
    /// An older vault has the data: it's read from `zoneName` and then written to the current vault
    case migrate(from: String)
    
    static func decide(found: [VaultVersion]) -> VaultMigrationDecision {
        if found.contains(.v4) { return .useCurrentVault }
        if found.isEmpty { return .startClean }
        // The newest of the older vaults – the ones before it were migrated into it
        if found.contains(.v3) { return .migrate(from: Config.vaultV2) }
        return .migrate(from: Config.vaultV1)
    }
}

extension MigrationHandler: MigrationHandling {
    var isMigratingInV1Zone: Bool {
        zoneManager.currentZoneID.zoneName == Config.vaultV1 && isMigrating
    }
    
    @MainActor
    func checkIfMigrationNeeded() async -> Bool {
        guard !ConstStorage.cloudMigratedToV4 else {
            Log("MigrationHandler: cached value - already migrated", module: .cloudSync)
            zoneManager.setCurrentZoneID(Config.vaultV3)
            return true
        }
        if isMigrating { return true }
        Log("MigrationHandler: probing cloud", module: .cloudSync)
        do {
            let result = try await withCheckedThrowingContinuation { continuation in
                cloudProbe.checkForVaults { result in
                    continuation.resume(with: result)
                }
            }
            switch VaultMigrationDecision.decide(found: result) {
            case .useCurrentVault:
                Log("MigrationHandler: probed value - already migrated", module: .cloudSync)
                zoneManager.setCurrentZoneID(Config.vaultV3)
                ConstStorage.cloudMigratedToV4 = true
                Task { @MainActor in
                    clearCloudState?()
                }
            case .startClean:
                Log("MigrationHandler: probed value - clean iCloud", module: .cloudSync)
                zoneManager.setCurrentZoneID(Config.vaultV3)
                ConstStorage.cloudMigratedToV4 = true
            case .migrate(let zoneName):
                Log("MigrationHandler: awaiting migration from \(zoneName)", module: .cloudSync)
                zoneManager.setCurrentZoneID(zoneName)
                isMigrating = true
                Task { @MainActor in
                    setFirstStart?()
                    isMigratingToV3?()
                }
            }
            return true
        } catch {
            // Without knowing what is in the cloud nothing is decided: no vault is chosen and nothing is
            // remembered. A cloud that couldn't be read isn't an empty one – starting the current vault clean
            // now would make every other device leave the vault that has the data.
            Log("MigrationHandler - can't probe cloud, the sync doesn't go on", module: .cloudSync, severity: .error)
            return false
        }
    }
    
    func restartAfterVaultWasRetired() {
        Log("MigrationHandler: the vault read for the migration was retired – checking the cloud again", module: .cloudSync)
        isMigrating = false
    }
    
    func accountChanged() {
        Log("MigrationHandler: account changed – the vaults are checked again", module: .cloudSync)
        isMigrating = false
        ConstStorage.cloudMigratedToV4 = false
        ConstStorage.oldVaultsRetirementPending = false
    }
        
    func migrateIfNeeded() -> Bool {
        guard isMigrating else { return false }
        if !zoneManager.usesSealedRecords {
            Log("MigrationHandler: migration from an older Vault", module: .cloudSync)
            zoneManager.setCurrentZoneID(Config.vaultV3)
            return true
        } else {
            Log("MigrationHandler: migrated", module: .cloudSync)
            isMigrating = false
            ConstStorage.cloudMigratedToV4 = true
            // The data of the older vault is in the current one now – this device retires the older ones
            ConstStorage.oldVaultsRetirementPending = true
            Task { @MainActor in
                finishedMigratingToV3?()
                NotificationCenter.default.post(name: .vaultWasMigrated, object: nil)
            }
            return false
        }
    }
}
