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
import CryptoTokenKit
import Security
import KeychainAccess
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

// MARK: - Keychain

enum KeychainItemError: Error, Equatable {
    case unavailable(OSStatus)
}

protocol KeychainItemStoring {
    /// Returns nil only when Keychain confirms there's no such item (`errSecItemNotFound`)
    func read(account: String) throws -> Data?
    func add(_ data: Data, account: String) throws
    func remove(account: String)
}

/// Every key gets its own account (a fresh keyID), so `add` never meets an existing item
struct SystemKeychainItemStore: KeychainItemStoring {
    private let keychain: Keychain

    init(service: String = Config.keychain) {
        keychain = Keychain(service: service)
            .synchronizable(false)
            .accessibility(.afterFirstUnlockThisDeviceOnly)
    }

    func read(account: String) throws -> Data? {
        do {
            return try keychain.getData(account)
        } catch {
            throw Self.unavailable(error)
        }
    }

    func add(_ data: Data, account: String) throws {
        do {
            try keychain.set(data, key: account)
        } catch {
            throw Self.unavailable(error)
        }
    }

    func remove(account: String) {
        try? keychain.remove(account)
    }

    private static func unavailable(_ error: Error) -> KeychainItemError {
        .unavailable((error as? Status)?.rawValue ?? errSecInternalError)
    }
}

// MARK: - Data key protection

enum DataKeyProtectionError: Error, Equatable {
    /// The data key can never be recovered: corrupted payload or a Secure Enclave key that is gone for good
    case keyInvalidated(domain: String, code: Int)
    /// Can't be used right now - never a reason to discard the key
    case unavailable(domain: String, code: Int)

    static let malformedPayload = Self.keyInvalidated(domain: ownDomain, code: 1)
    static let secureEnclaveNotAvailable = Self.unavailable(domain: ownDomain, code: 2)
    static let internalFailure = Self.unavailable(domain: ownDomain, code: 3)

    private static let ownDomain = "com.2fas.localStorageKey"

    init(keyInvalidatedBy error: Error) {
        let error = error as NSError
        self = .keyInvalidated(domain: error.domain, code: error.code)
    }

    init(unavailableBy error: Error) {
        let error = error as NSError
        self = .unavailable(domain: error.domain, code: error.code)
    }
}

protocol DataKeyProtecting {
    /// First byte of the stored Keychain item
    var kind: UInt8 { get }
    func protect(_ dataKey: SymmetricKey) throws -> Data
    func unprotect(_ payload: Data) throws -> SymmetricKey
}

private let dataKeyByteCount = 32

/// Data key stored as is - devices without Secure Enclave
struct PlainDataKeyProtection: DataKeyProtecting {
    var kind: UInt8 { 0x01 }

    func protect(_ dataKey: SymmetricKey) throws -> Data {
        dataKey.withUnsafeBytes { Data($0) }
    }

    func unprotect(_ payload: Data) throws -> SymmetricKey {
        guard payload.count == dataKeyByteCount else { throw DataKeyProtectionError.malformedPayload }
        return SymmetricKey(data: payload)
    }
}

/// Data key wrapped with ECDH (ephemeral key × Secure Enclave key) + HKDF + AES-GCM.
/// Payload: UInt16 BE length ‖ SE key dataRepresentation ‖ ephemeral public key x963 (65 B) ‖ AES.GCM combined
/// Always registered, so a stored SE-wrapped key is never mistaken for an unknown kind; `protect` and `unprotect`
/// throw `secureEnclaveNotAvailable` on devices without Secure Enclave.
struct SecureEnclaveDataKeyProtection: DataKeyProtecting {
    private static let wrapInfo = Data("2fas.local-storage.wrap.v1".utf8)
    private static let lengthByteCount = 2
    private static let ephemeralPublicKeyByteCount = 65
    /// `TKError.Code.invalidatedDeviceKey`, declared only in the iOS/watchOS 27 SDK
    private static let invalidatedDeviceKeyCode = -10

    var kind: UInt8 { 0x02 }

    func protect(_ dataKey: SymmetricKey) throws -> Data {
        guard SecureEnclave.isAvailable else { throw DataKeyProtectionError.secureEnclaveNotAvailable }
        let secureEnclaveKey = try SecureEnclave.P256.KeyAgreement.PrivateKey(accessControl: Self.accessControl())
        let secureEnclaveKeyData = secureEnclaveKey.dataRepresentation
        guard secureEnclaveKeyData.count <= UInt16.max else { throw DataKeyProtectionError.internalFailure }

        let ephemeralKey = P256.KeyAgreement.PrivateKey()
        let ephemeralPublicKey = ephemeralKey.publicKey.x963Representation
        let sharedSecret = try ephemeralKey.sharedSecretFromKeyAgreement(with: secureEnclaveKey.publicKey)
        let sealed = try AES.GCM.seal(
            dataKey.withUnsafeBytes { Data($0) },
            using: Self.wrappingKey(from: sharedSecret, salt: ephemeralPublicKey)
        )
        guard let combined = sealed.combined else { throw DataKeyProtectionError.internalFailure }

        let length = UInt16(secureEnclaveKeyData.count)
        var payload = Data([UInt8(length >> 8), UInt8(length & 0xFF)])
        payload.append(secureEnclaveKeyData)
        payload.append(ephemeralPublicKey)
        payload.append(combined)
        return payload
    }

    /// Only deterministic corruption or an unambiguous Secure Enclave answer gives `keyInvalidated`
    func unprotect(_ payload: Data) throws -> SymmetricKey {
        let parts = try Self.split(payload)
        let ephemeralPublicKey: P256.KeyAgreement.PublicKey
        let sealed: AES.GCM.SealedBox
        do {
            ephemeralPublicKey = try P256.KeyAgreement.PublicKey(x963Representation: parts.ephemeralPublicKey)
            sealed = try AES.GCM.SealedBox(combined: parts.sealed)
        } catch {
            throw DataKeyProtectionError(keyInvalidatedBy: error)
        }

        guard SecureEnclave.isAvailable else { throw DataKeyProtectionError.secureEnclaveNotAvailable }
        let secureEnclaveKey: SecureEnclave.P256.KeyAgreement.PrivateKey
        do {
            secureEnclaveKey = try SecureEnclave.P256.KeyAgreement.PrivateKey(
                dataRepresentation: parts.secureEnclaveKey
            )
        } catch {
            throw Self.classify(error)
        }
        let sharedSecret: SharedSecret
        do {
            sharedSecret = try secureEnclaveKey.sharedSecretFromKeyAgreement(with: ephemeralPublicKey)
        } catch {
            throw DataKeyProtectionError(unavailableBy: error)
        }

        let wrappingKey = Self.wrappingKey(from: sharedSecret, salt: parts.ephemeralPublicKey)
        let keyData: Data
        do {
            keyData = try AES.GCM.open(sealed, using: wrappingKey)
        } catch {
            throw DataKeyProtectionError(keyInvalidatedBy: error)
        }
        guard keyData.count == dataKeyByteCount else { throw DataKeyProtectionError.malformedPayload }
        return SymmetricKey(data: keyData)
    }

    /// For errors of `SecureEnclave.P256.KeyAgreement.PrivateKey(dataRepresentation:)`. Only codes proving the blob
    /// is corrupted, foreign or invalidated mean the key is gone - anything else (communication errors, missing
    /// entitlement, interaction not allowed, …) may be transient.
    static func classify(_ error: Error) -> DataKeyProtectionError {
        if let error = error as? CryptoKitError, error == .incorrectKeySize || error == .incorrectParameterSize {
            return DataKeyProtectionError(keyInvalidatedBy: error)
        }
        let nsError = error as NSError
        switch (nsError.domain, nsError.code) {
        case (TKErrorDomain, TKError.Code.corruptedData.rawValue),
             (TKErrorDomain, invalidatedDeviceKeyCode),
             (NSOSStatusErrorDomain, Int(errSecParam)):
            return .keyInvalidated(domain: nsError.domain, code: nsError.code)
        default:
            return .unavailable(domain: nsError.domain, code: nsError.code)
        }
    }

    private typealias Parts = (secureEnclaveKey: Data, ephemeralPublicKey: Data, sealed: Data)

    private static func split(_ payload: Data) throws -> Parts {
        let bytes = [UInt8](payload)
        guard bytes.count >= lengthByteCount else { throw DataKeyProtectionError.malformedPayload }
        let secureEnclaveKeyEnd = lengthByteCount + (Int(bytes[0]) << 8 | Int(bytes[1]))
        let ephemeralPublicKeyEnd = secureEnclaveKeyEnd + ephemeralPublicKeyByteCount
        guard bytes.count > ephemeralPublicKeyEnd else { throw DataKeyProtectionError.malformedPayload }
        return (
            Data(bytes[lengthByteCount..<secureEnclaveKeyEnd]),
            Data(bytes[secureEnclaveKeyEnd..<ephemeralPublicKeyEnd]),
            Data(bytes[ephemeralPublicKeyEnd...])
        )
    }

    private static func wrappingKey(from sharedSecret: SharedSecret, salt: Data) -> SymmetricKey {
        sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt,
            sharedInfo: wrapInfo,
            outputByteCount: dataKeyByteCount
        )
    }

    private static func accessControl() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            .privateKeyUsage,
            &error
        ) else {
            throw error?.takeRetainedValue() ?? DataKeyProtectionError.internalFailure
        }
        return accessControl
    }
}

// MARK: - Key store

/// Not thread safe - `LocalStorageCipherImpl` serializes access.
/// Never logs itself: it runs under the cipher's lock, and saving a log can reach Storage, which uses the cipher.
/// Failures are passed to `report` (kinds and error domains/codes only) for the caller to log.
final class LocalStorageKeyStore {
    static let keyIDDefaultsKey = "com.2fas.localStorageKeyID"

    static func account(for keyID: UUID) -> String {
        "com.2fas.localStorageKey.\(keyID.uuidString)"
    }

    /// Error domain and code only - descriptions could carry more than belongs in logs
    static func describe(_ error: Error) -> String {
        switch error {
        case let error as DataKeyProtectionError: "\(error)"
        case let error as KeychainItemError: "\(error)"
        default: "\((error as NSError).domain) \((error as NSError).code)"
        }
    }

    enum LoadResult: Equatable {
        /// No keyID - Keychain wasn't touched
        case noKey
        case loaded(SymmetricKey)
        /// The key is gone for good - only when Keychain or Secure Enclave says so unambiguously
        case lost
        /// Keychain or Secure Enclave can't be used right now (e.g. before the first unlock)
        case unavailable
    }

    /// Kinds that could ever have been written - any other kind byte is corruption
    private static let knownKinds: Set<UInt8> = [PlainDataKeyProtection().kind, SecureEnclaveDataKeyProtection().kind]

    private let defaults: UserDefaults
    private let keychain: KeychainItemStoring
    private let protections: [DataKeyProtecting]

    init(defaults: UserDefaults, keychain: KeychainItemStoring, protections: [DataKeyProtecting]) {
        self.defaults = defaults
        self.keychain = keychain
        self.protections = protections
    }

    func load(report: (String) -> Void = { _ in }) -> LoadResult {
        guard let storedKeyID = defaults.string(forKey: Self.keyIDDefaultsKey) else {
            return .noKey
        }
        guard let keyID = UUID(uuidString: storedKeyID) else {
            report("Malformed local storage keyID")
            return .lost
        }
        let item: Data?
        do {
            item = try keychain.read(account: Self.account(for: keyID))
        } catch {
            report("Can't read local storage key: \(Self.describe(error))")
            return .unavailable
        }
        guard let item else {
            report("Local storage key not found")
            return .lost
        }
        guard let kind = item.first, Self.knownKinds.contains(kind) else {
            report("Unknown local storage key kind")
            return .lost
        }
        guard let protection = protections.first(where: { $0.kind == kind }) else {
            report("No protection for local storage key of kind \(kind)")
            return .unavailable
        }
        do {
            return .loaded(try protection.unprotect(item.dropFirst()))
        } catch {
            if case .keyInvalidated? = error as? DataKeyProtectionError {
                report("Local storage key of kind \(kind) is invalidated: \(Self.describe(error))")
                return .lost
            }
            report("Can't unprotect local storage key of kind \(kind): \(Self.describe(error))")
            return .unavailable
        }
    }

    /// Order matters: an interruption leaves at most an orphaned Keychain item, never a keyID without a key
    func create(report: (String) -> Void = { _ in }) throws -> SymmetricKey {
        let dataKey = SymmetricKey(size: .bits256)
        let keyID = UUID()
        var lastError: Error = DataKeyProtectionError.internalFailure
        for protection in protections {
            let payload: Data
            do {
                payload = try protection.protect(dataKey)
            } catch {
                report("Can't protect local storage key with kind \(protection.kind): \(Self.describe(error))")
                lastError = error
                continue
            }
            try keychain.add(Data([protection.kind]) + payload, account: Self.account(for: keyID))
            defaults.set(keyID.uuidString, forKey: Self.keyIDDefaultsKey)
            return dataKey
        }
        throw lastError
    }

    /// The Keychain item stays - it's never looked up without its keyID
    func discardKeyID() {
        defaults.removeObject(forKey: Self.keyIDDefaultsKey)
    }
}
