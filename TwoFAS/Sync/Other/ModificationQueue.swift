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

final class ModificationQueue {
    private let batchElementLimit = 399
    
    private var batchModify: [[CKRecord]] = []
    private var batchDelete: [[CKRecord.ID]] = []
    
    private var batchCount: Int = 0
    
    var finished: Bool {
        batchCount < 0
    }
    
    func setRecordsToModifyOnServer(_ modify: [CKRecord]?, deleteIDs: [CKRecord.ID]?) {
        if let modify {
            batchModify = modify.grouped(by: batchElementLimit)
        }
        
        if let deleteIDs {
            batchDelete = deleteIDs.grouped(by: batchElementLimit)
        }
        
        let maxBatchCount = max(batchModify.count, batchDelete.count)
        batchCount = maxBatchCount - 1
        
        Log("ModificationQueue - spliting into \(maxBatchCount) batches", module: .cloudSync)
    }
    
    func currentBatch() -> (modify: [CKRecord]?, delete: [CKRecord.ID]?) {
        let modify = batchModify[safe: batchCount]
        let delete = batchDelete[safe: batchCount]
        return (modify: modify, delete: delete)
    }
    
    func prevBatchProcessed() {
        batchCount -= 1
    }
    
    func clear() {
        batchCount = 0
        batchModify = []
        batchDelete = []
    }
}
