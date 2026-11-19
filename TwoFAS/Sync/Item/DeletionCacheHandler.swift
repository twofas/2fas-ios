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

/// The cache of the deletion records that are in the cloud (`RecordType.deletedService`, `.deletedSection`):
/// `DeletedServiceCacheEntity` and `DeletedSectionCacheEntity`.
final class DeletionCacheHandler {
    private let coreDataStack: CoreDataStack
    private var context: NSManagedObjectContext { coreDataStack.context }

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - Services

    func listServices() -> [SyncDeletion] {
        DeletedServiceCacheEntity.listAll(on: context)
            .map { SyncDeletion(identifier: $0.secretHash, deletedAt: $0.deletedAt) }
            .sorted { $0.recordName < $1.recordName }
    }

    /// The system fields of the record of the deletion. `nil` when it isn't cached or can't be opened.
    func serviceMetadata(identifier: Data) -> Data? {
        DeletedServiceCacheEntity.find(on: context, identifier: identifier).first?.metadata
    }

    func updateOrCreateService(_ deletion: SyncDeletion, metadata: Data) {
        let existing = DeletedServiceCacheEntity.find(on: context, identifier: deletion.identifier).first
        let entity = existing ?? DeletedServiceCacheEntity(context: context)
        entity.secretHash = deletion.identifier
        entity.deletedAt = deletion.deletedAt
        do {
            try entity.setMetadata(metadata)
        } catch {
            Log("DeletionCacheHandler - can't seal the metadata of a deletion", module: .cloudSync, severity: .error)
            // The cache would miss the record
            if existing == nil {
                context.delete(entity)
            }
            ConstStorage.syncResetRequired = true
        }
    }

    func deleteService(identifier: Data) {
        DeletedServiceCacheEntity.find(on: context, identifier: identifier).forEach { context.delete($0) }
    }

    // MARK: - Sections

    /// - Parameter identifier: Gives the identifier of the deletion of a section by its ID.
    func listSections(identifier: (String) -> Data) -> [SyncDeletion] {
        DeletedSectionCacheEntity.listAll(on: context)
            .map {
                SyncDeletion(identifier: identifier($0.sectionID), deletedAt: $0.deletedAt, sectionID: $0.sectionID)
            }
            .sorted { $0.recordName < $1.recordName }
    }

    func sectionMetadata(sectionID: String) -> Data? {
        DeletedSectionCacheEntity.find(on: context, sectionID: sectionID).first?.metadata
    }

    func updateOrCreateSection(sectionID: String, deletedAt: Date, metadata: Data) {
        let entity = DeletedSectionCacheEntity.find(on: context, sectionID: sectionID).first
            ?? DeletedSectionCacheEntity(context: context)
        entity.sectionID = sectionID
        entity.deletedAt = deletedAt
        entity.metadata = metadata
    }

    func deleteSection(sectionID: String) {
        DeletedSectionCacheEntity.find(on: context, sectionID: sectionID).forEach { context.delete($0) }
    }

    // MARK: -

    var isEmpty: Bool {
        DeletedServiceCacheEntity.listAll(on: context).isEmpty
            && DeletedSectionCacheEntity.listAll(on: context).isEmpty
    }

    func purge() {
        DeletedServiceCacheEntity.listAll(on: context).forEach { context.delete($0) }
        DeletedSectionCacheEntity.listAll(on: context).forEach { context.delete($0) }
        coreDataStack.save()
    }

    func save() {
        coreDataStack.save()
    }
}
