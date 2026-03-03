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
import Common

public protocol CloudProbing: AnyObject {
    func checkForVaults(completion: @escaping (Result<[VaultVersion], Error>) -> Void)
}

public enum CloudProbeError: Error {
    case operationFailed
}

public final class CloudProbe: CloudProbing {
    private let container: CKContainer
    private let database: CKDatabase
    
    private var completion: ((Result<[VaultVersion], Error>) -> Void)?
    private var foundVaults: [VaultVersion] = []
    
    private var hasError = false
    
    public init() {
        container = CKContainer(identifier: Config.containerIdentifier)
        database = container.privateCloudDatabase
    }
    
    public func checkForVaults(completion: @escaping (Result<[VaultVersion], Error>) -> Void) {
        Log("CloudProbe: checking Vault", module: .cloudSync)
        
        self.completion = completion
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RecordType.info.rawValue, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.database = database
        
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 2
        
        queryOperation.recordMatchedBlock = recordMatchedBlock
        queryOperation.completionBlock = completionBlock
        
        database.add(queryOperation)
    }
    
    func recordMatchedBlock(_ recordID: CKRecord.ID, _ result: Result<CKRecord, any Error>) {
        switch result {
        case .success(let record):
            guard record.recordType == RecordType.info.rawValue else {
                hasError = true
                Log("CloudProbe: Error - incorrect record type!", module: .cloudSync, severity: .error)
                return
            }
            let zoneID = recordID.zoneID
            let vaultInfo = InfoRecord(record: record)
            if vaultInfo.version == 1 {
                Log("CloudProbe: found V1 in \(zoneID)", module: .cloudSync)
                foundVaults.append(VaultVersion.v1)
            } else if vaultInfo.version == 2 {
                Log("CloudProbe: found V2 in \(zoneID)", module: .cloudSync)
                foundVaults.append(VaultVersion.v2)
            } else {
                Log("CloudProbe: found V3 in \(zoneID)", module: .cloudSync)
                foundVaults.append(VaultVersion.v3)
            }
        case .failure(let error):
            hasError = true
            Log("CloudProbe: Error while checking Vault  \(error)", module: .cloudSync, severity: .error)
        }
    }
    
    func completionBlock() {
        if self.hasError {
            completion?(.failure(CloudProbeError.operationFailed))
        } else {
            Log("CloudProbe: Query completed!, Vaults found: \(foundVaults.count)", module: .cloudSync)
            completion?(.success(foundVaults))
        }
        completion = nil
        hasError = false
        foundVaults = []
    }
}
