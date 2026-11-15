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
import Common
@testable import Protection

final class LocalStorageCipherCoreTests: XCTestCase {
    private let dataKey = SymmetricKey(size: .bits256)
    private lazy var core = LocalStorageCipherCore(dataKey: dataKey)
    private let plaintext = Data("secret payload".utf8)
    private let ad = Data("2fas.ServiceEntity.v1".utf8)

    private func derived(_ info: String) -> SymmetricKey {
        HKDF<SHA256>.deriveKey(inputKeyMaterial: dataKey, info: Data(info.utf8), outputByteCount: 32)
    }

    func testPrepareForWritingIsNoop() throws {
        XCTAssertNoThrow(try core.prepareForWriting())
        XCTAssertEqual(core.state, .available)
    }

    func testSealOpenRoundTrip() throws {
        let sealed = try core.seal(plaintext, associatedData: ad)
        XCTAssertEqual(try core.open(sealed, associatedData: ad), plaintext)
    }

    func testEnvelopeLayout() throws {
        let sealed = try core.seal(plaintext, associatedData: ad)
        XCTAssertEqual(sealed[0], 0x01)
        XCTAssertEqual(sealed.count, 1 + 12 + plaintext.count + 16)
    }

    func testSealIsRandomized() throws {
        XCTAssertNotEqual(try core.seal(plaintext, associatedData: ad), try core.seal(plaintext, associatedData: ad))
    }

    func testOpenFailsForDifferentAssociatedData() throws {
        let sealed = try core.seal(plaintext, associatedData: ad)
        XCTAssertThrowsError(try core.open(sealed, associatedData: Data("other".utf8)))
    }

    func testOpenFailsForTamperedCiphertext() throws {
        var sealed = try core.seal(plaintext, associatedData: ad)
        sealed[sealed.count - 1] ^= 0xFF
        XCTAssertThrowsError(try core.open(sealed, associatedData: ad))
    }

    func testOpenRejectsUnknownVersion() throws {
        var sealed = try core.seal(plaintext, associatedData: ad)
        sealed[0] = 0x02
        XCTAssertThrowsError(try core.open(sealed, associatedData: ad)) {
            XCTAssertEqual($0 as? LocalStorageCipherError, .unsupportedEnvelopeVersion(0x02))
        }
    }

    func testOpenRejectsTruncatedEnvelope() {
        XCTAssertThrowsError(try core.open(Data(count: 28), associatedData: ad)) {
            XCTAssertEqual($0 as? LocalStorageCipherError, .malformedEnvelope)
        }
    }

    func testLookupHashIsDeterministic32Bytes() throws {
        let first = try core.lookupHash(for: "ABC", context: "ServiceEntity.secret")
        XCTAssertEqual(first, try core.lookupHash(for: "ABC", context: "ServiceEntity.secret"))
        XCTAssertEqual(first.count, 32)
    }

    func testLookupHashDependsOnContextAndKey() throws {
        let base = try core.lookupHash(for: "ABC", context: "ServiceEntity.secret")
        XCTAssertNotEqual(base, try core.lookupHash(for: "ABC", context: "AuthRequestEntity.secret"))
        let other = LocalStorageCipherCore(dataKey: SymmetricKey(size: .bits256))
        XCTAssertNotEqual(base, try other.lookupHash(for: "ABC", context: "ServiceEntity.secret"))
    }

    func testLookupHashMatchesSpecConstruction() throws {
        let message = Data("ServiceEntity.secret".utf8) + [0] + Data("ABC".utf8)
        let expected = HMAC<SHA256>.authenticationCode(for: message, using: derived("2fas.local-storage.lookup.v1"))
        XCTAssertEqual(try core.lookupHash(for: "ABC", context: "ServiceEntity.secret"), Data(expected))
    }

    func testEncryptionUsesDerivedKey() throws {
        let sealed = try core.seal(plaintext, associatedData: ad)
        let box = try AES.GCM.SealedBox(combined: sealed.dropFirst())
        let opened = try AES.GCM.open(box, using: derived("2fas.local-storage.encryption.v1"), authenticating: ad)
        XCTAssertEqual(opened, plaintext)
    }
}
