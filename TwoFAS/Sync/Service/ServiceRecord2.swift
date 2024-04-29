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

enum ServiceEntryKey2: String {
    case name
    case secret
    case serviceTypeID
    case additionalInfo
    case rawIssuer
    case otpAuth
    case tokenLength
    case tokenPeriod
    case badgeColor
    case iconType
    case labelTitle
    case labelColor
    case iconTypeID
    case sectionID
    case sectionOrder
    case algorithm
    case counter
    case tokenType
    case source
    case reference
}

final class ServiceRecord2 {
    private(set) var name: String = ""
    private(set) var secret: String = ""
    private(set) var unencryptedSecret: String = ""
    private(set) var serviceTypeID: String?
    private(set) var additionalInfo: String?
    private(set) var rawIssuer: String?
    private(set) var otpAuth: String?
    private(set) var ckRecord: CKRecord?
    private(set) var creationDate = Date()
    private(set) var modificationDate = Date()
    private(set) var tokenLength: Int = 0
    private(set) var tokenPeriod: Int?
    private(set) var badgeColor: String?
    private(set) var iconType: String = ""
    private(set) var iconTypeID: String = ""
    private(set) var labelColor: String = ""
    private(set) var labelTitle: String = ""
    private(set) var sectionID: String?
    private(set) var sectionOrder: Int = 0
    private(set) var algorithm: String = ""
    private(set) var counter: Int?
    private(set) var tokenType: String
    private(set) var source: String
    private(set) var reference: String
    
    init(record: CKRecord) {
        name = record[.name] as! String
        secret = record[.secret] as! String

        if let serviceTypeIDRaw = record[.serviceTypeID] as? String, !serviceTypeIDRaw.isEmpty {
            serviceTypeID = serviceTypeIDRaw
        } else {
            serviceTypeID = nil
        }
        
        if let rawAdditionalInfo = record[.additionalInfo] as? String, !rawAdditionalInfo.isEmpty {
            additionalInfo = rawAdditionalInfo
        } else {
            additionalInfo = nil
        }
        
        if let rawRawIssuer = record[.rawIssuer] as? String, !rawRawIssuer.isEmpty {
            rawIssuer = rawRawIssuer
        } else {
            rawIssuer = nil
        }
        
        if let rawOtpAuth = record[.otpAuth] as? String, !rawOtpAuth.isEmpty {
            otpAuth = rawOtpAuth
        } else {
            otpAuth = nil
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
        iconTypeID = record[.iconTypeID] as! String
        
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
        
        reference = record[.reference] as! String
        
        ckRecord = record
    }
    
    func encodeSystemFields() -> Data {
        guard let ckRecord else { fatalError("No record saved!") }
        return ckRecord.encodeSystemFields()
    }
    
    static func create(
        with metadata: Data,
        name: String,
        secret: String,
        serviceTypeID: String?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        tokenPeriod: Int?,
        tokenLength: Int,
        badgeColor: String?,
        iconType: String,
        iconTypeID: String,
        labelColor: String,
        labelTitle: String,
        sectionID: String?,
        sectionOrder: Int,
        algorithm: String,
        counter: Int?,
        tokenType: String,
        source: String,
        reference: String
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
            source: source,
            reference: reference
        )
        
        return record
    }
    
    static func create(
        zoneID: CKRecordZone.ID,
        name: String,
        secret: String,
        unencryptedSecret: String,
        serviceTypeID: String?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        tokenPeriod: Int?,
        tokenLength: Int,
        badgeColor: String?,
        iconType: String,
        iconTypeID: String,
        labelColor: String,
        labelTitle: String,
        sectionID: String?,
        sectionOrder: Int,
        algorithm: String,
        counter: Int?,
        tokenType: String,
        source: String,
        reference: String
    ) -> CKRecord? {
        let record = CKRecord(
            recordType: RecordType.service2.rawValue,
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
            source: source,
            reference: reference
        )
        
        return record
    }
    
    static func update(
        _ record: CKRecord,
        name: String,
        secret: String,
        serviceTypeID: String?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        tokenPeriod: Int?,
        tokenLength: Int,
        badgeColor: String?,
        iconType: String,
        iconTypeID: String,
        labelColor: String,
        labelTitle: String,
        sectionID: String?,
        sectionOrder: Int,
        algorithm: String,
        counter: Int?,
        tokenType: String,
        source: String,
        reference: String
    ) {
        record[.name] = name as CKRecordValue
        record[.secret] = secret as CKRecordValue
        record[.serviceTypeID] = (serviceTypeID ?? "") as CKRecordValue
        record[.additionalInfo] = (additionalInfo ?? "") as CKRecordValue
        record[.rawIssuer] = (rawIssuer ?? "") as CKRecordValue
        record[.otpAuth] = (otpAuth ?? "") as CKRecordValue
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
        record[.reference] = reference as CKRecordValue
    }
}

extension ServiceRecord2: RecordIDGenerator {
    static func recordID(with identifier: String, zoneID: CKRecordZone.ID) -> CKRecord.ID {
        CKRecord.ID(recordName: "\(iCloudIdentifier.generate(from: identifier))".encrypt(), zoneID: zoneID)
    }
}

private extension CKRecord {
    subscript(_ key: ServiceEntryKey2) -> CKRecordValue? {
        get { self[key.rawValue] }
        set { self[key.rawValue] = newValue }
    }
}
