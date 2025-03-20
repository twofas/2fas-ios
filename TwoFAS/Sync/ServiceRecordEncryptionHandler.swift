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

final class ServiceRecordEncryptionHandler {
    private let zoneID: CKRecordZone.ID
    private let encryptionHandler: SyncEncryptionHandler
    
    init(zoneID: CKRecordZone.ID, encryptionHandler: SyncEncryptionHandler) {
        self.zoneID = zoneID
        self.encryptionHandler = encryptionHandler
    }
    
    func createServiceRecord3(from serviceData: ServiceData, metadata: Data?, list: [ServiceData]) -> CKRecord? {
        let sectionOrder = Dictionary(grouping: list, by: { $0.sectionID })[serviceData.sectionID]?
            .firstIndex(where: { $0.secret == serviceData.secret }) ?? 0
        
        guard let name = encrypt(serviceData.name),
              let secret = encrypt(serviceData.secret),
              let iconTypeID = encrypt(serviceData.iconTypeID.uuidString)
        else {
            return nil
        }
        let serviceTypeID: Data? = {
            if let serviceTypeID = serviceData.serviceTypeID {
                return encrypt(serviceTypeID.uuidString)
            }
            return nil
        }()
        let additionalInfo: Data? = {
            if let additionalInfo = serviceData.additionalInfo {
                return encrypt(additionalInfo)
            }
            return nil
        }()
        let rawIssuer: Data? = {
            if let rawIssuer = serviceData.rawIssuer {
                return encrypt(rawIssuer)
            }
            return nil
        }()
        let otpAuth: Data? = {
            if let otpAuth = serviceData.otpAuth {
                return encrypt(otpAuth)
            }
            return nil
        }()
        
        if let metadata {
            return ServiceRecord3.create(
                with: metadata,
                name: name,
                secret: secret,
                serviceTypeID: serviceTypeID,
                additionalInfo: additionalInfo,
                rawIssuer: rawIssuer,
                otpAuth: otpAuth,
                tokenPeriod: serviceData.tokenPeriod?.rawValue,
                tokenLength: serviceData.tokenLength.rawValue,
                badgeColor: serviceData.badgeColor?.rawValue,
                iconType: serviceData.iconType.rawValue,
                iconTypeID: iconTypeID,
                labelColor: serviceData.labelColor.rawValue,
                labelTitle: serviceData.labelTitle,
                sectionID: serviceData.sectionID?.uuidString,
                sectionOrder: sectionOrder,
                algorithm: serviceData.algorithm.rawValue,
                counter: serviceData.counter,
                tokenType: serviceData.tokenType.rawValue,
                source: serviceData.source.rawValue
            )
        }
        
        return ServiceRecord3.create(
            zoneID: zoneID,
            name: name,
            secret: secret,
            unencryptedSecret: serviceData.secret,
            serviceTypeID: serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            otpAuth: otpAuth,
            tokenPeriod: serviceData.tokenPeriod?.rawValue,
            tokenLength: serviceData.tokenLength.rawValue,
            badgeColor: serviceData.badgeColor?.rawValue,
            iconType: serviceData.iconType.rawValue,
            iconTypeID: iconTypeID,
            labelColor: serviceData.labelColor.rawValue,
            labelTitle: serviceData.labelTitle,
            sectionID: serviceData.sectionID?.uuidString,
            sectionOrder: sectionOrder,
            algorithm: serviceData.algorithm.rawValue,
            counter: serviceData.counter,
            tokenType: serviceData.tokenType.rawValue,
            source: serviceData.source.rawValue
        )
    }
    
    func createServiceData(from record: ServiceRecord3) -> ServiceData? {
        guard let name = decrypt(record.name),
              let secret = decrypt(record.secret),
              let iconTypeIDString = decrypt(record.iconTypeID),
              let iconTypeID = UUID(uuidString: iconTypeIDString)
        else {
            return nil
        }
        
        let serviceTypeID: UUID? = {
            if let serviceTypeIDData = record.serviceTypeID,
               let serviceTypeIDString = decrypt(serviceTypeIDData),
               let uuid = UUID(uuidString: serviceTypeIDString) {
                return uuid
            }
            return nil
        }()
        let additionalInfo: String? = {
            if let additionalInfoData = record.additionalInfo,
               let additionalInfo = decrypt(additionalInfoData){
                return additionalInfo
            }
            return nil
        }()
        let rawIssuer: String? = {
            if let rawIssuerData = record.rawIssuer,
               let rawIssuer = decrypt(rawIssuerData){
                return rawIssuer
            }
            return nil
        }()
        let otpAuth: String? = {
            if let otpAuthData = record.otpAuth,
               let otpAuth = decrypt(otpAuthData){
                return otpAuth
            }
            return nil
        }()
        let sectionID: UUID? = {
            if let sectionIDString = record.sectionID {
                return UUID(uuidString: sectionIDString)
            }
            return nil
        }()
        
        return ServiceData(
            name: name,
            secret: secret,
            serviceTypeID: serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            modifiedAt: record.modificationDate,
            createdAt: record.creationDate,
            tokenPeriod: Period.create(Int(record.tokenType)),
            tokenLength: Digits.create(Int(record.tokenLength)),
            badgeColor: TintColor.fromString(record.badgeColor),
            iconType: IconType(optionalWithDefaultRawValue: record.iconType),
            iconTypeID: iconTypeID,
            labelColor: TintColor.fromString(record.labelColor),
            labelTitle: record.labelTitle,
            algorithm: Algorithm.create(record.algorithm),
            isTrashed: false,
            trashingDate: nil,
            counter: record.counter,
            tokenType: TokenType.create(record.tokenType),
            source: ServiceSource(optionalWithDefaultRawValue: record.source),
            otpAuth: otpAuth,
            order: record.sectionOrder,
            sectionID: sectionID
        )
    }
}

private extension ServiceRecordEncryptionHandler { // using current encryption
    func encrypt(_ str: String) -> Data? {
        guard let data = str.data(using: .utf8) else {
            return nil
        }
        return encryptionHandler.encrypt(data)
    }
    
    func decrypt(_ data: Data) -> String? {
        guard let decrypted = encryptionHandler.decrypt(data),
              let str = String(data: decrypted, encoding: .utf8)
        else {
            return nil
        }
        return str
    }
}
