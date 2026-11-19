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

/// The cached record of a deleted service (`RecordType.deletedService`)
@objc(DeletedServiceCacheEntity)
final class DeletedServiceCacheEntity: NSManagedObject {
    @nonobjc static let entityName = "DeletedServiceCacheEntity"
    @nonobjc private static let metadataDomain = Data("2fas.DeletedServiceCacheEntity.metadata.v1".utf8)

    @nonobjc class func request() -> NSFetchRequest<DeletedServiceCacheEntity> {
        NSFetchRequest<DeletedServiceCacheEntity>(entityName: entityName)
    }

    /// The identifier of the deletion: the hash of the secret of the deleted service derived with
    /// `SyncIdentifierKey` – also the name of the record. (Not the hash the local store finds the service by:
    /// that one is derived with the local storage key.)
    @NSManaged var secretHash: Data
    @NSManaged var deletedAt: Date
    /// Not used by the cache – what the record says is in `deletedAt` and in its name
    @NSManaged var encryptedContent: Data?
    /// The system fields of the record, sealed with the local storage key
    @NSManaged var encryptedMetadata: Data?

    @nonobjc static func find(on context: NSManagedObjectContext, identifier: Data) -> [DeletedServiceCacheEntity] {
        let request = request()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(DeletedServiceCacheEntity.secretHash),
            identifier as NSData
        )
        request.includesPendingChanges = true
        return fetch(request, on: context)
    }

    @nonobjc static func listAll(on context: NSManagedObjectContext) -> [DeletedServiceCacheEntity] {
        let request = request()
        request.includesPendingChanges = true
        return fetch(request, on: context)
    }

    /// The system fields of the record. `nil` when they can't be opened.
    @nonobjc var metadata: Data? {
        guard let encryptedMetadata, let cipher = managedObjectContext?.localStorageCipher else { return nil }
        return try? cipher.open(encryptedMetadata, associatedData: Self.metadataDomain + secretHash)
    }

    /// - Throws: When the system fields can't be sealed. Nothing is changed then.
    @nonobjc func setMetadata(_ metadata: Data) throws {
        guard let cipher = managedObjectContext?.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
        encryptedMetadata = try cipher.seal(metadata, associatedData: Self.metadataDomain + secretHash)
    }

    @nonobjc private static func fetch(
        _ request: NSFetchRequest<DeletedServiceCacheEntity>,
        on context: NSManagedObjectContext
    ) -> [DeletedServiceCacheEntity] {
        do {
            return try context.fetch(request)
        } catch {
            Log("\(entityName) - can't fetch", module: .cloudSync, severity: .error)
            return []
        }
    }
}

/// The cached record of a deleted section (`RecordType.deletedSection`)
@objc(DeletedSectionCacheEntity)
final class DeletedSectionCacheEntity: NSManagedObject {
    @nonobjc static let entityName = "DeletedSectionCacheEntity"

    @nonobjc class func request() -> NSFetchRequest<DeletedSectionCacheEntity> {
        NSFetchRequest<DeletedSectionCacheEntity>(entityName: entityName)
    }

    @NSManaged var sectionID: String
    @NSManaged var deletedAt: Date
    /// The system fields of the record
    @NSManaged var metadata: Data?

    @nonobjc static func find(on context: NSManagedObjectContext, sectionID: String) -> [DeletedSectionCacheEntity] {
        let request = request()
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(DeletedSectionCacheEntity.sectionID),
            sectionID
        )
        request.includesPendingChanges = true
        return fetch(request, on: context)
    }

    @nonobjc static func listAll(on context: NSManagedObjectContext) -> [DeletedSectionCacheEntity] {
        let request = request()
        request.includesPendingChanges = true
        return fetch(request, on: context)
    }

    @nonobjc private static func fetch(
        _ request: NSFetchRequest<DeletedSectionCacheEntity>,
        on context: NSManagedObjectContext
    ) -> [DeletedSectionCacheEntity] {
        do {
            return try context.fetch(request)
        } catch {
            Log("\(entityName) - can't fetch", module: .cloudSync, severity: .error)
            return []
        }
    }
}
