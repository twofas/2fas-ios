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

enum SectionEntryKey: String {
    case sectionID
    case title
    case order
}

final class SectionRecord {
    private(set) var sectionID: String = ""
    private(set) var title: String = ""
    private(set) var creationDate: Date?
    private(set) var modificationDate: Date?
    private(set) var order: Int = 0
    
    private(set) var ckRecord: CKRecord?
        
    init(record: CKRecord) {
        sectionID = record[SectionEntryKey.sectionID] as! String
        title = record[SectionEntryKey.title] as! String
        creationDate = record.creationDate ?? Date()
        modificationDate = record.modificationDate
        order = record[SectionEntryKey.order] as! Int
        
        ckRecord = record
    }
    
    func encodeSystemFields() -> Data {
        guard let ckRecord else { fatalError("No record saved!") }
        return ckRecord.encodeSystemFields()
    }
    
    static func create(with metadata: Data, sectionID: String, title: String, order: Int) -> CKRecord? {
        guard let decoder = try? NSKeyedUnarchiver(forReadingFrom: metadata) else { return nil }
        decoder.requiresSecureCoding = true
        guard let record = CKRecord(coder: decoder) else { return nil }
        decoder.finishDecoding()
        
        update(record, sectionID: sectionID, title: title, order: order)
        return record
    }
    
    static func create(sectionID: String, title: String, order: Int, zoneID: CKRecordZone.ID) -> CKRecord? {
        let record = CKRecord(
            recordType: RecordType.section.rawValue,
            recordID: recordID(with: sectionID, zoneID: zoneID)
        )
        
        update(record, sectionID: sectionID, title: title, order: order)
        return record
    }
    
    static func update(_ record: CKRecord, sectionID: String, title: String, order: Int) {
        record[.sectionID] = sectionID as CKRecordValue
        record[.title] = title as CKRecordValue
        record[.order] = order as CKRecordValue
    }
}

extension SectionRecord: RecordIDGenerator {
    static func recordID(with identifier: String, zoneID: CKRecordZone.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: identifier, zoneID: zoneID)
    }
}

private extension CKRecord {
    subscript(_ key: SectionEntryKey) -> CKRecordValue? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
}
