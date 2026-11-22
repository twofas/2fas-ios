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
import CryptoKit
import CloudKit
@testable import Common
@testable import Protection
@testable import Sync

// MARK: - Recovering the user's key with the password

final class SyncUserKeyRecoveryTests: XCTestCase {
    private let reference = Data("reference".utf8)
    private var suites: [String] = []
    private var devices: [SyncEncryptionHandler] = []

    override func tearDown() {
        suites.forEach { UserDefaults.standard.removePersistentDomain(forName: $0) }
        devices.forEach { $0.removeSystemEncryptionElements() }
        suites = []
        devices = []
        super.tearDown()
    }

    /// A device of its own: a keychain and defaults nothing else uses
    private func makeDevice() -> SyncEncryptionHandler {
        makeDevice(named: "SyncUserKeyRecoveryTests.\(UUID().uuidString)")
    }

    /// - Parameter name: The same name again is the same device after the app was started again.
    private func makeDevice(named name: String) -> SyncEncryptionHandler {
        suites.append(name)
        let handler = SyncEncryptionHandler(
            reference: reference,
            localEncryptionKeyData: Data(count: 32),
            keychainService: name,
            userDefaults: UserDefaults(suiteName: name)! // swiftlint:disable:this force_unwrapping
        )
        handler.initialize()
        devices.append(handler)
        return handler
    }

    /// A device that protects the cloud with `password`, and what it leaves in the Info record
    private func makeProtectedCloud(password: String) throws -> (info: SyncCloudEncryptionInfo, reference: Data) {
        let device = makeDevice()
        guard case .success = device.create() else {
            throw XCTSkip("The keychain isn't available in this run")
        }
        guard device.hasSystemEncryptionElements else {
            throw XCTSkip("The keychain isn't available in this run")
        }
        device.setUserPassword(password)
        let info = device.cloudEncryptionInfo(cached: .empty)
        return (info, try XCTUnwrap(device.encryptionReference))
    }

    func testPasswordBringsBackTheKeyOnADeviceWithoutAnyKeys() throws {
        let cloud = try makeProtectedCloud(password: "correct horse")
        XCTAssertNotNil(cloud.info.kdfSalt)
        XCTAssertNotNil(cloud.info.kdfParameters)

        let device = makeDevice()
        XCTAssertFalse(device.hasSystemEncryptionElements)
        device.cloudEncryptionInfoFetched(cloud.info)

        XCTAssertTrue(device.recoverUserKey(password: "correct horse", cloudReference: cloud.reference))
        XCTAssertEqual(device.encryptionType, .user)
        XCTAssertTrue(device.hasCompleteEncryptionElements)
        // The same key: what one device seals, the other opens
        XCTAssertEqual(device.decrypt(cloud.reference), reference)
        XCTAssertTrue(device.verifyUserPassword("correct horse"))
    }

    func testWrongPasswordChangesNothing() throws {
        let cloud = try makeProtectedCloud(password: "correct horse")
        let device = makeDevice()
        device.cloudEncryptionInfoFetched(cloud.info)

        XCTAssertFalse(device.recoverUserKey(password: "wrong horse", cloudReference: cloud.reference))
        XCTAssertFalse(device.recoverUserKey(password: "correct horse", cloudReference: nil))
        XCTAssertEqual(device.encryptionType, .system)
        XCTAssertFalse(device.hasSystemEncryptionElements)
        XCTAssertNil(device.decrypt(cloud.reference))
    }

    /// The device has a salt of its own that isn't the one the cloud was protected with
    func testSaltOfTheCloudWinsOverTheLocalOne() throws {
        let cloud = try makeProtectedCloud(password: "correct horse")
        let device = makeDevice()
        guard case .success = device.create() else { throw XCTSkip("The keychain isn't available in this run") }
        XCTAssertNotEqual(device.cloudEncryptionInfo(cached: .empty).kdfSalt, cloud.info.kdfSalt)
        device.cloudEncryptionInfoFetched(cloud.info)

        XCTAssertTrue(device.recoverUserKey(password: "correct horse", cloudReference: cloud.reference))
        XCTAssertEqual(device.cloudEncryptionInfo(cached: .empty).kdfSalt, cloud.info.kdfSalt)
        XCTAssertEqual(device.decrypt(cloud.reference), reference)
    }

    func testCreateKeepsTheExistingSaltAndSystemKey() throws {
        let device = makeDevice()
        guard case .success = device.create() else { throw XCTSkip("The keychain isn't available in this run") }
        let exported = try XCTUnwrap(device.exportKeys())

        guard case .success = device.create() else { return XCTFail("create failed") }
        let exportedAgain = try XCTUnwrap(device.exportKeys())
        XCTAssertEqual(exported.salt, exportedAgain.salt)
        XCTAssertEqual(exported.systemKey, exportedAgain.systemKey)
    }

    // MARK: - The stand-in system key

    /// Without the system key of the iCloud Keychain the recovered key is sealed with a key that stays on the
    /// device – nothing is put into the iCloud Keychain, where it could replace the real key elsewhere
    func testRecoveryWithoutASystemKeyUsesAKeyThatStaysOnTheDevice() throws {
        let cloud = try makeProtectedCloud(password: "correct horse")
        let name = "SyncUserKeyRecoveryTests.\(UUID().uuidString)"
        let device = makeDevice(named: name)
        device.cloudEncryptionInfoFetched(cloud.info)

        XCTAssertTrue(device.recoverUserKey(password: "correct horse", cloudReference: cloud.reference))
        XCTAssertTrue(device.usesLocalSystemKey)
        // Nothing to export: the iCloud Keychain has no system key from this device
        XCTAssertNil(device.exportKeys()?.systemKey)

        // The app is started again: the stand-in still opens the user's key
        let relaunched = makeDevice(named: name)
        relaunched.cloudEncryptionInfoFetched(cloud.info)
        XCTAssertTrue(relaunched.usesLocalSystemKey)
        XCTAssertEqual(relaunched.encryptionType, .user)
        XCTAssertEqual(relaunched.decrypt(cloud.reference), reference)
    }

    /// The real key shows up later (here: imported from a file) – it takes over what the stand-in sealed
    func testRealSystemKeyReplacesTheStandIn() throws {
        let owner = makeDevice()
        guard case .success = owner.create() else { throw XCTSkip("The keychain isn't available in this run") }
        owner.setUserPassword("correct horse")
        let info = owner.cloudEncryptionInfo(cached: .empty)
        let cloudReference = try XCTUnwrap(owner.encryptionReference)
        let keys = try XCTUnwrap(owner.exportKeys())

        let name = "SyncUserKeyRecoveryTests.\(UUID().uuidString)"
        let device = makeDevice(named: name)
        device.cloudEncryptionInfoFetched(info)
        XCTAssertTrue(device.recoverUserKey(password: "correct horse", cloudReference: cloudReference))
        XCTAssertTrue(device.usesLocalSystemKey)

        let result = device.importKeys(
            salt: keys.salt,
            systemKey: keys.systemKey,
            password: nil,
            cloudReference: cloudReference,
            cloudEncryption: .user
        )

        XCTAssertEqual(result, .imported)
        XCTAssertFalse(device.usesLocalSystemKey)
        XCTAssertEqual(device.encryptionType, .user)
        XCTAssertEqual(device.decrypt(cloudReference), reference)
        XCTAssertEqual(device.exportKeys()?.systemKey, keys.systemKey)

        let relaunched = makeDevice(named: name)
        XCTAssertFalse(relaunched.usesLocalSystemKey)
        XCTAssertEqual(relaunched.encryptionType, .user)
        XCTAssertEqual(relaunched.decrypt(cloudReference), reference)
    }

    // MARK: - Importing keys

    func testImportedSystemKeyMustOpenACloudSealedWithIt() throws {
        let owner = makeDevice()
        guard case .success = owner.create() else { throw XCTSkip("The keychain isn't available in this run") }
        let cloudReference = try XCTUnwrap(owner.encryptionReference)
        let keys = try XCTUnwrap(owner.exportKeys())

        let device = makeDevice()
        let wrongKey = Data(repeating: 7, count: 32)
        XCTAssertEqual(
            device.importKeys(
                salt: keys.salt,
                systemKey: wrongKey,
                password: nil,
                cloudReference: cloudReference,
                cloudEncryption: .system
            ),
            .doesNotOpenBackup
        )
        XCTAssertFalse(device.hasSystemEncryptionElements, "Nothing was written")
        XCTAssertNil(device.exportKeys())

        XCTAssertEqual(
            device.importKeys(
                salt: keys.salt,
                systemKey: keys.systemKey,
                password: nil,
                cloudReference: cloudReference,
                cloudEncryption: .system
            ),
            .imported
        )
        XCTAssertEqual(device.encryptionType, .system)
        XCTAssertEqual(device.decrypt(cloudReference), reference)
    }

    func testImportWithAWrongPasswordChangesNothing() throws {
        let owner = makeDevice()
        guard case .success = owner.create() else { throw XCTSkip("The keychain isn't available in this run") }
        owner.setUserPassword("correct horse")
        let info = owner.cloudEncryptionInfo(cached: .empty)
        let cloudReference = try XCTUnwrap(owner.encryptionReference)
        let keys = try XCTUnwrap(owner.exportKeys())

        let device = makeDevice()
        device.cloudEncryptionInfoFetched(info)
        XCTAssertEqual(
            device.importKeys(
                salt: keys.salt,
                systemKey: keys.systemKey,
                password: "wrong horse",
                cloudReference: cloudReference,
                cloudEncryption: .user
            ),
            .doesNotOpenBackup
        )
        XCTAssertNil(device.exportKeys())

        XCTAssertEqual(
            device.importKeys(
                salt: keys.salt,
                systemKey: keys.systemKey,
                password: "correct horse",
                cloudReference: cloudReference,
                cloudEncryption: .user
            ),
            .imported
        )
        XCTAssertEqual(device.encryptionType, .user)
        XCTAssertEqual(device.decrypt(cloudReference), reference)
    }

    func testImportRejectsKeysOfUnexpectedSizes() {
        let device = makeDevice()
        XCTAssertEqual(
            device.importKeys(salt: Data(count: 32), systemKey: Data(count: 16), password: nil),
            .invalidKeys
        )
        XCTAssertEqual(
            device.importKeys(salt: Data(count: 4), systemKey: Data(count: 32), password: nil),
            .invalidKeys
        )
        XCTAssertNil(device.exportKeys())
    }
}
