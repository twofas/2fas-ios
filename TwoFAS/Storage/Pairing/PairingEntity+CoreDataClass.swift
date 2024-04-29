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
    
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        name: String,
        extensionID: ExtensionID,
        publicKey: String
    ) {
        let pairing = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! PairingEntity
        
        let date = Date()
        
        pairing.name = name
        pairing.extensionID = extensionID
        pairing.publicKey = publicKey
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
        
        pairingForUpdate.name = name
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
