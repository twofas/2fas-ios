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

import CloudKit
import Common

final class ReencryptionHandler {
    var isReencryptionPending: (() -> Bool)?
    var didStartReencryption: Callback?
    var didFinishReencryption: Callback?
    
    /// Gives every record of a vault of sealed records, sealed with the current sync key. `nil` in the older
    /// vaults, whose service records are encrypted field by field.
    var sealedRecordsForReencryption: (() -> [CKRecord]?)?
    
    private var shouldReencrypt = false
    private var isReencrypting = false
    
    private let serviceHandler: ServiceHandler
    private let serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler
    private let syncEncryptionHandler: SyncEncryptionHandler
    private let infoHandler: InfoHandler
    
    init(
        serviceHandler: ServiceHandler,
        serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler,
        syncEncryptionHandler: SyncEncryptionHandler,
        infoHandler: InfoHandler
    ) {
        self.serviceHandler = serviceHandler
        self.serviceRecordEncryptionHandler = serviceRecordEncryptionHandler
        self.syncEncryptionHandler = syncEncryptionHandler
        self.infoHandler = infoHandler
    }
}

extension ReencryptionHandler: ReencryptionHandling {
    var willReencrypt: Bool {
        guard !shouldReencrypt else { return true }
        // Asked for now – or started earlier and not finished (the app was closed between the operations): the
        // cloud has records of both keys then, and everything is sealed and sent again
        shouldReencrypt = isReencryptionPending?() == true || syncEncryptionHandler.isKeyChangeInProgress
        Log("ReencryptionHandler: will reencrypt: \(shouldReencrypt)", module: .cloudSync)
        return shouldReencrypt
    }
    
    func listForReencryption() -> (recordIDsToDeleteOnServer: [CKRecord.ID]?, recordsToModifyOnServer: [CKRecord]?) {
        guard shouldReencrypt else { return (nil, nil) }
        Log("ReencryptionHandler: encrypting", module: .cloudSync)
        // A try that didn't get through (an operation failed, the sync started over) is simply made again, with
        // everything – answered with nothing, the sync would end as if the key had been changed, with the Info
        // record never sent
        if !isReencrypting {
            isReencrypting = true
            Task { @MainActor in
                didStartReencryption?()
            }
        }
        
        var listForCreationModification = sealedRecordsForReencryption?() ?? listV3ForModification() ?? []
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
    
    func changesApplied() {
        Log("ReencryptionHandler: changes applied", module: .cloudSync)
        shouldReencrypt = false
        // Every record and the Info record are in the cloud with the new key
        syncEncryptionHandler.finishKeyChange()
    }
    
    func syncSucceded() {
        if isReencrypting {
            Log("ReencryptionHandler: sync succeded", module: .cloudSync)
            isReencrypting = false
        }
        Task { @MainActor in // called every time on sync succeded. Closes other encryption windows
            didFinishReencryption?()
        }
    }
}

private extension ReencryptionHandler {
    func listV3ForModification() -> [CKRecord]? {
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
}
