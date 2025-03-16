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

final class RequirementCheckHandler {
    var newerVersion: (() -> Void)?
    var cloudEncrypted: (() -> Void)?
    
    func checkIfStopSync(using records: [CKRecord], migrationPending: Bool) -> Bool {
        Log("RequirementCheckHandler - checkIfStopSync", module: .cloudSync)
        if let infoRecord = records.first(where: { RecordType(rawValue: $0.recordType) == .info }) {
            let info = InfoRecord(record: infoRecord)
            if info.version > Info.version {
                Log("RequirementCheckHandler - STOP: Never version!", module: .cloudSync)
                newerVersion?()
                return true
            }
            if !migrationPending && info.encryptionReference != encryptionReference {
                Log("RequirementCheckHandler - STOP: Different encryption!", module: .cloudSync)
                cloudEncrypted?()
                return true
            }
        }
        Log("RequirementCheckHandler - everything is fine. Continuing ...", module: .cloudSync)
        return false
    }
    
    private var encryptionReference: Data {
        Data()
    }
}
