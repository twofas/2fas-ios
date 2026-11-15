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
    case malformedPayload
}

protocol DataKeyProtecting {
    /// First byte of the stored Keychain item
    var kind: UInt8 { get }
    func protect(_ dataKey: SymmetricKey) throws -> Data
    func unprotect(_ payload: Data) throws -> SymmetricKey
}

private let dataKeyByteCount = 32

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
        /// The key is gone for good - only when Keychain says so unambiguously or the stored item is corrupted
        case lost
        /// Keychain can't be used right now (e.g. before the first unlock)
        case unavailable
    }

    /// Kinds that could ever have been written - any other kind byte is corruption
    private static let knownKinds: Set<UInt8> = [PlainDataKeyProtection().kind]

    private let defaults: UserDefaults
    private let keychain: KeychainItemStoring
    private let protections: [DataKeyProtecting]

    init(defaults: UserDefaults, keychain: KeychainItemStoring, protections: [DataKeyProtecting]) {
        self.defaults = defaults
        self.keychain = keychain
        self.protections = protections
    }

    /// The ID of the current key as stored – changes when the main app discards the key and creates a new one
    var storedKeyID: String? { defaults.string(forKey: Self.keyIDDefaultsKey) }

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
            if error is DataKeyProtectionError {
                report("Local storage key of kind \(kind) is corrupted: \(Self.describe(error))")
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
        var lastError: Error = KeychainItemError.unavailable(errSecInternalError)
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
