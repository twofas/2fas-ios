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
import Common
@testable import Protection

final class LocalStorageCipherImplTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var keychain: InMemoryKeychain!
    private var currentDate = Date(timeIntervalSinceReferenceDate: 0)
    private let plaintext = Data("secret payload".utf8)
    private let ad = Data("2fas.ServiceEntity.v1".utf8)
    private let context = "ServiceEntity.secret"

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

    private func makeKeyStore() -> LocalStorageKeyStore {
        LocalStorageKeyStore(defaults: defaults, keychain: keychain, protections: [PlainDataKeyProtection()])
    }

    private func makeCipher(canCreateKey: Bool) -> LocalStorageCipherImpl {
        // The cipher never outlives the test, so capturing self strongly is fine
        LocalStorageCipherImpl(keyStore: makeKeyStore(), canCreateKey: canCreateKey) { self.currentDate }
    }

    private func assertThrows(
        _ expected: LocalStorageCipherError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ expression: () throws -> some Any
    ) {
        XCTAssertThrowsError(try expression(), file: file, line: line) {
            XCTAssertEqual($0 as? LocalStorageCipherError, expected, file: file, line: line)
        }
    }

    func testExtensionCannotCreateKey() {
        let cipher = makeCipher(canCreateKey: false)

        XCTAssertEqual(cipher.state, .noKey)
        assertThrows(.noKey) { try cipher.seal(plaintext, associatedData: ad) }
        assertThrows(.noKey) { try cipher.lookupHash(for: "SECRET", context: context) }
        XCTAssertEqual(cipher.state, .noKey)
        XCTAssertTrue(keychain.items.isEmpty)
        XCTAssertNil(defaults.string(forKey: LocalStorageKeyStore.keyIDDefaultsKey))
    }

    func testMainAppCreatesKeyOnFirstSeal() throws {
        let cipher = makeCipher(canCreateKey: true)

        let sealed = try cipher.seal(plaintext, associatedData: ad)

        XCTAssertEqual(cipher.state, .available)
        XCTAssertEqual(try cipher.open(sealed, associatedData: ad), plaintext)
        let extensionCipher = makeCipher(canCreateKey: false)
        XCTAssertEqual(try extensionCipher.open(sealed, associatedData: ad), plaintext)
        XCTAssertEqual(
            try extensionCipher.lookupHash(for: "SECRET", context: context),
            try cipher.lookupHash(for: "SECRET", context: context)
        )
    }

    func testLookupHashNeverCreatesKey() {
        let cipher = makeCipher(canCreateKey: true)

        assertThrows(.noKey) { try cipher.lookupHash(for: "SECRET", context: context) }
        assertThrows(.noKey) { try cipher.open(Data(count: 40), associatedData: ad) }
        XCTAssertEqual(cipher.state, .noKey)
        XCTAssertTrue(keychain.items.isEmpty)
    }

    func testMainAppPrepareForWritingCreatesKey() throws {
        let cipher = makeCipher(canCreateKey: true)
        XCTAssertEqual(cipher.state, .noKey)

        try cipher.prepareForWriting()

        XCTAssertEqual(cipher.state, .available)
        XCTAssertEqual(keychain.items.count, 1)
        XCTAssertNoThrow(try cipher.lookupHash(for: "SECRET", context: context))
        try cipher.prepareForWriting()
        XCTAssertEqual(keychain.items.count, 1)
    }

    func testExtensionPrepareForWritingThrowsNoKey() {
        let cipher = makeCipher(canCreateKey: false)

        assertThrows(.noKey) { try cipher.prepareForWriting() }
        XCTAssertEqual(cipher.state, .noKey)
        XCTAssertTrue(keychain.items.isEmpty)
        XCTAssertNil(defaults.string(forKey: LocalStorageKeyStore.keyIDDefaultsKey))
    }

    func testPrepareForWritingWithLostKeyThrowsKeyLost() {
        defaults.set(UUID().uuidString, forKey: LocalStorageKeyStore.keyIDDefaultsKey)
        let cipher = makeCipher(canCreateKey: true)

        assertThrows(.keyLost) { try cipher.prepareForWriting() }
        XCTAssertEqual(cipher.state, .keyLost)
        XCTAssertTrue(keychain.items.isEmpty)
    }

    func testUnavailableIsRetriedAfterOneSecond() throws {
        _ = try makeKeyStore().create()
        keychain.readErrors = [KeychainItemError.unavailable(errSecInteractionNotAllowed)]
        let cipher = makeCipher(canCreateKey: true)

        XCTAssertEqual(cipher.state, .keyUnavailable)
        assertThrows(.keyUnavailable) { try cipher.seal(plaintext, associatedData: ad) }
        currentDate += 0.5
        XCTAssertEqual(cipher.state, .keyUnavailable)
        XCTAssertEqual(keychain.readCount, 1)
        XCTAssertEqual(keychain.items.count, 1)

        currentDate += 0.6
        XCTAssertEqual(cipher.state, .available)
        XCTAssertNoThrow(try cipher.seal(plaintext, associatedData: ad))
        currentDate += 10
        XCTAssertEqual(cipher.state, .available)
        XCTAssertEqual(keychain.readCount, 2)
    }

    func testNoKeyIsRetriedAfterOneSecond() throws {
        let cipher = makeCipher(canCreateKey: false)
        XCTAssertEqual(cipher.state, .noKey)

        _ = try makeKeyStore().create()
        currentDate += 0.5
        XCTAssertEqual(cipher.state, .noKey)
        currentDate += 0.6
        XCTAssertEqual(cipher.state, .available)
    }

    func testExtensionLoadsTheKeyThatReplacedTheLostOne() throws {
        let mainApp = makeCipher(canCreateKey: true)
        let appExtension = makeCipher(canCreateKey: false)
        _ = try mainApp.seal(plaintext, associatedData: ad)
        XCTAssertEqual(appExtension.state, .available)
        XCTAssertFalse(appExtension.reloadKeyIfChanged())

        // The main app resets the local data: the key is discarded and a new one is created
        mainApp.discardLostKey()
        let sealed = try mainApp.seal(plaintext, associatedData: ad)
        XCTAssertThrowsError(try appExtension.open(sealed, associatedData: ad))

        XCTAssertTrue(appExtension.reloadKeyIfChanged())
        XCTAssertEqual(try appExtension.open(sealed, associatedData: ad), plaintext)
        XCTAssertFalse(appExtension.reloadKeyIfChanged())
    }

    func testLostKeyIsCheckedAgainOnReload() throws {
        let keyID = UUID().uuidString
        defaults.set(keyID, forKey: LocalStorageKeyStore.keyIDDefaultsKey)
        let appExtension = makeCipher(canCreateKey: false)
        XCTAssertEqual(appExtension.state, .keyLost)

        // The same key ID – the stores weren't replaced, but the key is read again
        XCTAssertFalse(appExtension.reloadKeyIfChanged())
        XCTAssertEqual(appExtension.state, .keyLost)
        XCTAssertEqual(keychain.readCount, 2)

        let mainApp = makeCipher(canCreateKey: true)
        mainApp.discardLostKey()
        _ = try mainApp.seal(plaintext, associatedData: ad)

        XCTAssertTrue(appExtension.reloadKeyIfChanged())
        XCTAssertEqual(appExtension.state, .available)
    }

    func testReloadBeforeFirstUseReportsNoChange() {
        XCTAssertFalse(makeCipher(canCreateKey: false).reloadKeyIfChanged())
    }

    func testDiscardLostKeyResetsToNoKey() throws {
        defaults.set(UUID().uuidString, forKey: LocalStorageKeyStore.keyIDDefaultsKey)
        let cipher = makeCipher(canCreateKey: true)

        XCTAssertEqual(cipher.state, .keyLost)
        assertThrows(.keyLost) { try cipher.seal(plaintext, associatedData: ad) }
        currentDate += 10
        XCTAssertEqual(cipher.state, .keyLost)
        XCTAssertEqual(keychain.readCount, 1)

        cipher.discardLostKey()

        XCTAssertEqual(cipher.state, .noKey)
        XCTAssertNil(defaults.string(forKey: LocalStorageKeyStore.keyIDDefaultsKey))
        let sealed = try cipher.seal(plaintext, associatedData: ad)
        XCTAssertEqual(cipher.state, .available)
        XCTAssertEqual(try cipher.open(sealed, associatedData: ad), plaintext)
    }

    func testFailedKeyCreationIsKeyUnavailable() {
        keychain.addError = KeychainItemError.unavailable(errSecInteractionNotAllowed)
        let cipher = makeCipher(canCreateKey: true)

        assertThrows(.keyUnavailable) { try cipher.seal(plaintext, associatedData: ad) }
        assertThrows(.keyUnavailable) { try cipher.createKeyIfNeeded() }
        XCTAssertEqual(cipher.state, .noKey)
        XCTAssertNil(defaults.string(forKey: LocalStorageKeyStore.keyIDDefaultsKey))
    }

    func testCreateKeyIfNeededCreatesKeyOnce() throws {
        let cipher = makeCipher(canCreateKey: true)

        try cipher.createKeyIfNeeded()
        try cipher.createKeyIfNeeded()

        XCTAssertEqual(cipher.state, .available)
        XCTAssertEqual(keychain.items.count, 1)
    }

    func testConcurrentFirstSealsCreateOneKey() {
        let cipher = makeCipher(canCreateKey: true)
        let (plaintext, ad) = (plaintext, ad)
        let lock = NSLock()
        var failures = 0

        DispatchQueue.concurrentPerform(iterations: 50) { _ in
            do {
                _ = try cipher.seal(plaintext, associatedData: ad)
            } catch {
                lock.withLock { failures += 1 }
            }
        }

        XCTAssertEqual(failures, 0)
        XCTAssertEqual(keychain.items.count, 1)
        XCTAssertEqual(cipher.state, .available)
    }
}
