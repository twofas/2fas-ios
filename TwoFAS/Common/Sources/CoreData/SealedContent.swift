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

    public init(entityName: String) {
        self.entityName = entityName
    }

    public func associatedData(hashes: [Data]) -> Data {
        hashes.reduce(into: Data("2fas.\(entityName).v1".utf8)) { $0.append($1) }
    }

    public func seal(_ content: Content, hashes: [Data], cipher: LocalStorageCipher) throws -> Data {
        let plaintext = try JSONEncoder().encode(content)
        return try cipher.seal(plaintext, associatedData: associatedData(hashes: hashes))
    }

    public func open(_ sealed: Data, hashes: [Data], cipher: LocalStorageCipher) throws -> Content {
        let plaintext = try cipher.open(sealed, associatedData: associatedData(hashes: hashes))
        return try JSONDecoder().decode(Content.self, from: plaintext)
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
