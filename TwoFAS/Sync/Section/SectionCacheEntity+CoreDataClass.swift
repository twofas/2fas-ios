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

@objc(SectionCacheEntity)
final class SectionCacheEntity: NSManagedObject {
    @nonobjc private static let entityName = "SectionCacheEntity"
    
    /// Valid only for the current bytes of `encryptedContent`
    let contentCache = SealedContentCache<SectionSensitiveContent>()
    
    override func didTurnIntoFault() {
        super.didTurnIntoFault()
        contentCache.clear()
    }
    
    /// Nothing is inserted when the title can't be sealed – a reset of the cache is scheduled then, as the cache
    /// would miss the record.
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        sectionID: String,
        title: String,
        creationDate: Date,
        modificationDate: Date?,
        metadata: Data,
        order: Int32
    ) {
        let content = SectionSensitiveContent(title: title)
        let sealed: Data
        do {
            guard let cipher = context.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
            try cipher.prepareForWriting()
            sealed = try contentCodec.seal(content, hashes: [identityData(of: sectionID)], cipher: cipher)
        } catch {
            Log(
                "\(entityName) - can't seal new entity: \(SealedEntity.describe(error))",
                module: .cloudSync,
                severity: .error
            )
            ConstStorage.syncResetRequired = true
            return
        }
        
        let section = NSEntityDescription.insertNewObject(
            forEntityName: entityName,
            into: context
        ) as! SectionCacheEntity
        
        section.metadata = metadata
        section.sectionID = sectionID
        section.encryptedContent = sealed
        section.contentCache.store(content, sealed: sealed)
        section.creationDate = creationDate
        section.modificationDate = modificationDate
        section.order = order
    }
    
    @nonobjc static func listAll(on context: NSManagedObjectContext) -> [SectionCacheEntity] {
        listItems(on: context)
    }

    @nonobjc static func delete(on context: NSManagedObjectContext, identifiedBy sectionID: String) {
        guard let section = findSection(on: context, sectionID: sectionID) else { return }
        delete(on: context, sectionEntity: section)
    }
        
    @nonobjc static func findSection(on context: NSManagedObjectContext, sectionID: String) -> SectionCacheEntity? {
        let fetchRequest = SectionCacheEntity.request()
        fetchRequest.predicate = NSPredicate(format: "sectionID == %@", sectionID)
        
        var list: [SectionCacheEntity] = []
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log(err.localizedDescription, module: .storage)
            return nil
        }
        
        // if something went wrong (wrong migration, some bugs) -> remove duplicated entries instead of:
        // guard list.count < 2 else { fatalError("There're many sections with similar codes sectionID \(sectionID) }
        if list.count > 1 {
            
            let itemsForDeletition = list[1...]
            for item in itemsForDeletition {
                delete(on: context, sectionEntity: item)
            }
        }
        
        let item = list.first
        
        return item
    }
    
    // MARK: - Private
    
    @nonobjc private static func listItems(on context: NSManagedObjectContext) -> [SectionCacheEntity] {
        let fetchRequest = SectionCacheEntity.request()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(SectionCacheEntity.order), ascending: true)]
        
        var list: [SectionCacheEntity] = []
        
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log(err.localizedDescription, module: .storage)
            return []
        }
        
        return list
    }
    
    @nonobjc private static func delete(on context: NSManagedObjectContext, sectionEntity: SectionCacheEntity) {
        context.delete(sectionEntity)
    }
}

// The title is a plain Swift property (not `@objc`), like the encrypted fields of `ServiceCacheEntity`
extension SectionCacheEntity {
    @nonobjc static let contentCodec = SealedContentCodec<SectionSensitiveContent>(entityName: "SectionCacheEntity")
    
    /// What binds the sealed title to its section
    @nonobjc static func identityData(of sectionID: String) -> Data {
        Data(sectionID.utf8)
    }
    
    /// Throws when the title can't be decrypted – the cache can't be trusted then
    @nonobjc func decryptedContent() throws -> SectionSensitiveContent {
        try SealedEntity.openContent(
            of: self,
            sealed: { encryptedContent },
            hashes: { [Self.identityData(of: sectionID)] },
            codec: Self.contentCodec,
            cache: contentCache
        )
    }
    
    /// Replaces the title. A failure changes nothing.
    @nonobjc func setTitle(_ title: String) throws {
        guard let cipher = managedObjectContext?.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
        let content = SectionSensitiveContent(title: title)
        if let current = try? decryptedContent(), current == content { return }
        let sealed = try Self.contentCodec.seal(content, hashes: [Self.identityData(of: sectionID)], cipher: cipher)
        encryptedContent = sealed
        contentCache.store(content, sealed: sealed)
    }
    
    /// Empty when the title can't be decrypted – a reset of the cache is scheduled then
    @nonobjc var title: String {
        SyncStoreIntegrity.valueOrScheduleReset(entityName: "SectionCacheEntity", field: "content") {
            try decryptedContent()
        }?.title ?? ""
    }
}
