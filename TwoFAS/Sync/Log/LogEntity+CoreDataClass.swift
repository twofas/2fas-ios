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
    
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        entityID: String,
        action: String,
        date: Date,
        kind: String,
        isApplied: Bool = false
    ) {
        let logEntity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! LogEntity
    
        logEntity.entityID = entityID
        logEntity.action = action
        logEntity.date = date
        logEntity.kind = kind
        logEntity.isApplied = isApplied
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
        
    @nonobjc static func findLog(on context: NSManagedObjectContext, entityID: String) -> LogEntity? {
        let fetchRequest = LogEntity.request()
        fetchRequest.predicate = NSPredicate(format: "entityID == %@", entityID)
        
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
