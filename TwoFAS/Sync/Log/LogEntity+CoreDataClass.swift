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

@objc(LogEntity)
final class LogEntity: NSManagedObject {
    @nonobjc private static let entityName = "LogEntity"
    
    /// Valid only for the current bytes of `encryptedEntityID`. Not a transient attribute, so filling it never marks
    /// the object as updated.
    let contentCache = SealedContentCache<LogEntityContent>()
    
    override func didTurnIntoFault() {
        super.didTurnIntoFault()
        contentCache.clear()
    }
    
    /// `entityID` in plain text. Nothing is inserted when it can't be sealed – a reset of the cache is scheduled then,
    /// as the change would be lost.
    /// - Returns: Whether the entry was inserted.
    @discardableResult
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        entityID: String,
        action: String,
        date: Date,
        kind: String,
        isApplied: Bool = false
    ) -> Bool {
        let content = LogEntityContent(entityID: entityID)
        let entityIDHash: Data
        let sealed: Data
        do {
            guard let cipher = context.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
            // The hash is part of the associated data, so the key has to exist before hashing
            try cipher.prepareForWriting()
            entityIDHash = try Self.entityIDHash(for: content.entityID, cipher: cipher)
            sealed = try contentCodec.seal(content, hashes: [entityIDHash], cipher: cipher)
        } catch {
            Log(
                "\(entityName) - can't seal new entity: \(SealedEntity.describe(error))",
                module: .cloudSync,
                severity: .error
            )
            ConstStorage.syncResetRequired = true
            return false
        }
        
        let logEntity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! LogEntity
    
        logEntity.entityIDHash = entityIDHash
        logEntity.encryptedEntityID = sealed
        logEntity.contentCache.store(content, sealed: sealed)
        logEntity.action = action
        logEntity.date = date
        logEntity.kind = kind
        logEntity.isApplied = isApplied
        return true
    }
    
    @nonobjc static func listAll(on context: NSManagedObjectContext) -> [LogEntity] {
        listItems(on: context, isApplied: nil)
    }

    @nonobjc static func delete(on context: NSManagedObjectContext, identifiedBy entityID: String) {
        guard let logEntity = findLog(on: context, entityID: entityID) else { return }
        delete(on: context, logEntity: logEntity)
    }
    
    @nonobjc static func deleteAll(on context: NSManagedObjectContext) {
        let all = listItems(on: context, isApplied: nil)
        all.forEach {
            delete(on: context, logEntity: $0)
        }
    }
    
    @nonobjc static func deleteAllApplied(on context: NSManagedObjectContext) {
        let all = listItems(on: context, isApplied: true)
        all.forEach {
            delete(on: context, logEntity: $0)
        }
    }
    
    @nonobjc static func markAsApplied(on context: NSManagedObjectContext, entityID: String) {
        guard let logEntity = findLog(on: context, entityID: entityID) else { return }
        logEntity.isApplied = true
    }
    
    @nonobjc static func updateDate(on context: NSManagedObjectContext, entityID: String) {
        guard let logEntity = findLog(on: context, entityID: entityID) else { return }
        logEntity.date = Date()
    }
    
    @nonobjc static func countNotApplied(on context: NSManagedObjectContext) -> Int {
        listItems(on: context, isApplied: false).count
    }
        
    /// `entityID` in plain text. `nil` also when the hash can't be computed.
    @nonobjc static func findLog(on context: NSManagedObjectContext, entityID: String) -> LogEntity? {
        guard let entityIDHash = Self.entityIDHash(for: entityID, on: context) else { return nil }
        let fetchRequest = LogEntity.request()
        fetchRequest.predicate = NSPredicate(format: "entityIDHash == %@", entityIDHash as NSData)
        
        var list: [LogEntity] = []
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log("LogEntity: \(err.localizedDescription)", module: .cloudSync)
            return nil
        }

        // only one entry per log
        if list.count > 1 {
            let itemsForDeletition = list[1...]
            for item in itemsForDeletition {
                delete(on: context, logEntity: item)
            }
        }
        
        let item = list.first
        
        return item
    }
    
    /// The entries of many entities with a single fetch, by `entityID` in plain text. An entity without an entry –
    /// or one whose hash can't be computed – is missing in the result.
    @nonobjc static func findLogs(on context: NSManagedObjectContext, entityIDs: [String]) -> [String: LogEntity] {
        var entityIDsByHash: [Data: String] = [:]
        for entityID in entityIDs {
            guard let hash = Self.entityIDHash(for: entityID, on: context) else { continue }
            entityIDsByHash[hash] = entityID
        }
        guard !entityIDsByHash.isEmpty else { return [:] }
        let fetchRequest = LogEntity.request()
        fetchRequest.predicate = NSPredicate(format: "entityIDHash IN %@", entityIDsByHash.keys.map { $0 as NSData })
        
        var list: [LogEntity] = []
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log("LogEntity: \(err.localizedDescription)", module: .cloudSync)
            return [:]
        }
        
        var result: [String: LogEntity] = [:]
        for item in list {
            guard let entityID = entityIDsByHash[item.entityIDHash] else { continue }
            // only one entry per log
            if result[entityID] == nil {
                result[entityID] = item
            } else {
                delete(on: context, logEntity: item)
            }
        }
        return result
    }
    
    // MARK: - Private
    
    @nonobjc private static func listItems(on context: NSManagedObjectContext, isApplied: Bool?) -> [LogEntity] {
        let fetchRequest = LogEntity.request()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        if let isApplied {
            fetchRequest.predicate = NSPredicate(format: "isApplied == %d", isApplied)
        }
        
        var list: [LogEntity] = []
        
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log("LogEntity: \(err.localizedDescription)", module: .cloudSync)
            return []
        }
        
        return list
    }
    
    @nonobjc private static func delete(on context: NSManagedObjectContext, logEntity: LogEntity) {
        context.delete(logEntity)
    }
}
