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

final class MigrationHandler {
    var retriggerFullSync: (() -> Void)?
    
    private let migrationToV3Key = "migrationToV3"
    
    private var isFirstStart = false
    private var isMigrationPending = false
    private(set) var isMigrating = false
    
    private let serviceHandler: ServiceHandler
    private let zoneID: CKRecordZone.ID
    private let serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler
    private let infoHandler: InfoHandler
    private let userDefaults: UserDefaults
    
    init(
        serviceHandler: ServiceHandler,
        zoneID: CKRecordZone.ID,
        serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler,
        infoHandler: InfoHandler
    ) {
        self.serviceHandler = serviceHandler
        self.zoneID = zoneID
        self.serviceRecordEncryptionHandler = serviceRecordEncryptionHandler
        self.infoHandler = infoHandler
        self.userDefaults = .standard
    }
}

extension MigrationHandler: MigrationHandling {
    var migrationPending: Bool {
        isMigrationPending
    }
    
    func markFirstStart() {
        isFirstStart = true
    }
    
    func setMigrationPending() {
        isMigrationPending = true
    }
    
    func checkIfMigrationNeeded() -> Bool {
        guard migratedToNewestVersion || migrationPending else {
            return false
        }
        guard isFirstStart else {
            retriggerFullSync?()
            return true
        }
        isMigrating = true
        return true
    }
    
    func migrate(with records: [CKRecord]) -> (recordIDsToDeleteOnServer: [CKRecord.ID]?, recordsToModifyOnServer: [CKRecord]?) {
        guard isMigrating else { return (nil, nil) }
        if migrationPending { // encryption changed - recreating V3
            var listForCreationModification = listV3ForCreationModification()
            if let info = infoHandler.record() { // updating - should exist
                listForCreationModification?.append(info)
            }
            return (recordIDsToDeleteOnServer: nil, recordsToModifyOnServer: listForCreationModification)
        }
        if let infoRecord = records.first(where: { RecordType(rawValue: $0.recordType) == .info }) {
            let info = InfoRecord(record: infoRecord)
            if info.version < Info().version { // Migration from V2 to V3
                let listForRemoval = listV2ForRemoval(from: records)
                var listForCreationModification = listV3ForCreationModification()
                if let info = infoHandler.record() { // updating - should exist
                    listForCreationModification?.append(info)
                }
                return (recordIDsToDeleteOnServer: listForRemoval, recordsToModifyOnServer: listForCreationModification)
            }
        } else { // Migration from V1 to V3
            let listForRemoval = listV1ForRemoval(from: records)
            var listForCreationModification = listV3ForCreationModification()
            if let info = infoHandler.record() {
                listForCreationModification?.append(info)
            }
            return (recordIDsToDeleteOnServer: listForRemoval, recordsToModifyOnServer: listForCreationModification)
        }
        return (recordIDsToDeleteOnServer: nil, recordsToModifyOnServer: nil)
    }
        
    func migrationFinished() {
        setMigratedToNewestVersion()
        
        isMigrating = false
        isMigrationPending = false
        isFirstStart = false
    }
}

private extension MigrationHandler {
    func listV1ForRemoval(from records: [CKRecord]) -> [CKRecord.ID]? {
        let list = records.filter { RecordType(rawValue: $0.recordType) == .service1 }
        guard !list.isEmpty else {
            return nil
        }
        return list.map({ $0.recordID })
    }
    
    func listV2ForRemoval(from records: [CKRecord]) -> [CKRecord.ID]? {
        let list = records.filter { RecordType(rawValue: $0.recordType) == .service2 }
        guard !list.isEmpty else {
            return nil
        }
        return list.map({ $0.recordID })
    }
    
    func listV3ForCreationModification() -> [CKRecord]? {
        let list = serviceHandler.listAll()
        let servicesRecords = list.compactMap ({ serviceRecordEncryptionHandler.createServiceRecord3(
            from: $0,
            metadata: nil,
            list: list
        ) })
        guard !servicesRecords.isEmpty else {
            return nil
        }
        return servicesRecords
    }
    
    var migratedToNewestVersion: Bool {
        userDefaults.bool(forKey: migrationToV3Key)
    }
    
    func setMigratedToNewestVersion() {
        userDefaults.set(true, forKey: migrationToV3Key)
        userDefaults.synchronize()
    }
}
