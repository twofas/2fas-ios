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

    private func assertKeyInvalidated(
        _ expression: @autoclosure () throws -> some Any,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try expression(), file: file, line: line) {
            guard case .keyInvalidated? = $0 as? DataKeyProtectionError else {
                return XCTFail("Unexpected error: \($0)", file: file, line: line)
            }
        }
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

    func testInvalidatedProtectionMeansLost() throws {
        let protection = StubProtection(kind: 0x02)
        _ = try makeStore(protections: [protection]).create()
        protection.unprotectError = DataKeyProtectionError.keyInvalidated(domain: "test", code: 7)
        var reports: [String] = []

        XCTAssertEqual(makeStore(protections: [protection]).load { reports.append($0) }, .lost)
        XCTAssertEqual(
            reports,
            [#"Local storage key of kind 2 is invalidated: keyInvalidated(domain: "test", code: 7)"#]
        )
    }

    func testUnavailableProtectionMeansUnavailable() throws {
        let protection = StubProtection(kind: 0x02)
        _ = try makeStore(protections: [protection]).create()
        protection.unprotectError = DataKeyProtectionError.unavailable(domain: "test", code: 8)
        var reports: [String] = []

        XCTAssertEqual(makeStore(protections: [protection]).load { reports.append($0) }, .unavailable)
        XCTAssertEqual(
            reports,
            [#"Can't unprotect local storage key of kind 2: unavailable(domain: "test", code: 8)"#]
        )
    }

    func testUnknownKindMeansLost() throws {
        _ = try makeStore(protections: [StubProtection(kind: 0x7F)]).create()

        XCTAssertEqual(makeStore().load(), .lost)
    }

    func testKnownKindWithoutProtectionIsUnavailable() throws {
        _ = try makeStore(protections: [StubProtection(kind: SecureEnclaveDataKeyProtection().kind)]).create()

        XCTAssertEqual(makeStore(protections: [PlainDataKeyProtection()]).load(), .unavailable)
    }

    func testFailingProtectionFallsBackToNext() throws {
        let failing = StubProtection(kind: 0x02)
        failing.protectError = DataKeyProtectionError.unavailable(domain: "test", code: 8)
        let protections: [DataKeyProtecting] = [failing, PlainDataKeyProtection()]

        let key = try makeStore(protections: protections).create()

        XCTAssertEqual(keychain.items.values.first?.first, PlainDataKeyProtection().kind)
        XCTAssertEqual(makeStore(protections: protections).load(), .loaded(key))
    }

    func testSecureEnclaveRoundTripAndGarbageIsInvalidated() throws {
        try XCTSkipUnless(SecureEnclave.isAvailable)
        let protection = SecureEnclaveDataKeyProtection()
        let key = SymmetricKey(size: .bits256)

        XCTAssertEqual(try protection.unprotect(protection.protect(key)), key)
        // Caught by the framing check, never reaches Secure Enclave
        XCTAssertThrowsError(try protection.unprotect(Data(repeating: 1, count: 200))) {
            XCTAssertEqual($0 as? DataKeyProtectionError, .malformedPayload)
        }
    }

    /// Reaches Secure Enclave with a real payload
    func testSecureEnclaveTamperedPayloadIsInvalidated() throws {
        try XCTSkipUnless(SecureEnclave.isAvailable)
        let protection = SecureEnclaveDataKeyProtection()
        let payload = [UInt8](try protection.protect(SymmetricKey(size: .bits256)))
        let ephemeralKeyStart = 2 + (Int(payload[0]) << 8 | Int(payload[1]))
        let sealedStart = ephemeralKeyStart + 65

        var flippedSealedBox = payload
        flippedSealedBox[sealedStart + 12 + 4] ^= 0xFF
        var foreignEphemeralKey = payload
        foreignEphemeralKey.replaceSubrange(
            ephemeralKeyStart..<sealedStart,
            with: P256.KeyAgreement.PrivateKey().publicKey.x963Representation
        )
        var corruptedSecureEnclaveKey = payload
        corruptedSecureEnclaveKey[2 + (ephemeralKeyStart - 2) / 2] ^= 0xFF

        assertKeyInvalidated(try protection.unprotect(Data(flippedSealedBox)))
        assertKeyInvalidated(try protection.unprotect(Data(foreignEphemeralKey)))
        assertKeyInvalidated(try protection.unprotect(Data(corruptedSecureEnclaveKey)))
    }

    /// Never reaches Secure Enclave
    func testSecureEnclaveMalformedPayloadIsInvalidated() {
        let protection = SecureEnclaveDataKeyProtection()
        let noSealedBox = Data([0x00, 0x10]) + Data(repeating: 1, count: 16 + 65)
        let framingErrors = [Data(), Data([0x00]), Data(repeating: 1, count: 200), noSealedBox]

        for payload in framingErrors {
            XCTAssertThrowsError(try protection.unprotect(payload)) {
                XCTAssertEqual($0 as? DataKeyProtectionError, .malformedPayload)
            }
        }
        let invalidEphemeralKey = noSealedBox + Data(repeating: 1, count: 12 + 32 + 16)
        assertKeyInvalidated(try protection.unprotect(invalidEphemeralKey))
    }

    func testSecureEnclaveKeyErrorClassification() {
        let invalidated = [
            NSError(domain: "CryptoTokenKit", code: -3),
            NSError(domain: "CryptoTokenKit", code: -10),
            NSError(domain: NSOSStatusErrorDomain, code: Int(errSecParam))
        ]
        let unavailable = [
            NSError(domain: "CryptoTokenKit", code: -2),
            NSError(domain: "CryptoTokenKit", code: -7),
            NSError(domain: "CryptoTokenKit", code: -9),
            NSError(domain: NSOSStatusErrorDomain, code: Int(errSecMissingEntitlement)),
            NSError(domain: NSOSStatusErrorDomain, code: Int(errSecInteractionNotAllowed)),
            NSError(domain: NSOSStatusErrorDomain, code: Int(errSecNotAvailable)),
            NSError(domain: NSCocoaErrorDomain, code: NSXPCConnectionInterrupted),
            NSError(domain: "Unrelated", code: -3)
        ]

        for error in invalidated {
            XCTAssertEqual(
                SecureEnclaveDataKeyProtection.classify(error),
                .keyInvalidated(domain: error.domain, code: error.code)
            )
        }
        for error in unavailable {
            XCTAssertEqual(
                SecureEnclaveDataKeyProtection.classify(error),
                .unavailable(domain: error.domain, code: error.code)
            )
        }
    }

    func testSecureEnclaveKeyCryptoKitErrorClassification() {
        for error in [CryptoKitError.incorrectKeySize, .incorrectParameterSize] {
            guard case .keyInvalidated = SecureEnclaveDataKeyProtection.classify(error) else {
                return XCTFail("\(error) should mean the key is invalidated")
            }
        }
        let coreCryptoError = CryptoKitError.underlyingCoreCryptoError(error: 1)
        guard case .unavailable = SecureEnclaveDataKeyProtection.classify(coreCryptoError) else {
            return XCTFail("Underlying CoreCrypto error should mean unavailable")
        }
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
