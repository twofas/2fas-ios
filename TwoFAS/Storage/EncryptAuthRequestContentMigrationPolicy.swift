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

@objc(EncryptAuthRequestContentMigrationPolicy)
final class EncryptAuthRequestContentMigrationPolicy: NSEntityMigrationPolicy {
    enum Failure: Error {
        case missingCipher
    }

    private static let entityName = "AuthRequestEntity"
    /// Attributes kept in plaintext under the same names
    private static let plainKeys = [
        "creationDate",
        "lastUsed",
        "usedCount"
    ]

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
        let content = AuthRequestSensitiveContent(
            secret: obfuscatedSecret.decrypt().uppercased(),
            domain: sInstance.value(forKey: "domain") as? String ?? "",
            extensionID: sInstance.value(forKey: "extensionID") as? String ?? ""
        )

        // The hashes are part of the associated data, so the key has to exist before hashing
        try cipher.prepareForWriting()
        let secretHash = try AuthRequestEntity.secretHash(for: content.secret, cipher: cipher)
        let domainHash = try AuthRequestEntity.domainHash(for: content.domain, cipher: cipher)
        let extensionIDHash = try AuthRequestEntity.extensionIDHash(for: content.extensionID, cipher: cipher)
        let sealed = try AuthRequestEntity.contentCodec.seal(
            content,
            hashes: [secretHash, domainHash, extensionIDHash],
            cipher: cipher
        )

        // Through KVC – the class' accessors of the encrypted fields aren't modeled attributes
        let dInstance = NSEntityDescription.insertNewObject(
            forEntityName: Self.entityName,
            into: manager.destinationContext
        )
        dInstance.setValue(secretHash, forKey: "secretHash")
        dInstance.setValue(domainHash, forKey: "domainHash")
        dInstance.setValue(extensionIDHash, forKey: "extensionIDHash")
        dInstance.setValue(sealed, forKey: "encryptedContent")
        for key in Self.plainKeys {
            dInstance.setValue(sInstance.value(forKey: key), forKey: key)
        }
        manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
    }
}

/// TwoFAS7 → TwoFAS8: the ID, the name and the public key of a paired browser extension (`PairingEntity`) move
/// into sealed content
@objc(EncryptPairingContentMigrationPolicy)
final class EncryptPairingContentMigrationPolicy: NSEntityMigrationPolicy {
    enum Failure: Error {
        case missingCipher
    }

    private static let entityName = "PairingEntity"
    /// Attributes kept in plaintext under the same names
    private static let plainKeys = ["creationDate", "modifcationDate"]

    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        assert(sInstance.entity.name == Self.entityName, "Policy used for another entity")
        guard let cipher = manager.localStorageCipher else { throw Failure.missingCipher }

        let content = PairingSensitiveContent(
            extensionID: sInstance.value(forKey: "extensionID") as? String ?? "",
            name: sInstance.value(forKey: "name") as? String ?? "",
            publicKey: sInstance.value(forKey: "publicKey") as? String ?? ""
        )

        // The hash is part of the associated data, so the key has to exist before hashing
        try cipher.prepareForWriting()
        let extensionIDHash = try PairingEntity.extensionIDHash(for: content.extensionID, cipher: cipher)
        let sealed = try PairingEntity.contentCodec.seal(content, hashes: [extensionIDHash], cipher: cipher)

        // Through KVC – the class' accessors of the encrypted fields aren't modeled attributes
        let dInstance = NSEntityDescription.insertNewObject(
            forEntityName: Self.entityName,
            into: manager.destinationContext
        )
        dInstance.setValue(extensionIDHash, forKey: "extensionIDHash")
        dInstance.setValue(sealed, forKey: "encryptedContent")
        for key in Self.plainKeys {
            dInstance.setValue(sInstance.value(forKey: key), forKey: key)
        }
        manager.associate(sourceInstance: sInstance, withDestinationInstance: dInstance, for: mapping)
    }
}
