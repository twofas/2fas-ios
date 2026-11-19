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
import Common

/// Retires the vaults used before `Config.vaultV3`, once the data is in the current one: their records are
/// removed and their Info record is left with `Info.retiredVersion`.
///
/// The zones themselves stay. An app version that still syncs with one of them would create a deleted zone again
/// and fill it with its own data; the Info record with a newer version makes it stop and ask for an update
/// instead.
///
/// Retiring is repeatable – a vault that is retired already is left as it is – and is tried again after the next
/// sync when it fails.
final class VaultRetirement {
    /// Records per modify operation – CloudKit refuses more than 400 items
    private static let batchSize = 300

    private let database: CKDatabase
    private var isRunning = false

    init() {
        database = CKContainer(identifier: Config.containerIdentifier).privateCloudDatabase
    }

    func retireOldVaults() {
        guard !isRunning, !ConstStorage.oldVaultsRetired else { return }
        isRunning = true
        Log("VaultRetirement: looking for old vaults", module: .cloudSync)

        var zoneIDs: [CKRecordZone.ID] = []
        let lock = NSLock()
        let fetchZones = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        fetchZones.perRecordZoneResultBlock = { zoneID, result in
            guard case .success = result, Self.isOldVault(zoneID.zoneName) else { return }
            lock.withLock { zoneIDs.append(zoneID) }
        }
        fetchZones.fetchRecordZonesResultBlock = { [weak self] result in
            switch result {
            case .success:
                self?.retire(zoneIDs)
            case .failure(let error):
                self?.finish(error: error)
            }
        }
        database.add(fetchZones)
    }

    static func isOldVault(_ zoneName: String) -> Bool {
        zoneName == Config.vaultV1 || zoneName == Config.vaultV2
    }

    /// The Info record of a retired vault. It has every field the older app versions read from it.
    static func retiredInfoRecord(zoneID: CKRecordZone.ID) -> CKRecord {
        let record = CKRecord(
            recordType: RecordType.info.rawValue,
            recordID: InfoRecord.recordID(with: Info.id, zoneID: zoneID)
        )
        InfoRecord.update(
            record,
            version: Info.retiredVersion,
            encryption: Info.Encryption.system.rawValue,
            allowedDevices: ["none"],
            enableWatch: false,
            encryptionReference: Data(),
            encryptionInfo: .empty,
            modificationDate: Date()
        )
        return record
    }

    // MARK: - Private

    private func retire(_ zoneIDs: [CKRecordZone.ID]) {
        guard let zoneID = zoneIDs.first else {
            finish(error: nil)
            return
        }
        let remaining = Array(zoneIDs.dropFirst())
        Log("VaultRetirement: retiring \(zoneID.zoneName)", module: .cloudSync)

        // Everything in the zone, without its content
        var recordIDs: [CKRecord.ID] = []
        let lock = NSLock()
        let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        configuration.desiredKeys = []
        let fetch = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [zoneID],
            configurationsByRecordZoneID: [zoneID: configuration]
        )
        fetch.fetchAllChanges = true
        fetch.recordWasChangedBlock = { recordID, result in
            guard case .success = result, recordID.recordName != Info.id else { return }
            lock.withLock { recordIDs.append(recordID) }
        }
        fetch.fetchRecordZoneChangesResultBlock = { [weak self] result in
            switch result {
            case .success:
                self?.remove(recordIDs, from: zoneID) { [weak self] error in
                    if let error {
                        self?.finish(error: error)
                    } else {
                        self?.retire(remaining)
                    }
                }
            case .failure(let error):
                self?.finish(error: error)
            }
        }
        database.add(fetch)
    }

    /// Removes the records in batches. The Info record is marked with the last batch, so a vault that was only
    /// partly emptied isn't taken for a retired one.
    private func remove(_ recordIDs: [CKRecord.ID], from zoneID: CKRecordZone.ID, completion: @escaping (Error?) -> Void) {
        let batch = Array(recordIDs.prefix(Self.batchSize))
        let remaining = Array(recordIDs.dropFirst(Self.batchSize))
        let isLast = remaining.isEmpty
        let operation = CKModifyRecordsOperation(
            recordsToSave: isLast ? [Self.retiredInfoRecord(zoneID: zoneID)] : nil,
            recordIDsToDelete: batch
        )
        // Whatever the Info record says now
        operation.savePolicy = .allKeys
        operation.isAtomic = false
        operation.modifyRecordsResultBlock = { [weak self] result in
            switch result {
            case .success:
                if isLast {
                    completion(nil)
                } else {
                    self?.remove(remaining, from: zoneID, completion: completion)
                }
            case .failure(let error):
                completion(error)
            }
        }
        database.add(operation)
    }

    private func finish(error: Error?) {
        DispatchQueue.main.async {
            self.isRunning = false
            if let error {
                let nsError = error as NSError
                Log(
                    "VaultRetirement: failed (\(nsError.domain) \(nsError.code)), will be tried again",
                    module: .cloudSync,
                    severity: .error
                )
            } else {
                Log("VaultRetirement: old vaults are retired", module: .cloudSync)
                ConstStorage.oldVaultsRetired = true
            }
        }
    }
}
