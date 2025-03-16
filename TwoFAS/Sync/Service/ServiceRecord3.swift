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

private enum ServiceEntryKey3: String {
    case tokenLength
    case tokenPeriod
    case badgeColor
    case iconType
    case labelTitle
    case labelColor
    case sectionID
    case sectionOrder
    case algorithm
    case counter
    case tokenType
    case source
}

private enum ServiceEntryKeyEncrypted3: String {
    case name
    case secret
    case serviceTypeID
    case additionalInfo
    case rawIssuer
    case otpAuth
    case iconTypeID
}

final class ServiceRecord3 {
    private(set) var name: Data = Data()
    private(set) var secret: Data = Data()
    private(set) var unencryptedSecret: String = ""
    private(set) var serviceTypeID: Data? = nil
    private(set) var additionalInfo: Data? = nil
    private(set) var rawIssuer: Data? = nil
    private(set) var otpAuth: Data? = nil
    private(set) var ckRecord: CKRecord?
    private(set) var creationDate = Date()
    private(set) var modificationDate = Date()
    private(set) var tokenLength: Int = 0
    private(set) var tokenPeriod: Int?
    private(set) var badgeColor: String?
    private(set) var iconType: String = ""
    private(set) var iconTypeID: Data = Data()
    private(set) var labelColor: String = ""
    private(set) var labelTitle: String = ""
    private(set) var sectionID: String?
    private(set) var sectionOrder: Int = 0
    private(set) var algorithm: String = ""
    private(set) var counter: Int?
    private(set) var tokenType: String
    private(set) var source: String
    
    init(record: CKRecord) {
        name = record[.name] as! Data
        secret = record[.secret] as! Data
        
        if let data = record[.serviceTypeID] as? Data, !data.isEmpty {
            serviceTypeID = data
        }
        
        if let data = record[.additionalInfo] as? Data, !data.isEmpty {
            additionalInfo = data
        }
        
        if let data = record[.rawIssuer] as? Data, !data.isEmpty {
            rawIssuer = data
        }

        if let data = record[.otpAuth] as? Data, !data.isEmpty {
            otpAuth = data
        }
        
        creationDate = record.creationDate ?? Date()
        modificationDate = record.modificationDate ?? Date()
        
        tokenLength = record[.tokenLength] as! Int
        
        if let rawTokenPeriod = record[.tokenPeriod] as? Int, rawTokenPeriod != 0 {
            tokenPeriod = rawTokenPeriod
        } else {
            tokenPeriod = nil
        }
                
        if let rawBadgeColor = record[.badgeColor] as? String, !rawBadgeColor.isEmpty {
            badgeColor = rawBadgeColor
        } else {
            badgeColor = nil
        }
        
        iconType = record[.iconType] as! String
        iconTypeID = record[.iconTypeID] as! Data
        
        labelColor = record[.labelColor] as! String
        labelTitle = record[.labelTitle] as! String
        
        if let rawSectionID = record[.sectionID] as? String, !rawSectionID.isEmpty {
            sectionID = rawSectionID
        } else {
            sectionID = nil
        }
        
        tokenType = record[.tokenType] as! String
        algorithm = record[.algorithm] as! String
        
        sectionOrder = (record[.sectionOrder] as? Int) ?? 0
        counter = record[.counter] as? Int ?? TokenType.hotpDefaultValue
        
        source = record[.source] as! String
        
        ckRecord = record
    }
    
    func encodeSystemFields() -> Data {
        guard let ckRecord else { fatalError("No record saved!") }
        return ckRecord.encodeSystemFields()
    }
    
    static func create(
        with metadata: Data,
        name: Data,
        secret: Data,
        serviceTypeID: Data?,
        additionalInfo: Data?,
        rawIssuer: Data?,
        otpAuth: Data?,
        tokenPeriod: Int?,
        tokenLength: Int,
        badgeColor: String?,
        iconType: String,
        iconTypeID: Data,
        labelColor: String,
        labelTitle: String,
        sectionID: String?,
        sectionOrder: Int,
        algorithm: String,
        counter: Int?,
        tokenType: String,
        source: String
    ) -> CKRecord? {
        guard let decoder = try? NSKeyedUnarchiver(forReadingFrom: metadata) else { return nil }
        decoder.requiresSecureCoding = true
        guard let record = CKRecord(coder: decoder) else { return nil }
        decoder.finishDecoding()
        
        update(
            record,
            name: name,
            secret: secret,
            serviceTypeID: serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            otpAuth: otpAuth,
            tokenPeriod: tokenPeriod,
            tokenLength: tokenLength,
            badgeColor: badgeColor,
            iconType: iconType,
            iconTypeID: iconTypeID,
            labelColor: labelColor,
            labelTitle: labelTitle,
            sectionID: sectionID,
            sectionOrder: sectionOrder,
            algorithm: algorithm,
            counter: counter,
            tokenType: tokenType,
            source: source
        )
        
        return record
    }
    
    static func create(
        zoneID: CKRecordZone.ID,
        name: Data,
        secret: Data,
        unencryptedSecret: String,
        serviceTypeID: Data?,
        additionalInfo: Data?,
        rawIssuer: Data?,
        otpAuth: Data?,
        tokenPeriod: Int?,
        tokenLength: Int,
        badgeColor: String?,
        iconType: String,
        iconTypeID: Data,
        labelColor: String,
        labelTitle: String,
        sectionID: String?,
        sectionOrder: Int,
        algorithm: String,
        counter: Int?,
        tokenType: String,
        source: String
    ) -> CKRecord? {
        let record = CKRecord(
            recordType: RecordType.service3.rawValue,
            recordID: recordID(with: unencryptedSecret, zoneID: zoneID)
        )
        
        update(
            record,
            name: name,
            secret: secret,
            serviceTypeID: serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            otpAuth: otpAuth,
            tokenPeriod: tokenPeriod,
            tokenLength: tokenLength,
            badgeColor: badgeColor,
            iconType: iconType,
            iconTypeID: iconTypeID,
            labelColor: labelColor,
            labelTitle: labelTitle,
            sectionID: sectionID,
            sectionOrder: sectionOrder,
            algorithm: algorithm,
            counter: counter,
            tokenType: tokenType,
            source: source
        )
        
        return record
    }
    
    static func update(
        _ record: CKRecord,
        name: Data,
        secret: Data,
        serviceTypeID: Data?,
        additionalInfo: Data?,
        rawIssuer: Data?,
        otpAuth: Data?,
        tokenPeriod: Int?,
        tokenLength: Int,
        badgeColor: String?,
        iconType: String,
        iconTypeID: Data,
        labelColor: String,
        labelTitle: String,
        sectionID: String?,
        sectionOrder: Int,
        algorithm: String,
        counter: Int?,
        tokenType: String,
        source: String
    ) {
        record[.name] = name as CKRecordValue
        record[.secret] = secret as CKRecordValue
        record[.serviceTypeID] = (serviceTypeID ?? Data()) as CKRecordValue
        record[.additionalInfo] = (additionalInfo ?? Data()) as CKRecordValue
        record[.rawIssuer] = (rawIssuer ?? Data()) as CKRecordValue
        record[.otpAuth] = (otpAuth ?? Data()) as CKRecordValue
        record[.tokenLength] = tokenLength as CKRecordValue
        record[.tokenPeriod] = (tokenPeriod ?? 0) as CKRecordValue
        record[.badgeColor] = (badgeColor ?? "") as CKRecordValue
        record[.iconType] = iconType as CKRecordValue
        record[.iconTypeID] = iconTypeID as CKRecordValue
        record[.labelColor] = labelColor as CKRecordValue
        record[.labelTitle] = labelTitle as CKRecordValue
        record[.sectionID] = (sectionID ?? "") as CKRecordValue
        record[.sectionOrder] = sectionOrder as CKRecordValue
        record[.algorithm] = algorithm as CKRecordValue
        record[.counter] = (counter ?? TokenType.hotpDefaultValue) as CKRecordValue
        record[.tokenType] = tokenType as CKRecordValue
        record[.source] = source as CKRecordValue
    }
}

extension ServiceRecord3: RecordIDGenerator {
    static func recordID(with identifier: String, zoneID: CKRecordZone.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: "\(iCloudIdentifier.generate(from: identifier))".encrypt(), zoneID: zoneID)
    }
}

private extension CKRecord {
    subscript(_ key: ServiceEntryKey3) -> CKRecordValue? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
    
    subscript(_ key: ServiceEntryKeyEncrypted3) -> CKRecordValue? {
        get { self.encryptedValues[key.rawValue] }
        set { self.encryptedValues[key.rawValue] = newValue }
    }
}
