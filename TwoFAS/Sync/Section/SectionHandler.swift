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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif
import CoreData

final class SectionHandler {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func create(
        metadata: Data,
        sectionID: String,
        title: String,
        order: Int,
        creationDate: Date,
        modificationDate: Date?
    ) {
        SectionCacheEntity.create(
            on: coreDataStack.context,
            sectionID: sectionID,
            title: title,
            creationDate: creationDate,
            modificationDate: modificationDate,
            metadata: metadata,
            order: Int32(order)
        )
        coreDataStack.save()
    }
    
    func delete(identifiedBy sectionID: String) {
        SectionCacheEntity.delete(on: coreDataStack.context, identifiedBy: sectionID)
        coreDataStack.save()
    }
    
    func delete(identifiedBy sectionIDs: [String]) {
        sectionIDs.forEach { sec in
            SectionCacheEntity.delete(on: coreDataStack.context, identifiedBy: sec)
        }
        coreDataStack.save()
    }
    
    func purge() {
        let list = listAll()
        delete(identifiedBy: list.map { $0.sectionID })
    }
    
    func listAll() -> [SectionCacheEntity] {
        SectionCacheEntity.listAll(on: coreDataStack.context)
    }
    
    func count() -> Int {
        SectionCacheEntity.listAll(on: coreDataStack.context).count
    }
    
    func findSection(by sectionID: String) -> SectionCacheEntity? {
        SectionCacheEntity.findSection(on: coreDataStack.context, sectionID: sectionID)
    }
    
    func findSections(by sectionIDs: [String]) -> [SectionCacheEntity] {
        let sections = sectionIDs.compactMap {
            SectionCacheEntity.findSection(on: coreDataStack.context, sectionID: $0)
        }
        return sections
    }
    
    func updateOrCreate(with records: [SectionRecord]) {
        records.forEach { record in
            updateOrCreate(with: record, save: false)
        }
        coreDataStack.save()
    }
    
    func updateOrCreate(with record: SectionRecord, save: Bool) {
        if let section = findSection(by: record.sectionID) {
            section.title = record.title
            section.order = Int32(record.order)
            section.metadata = record.encodeSystemFields()
            section.creationDate = record.creationDate ?? Date()
            section.modificationDate = record.modificationDate
        } else {
            SectionCacheEntity.create(
                on: coreDataStack.context,
                sectionID: record.sectionID,
                title: record.title,
                creationDate: record.creationDate ?? Date(),
                modificationDate: record.modificationDate,
                metadata: record.encodeSystemFields(),
                order: Int32(record.order)
            )
        }
        if save {
            coreDataStack.save()
        }
    }
    
    func saveAfterBatch() {
        coreDataStack.save()
    }
}

extension SectionHandler {
    func listAllCommonSection() -> [CommonSectionData] {
        listAll().map {
            CommonSectionData(
                name: $0.title,
                sectionID: $0.sectionID,
                creationDate: $0.creationDate,
                modificationDate: $0.modificationDate,
                isCollapsed: false
            )
        }
    }
    
    private func intToNumber(_ int: Int?) -> NSNumber? {
        guard let int else { return nil }
        return NSNumber(value: int)
    }
}
