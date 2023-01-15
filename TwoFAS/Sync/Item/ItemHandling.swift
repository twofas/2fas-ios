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

protocol ItemHandling: AnyObject {
    func purge()
    func deleteEntries(_ entries: [EntityOfKind])
    func updateOrCreate(with entries: [CKRecord])
    func listAllCommonItems() -> [RecordType: [Any]]
    func findItemsRecordIDs(for items: [EntityOfKind], zoneID: CKRecordZone.ID) -> [CKRecord.ID]
    func filterDeleted(from items: [RecordType: [Any]], deleted: [EntityOfKind]) -> [RecordType: [Any]]
    func findItem(for item: Any, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex?
    func findItemForEntryID(_ entryID: String, type: RecordType, in items: [RecordType: [Any]]) -> CommonDataIndex?
    func record(for type: RecordType, item: Any, modifiedData from: [RecordType: [Any]]) -> CKRecord?
    func record(for type: RecordType, item: Any, index: Int, zoneID: CKRecordZone.ID, allItems: [Any]) -> CKRecord?
}
