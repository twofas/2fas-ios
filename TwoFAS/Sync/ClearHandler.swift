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
import CloudKit

final class ClearHandler {
    private let cloudKit = CloudKit()
    private var isClearing = false
    private var batchCount: Int = 0
    private let batchElementLimit = 399

    var didClear: Callback?
    
    func clear(recordIDs: [CKRecord.ID]) {
        guard !isClearing else { return }
        Log("ClearHandler - Deleting 2FAS Backup", module: .cloudSync)
        isClearing = true
        cloudKit.initialize()
        cloudKit.changesSavedSuccessfuly = { [weak self] in
            guard let self, batchCount > 0, isClearing else { return }
            batchCount -= 1
            Log("ClearHandler - Batch Delete Saved Successfuly", module: .cloudSync)
            if batchCount == 0 {
                Log("ClearHandler - All Entries Deleted Successfuly", module: .cloudSync)
                changesSavedSuccessfuly()
            }
        }
        
        let batch = recordIDs.grouped(by: batchElementLimit)
        batchCount = batch.count
        for i in 0..<batchCount {
            cloudKit.modifyRecord(recordsToSave: nil, recordIDsToDelete: batch[i])
        }
    }
    
    private func changesSavedSuccessfuly() {
        isClearing = false
        Log("ClearHandler - Deletition of 2FAS Backup was successful", module: .cloudSync)
        cloudKit.clear()
        didClear?()
    }
}
