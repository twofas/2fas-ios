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
    enum ClearError: Error {
        case inProgress
    }
    
    private var isClearing = false
    private var callback: ResultCallback?
    
    func erase(complete callback: @escaping ResultCallback) {
        guard !isClearing else {
            callback(.failure(ClearError.inProgress))
            return
        }

        Log("ClearHandler: Erasing iCloud contents", module: .cloudSync)
        
        self.callback = callback
        isClearing = true

        var zoneIDs: [CKRecordZone.ID] = []
        let database = CKContainer(identifier: Config.containerIdentifier).privateCloudDatabase
        let fetchZones = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        fetchZones.perRecordZoneResultBlock = { recordZoneID, _ in
            zoneIDs.append(recordZoneID)
        }
        fetchZones.fetchRecordZonesResultBlock = { [weak self] result in
            switch result {
            case .success:
                if zoneIDs.isEmpty {
                    self?.didFinish(nil)
                    return
                }
                self?.removeZones(zoneIDs, database: database)
            case .failure(let error):
                Log(
                    "ClearHandler: Erase error in fetchRecordZonesResultBlock: \(error)",
                    module: .cloudSync,
                    severity: .error
                )
                self?.didFinish(error)
            }
        }
        database.add(fetchZones)
    }
    
    private func removeZones(_ zoneIDs: [CKRecordZone.ID], database: CKDatabase) {
        Log("ClearHandler: erasing: \(zoneIDs)", module: .cloudSync)
       
        let modifyOp = CKModifyRecordZonesOperation(recordZonesToSave: nil, recordZoneIDsToDelete: zoneIDs)
        modifyOp.modifyRecordZonesResultBlock = { [weak self] result in
            switch result {
            case .success:
                self?.didFinish(nil)
            case .failure(let error):
                Log(
                    "ClearHandler: Erase error in modifyRecordZonesResultBlock: \(error)",
                    module: .cloudSync,
                    severity: .error
                )
                self?.didFinish(error)
            }
        }
        database.add(modifyOp)
    }
    
    private func didFinish(_ error: Error?) {
        if let error {
            callback?(.failure(error))
        } else {
            Log("ClearHandler: contents cleared successfully", module: .cloudSync)
            callback?(.success(()))
        }
    }
}
