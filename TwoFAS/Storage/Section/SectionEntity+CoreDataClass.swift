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

@objc(SectionEntity)
final class SectionEntity: NSManagedObject {
    @nonobjc private static let entityName = "SectionEntity"
    
    @nonobjc static func create(on context: NSManagedObjectContext, title: String) -> UUID {
        create(
            on: context,
            title: title,
            sectionID: UUID(),
            createdAt: Date(),
            modifiedAt: nil,
            order: countItems(on: context)
        )
    }
    
    @discardableResult
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        title: String,
        sectionID: UUID,
        createdAt: Date,
        modifiedAt: Date?,
        order: Int,
        isCollapsed: Bool = false
    ) -> UUID {
        let section = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! SectionEntity
        
        section.title = title
        section.sectionID = sectionID
        section.order = Int32(order)
        section.isCollapsed = isCollapsed
        section.creationDate = createdAt
        section.modificationDate = modifiedAt
        
        return sectionID
    }
    
    @nonobjc static func delete(on context: NSManagedObjectContext, identifiedByObjectID objectID: NSManagedObjectID) {
        let sections = listAll(on: context)
        guard
            let sectionForDeletition = sections.first(where: { $0.objectID == objectID })
        else {
            Log("Can't find section for deletition in local storage", module: .storage)
            return
        }
        delete(on: context, sectionEntity: sectionForDeletition)
    }
    
    @nonobjc static func update(
        on context: NSManagedObjectContext,
        identifiedByObjectID objectID: NSManagedObjectID,
        title: String
    ) {
        let sections = listAll(on: context)
        guard
            let sectionForUpdate = sections.first(where: { $0.objectID == objectID })
        else {
            Log("Can't find sections for updating on local storage", module: .storage)
            return
        }
        
        sectionForUpdate.title = title
        sectionForUpdate.modificationDate = Date()
    }
    
    @nonobjc static func removeAll(on context: NSManagedObjectContext) {
        let all = listAll(on: context)
        all.forEach { context.delete($0) }
    }
    
    @nonobjc static func expand(on context: NSManagedObjectContext, identifiedByObjectID objectID: NSManagedObjectID) {
        let sections = listAll(on: context)
        guard
            let sectionForExpansion = sections.first(where: { $0.objectID == objectID })
        else {
            Log("Can't find section for expansion in local storage", module: .storage)
            return
        }
        sectionForExpansion.isCollapsed = false
    }
    
    @nonobjc static func collapse(
        on context: NSManagedObjectContext,
        identifiedByObjectID objectID: NSManagedObjectID
    ) {
        let sections = listAll(on: context)
        guard
            let sectionForCollapse = sections.first(where: { $0.objectID == objectID })
        else {
            Log("Can't find section for collapse in local storage", module: .storage)
            return
        }
        sectionForCollapse.isCollapsed = true
    }
    
    @nonobjc static func moveUp(
        on context: NSManagedObjectContext,
        identifiedByObjectID objectID: NSManagedObjectID
    ) -> [SectionEntity] {
        let sections = listAll(on: context)
        updateOrder(of: sections)
        var sortedSections = sections.sorted(by: { $0.order < $1.order })
        guard
            let currentIndex = sortedSections.firstIndex(where: { $0.objectID == objectID })
        else {
            Log("Can't find section index for moving up in local storage", module: .storage)
            return []
        }
        guard currentIndex > 0 else { return [] }
        let newIndex = currentIndex - 1
        sortedSections.insert(sortedSections.remove(at: currentIndex), at: newIndex)
        updateOrder(of: sortedSections)
        return listUpdated(on: context)
    }
    
    @nonobjc static func moveDown(
        on context: NSManagedObjectContext,
        identifiedByObjectID objectID: NSManagedObjectID
    ) -> [SectionEntity] {
        let sections = listAll(on: context)
        updateOrder(of: sections)
        var sortedSections = sections.sorted(by: { $0.order < $1.order })
        guard
            let currentIndex = sortedSections.firstIndex(where: { $0.objectID == objectID })
        else {
            Log("Can't find section index for moving down in local storage", module: .storage)
            return []
        }
        guard currentIndex < sortedSections.count - 1 else { return [] }
        let newIndex = currentIndex + 1
        sortedSections.insert(sortedSections.remove(at: currentIndex), at: newIndex)
        updateOrder(of: sortedSections)
        return listUpdated(on: context)
    }
    
    @nonobjc static func section(on context: NSManagedObjectContext, for sectionID: SectionID) -> SectionEntity? {
        let sections = listAll(on: context)
        return sections.first(where: { $0.sectionID == sectionID })
    }
    
    @nonobjc static func listAll(
        on context: NSManagedObjectContext,
        includesPendingChanges: Bool = false
    ) -> [SectionEntity] {
        let fetchRequest = SectionEntity.request()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.includesPendingChanges = includesPendingChanges
        var list: [SectionEntity] = []
        
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            Log("SectionEntity in Storage listItems(): \(err.localizedDescription)", module: .storage)
            return []
        }
        
        return list
    }
    
    @nonobjc static func countItems(on context: NSManagedObjectContext) -> Int {
        listAll(on: context).count
    }
    
    // MARK: - Private
    
    @nonobjc private static func delete(on context: NSManagedObjectContext, sectionEntity: SectionEntity) {
        context.delete(sectionEntity)
    }

    @nonobjc private static func listUpdated(on context: NSManagedObjectContext) -> [SectionEntity] {
        listAll(on: context).filter({ $0.isUpdated })
    }
    
    @nonobjc private static func updateOrder(of services: [SectionEntity]) {
        for (index, s) in services.enumerated() {
            s.order = Int32(index)
        }
    }
}
