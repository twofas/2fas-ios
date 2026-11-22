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
@testable import Protection
@testable import Storage
@testable import Sync

/// The sync engine from end to end: real local stores, the real `SyncHandler` and everything under it, and a
/// cloud in memory in place of iCloud
final class SyncEngineTests: XCTestCase {
    private var cloud: FakeCloud!
    private var keychainService = ""
    private var devices: [SyncTestDevice] = []
    private var savedMigratedToV4 = false
    private var savedResetRequired = false

    override func setUp() {
        super.setUp()
        EncryptionHolder.initialize(with: LocalKeyEncryption())
        savedMigratedToV4 = ConstStorage.cloudMigratedToV4
        savedResetRequired = ConstStorage.syncResetRequired
        ConstStorage.cloudMigratedToV4 = true
        ConstStorage.syncResetRequired = false
        cloud = FakeCloud()
        keychainService = "SyncEngineTests.\(UUID().uuidString)"
    }

    override func tearDown() {
        devices.forEach { $0.tearDown() }
        devices = []
        cloud = nil
        ConstStorage.cloudMigratedToV4 = savedMigratedToV4
        ConstStorage.syncResetRequired = savedResetRequired
        super.tearDown()
    }

    private func makeDevice(_ name: String) -> SyncTestDevice {
        let device = SyncTestDevice(name: name, cloud: cloud, keychainService: keychainService)
        device.turnBackupOn()
        devices.append(device)
        return device
    }

    private func services(inCloud cloud: FakeCloud) -> Int {
        cloud.records(in: Config.vaultV3, ofType: .service4).count
    }

    private func deletions(inCloud cloud: FakeCloud) -> Int {
        cloud.records(in: Config.vaultV3, ofType: .deletedService).count
    }

    // MARK: - The basics

    func testServiceAddedOnOneDeviceReachesTheOther() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA", name: "Alpha")

        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        XCTAssertEqual(tablet.secrets, ["AAAA"])
        XCTAssertEqual(tablet.name(of: "AAAA"), "Alpha")
        XCTAssertEqual(services(inCloud: cloud), 1)
        XCTAssertEqual(cloud.records(in: Config.vaultV3, ofType: .info).count, 1)
    }

    /// The watch: a device that only updates the services of the vault. With no vault in the cloud (erased from the phone, another
    /// account) it must not write its own data there as a new backup.
    func testWatchNeverWritesToAnEmptyCloud() {
        let watch = makeDevice("watch")
        watch.syncHandler.onlyUpdatesServices = true
        watch.addService("AAAA", name: "Alpha")
        watch.syncHandler.firstStart()

        synchronizeUntilSettled([watch], cloud: cloud)

        XCTAssertTrue(cloud.operations.isEmpty)
        XCTAssertEqual(services(inCloud: cloud), 0)
        XCTAssertTrue(cloud.records(in: Config.vaultV3, ofType: .info).isEmpty)
    }

    func testWatchReadsTheVaultAndSendsNothingOfItsOwn() {
        let phone = makeDevice("phone")
        let watch = makeDevice("watch")
        watch.syncHandler.onlyUpdatesServices = true
        phone.addService("AAAA", name: "Alpha")
        synchronizeUntilSettled([phone], cloud: cloud)
        let operationsOfThePhone = cloud.operations.count

        // Something the cloud doesn't have, as a stale mirror would
        watch.addService("BBBB", name: "Stale")
        watch.syncHandler.firstStart()
        synchronizeUntilSettled([watch, phone], cloud: cloud)

        XCTAssertTrue(watch.secrets.contains("AAAA"))
        XCTAssertEqual(cloud.operations.count, operationsOfThePhone)
        XCTAssertEqual(services(inCloud: cloud), 1)
        XCTAssertEqual(phone.secrets, ["AAAA"])
    }

    /// The one change the watch makes: the counter of an HOTP token used on it. Sent as a change of the service
    /// the vault already has; what the watch trashed or added on its own isn't.
    func testWatchSendsOnlyAChangeOfAServiceTheVaultHas() {
        let phone = makeDevice("phone")
        let watch = makeDevice("watch")
        watch.syncHandler.onlyUpdatesServices = true
        phone.addService("AAAA", name: "Alpha")
        phone.addService("BBBB", name: "Beta")
        synchronizeUntilSettled([phone, watch], cloud: cloud)
        XCTAssertEqual(watch.secrets, ["AAAA", "BBBB"])

        pause()
        watch.renameService("AAAA", to: "Changed on the watch")
        watch.trashService("BBBB")
        watch.addService("CCCC", name: "Only on the watch")
        synchronizeUntilSettled([watch, phone], cloud: cloud)

        XCTAssertEqual(phone.name(of: "AAAA"), "Changed on the watch")
        XCTAssertEqual(phone.secrets, ["AAAA", "BBBB"])
        XCTAssertEqual(services(inCloud: cloud), 2)
        XCTAssertEqual(deletions(inCloud: cloud), 0)
        XCTAssertEqual(cloud.records(in: Config.vaultV3, ofType: .info).count, 1)
    }

    func testEditReachesTheOtherDevice() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA", name: "Alpha")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        pause()
        tablet.renameService("AAAA", to: "Renamed")
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(phone.name(of: "AAAA"), "Renamed")
        XCTAssertEqual(tablet.name(of: "AAAA"), "Renamed")
        XCTAssertEqual(services(inCloud: cloud), 1)
    }

    func testDeletionReachesTheOtherDeviceThroughItsRecord() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA")
        phone.addService("BBBB")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        pause()
        phone.trashService("AAAA")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        XCTAssertEqual(tablet.secrets, ["BBBB"])
        XCTAssertEqual(tablet.trashedSecrets, ["AAAA"])
        XCTAssertEqual(services(inCloud: cloud), 1)
        XCTAssertEqual(deletions(inCloud: cloud), 1)
    }

    func testRestoringFromTrashBringsTheServiceBackEverywhere() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)
        pause()
        phone.trashService("AAAA")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)
        XCTAssertEqual(tablet.trashedSecrets, ["AAAA"])

        pause()
        tablet.untrashService("AAAA")
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(phone.secrets, ["AAAA"])
        XCTAssertEqual(tablet.secrets, ["AAAA"])
        XCTAssertEqual(phone.trashedSecrets, [])
        XCTAssertEqual(services(inCloud: cloud), 1)
        XCTAssertEqual(deletions(inCloud: cloud), 0, "The record of the deletion is gone with the deletion")
    }

    func testSectionsAndTheirServicesReachTheOtherDevice() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        let work = phone.createSection("Work")
        phone.addService("AAAA", sectionID: work)
        phone.addService("BBBB")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        XCTAssertEqual(tablet.sectionTitles, ["Work"])
        XCTAssertEqual(tablet.repo.section(for: "AAAA")?.title, "Work")
        XCTAssertNil(tablet.repo.section(for: "BBBB"))

        pause()
        tablet.deleteSection(work)
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(phone.sectionTitles, [])
        XCTAssertEqual(phone.secrets, ["AAAA", "BBBB"], "The services of a deleted section stay")
        XCTAssertEqual(cloud.records(in: Config.vaultV3, ofType: .section2).count, 0)
        XCTAssertEqual(cloud.records(in: Config.vaultV3, ofType: .deletedSection).count, 1)
    }

    func testEmptyDevicesSettleWithNothingButTheInfoRecord() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")

        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        XCTAssertEqual(cloud.records(in: Config.vaultV3).count, 1)
        XCTAssertEqual(cloud.records(in: Config.vaultV3, ofType: .info).count, 1)
    }

    /// Once the devices agree, syncing again sends nothing
    func testSettledDevicesStayQuiet() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        (0..<20).forEach { phone.addService("SECRET\($0)") }
        let section = phone.createSection("Work")
        phone.moveService("SECRET3", toSection: section)
        synchronizeUntilSettled([phone, tablet], cloud: cloud)
        let operations = cloud.operations.count

        for _ in 0..<3 {
            XCTAssertEqual(synchronize(phone), .finished)
            XCTAssertEqual(synchronize(tablet), .finished)
        }

        XCTAssertEqual(cloud.operations.count, operations)
    }

    // MARK: - Both devices at once

    func testServicesAddedOnBothDevicesEndUpOnBoth() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA")
        tablet.addService("BBBB")

        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        XCTAssertEqual(phone.secrets, ["AAAA", "BBBB"])
        XCTAssertEqual(tablet.secrets, ["AAAA", "BBBB"])
        XCTAssertEqual(services(inCloud: cloud), 2)
    }

    /// The same service added on two devices before either synced is one service
    func testTheSameServiceAddedOnBothDevicesIsNotDuplicated() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA", name: "From phone")
        pause()
        tablet.addService("AAAA", name: "From tablet")

        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        XCTAssertEqual(phone.secrets, ["AAAA"])
        XCTAssertEqual(tablet.secrets, ["AAAA"])
        XCTAssertEqual(services(inCloud: cloud), 1)
        XCTAssertEqual(phone.name(of: "AAAA"), tablet.name(of: "AAAA"))
    }

    /// A device that already has services joins a backup that has others: nothing is lost on either side
    func testDeviceWithItsOwnServicesJoinsAnExistingBackup() {
        let phone = makeDevice("phone")
        phone.addService("AAAA")
        phone.addService("BBBB")
        synchronizeUntilSettled([phone], cloud: cloud)

        let tablet = makeDevice("tablet")
        tablet.addService("CCCC")
        tablet.addService("BBBB")
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(phone.secrets, ["AAAA", "BBBB", "CCCC"])
        XCTAssertEqual(tablet.secrets, ["AAAA", "BBBB", "CCCC"])
        XCTAssertEqual(services(inCloud: cloud), 3)
    }

    // MARK: - More than one operation takes

    /// More services than CloudKit takes in one operation
    func testBulkAddIsSentInOperationsTheCloudTakes() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        let secrets = Set((0..<1000).map { "BULKSECRET\($0)" })
        secrets.forEach { phone.addService($0) }

        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        XCTAssertEqual(cloud.oversizedOperations, 0)
        XCTAssertGreaterThanOrEqual(cloud.appliedOperations, 3)
        XCTAssertEqual(services(inCloud: cloud), 1000)
        XCTAssertEqual(tablet.secrets, secrets)
        XCTAssertEqual(phone.secrets, secrets)
    }

    /// Many deletions and many additions in the same sync
    func testBulkDeletionsAndAdditionsInOneSync() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        let old = (0..<450).map { "OLDSECRET\($0)" }
        old.forEach { phone.addService($0) }
        synchronizeUntilSettled([phone, tablet], cloud: cloud)
        XCTAssertEqual(tablet.secrets, Set(old))

        pause()
        let new = Set((0..<450).map { "NEWSECRET\($0)" })
        // From the top of the list: trashing a service logs a change of every service after it (their
        // positions shift)
        old.forEach { phone.trashService($0) }
        new.forEach { phone.addService($0) }
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        XCTAssertEqual(cloud.oversizedOperations, 0)
        XCTAssertEqual(cloud.refusals, [])
        XCTAssertEqual(services(inCloud: cloud), 450)
        XCTAssertEqual(deletions(inCloud: cloud), 450)
        XCTAssertEqual(tablet.secrets, new)
        XCTAssertEqual(tablet.trashedSecrets, Set(old))
        XCTAssertEqual(phone.secrets, new)
    }

    // MARK: - Change log
    
    /// Trashing from the top of a long list modifies every service behind
    func testTrashingOnLongListIsFast() {
        let phone = makeDevice("phone")
        let secrets = (0..<450).map { "SECRET\($0)" }
        secrets.forEach { phone.addService($0) }
        
        let start = Date()
        secrets.prefix(20).forEach { phone.trashService($0) }
        let perTrash = Date().timeIntervalSince(start) / 20
        
        XCTAssertLessThan(perTrash, 0.1)
        XCTAssertEqual(phone.trashedSecrets, Set(secrets.prefix(20)))
    }

    func testDeletionAndAdditionInOneOperation() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)
        let operationsBefore = cloud.appliedOperations

        pause()
        phone.trashService("AAAA")
        phone.addService("BBBB")
        XCTAssertEqual(synchronize(phone), .finished)

        XCTAssertEqual(cloud.appliedOperations, operationsBefore + 1, "One operation carries both")
        XCTAssertEqual(services(inCloud: cloud), 1)
        XCTAssertEqual(deletions(inCloud: cloud), 1)

        synchronizeUntilSettled([tablet, phone], cloud: cloud)
        XCTAssertEqual(tablet.secrets, ["BBBB"])
        XCTAssertEqual(tablet.trashedSecrets, ["AAAA"])
    }

    // MARK: - Conflicts

    /// Both devices changed the same service; the one that syncs second is refused and has to merge
    func testLaterEditWinsWhenBothDevicesEditedTheService() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA", name: "Original")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        pause()
        phone.renameService("AAAA", to: "Phone edit")
        pause()
        tablet.renameService("AAAA", to: "Tablet edit")
        XCTAssertEqual(synchronize(phone), .finished)
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(tablet.name(of: "AAAA"), "Tablet edit")
        XCTAssertEqual(phone.name(of: "AAAA"), "Tablet edit")
        XCTAssertEqual(services(inCloud: cloud), 1)
    }

    /// Another device writes the record between this device's fetch and its save: the save is refused, and the
    /// device fetches again and gets its change through
    func testRefusedSaveIsFetchedAgainAndRetried() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA", name: "Original")
        phone.addService("BBBB")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        pause()
        tablet.renameService("AAAA", to: "Tablet edit")
        tablet.cloudKit.beforeNextModification = { [cloud] in
            cloud?.resaveRecords(in: Config.vaultV3, ofType: .service4)
        }
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(cloud.refusedOperations, 1)
        XCTAssertEqual(tablet.cloudKit.refetchesAfterRefusal, 1)
        XCTAssertEqual(phone.name(of: "AAAA"), "Tablet edit")
        XCTAssertEqual(phone.secrets, ["AAAA", "BBBB"])
        XCTAssertEqual(tablet.secrets, ["AAAA", "BBBB"])
        XCTAssertEqual(services(inCloud: cloud), 2)
    }

    func testEarlierEditLosesWhenItSyncsSecond() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA", name: "Original")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        pause()
        tablet.renameService("AAAA", to: "Tablet edit")
        pause()
        phone.renameService("AAAA", to: "Phone edit")
        XCTAssertEqual(synchronize(phone), .finished)
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(tablet.name(of: "AAAA"), "Phone edit")
        XCTAssertEqual(phone.name(of: "AAAA"), "Phone edit")
    }

    /// Deleted on one device, changed later on another: the change wins and the deletion is taken back
    func testServiceChangedAfterItWasDeletedElsewhereSurvives() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA", name: "Original")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        pause()
        phone.trashService("AAAA")
        pause()
        tablet.renameService("AAAA", to: "Still needed")
        XCTAssertEqual(synchronize(phone), .finished)
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(tablet.secrets, ["AAAA"])
        XCTAssertEqual(phone.secrets, ["AAAA"])
        XCTAssertEqual(phone.name(of: "AAAA"), "Still needed")
        XCTAssertEqual(phone.trashedSecrets, [])
        XCTAssertEqual(services(inCloud: cloud), 1)
        XCTAssertEqual(deletions(inCloud: cloud), 0)
    }

    /// Changed on one device, deleted later on another: the deletion wins
    func testServiceDeletedAfterItWasChangedElsewhereIsDeleted() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA", name: "Original")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        pause()
        tablet.renameService("AAAA", to: "Edited")
        pause()
        phone.trashService("AAAA")
        XCTAssertEqual(synchronize(phone), .finished)
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(tablet.secrets, [])
        XCTAssertEqual(tablet.trashedSecrets, ["AAAA"])
        XCTAssertEqual(phone.secrets, [])
        XCTAssertEqual(services(inCloud: cloud), 0)
        XCTAssertEqual(deletions(inCloud: cloud), 1)
    }

    /// A service that was only pushed to another position isn't changed: its deletion, made elsewhere before,
    /// still holds
    func testReorderingDoesNotBringADeletedServiceBack() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA")
        phone.addService("BBBB")
        phone.addService("CCCC")
        let section = phone.createSection("Work")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        pause()
        tablet.trashService("CCCC")
        pause()
        // Moves AAAA away – BBBB and CCCC shift on the phone and their records are written again
        phone.moveService("AAAA", toSection: section)
        XCTAssertEqual(synchronize(phone), .finished)
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(tablet.secrets, ["AAAA", "BBBB"])
        XCTAssertEqual(phone.secrets, ["AAAA", "BBBB"])
        XCTAssertEqual(phone.trashedSecrets, ["CCCC"])
        XCTAssertEqual(services(inCloud: cloud), 2)
        XCTAssertEqual(deletions(inCloud: cloud), 1)
    }

    func testTheSameServiceDeletedOnBothDevicesIsOneDeletion() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        phone.addService("AAAA")
        phone.addService("BBBB")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        pause()
        phone.trashService("AAAA")
        pause()
        tablet.trashService("AAAA")
        synchronizeUntilSettled([phone, tablet], cloud: cloud)

        XCTAssertEqual(cloud.refusals, [])
        XCTAssertEqual(phone.secrets, ["BBBB"])
        XCTAssertEqual(tablet.secrets, ["BBBB"])
        XCTAssertEqual(services(inCloud: cloud), 1)
        XCTAssertEqual(deletions(inCloud: cloud), 1)
    }

    // MARK: - Devices that come later

    /// A new device gets what is there and nothing of what was deleted
    func testNewDeviceGetsOnlyWhatIsNotDeleted() {
        let phone = makeDevice("phone")
        phone.addService("AAAA")
        phone.addService("BBBB")
        synchronizeUntilSettled([phone], cloud: cloud)
        pause()
        phone.trashService("AAAA")
        synchronizeUntilSettled([phone], cloud: cloud)

        let watchlessTablet = makeDevice("tablet")
        synchronizeUntilSettled([watchlessTablet, phone], cloud: cloud)

        XCTAssertEqual(watchlessTablet.secrets, ["BBBB"])
        XCTAssertEqual(watchlessTablet.trashedSecrets, [])
        XCTAssertEqual(phone.secrets, ["BBBB"])
        XCTAssertEqual(deletions(inCloud: cloud), 1)
    }

    /// A device that still has a service that was deleted elsewhere in the meantime: it isn't sent back
    func testDeviceWithAnOldCopyOfADeletedServiceDoesNotBringItBack() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        tablet.addService("AAAA")
        pause()
        phone.addService("AAAA")
        phone.addService("BBBB")
        synchronizeUntilSettled([phone], cloud: cloud)
        pause()
        phone.trashService("AAAA")
        synchronizeUntilSettled([phone], cloud: cloud)

        // The tablet joins only now, with its copy from before the deletion
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(tablet.secrets, ["BBBB"])
        XCTAssertEqual(tablet.trashedSecrets, ["AAAA"])
        XCTAssertEqual(phone.secrets, ["BBBB"])
        XCTAssertEqual(services(inCloud: cloud), 1)
        XCTAssertEqual(deletions(inCloud: cloud), 1)
    }

    /// The same, but the device added the service after it was deleted elsewhere: it's wanted again
    func testServiceAddedAfterItsDeletionElsewhereComesBack() {
        let phone = makeDevice("phone")
        phone.addService("AAAA")
        phone.addService("BBBB")
        synchronizeUntilSettled([phone], cloud: cloud)
        pause()
        phone.trashService("AAAA")
        synchronizeUntilSettled([phone], cloud: cloud)

        pause()
        let tablet = makeDevice("tablet")
        tablet.addService("AAAA", name: "Added again")
        synchronizeUntilSettled([tablet, phone], cloud: cloud)

        XCTAssertEqual(tablet.secrets, ["AAAA", "BBBB"])
        XCTAssertEqual(phone.secrets, ["AAAA", "BBBB"])
        XCTAssertEqual(phone.name(of: "AAAA"), "Added again")
        XCTAssertEqual(services(inCloud: cloud), 2)
        XCTAssertEqual(deletions(inCloud: cloud), 0)
    }

    /// Three devices changing different things at once all end with the same
    func testThreeDevicesConverge() {
        let phone = makeDevice("phone")
        let tablet = makeDevice("tablet")
        let second = makeDevice("second phone")
        (0..<10).forEach { phone.addService("SHARED\($0)") }
        synchronizeUntilSettled([phone, tablet, second], cloud: cloud)

        pause()
        phone.trashService("SHARED0")
        phone.addService("FROMPHONE")
        tablet.renameService("SHARED1", to: "Renamed on tablet")
        tablet.addService("FROMTABLET")
        second.trashService("SHARED2")
        let section = second.createSection("Second")
        second.moveService("SHARED3", toSection: section)
        synchronizeUntilSettled([phone, tablet, second], cloud: cloud, maxRounds: 12)

        let expected = Set((3..<10).map { "SHARED\($0)" } + ["SHARED1", "FROMPHONE", "FROMTABLET"])
        for device in [phone, tablet, second] {
            XCTAssertEqual(device.secrets, expected, device.name)
            XCTAssertEqual(device.name(of: "SHARED1"), "Renamed on tablet", device.name)
            XCTAssertEqual(device.sectionTitles, ["Second"], device.name)
            XCTAssertEqual(device.repo.section(for: "SHARED3")?.title, "Second", device.name)
        }
        XCTAssertEqual(services(inCloud: cloud), expected.count)
        XCTAssertEqual(deletions(inCloud: cloud), 2)
        XCTAssertEqual(cloud.oversizedOperations, 0)
    }

    /// Lets the clock move: what happened later has to have a later date
    private func pause() {
        Thread.sleep(forTimeInterval: 0.02)
    }
}
