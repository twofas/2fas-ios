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

// Encrypted fields are plain Swift properties (not `@objc`) – the legacy migration policies set the old model's
// attributes of the same names through KVC on instances of these classes.
extension ServiceEntity {
    @nonobjc static let contentCodec = SealedContentCodec<ServiceSensitiveContent>(entityName: "ServiceEntity")
    @nonobjc private static let secretHashContext = "ServiceEntity.secret"
    
    @nonobjc static func secretHash(for secret: String, cipher: LocalStorageCipher) throws -> Data {
        try cipher.lookupHash(for: secret.uppercased(), context: secretHashContext)
    }
    
    /// `nil` when the context has no cipher or the hash can't be computed (e.g. no key) – nothing can match then
    @nonobjc static func secretHash(for secret: String, on context: NSManagedObjectContext) -> Data? {
        SealedEntity.lookupHash(on: context) { try secretHash(for: secret, cipher: $0) }
    }
    
    /// `nil` when the content can't be decrypted
    @nonobjc var content: ServiceSensitiveContent? {
        SealedEntity.content(
            of: self,
            entityName: "ServiceEntity",
            module: .storage,
            sealed: { encryptedContent },
            hashes: { [secretHash] },
            codec: Self.contentCodec,
            cache: contentCache
        )
    }
    
    /// Changes the content with a single seal. The secret identifies the service and can't be changed.
    @nonobjc func updateContent(_ change: (inout ServiceSensitiveContent) -> Void) throws {
        guard let cipher = managedObjectContext?.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
        guard let current = content else { throw SealedEntity.Failure.unreadableContent }
        var updated = current
        change(&updated)
        assert(updated.secret == current.secret, "The secret of a service can't be changed")
        updated.secret = current.secret
        guard updated != current else { return }
        let sealed = try Self.contentCodec.seal(updated, hashes: [secretHash], cipher: cipher)
        encryptedContent = sealed
        contentCache.store(updated, sealed: sealed)
    }
    
    @nonobjc var secret: String { content?.secret ?? "" }
    @nonobjc var name: String { content?.name ?? "" }
    @nonobjc var additionalInfo: String? { content?.additionalInfo }
    @nonobjc var rawIssuer: String? { content?.rawIssuer }
    @nonobjc var otpAuth: String? { content?.otpAuth }
    @nonobjc var labelTitle: String { content?.labelTitle ?? "" }
    @nonobjc var serviceTypeID: ServiceTypeID? { content?.serviceTypeID }
    @nonobjc var iconTypeID: IconTypeID { content?.iconTypeID ?? .default }
}

/// A readable service with its content opened once – filtering and sorting compare the fields many times, and
/// every read through the entity looks the content up again
struct ListedService: ServiceListable {
    let entity: ServiceEntity
    private let content: ServiceSensitiveContent
    
    /// `nil` when the content can't be decrypted
    init?(entity: ServiceEntity) {
        guard let content = entity.content else { return nil }
        self.entity = entity
        self.content = content
    }
    
    var name: String { content.name }
    var additionalInfo: String? { content.additionalInfo }
    var serviceTypeID: ServiceTypeID? { content.serviceTypeID }
}
