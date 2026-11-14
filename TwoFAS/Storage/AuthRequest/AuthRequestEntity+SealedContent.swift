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

struct AuthRequestSensitiveContent: Codable, Equatable {
    var secret: String
    var domain: String
}

// Encrypted fields are plain Swift properties (not `@objc`), like in `ServiceEntity`
extension AuthRequestEntity {
    @nonobjc static let contentCodec = SealedContentCodec<AuthRequestSensitiveContent>(entityName: "AuthRequestEntity")
    @nonobjc private static let secretHashContext = "AuthRequestEntity.secret"
    @nonobjc private static let domainHashContext = "AuthRequestEntity.domain"
    
    @nonobjc static func secretHash(for secret: String, cipher: LocalStorageCipher) throws -> Data {
        try cipher.lookupHash(for: secret.uppercased(), context: secretHashContext)
    }
    
    /// The domain isn't normalized – it's compared exactly
    @nonobjc static func domainHash(for domain: String, cipher: LocalStorageCipher) throws -> Data {
        try cipher.lookupHash(for: domain, context: domainHashContext)
    }
    
    /// `nil` when the context has no cipher or the hash can't be computed (e.g. no key) – nothing can match then
    @nonobjc static func secretHash(for secret: String, on context: NSManagedObjectContext) -> Data? {
        SealedEntity.lookupHash(on: context) { try secretHash(for: secret, cipher: $0) }
    }
    
    /// `nil` when the context has no cipher or the hash can't be computed (e.g. no key) – nothing can match then
    @nonobjc static func domainHash(for domain: String, on context: NSManagedObjectContext) -> Data? {
        SealedEntity.lookupHash(on: context) { try domainHash(for: domain, cipher: $0) }
    }
    
    /// `nil` when the content can't be decrypted
    @nonobjc var content: AuthRequestSensitiveContent? {
        SealedEntity.content(
            of: self,
            entityName: "AuthRequestEntity",
            module: .storage,
            sealed: { encryptedContent },
            hashes: { [secretHash, domainHash] },
            codec: Self.contentCodec,
            cache: contentCache
        )
    }
    
    @nonobjc var secret: String { content?.secret ?? "" }
    @nonobjc var domain: String { content?.domain ?? "" }
}
