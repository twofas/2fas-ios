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

import Foundation
import CryptoKit
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public final class LocalStorageCipherCore: LocalStorageCipher {
    public static let envelopeVersion: UInt8 = 0x01

    private static let nonceLength = 12
    private static let tagLength = 16

    private let encryptionKey: SymmetricKey
    private let lookupKey: SymmetricKey

    public init(dataKey: SymmetricKey) {
        encryptionKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: dataKey,
            info: Data("2fas.local-storage.encryption.v1".utf8),
            outputByteCount: 32
        )
        lookupKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: dataKey,
            info: Data("2fas.local-storage.lookup.v1".utf8),
            outputByteCount: 32
        )
    }

    public var state: LocalStorageCipherState { .available }

    public func seal(_ plaintext: Data, associatedData: Data) throws -> Data {
        let box = try AES.GCM.seal(plaintext, using: encryptionKey, authenticating: associatedData)
        guard let combined = box.combined else { throw LocalStorageCipherError.malformedEnvelope }
        return Data([Self.envelopeVersion]) + combined
    }

    public func open(_ sealed: Data, associatedData: Data) throws -> Data {
        guard sealed.count >= 1 + Self.nonceLength + Self.tagLength else {
            throw LocalStorageCipherError.malformedEnvelope
        }
        let version = sealed[sealed.startIndex]
        guard version == Self.envelopeVersion else {
            throw LocalStorageCipherError.unsupportedEnvelopeVersion(version)
        }
        let box = try AES.GCM.SealedBox(combined: sealed.dropFirst())
        return try AES.GCM.open(box, using: encryptionKey, authenticating: associatedData)
    }

    /// The key is always there
    public func prepareForWriting() {}

    public func lookupHash(for value: String, context: String) throws -> Data {
        var message = Data(context.utf8)
        message.append(0)
        message.append(Data(value.utf8))
        return Data(HMAC<SHA256>.authenticationCode(for: message, using: lookupKey))
    }
}
