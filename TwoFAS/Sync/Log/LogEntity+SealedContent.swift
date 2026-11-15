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

/// The ID of a service is its secret, so every log entry keeps its `entityID` sealed – sections too, for simplicity
struct LogEntityContent: Codable, Equatable {
    var entityID: String
}

// `entityID` is a plain Swift property (not `@objc`), like the encrypted fields of `ServiceCacheEntity`
extension LogEntity {
    @nonobjc static let contentCodec = SealedContentCodec<LogEntityContent>(entityName: "LogEntity")
    @nonobjc static let sealedKey = "encryptedEntityID"
    @nonobjc private static let entityIDHashContext = "LogEntity.entityID"

    /// The ID isn't normalized – it's compared exactly
    @nonobjc static func entityIDHash(for entityID: String, cipher: LocalStorageCipher) throws -> Data {
        try cipher.lookupHash(for: entityID, context: entityIDHashContext)
    }

    /// `nil` when the context has no cipher or the hash can't be computed (e.g. no key) – nothing can match then
    @nonobjc static func entityIDHash(for entityID: String, on context: NSManagedObjectContext) -> Data? {
        SealedEntity.lookupHash(on: context) { try entityIDHash(for: entityID, cipher: $0) }
    }

    /// Throws when the ID can't be decrypted – the change log can't be trusted then
    @nonobjc func decryptedEntityID() throws -> String {
        try SealedEntity.openContent(
            of: self,
            sealedKey: Self.sealedKey,
            sealed: { encryptedEntityID },
            hashes: { [entityIDHash] },
            codec: Self.contentCodec,
            cache: contentCache
        ).entityID
    }

    /// Empty when the ID can't be decrypted – a reset of the cache is scheduled then
    @nonobjc var entityID: String {
        SyncStoreIntegrity.valueOrScheduleReset(entityName: "LogEntity", field: "entityID") {
            try decryptedEntityID()
        } ?? ""
    }
}
