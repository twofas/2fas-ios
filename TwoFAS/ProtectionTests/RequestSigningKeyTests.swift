//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

final class RequestSigningKeyTests: XCTestCase {
    // Test key from the server's golden tests (internal/common/signing/golden/golden_test.go)
    private let pem = """
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgXx9Q+l7f5k+3GVGS
w8e/9xBcbmRD9ct0D3HFNfm4BJehRANCAAR6PkAbQJMm2yYl8eBILTDTxPjU/TjO
FpEf+E3UohwO/Bi2EMf0r5UwLZHLTr0aAS6JjenrZ810pTrieOtp7j39
-----END PRIVATE KEY-----
"""
    
    func testPublicKeyIsBase64EncodedPKIX() throws {
        // GIVEN
        let key = try P256.Signing.PrivateKey(pemRepresentation: pem)
        // WHEN
        let publicKey = SigningKey.software(key).publicKey
        // THEN
        let der = try XCTUnwrap(Data(base64Encoded: publicKey))
        let parsed = try P256.Signing.PublicKey(derRepresentation: der)
        XCTAssertEqual(parsed.rawRepresentation, key.publicKey.rawRepresentation)
    }
    
    func testSignatureIsDEREncodedAndVerifiableOverPayload() throws {
        // GIVEN
        let key = try P256.Signing.PrivateKey(pemRepresentation: pem)
        let payload = Data("v:1\nmethod:GET".utf8)
        // WHEN
        let signature = try XCTUnwrap(SigningKey.software(key).signature(for: payload))
        // THEN
        let parsed = try P256.Signing.ECDSASignature(derRepresentation: signature)
        XCTAssertTrue(key.publicKey.isValidSignature(parsed, for: SHA256.hash(data: payload)))
    }
    
    func testSecureEnclaveKeySignatureIsVerifiableWithPublishedKey() throws {
        try XCTSkipUnless(SecureEnclave.isAvailable, "Secure Enclave isn't available")
        // GIVEN
        let key = try SecureEnclave.P256.Signing.PrivateKey()
        let restored = try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: key.dataRepresentation)
        let payload = Data("v:1\nmethod:GET".utf8)
        // WHEN
        let signature = try XCTUnwrap(SigningKey.secureEnclave(restored).signature(for: payload))
        // THEN
        let der = try XCTUnwrap(Data(base64Encoded: SigningKey.secureEnclave(key).publicKey))
        let publicKey = try P256.Signing.PublicKey(derRepresentation: der)
        let parsed = try P256.Signing.ECDSASignature(derRepresentation: signature)
        XCTAssertTrue(publicKey.isValidSignature(parsed, for: SHA256.hash(data: payload)))
    }
}
