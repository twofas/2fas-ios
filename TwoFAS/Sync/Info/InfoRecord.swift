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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

enum InfoEntryKey: String {
    case version
    case encryption
    case allowedDevices
    case enableWatch
    case encryptionReference
    case modificationDate
}

final class InfoRecord {
    private(set) var version: Int = 0
    private(set) var encryption: String = ""
    private(set) var ckRecord: CKRecord?
    private(set) var modificationDate = Date()
    private(set) var allowedDevices: [String] = []
    private(set) var encryptionReference: Data? = nil
    private(set) var enableWatch = false
    
    init(record: CKRecord) {
        version = record[.version] as! Int
        encryption = record[.encryption] as! String
        allowedDevices = record[.allowedDevices] as! [String]
        enableWatch = record[.enableWatch] as! Bool
        if let er = record[.encryptionReference] as? Data {
            encryptionReference = er
        }

        modificationDate = record.modificationDate ?? Date()

        ckRecord = record
    }
    
    func encodeSystemFields() -> Data {
        guard let ckRecord else { fatalError("No record saved!") }
        return ckRecord.encodeSystemFields()
    }
    
    static func recreate(
        with metadata: Data,
        version: Int,
        encryption: String,
        allowedDevices: [String],
        enableWatch: Bool,
        encryptionReference: Data,
        modificationDate: Date
    ) -> CKRecord? {
        guard let decoder = try? NSKeyedUnarchiver(forReadingFrom: metadata) else { return nil }
        decoder.requiresSecureCoding = true
        guard let record = CKRecord(coder: decoder) else { return nil }
        decoder.finishDecoding()
        
        update(
            record,
            version: version,
            encryption: encryption,
            allowedDevices: allowedDevices,
            enableWatch: enableWatch,
            encryptionReference: encryptionReference,
            modificationDate: modificationDate
        )
        
        return record
    }
    
    static func create(
        zoneID: CKRecordZone.ID,
        version: Int,
        encryption: String,
        allowedDevices: [String],
        enableWatch: Bool,
        encryptionReference: Data,
        modificationDate: Date
    ) -> CKRecord? {
        let record = CKRecord(recordType: RecordType.info.rawValue, recordID: recordID(with: "", zoneID: zoneID))
        
        update(
            record,
            version: version,
            encryption: encryption,
            allowedDevices: allowedDevices,
            enableWatch: enableWatch,
            encryptionReference: encryptionReference,
            modificationDate: modificationDate
        )
        
        return record
    }
    
    static func update(
        _ record: CKRecord,
        version: Int,
        encryption: String,
        allowedDevices: [String],
        enableWatch: Bool,
        encryptionReference: Data,
        modificationDate: Date
    ) {
        record[.version] = version as CKRecordValue
        record[.encryption] = encryption as CKRecordValue
        record[.allowedDevices] = allowedDevices as CKRecordValue
        record[.enableWatch] = enableWatch as CKRecordValue
        record[.encryptionReference] = encryptionReference as CKRecordValue
        record[.modificationDate] = modificationDate as CKRecordValue
    }
}

extension InfoRecord: RecordIDGenerator {
    static func recordID(with identifier: String, zoneID: CKRecordZone.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: Info.id, zoneID: zoneID)
    }
}

private extension CKRecord {
    subscript(_ key: InfoEntryKey) -> CKRecordValue? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
}
