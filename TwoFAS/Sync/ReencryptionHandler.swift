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
        shouldReencrypt = isReencryptionPending?() == true
        Log("ReencryptionHandler: will reencrypt: \(shouldReencrypt)", module: .cloudSync)
        return shouldReencrypt
    }
    
    func listForReencryption() -> (recordIDsToDeleteOnServer: [CKRecord.ID]?, recordsToModifyOnServer: [CKRecord]?) {
        guard shouldReencrypt, !isReencrypting else { return (nil, nil) }
        isReencrypting = true
        Log("ReencryptionHandler: encrypting", module: .cloudSync)
        Task { @MainActor in
            didStartReencryption?()
        }
        
        var listForCreationModification = listV3ForModification() ?? []
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
