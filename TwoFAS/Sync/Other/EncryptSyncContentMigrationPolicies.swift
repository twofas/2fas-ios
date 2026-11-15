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

@objc(EncryptServiceCacheContentMigrationPolicy)
final class EncryptServiceCacheContentMigrationPolicy: NSEntityMigrationPolicy {
    enum Failure: Error {
        case missingCipher
    }

    private static let entityName = "ServiceCacheEntity"
    /// Attributes kept in plaintext under the same names
    private static let plainKeys = [
        "creationDate",
        "modificationDate",
        "sectionID",
        "sectionOrder",
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

    /// Destination instance of every migrated secret, with what decides which duplicate is kept
    private var migrated: [Data: (instance: NSManagedObject, modificationDate: Date)] = [:]

    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        assert(sInstance.entity.name == Self.entityName, "Policy used for another entity")
        guard let cipher = manager.localStorageCipher else { throw Failure.missingCipher }

        // Stored as `encrypt(secret.uppercased())`
        guard let obfuscatedSecret = sInstance.value(forKey: "secret") as? String, !obfuscatedSecret.isEmpty else {
            Log("Sync Migration - \(Self.entityName) skipped: empty secret", module: .cloudSync, severity: .warning)
            return
        }
        let secret = obfuscatedSecret.decrypt().uppercased()

        // The hash is part of the associated data, so the key has to exist before hashing
        try cipher.prepareForWriting()
        let secretHash = try ServiceCacheEntity.secretHash(for: secret, cipher: cipher)
        // A secret identifies a service, so only the row of a duplicated secret that was modified last is kept
        let modificationDate = sInstance.value(forKey: "modificationDate") as? Date ?? .distantPast
        let duplicate = migrated[secretHash]
        if let duplicate {
            guard modificationDate > duplicate.modificationDate else {
                Log(
                    "Sync Migration - \(Self.entityName) skipped: duplicated secret",
                    module: .cloudSync,
                    severity: .warning
                )
                return
            }
            Log(
                "Sync Migration - \(Self.entityName) replaced: duplicated secret",
                module: .cloudSync,
                severity: .warning
            )
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
        let sealed = try ServiceCacheEntity.contentCodec.seal(content, hashes: [secretHash], cipher: cipher)
        let metadata = sInstance.value(forKey: "metadata") as? Data ?? Data()
        let sealedMetadata = try ServiceCacheEntity.sealMetadata(metadata, secretHash: secretHash, cipher: cipher)

        // Through KVC – the class' accessors of the encrypted fields aren't modeled attributes
        let dInstance = duplicate?.instance ?? NSEntityDescription.insertNewObject(
            forEntityName: Self.entityName,
            into: manager.destinationContext
        )
        migrated[secretHash] = (dInstance, modificationDate)
        dInstance.setValue(secretHash, forKey: "secretHash")
        dInstance.setValue(sealed, forKey: "encryptedContent")
        dInstance.setValue(sealedMetadata, forKey: "encryptedMetadata")
        for key in Self.plainKeys {
            dInstance.setValue(sInstance.value(forKey: key), forKey: key)
        }
        // A destination instance is associated with one source only – the row it was first created for
        if duplicate == nil {
            manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
        }
    }
}

/// Sync5 → Sync6: the plaintext `entityID` of `LogEntity` (a secret for services) becomes `entityIDHash` +
/// `encryptedEntityID`. Every row is migrated – rows aren't deduplicated.
@objc(EncryptLogEntityMigrationPolicy)
final class EncryptLogEntityMigrationPolicy: NSEntityMigrationPolicy {
    enum Failure: Error {
        case missingCipher
    }

    private static let entityName = "LogEntity"
    private static let plainKeys = ["action", "date", "kind", "isApplied"]

    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        assert(sInstance.entity.name == Self.entityName, "Policy used for another entity")
        guard let cipher = manager.localStorageCipher else { throw Failure.missingCipher }

        // Plaintext, no normalization
        let entityID = sInstance.value(forKey: "entityID") as? String ?? ""

        try cipher.prepareForWriting()
        let entityIDHash = try LogEntity.entityIDHash(for: entityID, cipher: cipher)
        let sealed = try LogEntity.contentCodec.seal(
            LogEntityContent(entityID: entityID),
            hashes: [entityIDHash],
            cipher: cipher
        )

        let dInstance = NSEntityDescription.insertNewObject(
            forEntityName: Self.entityName,
            into: manager.destinationContext
        )
        dInstance.setValue(entityIDHash, forKey: "entityIDHash")
        dInstance.setValue(sealed, forKey: LogEntity.sealedKey)
        for key in Self.plainKeys {
            dInstance.setValue(sInstance.value(forKey: key), forKey: key)
        }
        manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
    }
}

/// Sync5 → Sync6: the title of `SectionCacheEntity` moves into sealed content bound to the ID of the section
@objc(EncryptSectionCacheContentMigrationPolicy)
final class EncryptSectionCacheContentMigrationPolicy: NSEntityMigrationPolicy {
    enum Failure: Error {
        case missingCipher
    }

    private static let entityName = "SectionCacheEntity"
    private static let plainKeys = ["sectionID", "order", "metadata", "creationDate", "modificationDate"]

    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        assert(sInstance.entity.name == Self.entityName, "Policy used for another entity")
        guard let cipher = manager.localStorageCipher else { throw Failure.missingCipher }

        guard let sectionID = sInstance.value(forKey: "sectionID") as? String else {
            Log("Sync Migration - \(Self.entityName) skipped: no ID", module: .cloudSync, severity: .warning)
            return
        }
        try cipher.prepareForWriting()
        let sealed = try SectionCacheEntity.contentCodec.seal(
            SectionSensitiveContent(title: sInstance.value(forKey: "title") as? String ?? ""),
            hashes: [SectionCacheEntity.identityData(of: sectionID)],
            cipher: cipher
        )

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
