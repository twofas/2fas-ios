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
@testable import Protection

final class LocalStorageKeyStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var keychain: InMemoryKeychain!

    override func setUp() {
        super.setUp()
        suiteName = "test.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        keychain = InMemoryKeychain()
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        keychain = nil
        super.tearDown()
    }

    private var storedKeyID: String? {
        defaults.string(forKey: LocalStorageKeyStore.keyIDDefaultsKey)
    }

    private func makeStore(protections: [DataKeyProtecting] = [PlainDataKeyProtection()]) -> LocalStorageKeyStore {
        LocalStorageKeyStore(defaults: defaults, keychain: keychain, protections: protections)
    }

    func testLoadWithoutKeyIDDoesNotTouchKeychain() {
        XCTAssertEqual(makeStore().load(), .noKey)
        XCTAssertEqual(keychain.readCount, 0)
    }

    func testCreateStoresItemBeforeKeyID() throws {
        var keyIDsSeenByAdd: [String?] = []
        let defaults: UserDefaults = defaults
        keychain.onAdd = { keyIDsSeenByAdd.append(defaults.string(forKey: LocalStorageKeyStore.keyIDDefaultsKey)) }
        keychain.addError = KeychainItemError.unavailable(errSecNotAvailable)

        XCTAssertThrowsError(try makeStore().create()) {
            XCTAssertEqual($0 as? KeychainItemError, .unavailable(errSecNotAvailable))
        }
        XCTAssertNil(storedKeyID)

        keychain.addError = nil
        _ = try makeStore().create()
        XCTAssertEqual(keyIDsSeenByAdd, [nil, nil])
        XCTAssertNotNil(storedKeyID)
    }

    func testCreateThenLoadReturnsSameKey() throws {
        let key = try makeStore().create()

        XCTAssertEqual(makeStore().load(), .loaded(key))
        let keyID = try XCTUnwrap(storedKeyID.flatMap(UUID.init(uuidString:)))
        XCTAssertEqual(LocalStorageKeyStore.account(for: keyID), "com.2fas.localStorageKey.\(keyID.uuidString)")
        let item = try XCTUnwrap(keychain.items[LocalStorageKeyStore.account(for: keyID)])
        XCTAssertEqual(item.first, PlainDataKeyProtection().kind)
        XCTAssertEqual(item.count, 1 + 32)
    }

    func testKeyIDWithoutKeychainItemIsLost() {
        defaults.set(UUID().uuidString, forKey: LocalStorageKeyStore.keyIDDefaultsKey)

        XCTAssertEqual(makeStore().load(), .lost)
    }

    func testUnreadableKeychainIsUnavailable() throws {
        _ = try makeStore().create()
        keychain.readErrors = [KeychainItemError.unavailable(errSecInteractionNotAllowed)]

        XCTAssertEqual(makeStore().load(), .unavailable)
    }

    func testLeftoverKeychainItemWithoutKeyIDIsIgnored() throws {
        let store = makeStore()
        let oldKey = try store.create()
        let oldKeyID = try XCTUnwrap(storedKeyID)

        store.discardKeyID()
        XCTAssertEqual(store.load(), .noKey)
        XCTAssertEqual(keychain.items.count, 1)

        let newKey = try store.create()
        XCTAssertNotEqual(try XCTUnwrap(storedKeyID), oldKeyID)
        XCTAssertNotEqual(newKey, oldKey)
        XCTAssertEqual(store.load(), .loaded(newKey))
    }

    func testCorruptedPayloadMeansLost() throws {
        let protection = StubProtection(kind: PlainDataKeyProtection().kind)
        _ = try makeStore(protections: [protection]).create()
        protection.unprotectError = DataKeyProtectionError.malformedPayload
        var reports: [String] = []

        XCTAssertEqual(makeStore(protections: [protection]).load { reports.append($0) }, .lost)
        XCTAssertEqual(reports, ["Local storage key of kind 1 is corrupted: malformedPayload"])
    }

    func testPlainProtectionRejectsPayloadOfWrongSize() {
        XCTAssertThrowsError(try PlainDataKeyProtection().unprotect(Data(repeating: 1, count: 31))) {
            XCTAssertEqual($0 as? DataKeyProtectionError, .malformedPayload)
        }
    }

    func testUnavailableProtectionMeansUnavailable() throws {
        let protection = StubProtection(kind: PlainDataKeyProtection().kind)
        _ = try makeStore(protections: [protection]).create()
        protection.unprotectError = NSError(domain: "test", code: 8)
        var reports: [String] = []

        XCTAssertEqual(makeStore(protections: [protection]).load { reports.append($0) }, .unavailable)
        XCTAssertEqual(reports, ["Can't unprotect local storage key of kind 1: test 8"])
    }

    func testUnknownKindMeansLost() throws {
        _ = try makeStore(protections: [StubProtection(kind: 0x7F)]).create()

        XCTAssertEqual(makeStore().load(), .lost)
    }

    func testKnownKindWithoutProtectionIsUnavailable() throws {
        _ = try makeStore().create()

        XCTAssertEqual(makeStore(protections: []).load(), .unavailable)
    }

    func testFailingProtectionFallsBackToNext() throws {
        let failing = StubProtection(kind: 0x02)
        failing.protectError = NSError(domain: "test", code: 8)
        let protections: [DataKeyProtecting] = [failing, PlainDataKeyProtection()]

        let key = try makeStore(protections: protections).create()

        XCTAssertEqual(keychain.items.values.first?.first, PlainDataKeyProtection().kind)
        XCTAssertEqual(makeStore(protections: protections).load(), .loaded(key))
    }
}

final class InMemoryKeychain: KeychainItemStoring {
    var items: [String: Data] = [:]
    private(set) var readCount = 0
    /// Thrown by consecutive reads, one per read
    var readErrors: [Error] = []
    var addError: Error?
    var onAdd: (() -> Void)?

    func read(account: String) throws -> Data? {
        readCount += 1
        if !readErrors.isEmpty {
            throw readErrors.removeFirst()
        }
        return items[account]
    }

    func add(_ data: Data, account: String) throws {
        onAdd?()
        if let addError {
            throw addError
        }
        items[account] = data
    }

    func remove(account: String) {
        items[account] = nil
    }
}

final class StubProtection: DataKeyProtecting {
    let kind: UInt8
    var protectError: Error?
    var unprotectError: Error?

    init(kind: UInt8) {
        self.kind = kind
    }

    func protect(_ dataKey: SymmetricKey) throws -> Data {
        if let protectError {
            throw protectError
        }
        return dataKey.withUnsafeBytes { Data($0) }
    }

    func unprotect(_ payload: Data) throws -> SymmetricKey {
        if let unprotectError {
            throw unprotectError
        }
        return SymmetricKey(data: payload)
    }
}
