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

@objc(LogEntryEntity)
final class LogEntryEntity: NSManagedObject {
    @nonobjc private static let entityName = "LogEntryEntity"
    
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        content: String,
        timestamp: Date,
        module: Int,
        severity: Int
    ) {
        let log = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! LogEntryEntity
        
        log.content = content
        log.timestamp = timestamp
        log.module = Int16(module)
        log.severity = Int16(severity)
    }
    
    @nonobjc static func removeAll(on context: NSManagedObjectContext) {
        let all = listAll(on: context)
        remove(on: context, objects: all)
    }
    
    @nonobjc static func remove(on context: NSManagedObjectContext, objects: [NSManagedObject]) {
        objects.forEach { context.delete($0) }
    }
    
    @nonobjc static func listAll(
        on context: NSManagedObjectContext,
        quickFetch: Bool = false,
        ascending: Bool = false
    ) -> [LogEntryEntity] {
        let key = "timestamp"
        let fetchRequest = LogEntryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        fetchRequest.includesPendingChanges = true
        fetchRequest.returnsObjectsAsFaults = false
        
        if quickFetch {
            fetchRequest.propertiesToFetch = [key]
        }
        
        var list: [LogEntryEntity] = []
        
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log("LogEntryEntity in Storage listAll(): \(err.localizedDescription)", module: .storage)
            return []
        }
        
        return list
    }
    
    @nonobjc static func count(on context: NSManagedObjectContext) -> Int {
        let fetchRequest = LogEntryEntity.fetchRequest()
        fetchRequest.includesPendingChanges = true
        var result: Int?
        
        do {
            result = try context.count(for: fetchRequest)
        } catch {
            let err = error as NSError
            Log("LogEntryEntity in Storage, count error: \(err.localizedDescription)", module: .storage)
        }
        
        return result ?? 0
    }
}
