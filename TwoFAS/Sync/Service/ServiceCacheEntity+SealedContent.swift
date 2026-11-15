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

// Encrypted fields are plain Swift properties (not `@objc`), like in Storage's `ServiceEntity`
extension ServiceCacheEntity {
    @nonobjc static let contentCodec = SealedContentCodec<ServiceSensitiveContent>(entityName: "ServiceCacheEntity")
    @nonobjc private static let secretHashContext = "ServiceCacheEntity.secret"

    @nonobjc static func secretHash(for secret: String, cipher: LocalStorageCipher) throws -> Data {
        try cipher.lookupHash(for: secret.uppercased(), context: secretHashContext)
    }

    /// `nil` when the context has no cipher or the hash can't be computed (e.g. no key) – nothing can match then
    @nonobjc static func secretHash(for secret: String, on context: NSManagedObjectContext) -> Data? {
        SealedEntity.lookupHash(on: context) { try secretHash(for: secret, cipher: $0) }
    }

    /// Throws when the content can't be decrypted – the cache can't be trusted then
    @nonobjc func decryptedContent() throws -> ServiceSensitiveContent {
        try SealedEntity.openContent(
            of: self,
            sealed: { encryptedContent },
            hashes: { [secretHash] },
            codec: Self.contentCodec,
            cache: contentCache
        )
    }

    /// `nil` when the content can't be decrypted – a reset of the cache is scheduled then
    @nonobjc var content: ServiceSensitiveContent? {
        SyncStoreIntegrity.valueOrScheduleReset(entityName: "ServiceCacheEntity", field: "content") {
            try decryptedContent()
        }
    }

    /// Replaces the record metadata and changes the content with a single seal of the content. Both are sealed before
    /// anything is assigned, so a failure changes nothing. The secret identifies the service and can't be changed.
    @nonobjc func update(metadata: Data, content change: (inout ServiceSensitiveContent) -> Void) throws {
        guard let cipher = managedObjectContext?.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
        guard let current = content else { throw SealedEntity.Failure.unreadableContent }
        var updated = current
        change(&updated)
        updated.secret = current.secret
        let sealedContent = updated != current
            ? try Self.contentCodec.seal(updated, hashes: [secretHash], cipher: cipher)
            : nil
        let sealedMetadata = try Self.sealMetadata(metadata, secretHash: secretHash, cipher: cipher)
        if let sealedContent {
            encryptedContent = sealedContent
            contentCache.store(updated, sealed: sealedContent)
        }
        encryptedMetadata = sealedMetadata
        metadataCache.store(metadata, sealed: sealedMetadata)
    }

    // MARK: - Metadata

    /// The system fields of the `CKRecord` – the record name of an old (`service2`) record is derived from the secret,
    /// so they are sealed too. AAD = `UTF8("2fas.ServiceCacheEntity.metadata.v1") ‖ secretHash`.
    @nonobjc static func metadataAssociatedData(secretHash: Data) -> Data {
        Data("2fas.ServiceCacheEntity.metadata.v1".utf8) + secretHash
    }

    @nonobjc static func sealMetadata(_ metadata: Data, secretHash: Data, cipher: LocalStorageCipher) throws -> Data {
        try cipher.seal(metadata, associatedData: metadataAssociatedData(secretHash: secretHash))
    }

    /// Throws when the metadata can't be decrypted – the cache can't be trusted then
    @nonobjc func decryptedMetadata() throws -> Data {
        guard let context = managedObjectContext else { throw SealedEntity.Failure.missingContext }
        let sealed = encryptedMetadata
        if let cached = metadataCache.content(forSealed: sealed) {
            return cached
        }
        guard let cipher = context.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
        let metadata = try cipher.open(sealed, associatedData: Self.metadataAssociatedData(secretHash: secretHash))
        metadataCache.store(metadata, sealed: sealed)
        return metadata
    }

    /// Empty when the metadata can't be decrypted – a reset of the cache is scheduled then
    @nonobjc var metadata: Data {
        SyncStoreIntegrity.valueOrScheduleReset(entityName: "ServiceCacheEntity", field: "metadata") {
            try decryptedMetadata()
        } ?? Data()
    }

    // MARK: - Content accessors

    @nonobjc var secret: String { content?.secret ?? "" }
    @nonobjc var name: String { content?.name ?? "" }
    @nonobjc var additionalInfo: String? { content?.additionalInfo }
    @nonobjc var rawIssuer: String? { content?.rawIssuer }
    @nonobjc var otpAuth: String? { content?.otpAuth }
    @nonobjc var labelTitle: String { content?.labelTitle ?? "" }
    @nonobjc var serviceTypeID: ServiceTypeID? { content?.serviceTypeID }
    @nonobjc var iconTypeID: IconTypeID { content?.iconTypeID ?? .default }
}
