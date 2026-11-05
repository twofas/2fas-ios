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
@testable import NetworkStack

// Vectors come from the server's golden tests (internal/common/signing/golden/testdata/requests)
final class NetworkRequestSignerTests: XCTestCase {
    private struct Golden {
        let method: String
        let path: String
        let query: String
        let body: String
        let bodySHA256: String
        let timestamp: String
        let nonce: String
        let signature: String
    }
    
    private let pem = """
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgXx9Q+l7f5k+3GVGS
w8e/9xBcbmRD9ct0D3HFNfm4BJehRANCAAR6PkAbQJMm2yYl8eBILTDTxPjU/TjO
FpEf+E3UohwO/Bi2EMf0r5UwLZHLTr0aAS6JjenrZ810pTrieOtp7j39
-----END PRIVATE KEY-----
"""
    private let deviceID = "3f2a8c14-6b7d-4e91-a5c3-1d8e9f0b2a76"
    private let timestamp = "2026-01-01T12:00:00Z"
    private let date = Date(timeIntervalSince1970: 1767268800)
    
    // swiftlint:disable line_length
    private lazy var vectors: [Golden] = [
        Golden(
            method: "GET",
            path: "/mobile/devices/\(deviceID)/browser_extensions/2fa_requests",
            query: "",
            body: "",
            bodySHA256: "47DEQpj8HBSa-_TImW-5JCeuQeRkm5NMpJWZG3hSuFU=",
            timestamp: timestamp,
            nonce: "Z29sZGVuLW5vbmNlLW1vYmlsZV9nZXRfMmZhX3JlcXVlc3Rz",
            signature: "MEYCIQDv2qFogrsc77cPGvwo5hzjIFIUSAXo5YxvLAVhbbZ7XQIhAPG-zGbh63pPXWN6ZTuac7evTw1YlCSK7tgaZTlkqJyt"
        ),
        Golden(
            method: "PUT",
            path: "/mobile/devices/\(deviceID)",
            query: "",
            body: #"{"name":"Pixel 9","platform":"android","fcm_token":"example-fcm-token"}"#,
            bodySHA256: "_qH9Q6mWY4OaOJyDJL63B0VMabiZYw2aUxurmn_gSxk=",
            timestamp: timestamp,
            nonce: "Z29sZGVuLW5vbmNlLW1vYmlsZV91cGRhdGVfZGV2aWNl",
            signature: "MEUCIQD-fz3ECWp4vHn52FvSKUSGjq1Ko5jq9mk2ZqLlbPxcaAIgdMW1rsAkS1tvkQTfmcRVNWczUgSc6uE57xO-y49BCG4="
        ),
        Golden(
            method: "POST",
            path: "/api/browser-extensions/example",
            query: "lang=en",
            body: #"{"emoji":"✅","cjk":"こんにちは","escaped":"\"quoted\""}"#,
            bodySHA256: "QO0bLezFouXxF5CcA_PXoEpyPKQaZudFKTNDuWqln98=",
            timestamp: timestamp,
            nonce: "Z29sZGVuLW5vbmNlLXVuaWNvZGUtcGFkISE=",
            signature: "MEUCIQCuT_53SNThRg2N6MSgepn5GAunDlpnq9UHaSMJQnKd6QIgcL7GA1kZr0SUqHM4v202sgm42H5Kn3Fj-3hDtpJKnLc="
        )
    ]
    // swiftlint:enable line_length
    
    func testCanonicalPayloadMatchesServerSignatures() throws {
        // GIVEN
        let publicKey = try P256.Signing.PrivateKey(pemRepresentation: pem).publicKey
        for vector in vectors {
            // WHEN
            let payload = NetworkRequestSigner.canonicalPayload(
                method: vector.method,
                path: vector.path,
                query: vector.query,
                bodySHA256: vector.bodySHA256,
                timestamp: vector.timestamp,
                nonce: vector.nonce
            )
            // THEN
            let signature = try P256.Signing.ECDSASignature(derRepresentation: decode(vector.signature))
            XCTAssertTrue(
                publicKey.isValidSignature(signature, for: SHA256.hash(data: payload)),
                "Signature doesn't match for \(vector.method) \(vector.path)"
            )
        }
    }
    
    func testBodyHashMatchesServer() throws {
        let signer = NetworkRequestSigner(signPayload: { _ in Data() }, currentDate: { self.date })
        for vector in vectors {
            let headers = try XCTUnwrap(
                signer.headers(
                    method: vector.method,
                    path: vector.path,
                    query: vector.query,
                    body: Data(vector.body.utf8)
                )
            )
            XCTAssertEqual(headers[NetworkRequestSigner.Header.bodySHA256], vector.bodySHA256)
        }
    }
    
    func testSignedRequestHasHeadersVerifiableByServer() throws {
        // GIVEN
        let key = try P256.Signing.PrivateKey(pemRepresentation: pem)
        let signer = NetworkRequestSigner(
            signPayload: { try? key.signature(for: $0).derRepresentation },
            currentDate: { self.date }
        )
        var request = URLRequest(url: URL(string: "https://api2.2fas.com/mobile/devices/\(deviceID)?a=b%20c")!)
        request.httpMethod = "PUT"
        request.httpBody = Data("{}".utf8)
        // WHEN
        let signed = signer.signed(request)
        // THEN
        let value: (String) throws -> String = { try XCTUnwrap(signed.value(forHTTPHeaderField: $0)) }
        XCTAssertEqual(try value(NetworkRequestSigner.Header.version), "1")
        XCTAssertEqual(try value(NetworkRequestSigner.Header.timestamp), timestamp)
        XCTAssertEqual(signed.httpBody, request.httpBody)
        
        let nonce = try value(NetworkRequestSigner.Header.nonce)
        XCTAssertEqual(try decode(nonce).count, 16)
        
        let payload = NetworkRequestSigner.canonicalPayload(
            method: "PUT",
            path: "/mobile/devices/\(deviceID)",
            query: "a=b%20c",
            bodySHA256: try value(NetworkRequestSigner.Header.bodySHA256),
            timestamp: timestamp,
            nonce: nonce
        )
        let signature = try P256.Signing.ECDSASignature(
            derRepresentation: decode(try value(NetworkRequestSigner.Header.signature))
        )
        XCTAssertTrue(key.publicKey.isValidSignature(signature, for: SHA256.hash(data: payload)))
    }
    
    func testRequestIsLeftUntouchedWhenPayloadCantBeSigned() {
        // GIVEN
        let signer = NetworkRequestSigner(signPayload: { _ in nil }, currentDate: { self.date })
        var request = URLRequest(url: URL(string: "https://api2.2fas.com/mobile/devices/\(deviceID)")!)
        request.httpMethod = "GET"
        // WHEN
        let result = signer.signed(request)
        // THEN
        XCTAssertNil(result.value(forHTTPHeaderField: NetworkRequestSigner.Header.signature))
    }
    
    private func decode(_ base64URL: String) throws -> Data {
        let base64 = base64URL
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        return try XCTUnwrap(Data(base64Encoded: base64))
    }
}
