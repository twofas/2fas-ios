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

enum ServiceEntryKey: String {
    case name
    case secret
    case service
    case additionalInfo
    case rawIssuer
    case order
    case secretLength
    case secretPeriod
    case badgeColor
    case iconType
    case labelTitle
    case labelColor
    case brandIcon
    case sectionID
    case sectionOrder
    case algorithm
    case counter
    case tokenType
}

// swiftlint:disable line_length
final class ServiceRecord {
    private(set) var name: String = ""
    private(set) var secret: String = ""
    private(set) var service: String = ""
    private(set) var additionalInfo: String?
    private(set) var rawIssuer: String?
    private(set) var order: Int? = 0
    private(set) var ckRecord: CKRecord?
    private(set) var creationDate: Date?
    private(set) var modificationDate: Date?
    private(set) var secretLength: Int?
    private(set) var secretPeriod: Int?
    private(set) var badgeColor: String?
    private(set) var iconType: String?
    private(set) var brandIcon: String?
    private(set) var labelColor: String?
    private(set) var labelTitle: String?
    private(set) var sectionID: String?
    private(set) var sectionOrder: Int = 0
    private(set) var algorithm: String?
    private(set) var counter: Int?
    private(set) var tokenType: String?
        
    init(record: CKRecord) {
        name = record[.name] as! String
        secret = record[.secret] as! String
        service = record[.service] as! String
        
        if let rawAdditionalInfo = record[.additionalInfo] as? String {
            if rawAdditionalInfo.isEmpty {
                additionalInfo = nil
            } else {
                additionalInfo = rawAdditionalInfo
            }
        } else {
            additionalInfo = nil
        }
        
        if let rawRawIssuer = record[.rawIssuer] as? String {
            if rawRawIssuer.isEmpty {
                rawIssuer = nil
            } else {
                rawIssuer = rawRawIssuer
            }
        } else {
            rawIssuer = nil
        }
        
        order = record[.order] as? Int
        creationDate = record.creationDate
        modificationDate = record.modificationDate
        
        if let rawSecretLength = record[.secretLength] as? Int, rawSecretLength != 0 {
            secretLength = rawSecretLength
        } else {
            secretLength = nil
        }
        
        if let rawSecretPeriod = record[.secretPeriod] as? Int, rawSecretPeriod != 0 {
            secretPeriod = rawSecretPeriod
        } else {
            secretPeriod = nil
        }
                
        if let rawBadgeColor = record[.badgeColor] as? String {
            if rawBadgeColor.isEmpty {
                badgeColor = nil
            } else {
                badgeColor = rawBadgeColor
            }
        } else {
            badgeColor = nil
        }
        
        if let rawIconType = record[.iconType] as? String {
            if rawIconType.isEmpty {
                iconType = nil
            } else {
                iconType = rawIconType
            }
        } else {
            iconType = nil
        }
        
        if let rawBrandIcon = record[.brandIcon] as? String {
            if rawBrandIcon.isEmpty {
                brandIcon = nil
            } else {
                brandIcon = rawBrandIcon
            }
        } else {
            brandIcon = nil
        }
        
        if let rawLabelColor = record[.labelColor] as? String {
            if rawLabelColor.isEmpty {
                labelColor = nil
            } else {
                labelColor = rawLabelColor
            }
        } else {
            labelColor = nil
        }
        
        if let rawLabelTitle = record[.labelTitle] as? String {
            if rawLabelTitle.isEmpty {
                labelTitle = nil
            } else {
                labelTitle = rawLabelTitle
            }
        } else {
            labelTitle = nil
        }
        
        if let rawSectionID = record[.sectionID] as? String {
            if rawSectionID.isEmpty {
                sectionID = nil
            } else {
                sectionID = rawSectionID
            }
        } else {
            sectionID = nil
        }
        
        if let rawTokenType = record[.tokenType] as? String {
            if rawTokenType.isEmpty {
                tokenType = nil
            } else {
                tokenType = rawTokenType
            }
        } else {
            tokenType = nil
        }
        
        if let rawAlgorithm = record[.algorithm] as? String {
            if rawAlgorithm.isEmpty {
                algorithm = nil
            } else {
                algorithm = rawAlgorithm
            }
        } else {
            algorithm = nil
        }
        
        sectionOrder = (record[.sectionOrder] as? Int) ?? 0
        
        counter = record[.counter] as? Int ?? TokenType.hotpDefaultValue
        
        ckRecord = record
    }
    
    func encodeSystemFields() -> Data {
        guard let ckRecord else { fatalError("No record saved!") }
        return ckRecord.encodeSystemFields()
    }
    
    static func create(with metadata: Data, name: String, secret: String, service: String, additionalInfo: String?, rawIssuer: String?, secretLength: Int?, secretPeriod: Int?, badgeColor: String?, iconType: String?, brandIcon: String?, labelColor: String?, labelTitle: String?, sectionID: String?, sectionOrder: Int, algorithm: String?, counter: Int?, tokenType: String?) -> CKRecord? {
        guard let decoder = try? NSKeyedUnarchiver(forReadingFrom: metadata) else { return nil }
        decoder.requiresSecureCoding = true
        guard let record = CKRecord(coder: decoder) else { return nil }
        decoder.finishDecoding()
        
        update(record, name: name, secret: secret, service: service, additionalInfo: additionalInfo, rawIssuer: rawIssuer, secretLength: secretLength, secretPeriod: secretPeriod, badgeColor: badgeColor, iconType: iconType, brandIcon: brandIcon, labelColor: labelColor, labelTitle: labelTitle, sectionID: sectionID, sectionOrder: sectionOrder, algorithm: algorithm, counter: counter, tokenType: tokenType)
        return record
    }
    
    static func create(name: String, zoneID: CKRecordZone.ID, secret: String, service: String, additionalInfo: String?, rawIssuer: String?, secretLength: Int?, secretPeriod: Int?, badgeColor: String?, iconType: String?, brandIcon: String?, labelColor: String?, labelTitle: String?, sectionID: String?, sectionOrder: Int, algorithm: String?, counter: Int?, tokenType: String?) -> CKRecord? {
        let record = CKRecord(recordType: RecordType.service2.rawValue, recordID: recordID(with: secret, zoneID: zoneID))
        
        update(record, name: name, secret: secret, service: service, additionalInfo: additionalInfo, rawIssuer: rawIssuer, secretLength: secretLength, secretPeriod: secretPeriod, badgeColor: badgeColor, iconType: iconType, brandIcon: brandIcon, labelColor: labelColor, labelTitle: labelTitle, sectionID: sectionID, sectionOrder: sectionOrder, algorithm: algorithm, counter: counter, tokenType: tokenType)
        return record
    }
    
    static func update(_ record: CKRecord, name: String, secret: String, service: String, additionalInfo: String?, rawIssuer: String?, secretLength: Int?, secretPeriod: Int?, badgeColor: String?, iconType: String?, brandIcon: String?, labelColor: String?, labelTitle: String?, sectionID: String?, sectionOrder: Int, algorithm: String?, counter: Int?, tokenType: String?) {
        record[.name] = name as CKRecordValue
        record[.secret] = secret as CKRecordValue
        record[.service] = service as CKRecordValue
        record[.additionalInfo] = (additionalInfo ?? "") as CKRecordValue
        record[.rawIssuer] = (rawIssuer ?? "") as CKRecordValue
        record[.order] = ((record[.order] as? Int) ?? 0) as CKRecordValue
        record[.secretLength] = (secretLength ?? 0) as CKRecordValue
        record[.secretPeriod] = (secretPeriod ?? 0) as CKRecordValue
        record[.badgeColor] = (badgeColor ?? "") as CKRecordValue
        record[.iconType] = (iconType ?? "") as CKRecordValue
        record[.brandIcon] = (brandIcon ?? "") as CKRecordValue
        record[.labelColor] = (labelColor ?? "") as CKRecordValue
        record[.labelTitle] = (labelTitle ?? "") as CKRecordValue
        record[.sectionID] = (sectionID ?? "") as CKRecordValue
        record[.sectionOrder] = sectionOrder as CKRecordValue
        record[.algorithm] = (algorithm ?? "") as CKRecordValue
        record[.counter] = (counter ?? TokenType.hotpDefaultValue) as CKRecordValue
        record[.tokenType] = (tokenType ?? "") as CKRecordValue
    }
}
// swiftlint:enable line_length

extension ServiceRecord: RecordIDGenerator {
    static func recordID(with identifier: String, zoneID: CKRecordZone.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: identifier, zoneID: zoneID)
    }
}

private extension CKRecord {
    subscript(_ key: ServiceEntryKey) -> CKRecordValue? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
}

extension CKRecord {
    func encodeSystemFields() -> Data {
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        encodeSystemFields(with: encoder)
        encoder.finishEncoding()
        return encoder.encodedData
    }
}
