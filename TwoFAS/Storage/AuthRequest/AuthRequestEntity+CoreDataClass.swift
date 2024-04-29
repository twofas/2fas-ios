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

@objc(AuthRequestEntity)
final class AuthRequestEntity: NSManagedObject {
    @nonobjc private static let entityName = "AuthRequestEntity"
    
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        secret: String,
        extensionID: ExtensionID,
        domain: String
    ) {
        let auth = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! AuthRequestEntity
        
        let date = Date()
        
        auth.secret = secret
        auth.extensionID = extensionID
        auth.domain = domain
        auth.creationDate = date
        auth.lastUsed = date
        auth.usedCount = 1
    }
    
    @nonobjc static func delete(on context: NSManagedObjectContext, identifiedByObjectID objectID: NSManagedObjectID) {
        let auths = listAll(on: context)
        guard let authForDeletition = auths.first(where: { $0.objectID == objectID })
        else { Log("Can't find auth in local storage", module: .storage); return }
        delete(on: context, authEntity: authForDeletition)
    }
    
    @nonobjc static func updateUsage(
        on context: NSManagedObjectContext,
        identifiedByObjectID objectID: NSManagedObjectID
    ) {
        let auths = listAll(on: context)
        guard let authForUpdate = auths.first(where: { $0.objectID == objectID })
        else { Log("Can't find auth in local storage", module: .storage); return }
        
        authForUpdate.lastUsed = Date()
        authForUpdate.usedCount += 1
    }
    
    @nonobjc static func removeAll(on context: NSManagedObjectContext) {
        let all = listAll(on: context)
        all.forEach { context.delete($0) }
    }
    
    @nonobjc static func listAll(
        on context: NSManagedObjectContext,
        filterOptions: AuthRequestFilterOptions = .all
    ) -> [AuthRequestEntity] {
        let fetchRequest = AuthRequestEntity.request()
        fetchRequest.includesPendingChanges = true
        if let predicate = filterOptions.predicate {
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "domain", ascending: true),
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        
        var list: [AuthRequestEntity] = []
        
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log("AuthRequestEntity in Storage listItems(): \(err.localizedDescription)", module: .storage)
            return []
        }
        
        return list
    }
    
    // MARK: - Private
    
    @nonobjc private static func delete(on context: NSManagedObjectContext, authEntity: AuthRequestEntity) {
        context.delete(authEntity)
    }
}
