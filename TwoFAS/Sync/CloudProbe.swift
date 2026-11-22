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

public protocol CloudProbing: AnyObject {
    func checkForVaults(completion: @escaping (Result<[VaultVersion], Error>) -> Void)
}

public enum CloudProbeError: Error {
    /// What is in the cloud isn't known – the query, or reading one of the records, failed
    case operationFailed
}

public final class CloudProbe: CloudProbing {
    private let container: CKContainer
    private let database: CKDatabase
    
    private var completion: ((Result<[VaultVersion], Error>) -> Void)?
    private var foundVaults: [VaultVersion] = []
    
    private var hasError = false
    /// The query itself failed (no network, the service unavailable, …) – not the same as finding nothing
    private var operationError: Error?
    
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
        // One Info record per vault: the oldest ones, the previous one and the current one
        queryOperation.resultsLimit = 10
        
        queryOperation.recordMatchedBlock = recordMatchedBlock
        // `completionBlock` of `Operation` doesn't say whether the query worked: a failed query would look like
        // a cloud with no vaults
        queryOperation.queryResultBlock = { [weak self] result in
            if case .failure(let error) = result, !Self.meansNothingStored(error) {
                self?.operationError = error
            }
            self?.completionBlock()
        }
        
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
            let version = record[InfoEntryKey.version.rawValue] as? Int ?? 0
            if let vault = Self.vaultVersion(zoneName: zoneID.zoneName, infoVersion: version) {
                Log("CloudProbe: found \(vault) in \(zoneID)", module: .cloudSync)
                foundVaults.append(vault)
            } else {
                Log("CloudProbe: a retired vault in \(zoneID)", module: .cloudSync)
            }
        case .failure(let error):
            hasError = true
            Log("CloudProbe: Error while checking Vault  \(error)", module: .cloudSync, severity: .error)
        }
    }
    
    /// What the Info record of a zone says about the vault in it. `nil` for a vault that was retired: after its data
    /// was moved to `Config.vaultV3` its Info record is left with a newer version, only to make the app versions
    /// that still use it ask for an update.
    static func vaultVersion(zoneName: String, infoVersion: Int) -> VaultVersion? {
        if zoneName == Config.vaultV3 {
            return .v4
        }
        switch infoVersion {
        case 1: return .v1
        case 2: return .v2
        case 3: return .v3
        default: return nil
        }
    }
    
    /// The record type of the Info record isn't known to the container: no vault was ever saved
    static func meansNothingStored(_ error: Error) -> Bool {
        (error as? CKError)?.code == .unknownItem
    }
    
    func completionBlock() {
        if let operationError {
            let error = operationError as NSError
            Log(
                "CloudProbe: Error - the query failed (\(error.domain) \(error.code)): \(error.localizedDescription)",
                module: .cloudSync,
                severity: .error
            )
            completion?(.failure(CloudProbeError.operationFailed))
        } else if self.hasError {
            completion?(.failure(CloudProbeError.operationFailed))
        } else {
            Log("CloudProbe: Query completed!, Vaults found: \(foundVaults.count)", module: .cloudSync)
            completion?(.success(foundVaults))
        }
        completion = nil
        hasError = false
        operationError = nil
        foundVaults = []
    }
}
