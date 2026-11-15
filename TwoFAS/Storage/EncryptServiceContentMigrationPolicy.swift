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
import CoreData
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

@objc(EncryptServiceContentMigrationPolicy)
final class EncryptServiceContentMigrationPolicy: NSEntityMigrationPolicy {
    enum Failure: Error {
        case missingCipher
    }

    private static let entityName = "ServiceEntity"
    /// Attributes kept in plaintext under the same names
    private static let plainKeys = [
        "creationDate",
        "modificationDate",
        "sectionID",
        "sectionOrder",
        "isTrashed",
        "trashingDate",
        "tokenPeriod",
        "tokenLength",
        "algorithm",
        "tokenType",
        "counter",
        "badgeColor",
        "iconType",
        "labelColor",
        "source"
    ]

    private static let deletedEntityName = "DeletedServiceEntity"

    private struct Migrated {
        let instance: NSManagedObject
        let isTrashed: Bool
        let modificationDate: Date
        /// The deletion record of a trashed service
        var deletion: NSManagedObject?
    }

    /// What was migrated for every secret, with what decides which duplicate is kept
    private var migrated: [Data: Migrated] = [:]

    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        assert(sInstance.entity.name == Self.entityName, "Policy used for another entity")
        guard let cipher = manager.localStorageCipher else { throw Failure.missingCipher }

        // Stored as `encrypt(secret.uppercased())`
        guard let obfuscatedSecret = sInstance.value(forKey: "secret") as? String, !obfuscatedSecret.isEmpty else {
            Log("Migration - \(Self.entityName) skipped: empty secret", module: .storage, severity: .warning)
            return
        }
        let secret = obfuscatedSecret.decrypt().uppercased()

        // The hash is part of the associated data, so the key has to exist before hashing
        try cipher.prepareForWriting()
        let secretHash = try ServiceEntity.secretHash(for: secret, cipher: cipher)
        // A secret identifies a service, so only one row of a duplicated secret is kept: one that isn't trashed
        // rather than a trashed one, then the one modified last
        let isTrashed = sInstance.value(forKey: "isTrashed") as? Bool ?? false
        let modificationDate = sInstance.value(forKey: "modificationDate") as? Date ?? .distantPast
        let duplicate = migrated[secretHash]
        if let duplicate {
            let isBetter = duplicate.isTrashed != isTrashed
                ? !isTrashed
                : modificationDate > duplicate.modificationDate
            guard isBetter else {
                Log("Migration - \(Self.entityName) skipped: duplicated secret", module: .storage, severity: .warning)
                return
            }
            Log("Migration - \(Self.entityName) replaced: duplicated secret", module: .storage, severity: .warning)
        }

        let content = ServiceSensitiveContent(
            secret: secret,
            name: sInstance.value(forKey: "name") as? String ?? "",
            additionalInfo: sInstance.value(forKey: "additionalInfo") as? String,
            rawIssuer: sInstance.value(forKey: "rawIssuer") as? String,
            otpAuth: sInstance.value(forKey: "otpAuth") as? String,
            labelTitle: sInstance.value(forKey: "labelTitle") as? String ?? "",
            serviceTypeID: sInstance.value(forKey: "serviceTypeID") as? ServiceTypeID,
            iconTypeID: sInstance.value(forKey: "iconTypeID") as? IconTypeID ?? .default
        )
        let sealed = try ServiceEntity.contentCodec.seal(content, hashes: [secretHash], cipher: cipher)

        // Through KVC – the class' accessors of the encrypted fields aren't modeled attributes
        let dInstance = duplicate?.instance ?? NSEntityDescription.insertNewObject(
            forEntityName: Self.entityName,
            into: manager.destinationContext
        )
        dInstance.setValue(secretHash, forKey: "secretHash")
        dInstance.setValue(sealed, forKey: "encryptedContent")
        for key in Self.plainKeys {
            dInstance.setValue(sInstance.value(forKey: key), forKey: key)
        }
        // A destination instance is associated with one source only – the row it was first created for
        if duplicate == nil {
            manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
        }

        // A service in the trash is a deleted one – it gets its deletion record, dated when it was trashed
        var deletion = duplicate?.deletion
        if isTrashed {
            let deletedAt = sInstance.value(forKey: "trashingDate") as? Date ?? modificationDate
            let sealedSecret = try DeletedServiceEntity.contentCodec.seal(
                DeletedServiceSensitiveContent(secret: secret),
                hashes: [secretHash],
                cipher: cipher
            )
            let record = deletion ?? NSEntityDescription.insertNewObject(
                forEntityName: Self.deletedEntityName,
                into: manager.destinationContext
            )
            record.setValue(secretHash, forKey: "secretHash")
            record.setValue(sealedSecret, forKey: "encryptedContent")
            record.setValue(deletedAt, forKey: "deletedAt")
            deletion = record
        } else if let record = deletion {
            manager.destinationContext.delete(record)
            deletion = nil
        }
        migrated[secretHash] = Migrated(
            instance: dInstance,
            isTrashed: isTrashed,
            modificationDate: modificationDate,
            deletion: deletion
        )
    }
}

/// TwoFAS7 → TwoFAS8: the title of `SectionEntity` moves into sealed content bound to the ID of the section
@objc(EncryptSectionContentMigrationPolicy)
final class EncryptSectionContentMigrationPolicy: NSEntityMigrationPolicy {
    enum Failure: Error {
        case missingCipher
    }

    private static let entityName = "SectionEntity"
    /// Attributes kept in plaintext under the same names
    private static let plainKeys = ["sectionID", "order", "isCollapsed", "creationDate", "modificationDate"]

    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        assert(sInstance.entity.name == Self.entityName, "Policy used for another entity")
        guard let cipher = manager.localStorageCipher else { throw Failure.missingCipher }

        guard let sectionID = sInstance.value(forKey: "sectionID") as? UUID else {
            Log("Migration - \(Self.entityName) skipped: no ID", module: .storage, severity: .warning)
            return
        }
        try cipher.prepareForWriting()
        let sealed = try SectionEntity.contentCodec.seal(
            SectionSensitiveContent(title: sInstance.value(forKey: "title") as? String ?? ""),
            hashes: [sectionID.bytesData],
            cipher: cipher
        )

        // Through KVC – the class' accessor of the title isn't a modeled attribute
        let dInstance = NSEntityDescription.insertNewObject(
            forEntityName: Self.entityName,
            into: manager.destinationContext
        )
        dInstance.setValue(sealed, forKey: "encryptedContent")
        for key in Self.plainKeys {
            dInstance.setValue(sInstance.value(forKey: key), forKey: key)
        }
        manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
    }
}
