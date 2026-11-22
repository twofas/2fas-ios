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

import XCTest
import CloudKit
@testable import Common
@testable import Sync

/// How what is sent to the cloud is split into operations
final class SyncModificationQueueTests: XCTestCase {
    private let zoneID = CKRecordZone.ID(zoneName: "Queue", ownerName: CKCurrentUserDefaultName)

    private func record(_ name: String, type: RecordType = .service4) -> CKRecord {
        CKRecord(recordType: type.rawValue, recordID: CKRecord.ID(recordName: name, zoneID: zoneID))
    }

    private func recordIDs(_ count: Int) -> [CKRecord.ID] {
        (0..<count).map { CKRecord.ID(recordName: "deleted\($0)", zoneID: zoneID) }
    }

    func testNoOperationExceedsTheLimit() {
        let saves = (0..<900).map { record("saved\($0)") }
        let batches = ModificationQueue.makeBatches(modify: saves, delete: recordIDs(900), limit: 350)

        XCTAssertFalse(batches.isEmpty)
        for batch in batches {
            XCTAssertLessThanOrEqual(batch.modify.count + batch.delete.count, 350)
            XCTAssertGreaterThan(batch.modify.count + batch.delete.count, 0)
        }
        XCTAssertEqual(batches.flatMap(\.modify).map(\.recordID.recordName), saves.map(\.recordID.recordName))
        XCTAssertEqual(batches.flatMap(\.delete).count, 900)
        XCTAssertEqual(Set(batches.flatMap(\.delete)).count, 900)
    }

    /// The record of a deletion is saved no later than the record of its item is removed
    func testEverySaveGoesBeforeAnyDeletion() {
        let saves = (0..<500).map { record("saved\($0)") }
        let batches = ModificationQueue.makeBatches(modify: saves, delete: recordIDs(10), limit: 350)

        let firstWithDeletions = try? XCTUnwrap(batches.firstIndex { !$0.delete.isEmpty })
        let lastWithSaves = try? XCTUnwrap(batches.lastIndex { !$0.modify.isEmpty })
        XCTAssertNotNil(firstWithDeletions)
        XCTAssertEqual(firstWithDeletions, lastWithSaves, "Deletions start in the operation that takes the last saves")
        XCTAssertEqual(batches.count, 2)
    }

    func testInfoRecordGoesInTheFirstOperation() {
        var saves = (0..<800).map { record("saved\($0)") }
        saves.insert(record("info", type: .info), at: 777)

        let batches = ModificationQueue.makeBatches(modify: saves, delete: [], limit: 350)

        XCTAssertEqual(batches.first?.modify.first?.recordType, RecordType.info.rawValue)
        XCTAssertEqual(batches.flatMap(\.modify).count, 801)
    }

    func testQueueWalksItsBatchesAndFinishes() {
        let queue = ModificationQueue()
        XCTAssertTrue(queue.finished)
        XCTAssertNil(queue.currentBatch().modify)
        XCTAssertNil(queue.currentBatch().delete)

        queue.setRecordsToModifyOnServer((0..<400).map { record("saved\($0)") }, deleteIDs: recordIDs(3))
        XCTAssertFalse(queue.finished)
        XCTAssertEqual(queue.currentBatch().modify?.count, ModificationQueue.batchElementLimit)
        XCTAssertNil(queue.currentBatch().delete)

        queue.prevBatchProcessed()
        XCTAssertFalse(queue.finished)
        XCTAssertEqual(queue.currentBatch().modify?.count, 400 - ModificationQueue.batchElementLimit)
        XCTAssertEqual(queue.currentBatch().delete?.count, 3)

        queue.prevBatchProcessed()
        XCTAssertTrue(queue.finished)

        queue.setRecordsToModifyOnServer(nil, deleteIDs: nil)
        XCTAssertTrue(queue.finished)
    }

    func testOnlyDeletions() {
        let queue = ModificationQueue()
        queue.setRecordsToModifyOnServer(nil, deleteIDs: recordIDs(2))
        XCTAssertNil(queue.currentBatch().modify)
        XCTAssertEqual(queue.currentBatch().delete?.count, 2)
        queue.prevBatchProcessed()
        XCTAssertTrue(queue.finished)
    }
}
