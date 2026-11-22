//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

/// Splits what has to be sent to the cloud into operations.
///
/// - An operation never has more items than CloudKit takes (400, saves and deletions together).
/// - Saves go before deletions. The record of a deletion is saved no later than the record of its item is
///   removed: another device never sees an item that is simply gone – it would keep it and send it back – only
///   one that is deleted.
/// - The Info record goes in the first operation: the records are named with the identifier key it carries, and
///   without it nobody could match them.
final class ModificationQueue {
    typealias Batch = (modify: [CKRecord]?, delete: [CKRecord.ID]?)
    
    static let batchElementLimit = 350
    
    private var batches: [(modify: [CKRecord], delete: [CKRecord.ID])] = []
    private var currentIndex = 0
    
    var finished: Bool {
        currentIndex >= batches.count
    }
    
    func setRecordsToModifyOnServer(_ modify: [CKRecord]?, deleteIDs: [CKRecord.ID]?) {
        batches = Self.makeBatches(modify: modify ?? [], delete: deleteIDs ?? [], limit: Self.batchElementLimit)
        currentIndex = 0
        Log("ModificationQueue - spliting into \(batches.count) batches", module: .cloudSync)
    }
    
    static func makeBatches(
        modify: [CKRecord],
        delete: [CKRecord.ID],
        limit: Int
    ) -> [(modify: [CKRecord], delete: [CKRecord.ID])] {
        let infoFirst = modify.filter { $0.recordType == RecordType.info.rawValue }
            + modify.filter { $0.recordType != RecordType.info.rawValue }
        var batches: [(modify: [CKRecord], delete: [CKRecord.ID])] = []
        var saves = ArraySlice(infoFirst)
        var deletions = ArraySlice(delete)
        while !saves.isEmpty || !deletions.isEmpty {
            let batchSaves = Array(saves.prefix(limit))
            saves = saves.dropFirst(batchSaves.count)
            // Deletions only once every save was taken
            let batchDeletions = saves.isEmpty ? Array(deletions.prefix(limit - batchSaves.count)) : []
            deletions = deletions.dropFirst(batchDeletions.count)
            batches.append((batchSaves, batchDeletions))
        }
        return batches
    }
    
    func currentBatch() -> Batch {
        guard let batch = batches[safe: currentIndex] else { return (nil, nil) }
        return (
            modify: batch.modify.isEmpty ? nil : batch.modify,
            delete: batch.delete.isEmpty ? nil : batch.delete
        )
    }
    
    func prevBatchProcessed() {
        currentIndex += 1
    }
    
    func clear() {
        batches = []
        currentIndex = 0
    }
}
