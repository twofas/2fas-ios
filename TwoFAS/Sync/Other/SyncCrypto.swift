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
import Protection
#elseif os(watchOS)
import CommonWatch
import ProtectionWatch
#endif

// MARK: - Key derivation parameters

/// How the user's key is derived from the password. Stored (with the salt) in the Info record, so that a device
/// that has only the password can derive the same key – and so that the parameters can be raised later without
/// another change of the format.
struct SyncKDFParameters: Codable, Equatable {
    static let argon2id = "argon2id"
    /// Argon2 version 1.3
    static let argon2Version13 = 0x13

    var algorithm: String
    var version: Int
    var iterations: Int
    var memoryKiB: Int
    var parallelism: Int
    var keyLength: Int

    /// The weakest parameters a new key may be derived with – whatever the cloud says. It's the second
    /// recommended option of RFC 9106 (memory-constrained environments).
    static let minimum = SyncKDFParameters(
        algorithm: argon2id,
        version: argon2Version13,
        iterations: 3,
        memoryKiB: 64 * 1024,
        parallelism: 4,
        keyLength: 32
    )

    /// Used for every new key
    static let current = minimum

    /// What the keys were derived with before the parameters were stored
    static let legacy = minimum

    /// The parameters can be used to derive a key on this device: a known algorithm and values in sane bounds
    /// (what comes from the cloud must not make the device allocate gigabytes or run for minutes)
    var isSupported: Bool {
        algorithm == Self.argon2id
            && version == Self.argon2Version13
            && (1...64).contains(iterations)
            && (8 * 1024...1024 * 1024).contains(memoryKiB)
            && (1...16).contains(parallelism)
            && keyLength == 32
    }

    /// Not weaker than `minimum` in any value. A key derived with weaker parameters still opens what was sealed
    /// with it, but a new key is never derived with them.
    var meetsMinimum: Bool {
        isSupported
            && iterations >= Self.minimum.iterations
            && memoryKiB >= Self.minimum.memoryKiB
            && parallelism >= Self.minimum.parallelism
    }

    func encoded() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return try? encoder.encode(self)
    }

    init?(encoded: Data) {
        guard let parameters = try? JSONDecoder().decode(SyncKDFParameters.self, from: encoded) else { return nil }
        self = parameters
    }

    init(algorithm: String, version: Int, iterations: Int, memoryKiB: Int, parallelism: Int, keyLength: Int) {
        self.algorithm = algorithm
        self.version = version
        self.iterations = iterations
        self.memoryKiB = memoryKiB
        self.parallelism = parallelism
        self.keyLength = keyLength
    }
}

// MARK: - Record identifiers

/// What a record name is derived from. The names of different kinds never collide, also for the same value – a
/// service and the record of its deletion have different names.
enum SyncRecordKind: String, CaseIterable {
    case service
    case section
    case deletedService
    case deletedSection
}

enum SyncCryptoError: Error, Equatable {
    case malformedIdentifierKey
}

/// The key the record names are derived with. It's random and stays the same when the password changes (only its
/// wrapping in the Info record is replaced), so the names don't change either: a change of the password modifies
/// the records in place, and the record of a deletion needs nothing but its name to be found again.
struct SyncIdentifierKey: Equatable {
    static let byteCount = 32
    private static let domain = "2fas.sync.identifier"
    private static let wrapDomain = "2fas.sync.identifier-key"
    private static let wrapAssociatedData = Data("2fas.sync.identifier-key.v1".utf8)

    let data: Data

    init?(data: Data) {
        guard data.count == Self.byteCount else { return nil }
        self.data = data
    }

    static func generate() -> SyncIdentifierKey {
        let key = SymmetricKey(size: .bits256)
        return SyncIdentifierKey(data: key.withUnsafeBytes { Data($0) })! // swiftlint:disable:this force_unwrapping
    }

    /// The identifier of `value` (a secret, the ID of a section) as `kind` – 32 bytes
    func identifier(of value: String, kind: SyncRecordKind) -> Data {
        // The core only fails without a key, and this one always has it
        // swiftlint:disable:next force_try
        try! LocalStorageCipherCore(dataKey: SymmetricKey(data: data), domain: Self.domain)
            .lookupHash(for: value, context: kind.rawValue)
    }

    /// The record name of `value` as `kind`
    func recordName(of value: String, kind: SyncRecordKind) -> String {
        Self.recordName(identifier: identifier(of: value, kind: kind))
    }

    static func recordName(identifier: Data) -> String {
        let digits = Array("0123456789abcdef".utf8)
        var name = [UInt8]()
        name.reserveCapacity(identifier.count * 2)
        for byte in identifier {
            name.append(digits[Int(byte >> 4)])
            name.append(digits[Int(byte & 0x0f)])
        }
        // Hex digits only – always valid, nothing to fail on
        // swiftlint:disable:next optional_data_string_conversion
        return String(decoding: name, as: UTF8.self)
    }

    /// The key sealed with the sync key – what the Info record keeps
    func wrapped(with syncKey: SymmetricKey) throws -> Data {
        try LocalStorageCipherCore(dataKey: syncKey, domain: Self.wrapDomain)
            .seal(data, associatedData: Self.wrapAssociatedData)
    }

    /// - Throws: When `wrapped` wasn't sealed with `syncKey` or doesn't hold a key.
    static func unwrap(_ wrapped: Data, with syncKey: SymmetricKey) throws -> SyncIdentifierKey {
        let data = try LocalStorageCipherCore(dataKey: syncKey, domain: wrapDomain)
            .open(wrapped, associatedData: wrapAssociatedData)
        guard let key = SyncIdentifierKey(data: data) else { throw SyncCryptoError.malformedIdentifierKey }
        return key
    }
}

// MARK: - Record content

/// Seals the content of a record as one blob. The blob is bound to the type and the name of its record, so it
/// can't be moved to another record without being noticed.
struct SyncRecordCodec<Content: Codable> {
    private static var domain: String { "2fas.sync.record" }

    private let codec: SealedContentCodec<Content>
    private let cipher: LocalStorageCipherCore

    /// - Parameter recordType: The type of the CloudKit record the content belongs to.
    init(recordType: String, syncKey: SymmetricKey, contentVersion: Int = 1) {
        codec = SealedContentCodec<Content>(entityName: "sync.\(recordType)", contentVersion: contentVersion)
        cipher = LocalStorageCipherCore(dataKey: syncKey, domain: Self.domain)
    }

    func seal(_ content: Content, recordName: String) throws -> Data {
        try codec.seal(content, hashes: [Data(recordName.utf8)], cipher: cipher)
    }

    func open(_ sealed: Data, recordName: String) throws -> Content {
        try codec.open(sealed, hashes: [Data(recordName.utf8)], cipher: cipher)
    }
}

// MARK: - Watch ticket

/// The user's key handed to a paired watch through the Info record. It's sealed with the system key – which
/// every device of the user has in the iCloud Keychain and nobody else has – and bound to the device it's for.
enum SyncWatchTicket {
    private static let domain = "2fas.sync.watch-ticket"

    private static func associatedData(deviceCode: String) -> Data {
        Data("2fas.sync.watch-ticket.v1".utf8) + Data([0]) + Data(deviceCode.utf8)
    }

    static func seal(userKey: Data, systemKey: SymmetricKey, deviceCode: String) throws -> Data {
        try LocalStorageCipherCore(dataKey: systemKey, domain: domain)
            .seal(userKey, associatedData: associatedData(deviceCode: deviceCode))
    }

    static func open(_ ticket: Data, systemKey: SymmetricKey, deviceCode: String) throws -> Data {
        try LocalStorageCipherCore(dataKey: systemKey, domain: domain)
            .open(ticket, associatedData: associatedData(deviceCode: deviceCode))
    }
}
