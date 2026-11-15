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

/// Shared by the entities that keep their sensitive fields in a sealed attribute
public enum SealedEntity {
    public enum Failure: Error {
        case missingCipher
        case missingContext
        case unreadableContent
    }

    /// `nil` when the context has no cipher or `hash` throws (e.g. no key yet)
    public static func lookupHash(
        on context: NSManagedObjectContext,
        _ hash: (LocalStorageCipher) throws -> Data
    ) -> Data? {
        guard let cipher = context.localStorageCipher else { return nil }
        return try? hash(cipher)
    }

    /// Safe for logs: never contains values or blob bytes
    public static func describe(_ error: Error) -> String {
        if let error = error as? LocalStorageCipherError {
            return "\(error)"
        }
        if let error = error as? Failure {
            return "\(error)"
        }
        let nsError = error as NSError
        return "\(nsError.domain) \(nsError.code)"
    }

    /// Content cached for the current bytes of the sealed attribute, otherwise opened and cached. Has to be called on
    /// the queue of the object's context.
    /// - Parameter sealedKey: Name of the sealed attribute – read as a primitive value when the object has no context.
    /// - Throws: `Failure.missingContext`, `Failure.missingCipher` or the error of opening the content.
    public static func openContent<Content: Codable>(
        of object: NSManagedObject,
        sealedKey: String = defaultSealedKey,
        sealed: () -> Data,
        hashes: () -> [Data],
        codec: SealedContentCodec<Content>,
        cache: SealedContentCache<Content>
    ) throws -> Content {
        guard let context = object.managedObjectContext else {
            // A primitive read doesn't fire a fault
            if let sealed = object.primitiveValue(forKey: sealedKey) as? Data,
               let cached = cache.content(forSealed: sealed) {
                return cached
            }
            throw Failure.missingContext
        }
        let sealed = sealed()
        if let cached = cache.content(forSealed: sealed) {
            return cached
        }
        guard let cipher = context.localStorageCipher else { throw Failure.missingCipher }
        let content = try codec.open(sealed, hashes: hashes(), cipher: cipher)
        cache.store(content, sealed: sealed)
        return content
    }

    /// Like `openContent`, but `nil` on failure – logged to `module` with the entity name and error code only
    public static func content<Content: Codable>(
        of object: NSManagedObject,
        entityName: String,
        module: LogModule,
        sealedKey: String = defaultSealedKey,
        sealed: () -> Data,
        hashes: () -> [Data],
        codec: SealedContentCodec<Content>,
        cache: SealedContentCache<Content>
    ) -> Content? {
        do {
            return try openContent(
                of: object,
                sealedKey: sealedKey,
                sealed: sealed,
                hashes: hashes,
                codec: codec,
                cache: cache
            )
        } catch Failure.missingContext {
            assertionFailure("\(entityName) - reading content without a context")
            return nil
        } catch Failure.missingCipher {
            Log("\(entityName) - no cipher for reading content", module: module, severity: .error)
            return nil
        } catch {
            Log("\(entityName) - can't open content: \(describe(error))", module: module, severity: .error)
            return nil
        }
    }

    public static let defaultSealedKey = "encryptedContent"
}
