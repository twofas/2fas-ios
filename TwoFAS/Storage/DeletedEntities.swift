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

/// How long a deletion is remembered. A device that didn't sync for longer brings the deleted item back.
enum DeletionRetention {
    static let interval: TimeInterval = 365 * 24 * 60 * 60

    static func expirationDate(now: Date) -> Date {
        now.addingTimeInterval(-interval)
    }
}

/// The record of a deleted service: it exists while the service is in the trash and stays after the service is
/// removed from the trash for good. Restoring the service (or adding it again) removes the record. Sync decides
/// about deletions by these records – never by a service missing somewhere.
@objc(DeletedServiceEntity)
final class DeletedServiceEntity: NSManagedObject {
    @nonobjc private static let entityName = "DeletedServiceEntity"
    @nonobjc static let contentCodec = SealedContentCodec<DeletedServiceSensitiveContent>(
        entityName: "DeletedServiceEntity"
    )

    @nonobjc static func request() -> NSFetchRequest<DeletedServiceEntity> {
        NSFetchRequest<DeletedServiceEntity>(entityName: entityName)
    }

    /// The same hash as `ServiceEntity.secretHash` of the deleted service
    @NSManaged var secretHash: Data
    /// The sealed secret – what identifies the service on other devices. Kept only until `syncID` is set.
    @NSManaged var encryptedContent: Data?
    @NSManaged var deletedAt: Date
    /// The identifier of the deletion in the cloud, set by Sync
    @NSManaged var syncID: Data?

    /// Records that the service was deleted at `deletedAt`. A service has one record: when it was deleted more than
    /// once (e.g. on two devices before they synced), the latest deletion is the one that counts – it's the last
    /// thing the user did with the service.
    @nonobjc static func record(on context: NSManagedObjectContext, secret: String, deletedAt: Date) {
        let secretHash: Data
        let sealed: Data
        do {
            guard let cipher = context.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
            try cipher.prepareForWriting()
            secretHash = try ServiceEntity.secretHash(for: secret, cipher: cipher)
            sealed = try contentCodec.seal(
                DeletedServiceSensitiveContent(secret: secret.uppercased()),
                hashes: [secretHash],
                cipher: cipher
            )
        } catch {
            Log(
                "\(entityName) - can't record a deletion: \(SealedEntity.describe(error))",
                module: .storage,
                severity: .error
            )
            return
        }
        if let entity = merged(list(on: context, secretHash: secretHash), on: context) {
            entity.deletedAt = max(entity.deletedAt, deletedAt)
            // The identifier in the cloud doesn't change – the secret isn't needed again once it's there
            if entity.syncID == nil {
                entity.encryptedContent = sealed
            }
            return
        }
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            as! DeletedServiceEntity
        entity.secretHash = secretHash
        entity.deletedAt = deletedAt
        entity.encryptedContent = sealed
    }

    /// One record out of the records of the same service: it gets the latest deletion date and keeps the sync
    /// identifier (or, without one, the secret) of whichever record has it. The others are removed. `nil` for no
    /// records.
    @discardableResult
    @nonobjc static func merged(
        _ records: [DeletedServiceEntity],
        on context: NSManagedObjectContext
    ) -> DeletedServiceEntity? {
        // The record known to Sync is the one to keep – its identifier is what the other devices know
        guard let kept = records.first(where: { $0.syncID != nil }) ?? records.first else { return nil }
        for other in records where other !== kept {
            kept.deletedAt = max(kept.deletedAt, other.deletedAt)
            if kept.syncID == nil, kept.encryptedContent == nil {
                kept.encryptedContent = other.encryptedContent
            }
            context.delete(other)
        }
        return kept
    }

    /// Leaves one record per service – see `merged(_:on:)`.
    /// - Returns: Count of the removed records.
    @discardableResult
    @nonobjc static func removeDuplicates(on context: NSManagedObjectContext) -> Int {
        let all = listAll(on: context)
        let groups = Dictionary(grouping: all, by: \.secretHash).values.filter { $0.count > 1 }
        groups.forEach { merged($0, on: context) }
        return groups.reduce(0) { $0 + $1.count - 1 }
    }

    /// The service exists again (restored from the trash or added anew)
    @nonobjc static func remove(on context: NSManagedObjectContext, secretHash: Data) {
        list(on: context, secretHash: secretHash).forEach { context.delete($0) }
    }

    @nonobjc static func find(on context: NSManagedObjectContext, secret: String) -> DeletedServiceEntity? {
        guard let secretHash = ServiceEntity.secretHash(for: secret, on: context) else { return nil }
        return list(on: context, secretHash: secretHash).first
    }

    @nonobjc static func listAll(on context: NSManagedObjectContext) -> [DeletedServiceEntity] {
        fetch(on: context, predicate: nil)
    }

    @nonobjc static func removeAll(on context: NSManagedObjectContext) {
        listAll(on: context).forEach { context.delete($0) }
    }

    /// Removes the records of deletions older than the retention.
    /// - Returns: Count of the removed records.
    @discardableResult
    @nonobjc static func removeExpired(on context: NSManagedObjectContext, now: Date = Date()) -> Int {
        let expired = fetch(
            on: context,
            predicate: NSPredicate(format: "deletedAt < %@", DeletionRetention.expirationDate(now: now) as NSDate)
        )
        expired.forEach { context.delete($0) }
        return expired.count
    }

    /// `nil` when the secret was already dropped or can't be decrypted
    @nonobjc var secret: String? {
        guard let sealed = encryptedContent, let cipher = managedObjectContext?.localStorageCipher else { return nil }
        do {
            return try Self.contentCodec.open(sealed, hashes: [secretHash], cipher: cipher).secret
        } catch {
            Log(
                "\(Self.entityName) - can't open content: \(SealedEntity.describe(error))",
                module: .storage,
                severity: .error
            )
            return nil
        }
    }

    @nonobjc private static func list(on context: NSManagedObjectContext, secretHash: Data) -> [DeletedServiceEntity] {
        fetch(on: context, predicate: NSPredicate(format: "secretHash == %@", secretHash as NSData))
    }

    @nonobjc private static func fetch(
        on context: NSManagedObjectContext,
        predicate: NSPredicate?
    ) -> [DeletedServiceEntity] {
        let fetchRequest = request()
        fetchRequest.predicate = predicate
        fetchRequest.includesPendingChanges = true
        do {
            return try context.fetch(fetchRequest)
        } catch {
            Log("\(entityName) - can't fetch: \(SealedEntity.describe(error))", module: .storage, severity: .error)
            return []
        }
    }
}

/// The record of a deleted section (category). Creating a section with the same ID removes the record.
@objc(DeletedSectionEntity)
final class DeletedSectionEntity: NSManagedObject {
    @nonobjc private static let entityName = "DeletedSectionEntity"

    @nonobjc static func request() -> NSFetchRequest<DeletedSectionEntity> {
        NSFetchRequest<DeletedSectionEntity>(entityName: entityName)
    }

    @NSManaged var sectionID: SectionID
    @NSManaged var deletedAt: Date

    /// Records that the section was deleted at `deletedAt`. A section has one record – the latest deletion is the
    /// one that counts.
    @nonobjc static func record(on context: NSManagedObjectContext, sectionID: SectionID, deletedAt: Date) {
        if let entity = merged(list(on: context, sectionID: sectionID), on: context) {
            entity.deletedAt = max(entity.deletedAt, deletedAt)
            return
        }
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            as! DeletedSectionEntity
        entity.sectionID = sectionID
        entity.deletedAt = deletedAt
    }

    /// One record out of the records of the same section, with the latest deletion date. The others are removed.
    @discardableResult
    @nonobjc static func merged(
        _ records: [DeletedSectionEntity],
        on context: NSManagedObjectContext
    ) -> DeletedSectionEntity? {
        guard let kept = records.first else { return nil }
        for other in records.dropFirst() {
            kept.deletedAt = max(kept.deletedAt, other.deletedAt)
            context.delete(other)
        }
        return kept
    }

    /// Leaves one record per section.
    /// - Returns: Count of the removed records.
    @discardableResult
    @nonobjc static func removeDuplicates(on context: NSManagedObjectContext) -> Int {
        let groups = Dictionary(grouping: listAll(on: context), by: \.sectionID).values.filter { $0.count > 1 }
        groups.forEach { merged($0, on: context) }
        return groups.reduce(0) { $0 + $1.count - 1 }
    }

    @nonobjc static func remove(on context: NSManagedObjectContext, sectionID: SectionID) {
        list(on: context, sectionID: sectionID).forEach { context.delete($0) }
    }

    @nonobjc static func find(on context: NSManagedObjectContext, sectionID: SectionID) -> DeletedSectionEntity? {
        list(on: context, sectionID: sectionID).first
    }

    @nonobjc static func listAll(on context: NSManagedObjectContext) -> [DeletedSectionEntity] {
        fetch(on: context, predicate: nil)
    }

    @nonobjc static func removeAll(on context: NSManagedObjectContext) {
        listAll(on: context).forEach { context.delete($0) }
    }

    /// Removes the records of deletions older than the retention.
    /// - Returns: Count of the removed records.
    @discardableResult
    @nonobjc static func removeExpired(on context: NSManagedObjectContext, now: Date = Date()) -> Int {
        let expired = fetch(
            on: context,
            predicate: NSPredicate(format: "deletedAt < %@", DeletionRetention.expirationDate(now: now) as NSDate)
        )
        expired.forEach { context.delete($0) }
        return expired.count
    }

    @nonobjc private static func list(
        on context: NSManagedObjectContext,
        sectionID: SectionID
    ) -> [DeletedSectionEntity] {
        fetch(on: context, predicate: NSPredicate(format: "sectionID == %@", sectionID as CVarArg))
    }

    @nonobjc private static func fetch(
        on context: NSManagedObjectContext,
        predicate: NSPredicate?
    ) -> [DeletedSectionEntity] {
        let fetchRequest = request()
        fetchRequest.predicate = predicate
        fetchRequest.includesPendingChanges = true
        do {
            return try context.fetch(fetchRequest)
        } catch {
            Log("\(entityName) - can't fetch: \(SealedEntity.describe(error))", module: .storage, severity: .error)
            return []
        }
    }
}
