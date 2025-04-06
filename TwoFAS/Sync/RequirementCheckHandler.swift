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

final class RequirementCheckHandler {
    var newerVersion: (() -> Void)?
    var cloudEncrypted: ((Info.Encryption?) -> Void)?
    
    private let encryptionHandler: SyncEncryptionHandler
    private let infoHandler: InfoHandler
    
    init(encryptionHandler: SyncEncryptionHandler, infoHandler: InfoHandler) {
        self.encryptionHandler = encryptionHandler
        self.infoHandler = infoHandler
    }
}

extension RequirementCheckHandler: RequirementCheckHandling {
    func checkIfStopSync(using records: [CKRecord], migrationPending: Bool) -> Bool {
        Log("RequirementCheckHandler - checkIfStopSync", module: .cloudSync)
        if let infoRecord = records.first(where: { RecordType(rawValue: $0.recordType) == .info }) {
            let info = InfoRecord(record: infoRecord)
            if info.version > Info.version {
                Log("RequirementCheckHandler - STOP: Never version!", module: .cloudSync)
                newerVersion?()
                return true
            }
            if !migrationPending {
                if encryptionHandler.encryptionType.rawValue == info.encryption {
                    if let infoEncryptionReference = info.encryptionReference,
                       let infoDecryptedReference = encryptionHandler.decrypt(infoEncryptionReference),
                       let encryptionReference,
                       let decryptedReference = encryptionHandler.decrypt(encryptionReference) {
                        if infoDecryptedReference != decryptedReference {
                            Log("RequirementCheckHandler - STOP: Different encryption reference!", module: .cloudSync)
                            cloudEncrypted?(Info.Encryption(rawValue: info.encryption))
                            return true
                        }
                    } else {
                        Log("RequirementCheckHandler - STOP: Different encryption reference!", module: .cloudSync)
                        cloudEncrypted?(Info.Encryption(rawValue: info.encryption))
                        return true
                    }
                } else {
                    Log("RequirementCheckHandler - STOP: Different encryption type!", module: .cloudSync)
                    cloudEncrypted?(Info.Encryption(rawValue: info.encryption))
                    return true
                }
            }
        }
        Log("RequirementCheckHandler - everything is fine. Continuing ...", module: .cloudSync)
        return false
    }
    
    private var encryptionReference: Data? {
        encryptionHandler.encryptionReference
    }
}
