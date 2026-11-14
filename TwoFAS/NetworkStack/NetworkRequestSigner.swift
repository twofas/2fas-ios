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

import Foundation
import CryptoKit
import Common

struct NetworkRequestSigner {
    enum Header {
        static let version = "X-2fas-Signature-Version"
        static let timestamp = "X-2fas-Signature-Timestamp"
        static let nonce = "X-2fas-Signature-Nonce"
        static let signature = "X-2fas-Signature"
        static let bodySHA256 = "X-2fas-Body-Sha256"
    }
    
    private static let version = "1"
    private static let nonceLength = 16
    private static let timestampFormatter = ISO8601DateFormatter()
    
    let signPayload: (Data) -> Data?
    let currentDate: () -> Date
    
    /// If the payload can't be signed then the request is sent as is and it's up to the server to accept it
    func signed(_ request: URLRequest) -> URLRequest {
        guard let url = request.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let method = request.httpMethod,
              let headers = headers(
                method: method,
                path: components.path,
                query: components.percentEncodedQuery ?? "",
                body: request.httpBody ?? Data()
              )
        else {
            Log("Network Stack: Can't sign request", module: .network)
            return request
        }
        
        var signedRequest = request
        headers.forEach { signedRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        return signedRequest
    }
    
    func headers(method: String, path: String, query: String, body: Data) -> [String: String]? {
        let bodySHA256 = Data(SHA256.hash(data: body)).base64URLEncodedString()
        let timestamp = Self.timestampFormatter.string(from: currentDate())
        let nonce = Self.makeNonce()
        let payload = Self.canonicalPayload(
            method: method,
            path: path,
            query: query,
            bodySHA256: bodySHA256,
            timestamp: timestamp,
            nonce: nonce
        )
        guard let signature = signPayload(payload) else { return nil }
        
        return [
            Header.version: Self.version,
            Header.timestamp: timestamp,
            Header.nonce: nonce,
            Header.bodySHA256: bodySHA256,
            Header.signature: signature.base64URLEncodedString()
        ]
    }
    
    // swiftlint:disable:next function_parameter_count
    static func canonicalPayload(
        method: String,
        path: String,
        query: String,
        bodySHA256: String,
        timestamp: String,
        nonce: String
    ) -> Data {
        Data(
            [
                "v:\(version)",
                "method:\(method.uppercased())",
                "path:\(path)",
                "query:\(query)",
                "body_sha256:\(bodySHA256)",
                "timestamp:\(timestamp)",
                "nonce:\(nonce)"
            ]
            .joined(separator: "\n")
            .utf8
        )
    }
}

private extension NetworkRequestSigner {
    static func makeNonce() -> String {
        Data((0..<nonceLength).map { _ in UInt8.random(in: .min ... .max) }).base64URLEncodedString()
    }
}

extension Data {
    /// Base64url with padding, which is what the server expects
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}
