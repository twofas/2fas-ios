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

public final class SectionHandler: CommonSectionHandler {
    private let coreDataStack: CoreDataStack
        
    public var commonDidCreate: CommonDidCreate?
    public var commonDidModify: CommonDidModify?
    public var commonDidDelete: CommonDidDelete?

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    public func create(with title: String) {
        let uuid = SectionEntity.create(on: coreDataStack.context, title: title)
        coreDataStack.save()
        commonDidCreate?(uuid.uuidString)
    }
    
    public func delete(_ section: SectionData) {
        guard let objectID = section.objectID else { return }
        
        SectionEntity.delete(on: coreDataStack.context, identifiedByObjectID: objectID)
        DeletedSectionEntity.record(on: coreDataStack.context, sectionID: section.sectionID, deletedAt: Date())
        commonDidDelete?(section.sectionID.uuidString)
        coreDataStack.save()
    }
    
    public func update(_ section: SectionData, with title: String) {
        guard let objectID = section.objectID else { return }
        
        SectionEntity.update(on: coreDataStack.context, identifiedByObjectID: objectID, title: title)
        commonDidModify?([section.sectionID.uuidString])
        coreDataStack.save()
    }
    
    public func removeAll() {
        SectionEntity.removeAll(on: coreDataStack.context)
        coreDataStack.save()
    }
    
    public func expand(_ section: SectionData) {
        guard let objectID = section.objectID else { return }
        
        SectionEntity.expand(on: coreDataStack.context, identifiedByObjectID: objectID)
        coreDataStack.save()
    }
    
    public func collapse(_ section: SectionData) {
        guard let objectID = section.objectID else { return }
        
        SectionEntity.collapse(on: coreDataStack.context, identifiedByObjectID: objectID)
        coreDataStack.save()
    }
    
    public func moveUp(section: SectionData) {
        guard let objectID = section.objectID else { return }
        
        let updated = SectionEntity.moveUp(on: coreDataStack.context, identifiedByObjectID: objectID)
        commonDidModify?(updated.map { $0.sectionID.uuidString })
        coreDataStack.save()
    }
    
    public func moveDown(section: SectionData) {
        guard let objectID = section.objectID else { return }
        
        let updated = SectionEntity.moveDown(on: coreDataStack.context, identifiedByObjectID: objectID)
        commonDidModify?(updated.map { $0.sectionID.uuidString })
        coreDataStack.save()
    }
    
    public func listAll() -> [SectionData] {
        let list = SectionEntity.listAll(on: coreDataStack.context)
        return list.transformToSectionData()
    }
}

public extension SectionHandler {
    func getAllSections() -> [CommonSectionData] {
        listAll().map {
            .init(
                name: $0.title,
                sectionID: $0.sectionID.uuidString,
                creationDate: $0.createdAt,
                modificationDate: $0.modifiedAt,
                isCollapsed: $0.isCollapsed
            )
        }
    }
    
    @discardableResult
    func setSections(_ sections: [CommonSectionData]) -> Bool {
        Log("Adding sections afer sync: \(sections.count)", module: .storage)
        let currentSections = getAllSections()
        guard currentSections != sections else {
            Log("SectionHandler in Storage: Nothing new to import", module: .storage)
            return false
        }
        Log("SectionHandler in Storage: Removing all and relading!", module: .storage)
        let collapsedState = listCollapsedState()
        removeAll()
        addSections(sections, collapsedState: collapsedState)
        // The sections that are gone were deleted – the ones that came back had their deletion removed when created
        let remainingIDs = Set(sections.compactMap { UUID(uuidString: $0.sectionID) })
        let deletedAt = Date()
        for sectionID in collapsedState.keys where !remainingIDs.contains(sectionID) {
            DeletedSectionEntity.record(on: coreDataStack.context, sectionID: sectionID, deletedAt: deletedAt)
        }
        Log("New sections count: \(sections.count)", module: .storage)
        #if DEBUG
        Log("New sections: \(sections)", module: .storage, save: false)
        #endif
        coreDataStack.save()

        NotificationCenter.default.post(name: .sectionsWereUpdated, object: nil)

        Log("SectionHandler in Storage: Data imported", module: .storage)
        return true
    }
    
    public func getAllSectionDeletions() -> [CommonSectionDeletion] {
        DeletedSectionEntity.listAll(on: coreDataStack.context).map {
            CommonSectionDeletion(sectionID: $0.sectionID.uuidString, deletedAt: $0.deletedAt)
        }
    }
    
    @discardableResult
    public func setSections(_ cloudSections: [CommonSectionData], deletions: SyncedDeletions) -> Bool {
        let context = coreDataStack.context
        let currentSections = getAllSections()
        
        func date(of section: CommonSectionData) -> Date { section.modificationDate ?? section.creationDate }
        /// When the section was deleted, as far as this device and the cloud know
        func deletionDate(of sectionID: String) -> Date? {
            let localDate = UUID(uuidString: sectionID)
                .flatMap { DeletedSectionEntity.find(on: context, sectionID: $0)?.deletedAt }
            return [deletions.sections[sectionID], localDate].compactMap { $0 }.max()
        }
        
        var sectionsToSet: [CommonSectionData] = []
        var deletedHere: [(sectionID: String, deletedAt: Date)] = []
        var announceCreated: [String] = []
        var announceDeleted: [String] = []
        
        for section in cloudSections {
            if let deletedAt = deletionDate(of: section.sectionID) {
                if date(of: section) > deletedAt {
                    // Changed after it was deleted – the section wins and its deletion is removed
                    sectionsToSet.append(section)
                    announceCreated.append(section.sectionID)
                } else {
                    deletedHere.append((section.sectionID, deletedAt))
                    announceDeleted.append(section.sectionID)
                }
            } else {
                sectionsToSet.append(section)
            }
        }
        let cloudIDs = Set(cloudSections.map(\.sectionID))
        for section in currentSections where !cloudIDs.contains(section.sectionID) {
            if let deletedAt = deletions.sections[section.sectionID], date(of: section) <= deletedAt {
                // The only way a section is deleted from elsewhere: the record of its deletion
                deletedHere.append((section.sectionID, deletedAt))
            } else if deletions.keepsLocalOnlyItems {
                // Not in the cloud and not deleted – it's kept and sent
                sectionsToSet.append(section)
                announceCreated.append(section.sectionID)
            } else {
                deletedHere.append((section.sectionID, Date()))
            }
        }
        
        let hasChanges = currentSections != sectionsToSet
        if hasChanges {
            Log("SectionHandler in Storage: Merging. To set: \(sectionsToSet.count)", module: .storage)
            let collapsedState = listCollapsedState()
            removeAll()
            addSections(sectionsToSet, collapsedState: collapsedState)
        }
        for deleted in deletedHere {
            guard let sectionID = UUID(uuidString: deleted.sectionID) else { continue }
            DeletedSectionEntity.record(on: context, sectionID: sectionID, deletedAt: deleted.deletedAt)
        }
        // The deletions made here that the cloud doesn't know about yet
        let keptIDs = Set(sectionsToSet.map(\.sectionID))
        for record in DeletedSectionEntity.listAll(on: context) {
            let sectionID = record.sectionID.uuidString
            if let cloudDate = deletions.sections[sectionID] {
                record.deletedAt = max(record.deletedAt, cloudDate)
            } else if !keptIDs.contains(sectionID) {
                announceDeleted.append(sectionID)
            }
        }
        coreDataStack.save()
        
        if hasChanges {
            NotificationCenter.default.post(name: .sectionsWereUpdated, object: nil)
        }
        if deletions.keepsLocalOnlyItems {
            announceCreated.forEach { commonDidCreate?($0) }
            Set(announceDeleted).forEach { commonDidDelete?($0) }
        }
        return hasChanges
    }
    
    // MARK: - Import from file
    
    @discardableResult
    func addNonexistentSections(_ sections: [CommonSectionData]) -> Int {
        let currentSections = getAllSections().map { $0.sectionID }
        let newSections = sections.filter { !currentSections.contains($0.sectionID) }
        addSections(newSections)
        coreDataStack.save()
        newSections.forEach { commonDidCreate?($0.sectionID) }
        Log("SectionHandler in Storage: Data imported from file. Count: \(newSections.count)", module: .storage)
        return newSections.count
    }
    
    private func addSections(_ sections: [CommonSectionData], collapsedState: [SectionID: Bool]? = nil) {
        var currentCount = SectionEntity.countItems(on: coreDataStack.context)
        for s in sections {
            guard let sectionID = UUID(uuidString: s.sectionID) else { continue }
            let isCollapsed = collapsedState?[sectionID] ?? false
            SectionEntity.create(
                on: coreDataStack.context,
                title: s.name,
                sectionID: sectionID,
                createdAt: s.creationDate,
                modifiedAt: s.modificationDate,
                order: currentCount,
                isCollapsed: isCollapsed
            )
            currentCount += 1
        }
    }
    
    private func listCollapsedState() -> [SectionID: Bool] {
        var result = [SectionID: Bool]()
        let all = listAll()
        all.forEach { result[$0.sectionID] = $0.isCollapsed }
        return result
    }
}
