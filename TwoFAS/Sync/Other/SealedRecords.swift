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
import CloudKit
import CryptoKit
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

// MARK: - Sealed record

/// A record of the format used in `Config.vaultV3`: everything it says is in one sealed field, bound to the type
/// and the name of the record. The name is an identifier derived with `SyncIdentifierKey` – it says nothing about
/// what the record holds.
enum SealedRecord {
    static let contentKey = "content"

    enum Failure: Error, Equatable {
        case missingContent
        case malformedMetadata
        case unexpectedRecordType
    }

    /// A new record.
    static func create<Content: Codable>(
        type: RecordType,
        recordName: String,
        zoneID: CKRecordZone.ID,
        content: Content,
        syncKey: SymmetricKey
    ) throws -> CKRecord {
        let record = CKRecord(
            recordType: type.rawValue,
            recordID: CKRecord.ID(recordName: recordName, zoneID: zoneID)
        )
        try set(content, on: record, syncKey: syncKey)
        return record
    }

    /// The record known to the server (`metadata` – its encoded system fields) with new content.
    static func recreate<Content: Codable>(
        with metadata: Data,
        type: RecordType,
        content: Content,
        syncKey: SymmetricKey
    ) throws -> CKRecord {
        let record = try decodeSystemFields(metadata)
        guard record.recordType == type.rawValue else { throw Failure.unexpectedRecordType }
        try set(content, on: record, syncKey: syncKey)
        return record
    }

    static func content<Content: Codable>(
        of record: CKRecord,
        as contentType: Content.Type = Content.self,
        syncKey: SymmetricKey
    ) throws -> Content {
        guard let sealed = record.encryptedValues[contentKey] as? Data else { throw Failure.missingContent }
        return try SyncRecordCodec<Content>(recordType: record.recordType, syncKey: syncKey)
            .open(sealed, recordName: record.recordID.recordName)
    }

    static func decodeSystemFields(_ metadata: Data) throws -> CKRecord {
        guard let decoder = try? NSKeyedUnarchiver(forReadingFrom: metadata) else { throw Failure.malformedMetadata }
        decoder.requiresSecureCoding = true
        defer { decoder.finishDecoding() }
        guard let record = CKRecord(coder: decoder) else { throw Failure.malformedMetadata }
        return record
    }

    private static func set<Content: Codable>(_ content: Content, on record: CKRecord, syncKey: SymmetricKey) throws {
        let sealed = try SyncRecordCodec<Content>(recordType: record.recordType, syncKey: syncKey)
            .seal(content, recordName: record.recordID.recordName)
        record.encryptedValues[contentKey] = sealed as CKRecordValue
    }
}

// MARK: - Content

/// Everything a `RecordType.service4` record says about a service
struct ServiceRecordContent: Codable, Equatable {
    var secret: String
    var name: String
    var serviceTypeID: String?
    var additionalInfo: String?
    var rawIssuer: String?
    var otpAuth: String?
    var tokenPeriod: Int?
    var tokenLength: Int
    var badgeColor: String?
    var iconType: String
    var iconTypeID: String
    var labelColor: String
    var labelTitle: String
    var sectionID: String?
    var sectionOrder: Int
    var algorithm: String
    var counter: Int?
    var tokenType: String
    var source: String
    /// When the user last changed the service on the device that wrote the record. Unlike the modification date
    /// the server keeps for the record, it doesn't move when the record is only written again – after a change
    /// of its order, of the password, or a migration – so a deletion made in between isn't undone by it.
    var modifiedAt: Date?

    init(serviceData: ServiceData, sectionOrder: Int) {
        secret = serviceData.secret
        name = serviceData.name
        serviceTypeID = serviceData.serviceTypeID?.uuidString
        additionalInfo = serviceData.additionalInfo
        rawIssuer = serviceData.rawIssuer
        otpAuth = serviceData.otpAuth
        tokenPeriod = serviceData.tokenPeriod?.rawValue
        tokenLength = serviceData.tokenLength.rawValue
        badgeColor = serviceData.badgeColor?.rawValue
        iconType = serviceData.iconType.rawValue
        iconTypeID = serviceData.iconTypeID.uuidString
        labelColor = serviceData.labelColor.rawValue
        labelTitle = serviceData.labelTitle
        sectionID = serviceData.sectionID?.uuidString
        self.sectionOrder = sectionOrder
        algorithm = serviceData.algorithm.rawValue
        counter = serviceData.counter
        tokenType = serviceData.tokenType.rawValue
        source = serviceData.source.rawValue
        modifiedAt = serviceData.modifiedAt
    }

    /// - Parameters:
    ///   - createdAt: When the record was created on the server.
    ///   - modifiedAt: When the record was last modified on the server – used only for a record that doesn't
    ///     say when the user changed the service.
    func serviceData(createdAt: Date, modifiedAt: Date) -> ServiceData {
        ServiceData(
            name: name,
            secret: secret,
            serviceTypeID: serviceTypeID.flatMap { UUID(uuidString: $0) },
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            modifiedAt: self.modifiedAt ?? modifiedAt,
            createdAt: createdAt,
            tokenPeriod: Period.create(tokenPeriod),
            tokenLength: Digits.create(tokenLength),
            badgeColor: TintColor.fromString(badgeColor),
            iconType: IconType(optionalWithDefaultRawValue: iconType),
            iconTypeID: UUID(uuidString: iconTypeID) ?? .default,
            labelColor: TintColor.fromString(labelColor),
            labelTitle: labelTitle,
            algorithm: Algorithm.create(algorithm),
            isTrashed: false,
            trashingDate: nil,
            counter: counter,
            tokenType: TokenType.create(tokenType),
            source: ServiceSource(optionalWithDefaultRawValue: source),
            otpAuth: otpAuth,
            order: sectionOrder,
            sectionID: sectionID.flatMap { UUID(uuidString: $0) }
        )
    }
}

/// Everything a `RecordType.section2` record says about a section (category)
struct SectionRecordContent: Codable, Equatable {
    var sectionID: String
    var title: String
    var order: Int
    var modifiedAt: Date?
}

/// A `RecordType.deletedService` record: the service whose identifier is the name of the record was deleted. It
/// holds nothing about the service itself – a device recognizes the service by deriving the same identifier from
/// its secret.
struct DeletedServiceRecordContent: Codable, Equatable {
    var deletedAt: Date
}

/// A `RecordType.deletedSection` record
struct DeletedSectionRecordContent: Codable, Equatable {
    var sectionID: String
    var deletedAt: Date
}

// MARK: - Deletions as items

/// The deletion of a service or a section, as Sync keeps it: found by its identifier (the name of its record).
struct SyncDeletion: Hashable {
    /// `SyncIdentifierKey.identifier(of:kind:)` of the deleted service (by its secret) or section (by its ID)
    let identifier: Data
    let deletedAt: Date
    /// Only for a section
    let sectionID: String?

    let recordName: String

    /// The deletion is older than what is remembered – it's removed everywhere
    func isExpired(now: Date = Date()) -> Bool {
        deletedAt < now.addingTimeInterval(-SyncDeletion.retention)
    }

    static let retention: TimeInterval = 365 * 24 * 60 * 60

    init(identifier: Data, deletedAt: Date, sectionID: String? = nil) {
        self.identifier = identifier
        self.deletedAt = deletedAt
        self.sectionID = sectionID
        recordName = SyncIdentifierKey.recordName(identifier: identifier)
    }

    /// `nil` for a name that isn't an identifier
    static func identifier(recordName: String) -> Data? {
        guard recordName.count == SyncIdentifierKey.byteCount * 2 else { return nil }
        var data = Data(capacity: SyncIdentifierKey.byteCount)
        var index = recordName.startIndex
        while index < recordName.endIndex {
            let next = recordName.index(index, offsetBy: 2)
            guard let byte = UInt8(recordName[index..<next], radix: 16) else { return nil }
            data.append(byte)
            index = next
        }
        return data
    }
}
