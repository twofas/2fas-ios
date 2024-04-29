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
import CloudKit
import CommonWatch
import ContentWatch

final class ItemHandlerMigrationProxy {
    var newerVersion: (() -> Void)?
    var cloudEncrypted: (() -> Void)?
    
    private let itemHandler: ItemHandler
    
    private var isFirstStart = false
    
    private var deletedEntries: [EntityOfKind] = []
    private var updatedCreated: [CKRecord] = []
    
    private var itemsToDelete: [CKRecord.ID] = []
    private var itemsToAdd: [ServiceData] = []
    
    init(itemHandler: ItemHandler) {
        self.itemHandler = itemHandler
    }
    
    func firstStart() {
        Log("Migration proxy - first start!", module: .cloudSync)
        isFirstStart = true
    }
}

extension ItemHandlerMigrationProxy: ItemHandling {
    func commit() {
        Log("Migration proxy - commit", module: .cloudSync)
        if isFirstStart {
            if let infoRecord = updatedCreated.first(where: { RecordType(rawValue: $0.recordType) == .info }) {
                let info = InfoRecord(record: infoRecord)
                if info.version > Info().version {
                    Log("Migration proxy - newer version! Aborting...", module: .cloudSync)
                    newerVersion?()
                    return
                }
                if let encryption = Info.Encryption(rawValue: info.encryption), encryption == .user {
                    Log("Migration proxy - cloud encrypted! Aborting...", module: .cloudSync)
                    cloudEncrypted?()
                    return
                }
            }
            
            isFirstStart = false
        }
        itemHandler.deleteEntries(deletedEntries)
        itemHandler.updateOrCreate(with: updatedCreated)
        deletedEntries = []
        updatedCreated = []
    }
    
    func purge() {
        itemHandler.purge()
    }
    
    func itemsToDeleteAfterMigration() -> [CKRecord.ID] {
        let list = itemsToDelete
        itemsToDelete = []
        return list
    }
    
    func servicesToAppend() -> [ServiceData] {
        let services = itemsToAdd
        itemsToAdd = []
        return services
    }
    
    func listAllCommonItems() -> [RecordType: [Any]] {
        itemHandler.listAllCommonItems()
    }
    
    func findItemsRecordIDs(for items: [EntityOfKind], zoneID: CKRecordZone.ID) -> [CKRecord.ID] {
        itemHandler.findItemsRecordIDs(for: items, zoneID: zoneID)
    }
    
    func filterDeleted(from items: [RecordType: [Any]], deleted: [EntityOfKind]) -> [RecordType: [Any]] {
        itemHandler.filterDeleted(from: items, deleted: deleted)
    }
    
    func findItem(for item: Any, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex? {
        itemHandler.findItem(for: item, type: type, in: items)
    }
    
    func findItemForEntryID(_ entryID: String, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex? {
        itemHandler.findItemForEntryID(entryID, type: type, in: items)
    }
    
    func record(for type: RecordType, item: Any, modifiedData from: [RecordType: [Any]]) -> CKRecord? {
        itemHandler.record(for: type, item: item, modifiedData: from)
    }
    
    func record(for type: RecordType, item: Any, index: Int, zoneID: CKRecordZone.ID, allItems: [Any]) -> CKRecord? {
        itemHandler.record(for: type, item: item, index: index, zoneID: zoneID, allItems: allItems)
    }
    
    func deleteEntries(_ entries: [EntityOfKind]) {
        deletedEntries = entries
    }
    
    func updateOrCreate(with entries: [CKRecord]) {
        updatedCreated = entries
    }
}
