//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
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

import XCTest
import CloudKit
@testable import Common
@testable import Sync

/// Which vault a device syncs with, and when it retires the older ones
final class SyncVaultMigrationTests: XCTestCase {
    private final class FakeProbe: CloudProbing {
        var result: Result<[VaultVersion], Error> = .success([])
        private(set) var checks = 0

        func checkForVaults(completion: @escaping (Result<[VaultVersion], Error>) -> Void) {
            checks += 1
            completion(result)
        }
    }

    private var savedMigratedToV4 = false
    private var savedRetirementPending = false
    private var probe: FakeProbe!
    private var zoneManager: ZoneManager!
    private var handler: MigrationHandler!

    override func setUp() {
        super.setUp()
        savedMigratedToV4 = ConstStorage.cloudMigratedToV4
        savedRetirementPending = ConstStorage.oldVaultsRetirementPending
        ConstStorage.cloudMigratedToV4 = false
        ConstStorage.oldVaultsRetirementPending = false
        probe = FakeProbe()
        zoneManager = ZoneManager()
        handler = MigrationHandler(zoneManager: zoneManager, cloudProbe: probe)
    }

    override func tearDown() {
        ConstStorage.cloudMigratedToV4 = savedMigratedToV4
        ConstStorage.oldVaultsRetirementPending = savedRetirementPending
        handler = nil
        zoneManager = nil
        probe = nil
        super.tearDown()
    }

    /// A cloud that couldn't be read isn't an empty one: nothing is chosen, nothing is remembered
    func testFailedProbeDecidesNothing() async {
        probe.result = .failure(CloudProbeError.operationFailed)
        let zoneBefore = zoneManager.currentZoneID

        let canSync = await handler.checkIfMigrationNeeded()

        XCTAssertFalse(canSync)
        XCTAssertEqual(zoneManager.currentZoneID, zoneBefore)
        XCTAssertFalse(zoneManager.usesSealedRecords)
        XCTAssertFalse(ConstStorage.cloudMigratedToV4)
        XCTAssertFalse(ConstStorage.oldVaultsRetirementPending)
        XCTAssertFalse(handler.isMigrating)

        // Checked again with the next sync
        probe.result = .success([.v3])
        let canSyncNow = await handler.checkIfMigrationNeeded()
        XCTAssertTrue(canSyncNow)
        XCTAssertEqual(probe.checks, 2)
        XCTAssertTrue(handler.isMigrating)
    }

    /// The sync goes on right after the check: what it starts with has to be cleared by then, or its fetch uses
    /// the tokens of the previous sync, brings nothing, and the vault looks empty
    @MainActor
    func testStateIsResetBeforeTheSyncGoesOn() async {
        var events: [String] = []
        handler.setFirstStart = { events.append("reset") }
        handler.isMigratingToV3 = { events.append("migrating") }
        handler.clearCloudState = { events.append("clear") }

        probe.result = .success([.v3])
        _ = await handler.checkIfMigrationNeeded()
        XCTAssertEqual(events, ["reset", "migrating"])

        handler.restartAfterVaultWasRetired()
        events = []
        probe.result = .success([.v4])
        _ = await handler.checkIfMigrationNeeded()
        XCTAssertEqual(events, ["clear"])
    }

    /// The device remembers that the data is in the current vault, but has nothing of it cached – and in the
    /// cloud that vault is gone while an older one has the data. It's migrated, not started clean.
    func testNothingCachedAsksTheCloudAgainDespiteWhatWasRemembered() async {
        ConstStorage.cloudMigratedToV4 = true
        var isKnown = true
        handler.isVaultKnown = { isKnown }

        probe.result = .success([.v3])
        _ = await handler.checkIfMigrationNeeded()
        XCTAssertEqual(probe.checks, 0, "Something of the vault is cached – what was remembered holds")
        XCTAssertTrue(zoneManager.usesSealedRecords)

        isKnown = false
        let canSync = await handler.checkIfMigrationNeeded()
        XCTAssertTrue(canSync)
        XCTAssertEqual(probe.checks, 1)
        XCTAssertTrue(handler.isMigrating)
        XCTAssertEqual(zoneManager.currentZoneID.zoneName, Config.vaultV2)
        XCTAssertFalse(ConstStorage.cloudMigratedToV4)
    }

    func testEmptyCloudStartsTheCurrentVaultWithNothingToRetire() async {
        probe.result = .success([])

        let canSync = await handler.checkIfMigrationNeeded()

        XCTAssertTrue(canSync)
        XCTAssertTrue(zoneManager.usesSealedRecords)
        XCTAssertTrue(ConstStorage.cloudMigratedToV4)
        XCTAssertFalse(ConstStorage.oldVaultsRetirementPending)
    }

    /// The current vault is there, written by another device: this one never retires what it didn't migrate
    func testCurrentVaultFoundIsUsedWithoutRetiringAnything() async {
        probe.result = .success([.v3, .v4])

        let canSync = await handler.checkIfMigrationNeeded()

        XCTAssertTrue(canSync)
        XCTAssertTrue(zoneManager.usesSealedRecords)
        XCTAssertTrue(ConstStorage.cloudMigratedToV4)
        XCTAssertFalse(ConstStorage.oldVaultsRetirementPending)
        XCTAssertFalse(handler.isMigrating)
    }

    func testOnlyTheDeviceThatMigratedRetiresTheOldVault() async {
        probe.result = .success([.v3])

        let canSync = await handler.checkIfMigrationNeeded()
        XCTAssertTrue(canSync)
        XCTAssertTrue(handler.isMigrating)
        XCTAssertEqual(zoneManager.currentZoneID.zoneName, Config.vaultV2)
        XCTAssertFalse(ConstStorage.cloudMigratedToV4)

        // The old vault was read: the current one is written next
        XCTAssertTrue(handler.migrateIfNeeded())
        XCTAssertTrue(zoneManager.usesSealedRecords)
        XCTAssertFalse(ConstStorage.oldVaultsRetirementPending, "Nothing is in the current vault yet")

        // The current vault was written
        XCTAssertFalse(handler.migrateIfNeeded())
        XCTAssertFalse(handler.isMigrating)
        XCTAssertTrue(ConstStorage.cloudMigratedToV4)
        XCTAssertTrue(ConstStorage.oldVaultsRetirementPending)
    }

    /// While this device was about to migrate, another one did and retired the vault
    func testRetiredVaultRestartsTheCheck() async {
        probe.result = .success([.v3])
        _ = await handler.checkIfMigrationNeeded()
        XCTAssertTrue(handler.isMigrating)

        var abandoned = 0
        handler.migrationAbandoned = { dataIsInCurrentVault in
            XCTAssertTrue(dataIsInCurrentVault, "Another device migrated the data")
            abandoned += 1
        }
        handler.restartAfterVaultWasRetired()
        XCTAssertFalse(handler.isMigrating)
        XCTAssertEqual(abandoned, 1)
        // Only a migration that was in progress is abandoned
        handler.restartAfterVaultWasRetired()
        XCTAssertEqual(abandoned, 1)

        probe.result = .success([.v4])
        let canSync = await handler.checkIfMigrationNeeded()
        XCTAssertTrue(canSync)
        XCTAssertEqual(probe.checks, 2)
        XCTAssertTrue(zoneManager.usesSealedRecords)
        XCTAssertFalse(ConstStorage.oldVaultsRetirementPending)
    }

    func testAccountChangeForgetsWhatWasKnownAboutTheVaults() async {
        probe.result = .success([.v3])
        _ = await handler.checkIfMigrationNeeded()
        _ = handler.migrateIfNeeded()
        _ = handler.migrateIfNeeded()
        XCTAssertTrue(ConstStorage.cloudMigratedToV4)
        XCTAssertTrue(ConstStorage.oldVaultsRetirementPending)

        handler.accountChanged()

        XCTAssertFalse(ConstStorage.cloudMigratedToV4)
        XCTAssertFalse(ConstStorage.oldVaultsRetirementPending)
        XCTAssertFalse(handler.isMigrating)
        // The other account is checked on its own
        probe.result = .success([])
        _ = await handler.checkIfMigrationNeeded()
        XCTAssertEqual(probe.checks, 2)
    }

    func testOnlyAnUnknownRecordTypeMeansNothingIsStored() {
        XCTAssertTrue(CloudProbe.meansNothingStored(CKError(.unknownItem)))
        XCTAssertFalse(CloudProbe.meansNothingStored(CKError(.networkUnavailable)))
        XCTAssertFalse(CloudProbe.meansNothingStored(CKError(.networkFailure)))
        XCTAssertFalse(CloudProbe.meansNothingStored(CKError(.serviceUnavailable)))
        XCTAssertFalse(CloudProbe.meansNothingStored(CKError(.requestRateLimited)))
        XCTAssertFalse(CloudProbe.meansNothingStored(CKError(.notAuthenticated)))
        XCTAssertFalse(CloudProbe.meansNothingStored(CloudProbeError.operationFailed))
    }
}
