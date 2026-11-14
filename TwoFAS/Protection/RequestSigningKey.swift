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
import Security
import KeychainAccess
import Common

public enum RequestSigningKey {
    private static let keychain = Keychain(service: Config.keychain)
        .synchronizable(false)
        .accessibility(.afterFirstUnlockThisDeviceOnly)
    
    private static let secureEnclaveStorageKey = "com.2fas.requestSigningKey.secureEnclave"
    private static let softwareStorageKey = "com.2fas.requestSigningKey"
    
    private static let lock = NSLock()
    private static var cachedKey: SigningKey?
    
    /// True only if Keychain confirms there's no usable key. Unavailable Keychain (e.g. before the first unlock)
    /// doesn't mean the key is gone.
    public static var isMissing: Bool {
        lock.withLock {
            do {
                return try loadKey() == nil
            } catch {
                return false
            }
        }
    }
    
    /// Base64 encoded PKIX (SPKI) representation of the public key. Creates the key pair if there isn't one yet.
    public static func publicKeyCreatingIfNeeded() -> String? {
        lock.withLock {
            do {
                return try loadKey(removingCorrupted: true) ?? createKey()
            } catch {
                Log("Can't read request signing key: \(error)", module: .protection)
                return nil
            }
        }?.publicKey
    }
    
    /// ASN.1 DER encoded ECDSA signature over the SHA-256 digest of the payload. Never creates the key - a key
    /// the server doesn't know about can't be verified.
    public static func signature(for payload: Data) -> Data? {
        lock.withLock { try? loadKey() }?.signature(for: payload)
    }
}

enum SigningKey {
    case secureEnclave(SecureEnclave.P256.Signing.PrivateKey)
    case software(P256.Signing.PrivateKey)
    
    var publicKey: String {
        let publicKey: P256.Signing.PublicKey = switch self {
        case .secureEnclave(let key): key.publicKey
        case .software(let key): key.publicKey
        }
        return publicKey.derRepresentation.base64EncodedString()
    }
    
    func signature(for payload: Data) -> Data? {
        do {
            return switch self {
            case .secureEnclave(let key): try key.signature(for: payload).derRepresentation
            case .software(let key): try key.signature(for: payload).derRepresentation
            }
        } catch {
            Log("Can't sign request: \(error)", module: .protection)
            return nil
        }
    }
}

// Everything below has to be called while holding the lock
private extension RequestSigningKey {
    /// Throws when Keychain can't be read, returns nil when there's no usable key.
    /// Only the key creation path removes corrupted entries, so a key is never removed by an extension.
    static func loadKey(removingCorrupted: Bool = false) throws -> SigningKey? {
        if let cachedKey {
            return cachedKey
        }
        cachedKey = try storedKey(removingCorrupted: removingCorrupted)
        return cachedKey
    }
    
    static func storedKey(removingCorrupted: Bool) throws -> SigningKey? {
        if let data = try keychain.getData(secureEnclaveStorageKey) {
            if let key = try? SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: data) {
                return .secureEnclave(key)
            }
            Log("Can't restore Secure Enclave request signing key", module: .protection)
            if removingCorrupted {
                try? keychain.remove(secureEnclaveStorageKey)
            }
        }
        if let data = try keychain.getData(softwareStorageKey) {
            if let key = try? P256.Signing.PrivateKey(rawRepresentation: data) {
                return .software(key)
            }
            Log("Can't restore request signing key", module: .protection)
            if removingCorrupted {
                try? keychain.remove(softwareStorageKey)
            }
        }
        return nil
    }
    
    static func createKey() -> SigningKey? {
        if SecureEnclave.isAvailable {
            do {
                let key = try SecureEnclave.P256.Signing.PrivateKey(accessControl: secureEnclaveAccessControl())
                return add(.secureEnclave(key), data: key.dataRepresentation, for: secureEnclaveStorageKey)
            } catch {
                Log("Can't create Secure Enclave request signing key: \(error)", module: .protection)
            }
        }
        let key = P256.Signing.PrivateKey()
        return add(.software(key), data: key.rawRepresentation, for: softwareStorageKey)
    }
    
    static func secureEnclaveAccessControl() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            .privateKeyUsage,
            &error
        ) else {
            throw error!.takeRetainedValue() as Error
        }
        return accessControl
    }
    
    /// Adds without overwriting - the app and its extensions could create the key at the same time
    static func add(_ key: SigningKey, data: Data, for storageKey: String) -> SigningKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Config.keychain,
            kSecAttrAccount as String: storageKey,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecAttrSynchronizable as String: false,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            cachedKey = key
            return key
        case errSecDuplicateItem:
            return try? loadKey()
        default:
            Log("Can't save request signing key: \(status)", module: .protection)
            return nil
        }
    }
}
