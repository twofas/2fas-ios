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

import Foundation
import CoreData

public enum LocalStorageUserInfoKey {
    public static let cipher = "com.2fas.localStorageCipher"
}

public extension NSManagedObjectContext {
    var localStorageCipher: LocalStorageCipher? {
        userInfo[LocalStorageUserInfoKey.cipher] as? LocalStorageCipher
    }

    func setLocalStorageCipher(_ cipher: LocalStorageCipher) {
        userInfo[LocalStorageUserInfoKey.cipher] = cipher
    }
}

public extension NSMigrationManager {
    var localStorageCipher: LocalStorageCipher? {
        userInfo?[LocalStorageUserInfoKey.cipher] as? LocalStorageCipher
    }
}

public struct SealedContentCodec<Content: Codable> {
    private let entityName: String
    /// The schema version written with the content – also the newest one that can be read
    private let contentVersion: Int

    public init(entityName: String, contentVersion: Int = 1) {
        self.entityName = entityName
        self.contentVersion = contentVersion
    }

    public func associatedData(hashes: [Data]) -> Data {
        hashes.reduce(into: Data("2fas.\(entityName).v1".utf8)) { $0.append($1) }
    }

    public func seal(_ content: Content, hashes: [Data], cipher: LocalStorageCipher) throws -> Data {
        let plaintext = try JSONEncoder().encode(VersionedContent(version: contentVersion, content: content))
        return try cipher.seal(plaintext, associatedData: associatedData(hashes: hashes))
    }

    public func open(_ sealed: Data, hashes: [Data], cipher: LocalStorageCipher) throws -> Content {
        let plaintext = try cipher.open(sealed, associatedData: associatedData(hashes: hashes))
        return try decode(plaintext)
    }

    /// - Throws: `SealedEntity.Failure.unsupportedContentVersion` for content of a newer schema.
    func decode(_ plaintext: Data) throws -> Content {
        let decoder = JSONDecoder()
        decoder.userInfo[VersionedContent<Content>.newestVersionKey] = contentVersion
        return try decoder.decode(VersionedContent<Content>.self, from: plaintext).content
    }
}

/// The fields of the content and `"v"` in one JSON object – decoded in a single pass
private struct VersionedContent<Content: Codable>: Codable {
    private enum CodingKeys: String, CodingKey {
        case version = "v"
    }

    // swiftlint:disable:next force_unwrapping
    static var newestVersionKey: CodingUserInfoKey { CodingUserInfoKey(rawValue: "com.2fas.sealedContentVersion")! }

    let version: Int
    let content: Content

    init(version: Int, content: Content) {
        self.version = version
        self.content = content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
        if let newest = decoder.userInfo[Self.newestVersionKey] as? Int, version > newest {
            throw SealedEntity.Failure.unsupportedContentVersion(version)
        }
        content = try Content(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        try content.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
    }
}

/// Not thread-safe: access only on the queue of the managed object's context.
public final class SealedContentCache<Content> {
    private var sealed: Data?
    private var content: Content?

    public init() {}

    public func content(forSealed sealed: Data) -> Content? {
        guard let stored = self.sealed, stored == sealed else { return nil }
        return content
    }

    public func store(_ content: Content, sealed: Data) {
        self.sealed = sealed
        self.content = content
    }

    public func clear() {
        sealed = nil
        content = nil
    }
}
