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

@objc(PairingEntity)
final class PairingEntity: NSManagedObject {
    @nonobjc private static let entityName = "PairingEntity"
    
    /// Valid only for the current bytes of `encryptedContent`
    let contentCache = SealedContentCache<PairingSensitiveContent>()
    
    override func didTurnIntoFault() {
        super.didTurnIntoFault()
        contentCache.clear()
    }
    
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        name: String,
        extensionID: ExtensionID,
        publicKey: String
    ) {
        let content = PairingSensitiveContent(extensionID: extensionID, name: name, publicKey: publicKey)
        let extensionIDHash: Data
        let sealed: Data
        do {
            guard let cipher = context.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
            // The hash is part of the associated data, so the key has to exist before hashing
            try cipher.prepareForWriting()
            extensionIDHash = try Self.extensionIDHash(for: extensionID, cipher: cipher)
            sealed = try contentCodec.seal(content, hashes: [extensionIDHash], cipher: cipher)
        } catch {
            Log(
                "\(entityName) - can't seal new entity: \(SealedEntity.describe(error))",
                module: .storage,
                severity: .error
            )
            assertionFailure("\(entityName) - can't seal new entity")
            return
        }
        
        let pairing = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! PairingEntity
        
        let date = Date()
        
        pairing.extensionIDHash = extensionIDHash
        pairing.encryptedContent = sealed
        pairing.contentCache.store(content, sealed: sealed)
        pairing.creationDate = date
        pairing.modifcationDate = date
    }
    
    @nonobjc static func delete(on context: NSManagedObjectContext, identifiedByObjectID objectID: NSManagedObjectID) {
        let pairings = listAll(on: context)
        guard
            let pairingForDeletition = pairings.first(where: { $0.objectID == objectID })
        else {
            Log("Can't find pairing for deletition in local storage", module: .storage)
            return
        }
        delete(on: context, pairingEntity: pairingForDeletition)
    }
    
    @nonobjc static func update(
        on context: NSManagedObjectContext,
        identifiedByObjectID objectID: NSManagedObjectID,
        name: String
    ) {
        let pairings = listAll(on: context)
        guard
            let pairingForUpdate = pairings.first(where: { $0.objectID == objectID })
        else {
            Log("Can't find pairing for update in local storage", module: .storage)
            return
        }
        
        do {
            try pairingForUpdate.updateContent { $0.name = name }
        } catch {
            Log(
                "\(entityName) - can't update content: \(SealedEntity.describe(error))",
                module: .storage,
                severity: .error
            )
            assertionFailure("\(entityName) - can't update content")
            return
        }
        pairingForUpdate.modifcationDate = Date()
    }
    
    @nonobjc static func removeAll(on context: NSManagedObjectContext) {
        let all = listAll(on: context)
        all.forEach { context.delete($0) }
    }
    
    @nonobjc static func listAll(on context: NSManagedObjectContext) -> [PairingEntity] {
        let fetchRequest = PairingEntity.request()
        fetchRequest.includesPendingChanges = true
        var list: [PairingEntity] = []
        
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log("PairingEntity in Storage listItems(): \(err.localizedDescription)", module: .storage)
            return []
        }
        
        return list
    }
    
    // MARK: - Private
    
    @nonobjc private static func delete(on context: NSManagedObjectContext, pairingEntity: PairingEntity) {
        context.delete(pairingEntity)
    }
}

// Encrypted fields are plain Swift properties (not `@objc`) – the legacy migration policies set the old model's
// attributes of the same names through KVC on instances of this class.
extension PairingEntity {
    @nonobjc static let contentCodec = SealedContentCodec<PairingSensitiveContent>(entityName: "PairingEntity")
    @nonobjc private static let extensionIDHashContext = "PairingEntity.extensionID"
    
    /// The ID isn't normalized – it's compared exactly
    @nonobjc static func extensionIDHash(for extensionID: String, cipher: LocalStorageCipher) throws -> Data {
        try cipher.lookupHash(for: extensionID, context: extensionIDHashContext)
    }
    
    /// `nil` when the content can't be decrypted
    @nonobjc var content: PairingSensitiveContent? {
        SealedEntity.content(
            of: self,
            entityName: "PairingEntity",
            module: .storage,
            sealed: { encryptedContent },
            hashes: { [extensionIDHash] },
            codec: Self.contentCodec,
            cache: contentCache
        )
    }
    
    /// Changes the content with a single seal. The extension ID identifies the pairing and can't be changed.
    @nonobjc func updateContent(_ change: (inout PairingSensitiveContent) -> Void) throws {
        guard let cipher = managedObjectContext?.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
        guard let current = content else { throw SealedEntity.Failure.unreadableContent }
        var updated = current
        change(&updated)
        updated.extensionID = current.extensionID
        guard updated != current else { return }
        let sealed = try Self.contentCodec.seal(updated, hashes: [extensionIDHash], cipher: cipher)
        encryptedContent = sealed
        contentCache.store(updated, sealed: sealed)
    }
}
