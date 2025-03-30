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
    private enum MigrationPath {
        case v1v3
        case v2v3
        case reencryption
        
        var migratingToNewestVersion: Bool {
            switch self {
            case .v1v3, .v2v3: true
            case .reencryption: false
            }
        }
    }
    
    var isReencryptionPending: (() -> Bool)?
    var isMigratingToV3: (() -> Void)?
    
    var isMigrating: Bool {
        migrationPath != nil
    }
    
    var currentEncryption: CloudEncryptionType? {
        switch infoHandler.encryptionType {
        case .system: .system
        case .user: .user
        case .none: nil
        }
    }
    
    private var migrationPath: MigrationPath?
    
    private let serviceHandler: ServiceHandler
    private let zoneID: CKRecordZone.ID
    private let serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler
    private let infoHandler: InfoHandler
    private let syncEncryptionHandler: SyncEncryptionHandler
   
    init(
        serviceHandler: ServiceHandler,
        zoneID: CKRecordZone.ID,
        serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler,
        infoHandler: InfoHandler,
        syncEncryptionHandler: SyncEncryptionHandler
    ) {
        self.serviceHandler = serviceHandler
        self.zoneID = zoneID
        self.serviceRecordEncryptionHandler = serviceRecordEncryptionHandler
        self.infoHandler = infoHandler
        self.syncEncryptionHandler = syncEncryptionHandler
    }
}

extension MigrationHandler: MigrationHandling {
    func checkIfMigrationNeeded() -> Bool {
        guard let migrationPathValue = checkMigrationVersion() else {
            return false
        }
        if migrationPathValue.migratingToNewestVersion {
            isMigratingToV3?()
        }
        migrationPath = migrationPathValue
        return true
    }
    
    func migrate() -> (recordIDsToDeleteOnServer: [CKRecord.ID]?, recordsToModifyOnServer: [CKRecord]?) {
        guard let migrationPath else { return (nil, nil) }
        switch migrationPath {
        case .v1v3:
            let listForRemoval = serviceHandler
                .listAll()
                .map({ ServiceRecord.recordID(with: $0.secret, zoneID: zoneID) })
            var listForCreationModification = listV3ForCreationModification() ?? []
            if let info = infoHandler.createNew(
                encryptionReference: syncEncryptionHandler.encryptionReference ?? Data()
            ) {
                listForCreationModification.append(info)
            }
            return (recordIDsToDeleteOnServer: listForRemoval, recordsToModifyOnServer: listForCreationModification)
        case .v2v3:
            let listForRemoval = serviceHandler
                .listAll()
                .map({ ServiceRecord2.recordID(with: $0.secret, zoneID: zoneID) })
            var listForCreationModification = listV3ForCreationModification() ?? []
            infoHandler.update(
                version: Info.version,
                encryption: syncEncryptionHandler.encryptionType,
                allowedDevices: nil,
                enableWatch: nil,
                encryptionReference: syncEncryptionHandler.encryptionReference
            )
            if let info = infoHandler.recreate() { // updating - should exist
                listForCreationModification.append(info)
            }
            return (recordIDsToDeleteOnServer: listForRemoval, recordsToModifyOnServer: listForCreationModification)
        case .reencryption:
            var listForCreationModification = listV3ForCreationModification() ?? []
            infoHandler.update(
                version: Info.version,
                encryption: syncEncryptionHandler.encryptionType,
                allowedDevices: nil,
                enableWatch: nil,
                encryptionReference: syncEncryptionHandler.encryptionReference
            )
            if let info = infoHandler.recreate() { // updating - should exist
                listForCreationModification.append(info)
            }
            return (recordIDsToDeleteOnServer: nil, recordsToModifyOnServer: listForCreationModification)
        }
    }
        
    func itemsCommited() {
        migrationPath = nil
        if isReencryptionPending?() == true {
            migrationPath = .reencryption
        }
    }
}

private extension MigrationHandler {
    func listV3ForCreationModification() -> [CKRecord]? {
        let listWithMetadata = serviceHandler.listAllWithMetadata()
        let list = listWithMetadata.map({ $0.0 })
        let servicesRecords = listWithMetadata.compactMap({ serviceRecordEncryptionHandler.createServiceRecord3(
            from: $0.0,
            metadata: $0.1,
            list: list
        ) })
        guard !servicesRecords.isEmpty else {
            return nil
        }
        return servicesRecords
    }
    
    private func checkMigrationVersion() -> MigrationPath? {
        guard migrationPath == nil else {
            return migrationPath
        }
        guard let version = infoHandler.version else {
            return .v1v3
        }
        if version == Info.version - 1 {
            return .v2v3
        }
        return nil
    }
}
