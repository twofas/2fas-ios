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
import Common
import Protection

extension ImportFromFileInteractor {
    // MARK: 2FAS Parsing
    
    func checkTwoFAS(_ data: ExchangeDataFormat) -> ImportFromFileTwoFASCheck {
        Log("ImportFromFileInteractor - checkTwoFAS", module: .interactor)
        guard data.schemaVersion <= ExchangeConsts.schemaVersion else {
            Log("ImportFromFileInteractor - checkTwoFAS - newerSchema", module: .interactor)
            return .newerSchema
        }
        if data.isEncrypted {
            Log("ImportFromFileInteractor - checkTwoFAS - encrypted", module: .interactor)
            return .encrypted
        }
        Log("ImportFromFileInteractor - checkTwoFAS - unencrypted", module: .interactor)
        return .unencrypted
    }
    
    func decryptTwoFAS(_ data: ExchangeDataFormat, password: String) -> ImportFromFileTwoFASDecrypt {
        Log("ImportFromFileInteractor - decryptTwoFAS", module: .interactor)
        let decryption = ExchangeFileEncryption()
        guard let reference = data.reference, let servicesEncrypted = data.servicesEncrypted else {
            Log("ImportFromFileInteractor - decryptTwoFAS - cantReadFile", module: .interactor)
            return .cantReadFile
        }
        guard let decyptedData = decryption.decrypt(
            password: password,
            encodedData: servicesEncrypted,
            encodedReference: reference
        ) else {
            Log("ImportFromFileInteractor - decryptTwoFAS - wrongPassword", module: .interactor)
            return .wrongPassword
        }
        guard let result = data.parse(data: decyptedData, using: jsonDecoder) else {
            Log("ImportFromFileInteractor - decryptTwoFAS - cantReadFile - 2", module: .interactor)
            return .cantReadFile
        }
        Log("ImportFromFileInteractor - decryptTwoFAS - success", module: .interactor)
        return .success(result)
    }
    
    func parseSectionsTwoFAS(_ data: ExchangeDataFormat) -> [CommonSectionData] {
        data.parseGroups()
    }
    
    func parseTwoFASServices(with services: ExchangeDataServices, sections: [CommonSectionData]) -> [ServiceData] {
        switch services {
        case .twoFAS(let servicesList):
            return parseTwoFASServicesV12(with: servicesList, sections: sections)
        case .twoFASV34(let servicesList):
            return parseTwoFASServicesV34(with: servicesList, sections: sections)
        }
    }
    
    func parseTwoFASServicesV12(with services: [ExchangeData.Service], sections: [CommonSectionData]) -> [ServiceData] {
        Log("Parsing 2FAS Backup File V12", module: .interactor)
        let date = Date()
        return services
            .sorted { $0.order.position < $1.order.position }
            .compactMap { item in
                let modificationDate: Date = {
                    guard let updatedAt = item.updatedAt else { return date }
                    return Date(timeIntervalSince1970: TimeInterval(Double(updatedAt) / 1000.0))
                }()
                let icon: ExchangeData.Icon? = item.icon
                let iconType: IconType = {
                    guard let icon else { return .brand }
                    let iconType = icon.selected
                    switch iconType {
                    case .brand: return IconType.brand
                    case .label: return IconType.label
                    }
                }()
                let iconTypeID: IconTypeID = {
                    guard let iconString = icon?.brand?.id else { return .default }
                    return serviceDefinitionInteractor.findLegacyIcon(using: iconString) ?? .default
                }()
                let labelColor: TintColor = {
                    guard let colorString = icon?.label?.backgroundColor,
                          let tintColor = TintColor.fromImportString(colorString) else { return .random }
                    return tintColor
                }()
                let labelTitle: String = {
                    if let title = icon?.label?.text {
                        return title
                    }
                    return item.name.twoLetters
                }()
                let badgeColor: TintColor? = {
                    guard let colorString = item.badge?.color else { return nil }
                    return TintColor.fromImportString(colorString)
                }()
                
                let sectionID: UUID? = {
                    guard let groupId = item.groupId, let secID = UUID(uuidString: groupId),
                          sections.contains(where: { $0.sectionID == secID.uuidString }) else { return nil }
                    return secID
                }()
                
                let secret = item.secret.sanitazeSecret()
                guard secret.isValidSecret() else { return nil }
                
                return ServiceData(
                    name: item.name.sanitazeName(),
                    secret: secret,
                    serviceTypeID: serviceDefinitionInteractor.findLegacyService(using: item.type),
                    additionalInfo: item.otp.account?.sanitizeInfo(),
                    rawIssuer: item.otp.issuer,
                    modifiedAt: modificationDate,
                    createdAt: modificationDate,
                    tokenPeriod: Period.create(item.otp.period),
                    tokenLength: Digits.create(item.otp.digits),
                    badgeColor: badgeColor,
                    iconType: iconType,
                    iconTypeID: iconTypeID,
                    labelColor: labelColor,
                    labelTitle: labelTitle,
                    algorithm: Algorithm.create(item.otp.algorithm),
                    isTrashed: false,
                    trashingDate: nil,
                    counter: item.otp.counter,
                    tokenType: TokenType.create(item.otp.tokenType),
                    source: .link,
                    otpAuth: nil,
                    order: item.order.position,
                    sectionID: sectionID
                )
            }
    }
    
    func parseTwoFASServicesV34(
        with services: [ExchangeData2.Service],
        sections: [CommonSectionData]
    ) -> [ServiceData] {
        Log("Parsing 2FAS Backup File V3/V4", module: .interactor)
        let date = Date()
        return services
            .sorted { $0.order.position < $1.order.position }
            .compactMap { item in
                let modificationDate: Date = {
                    guard let updatedAt = item.updatedAt else { return date }
                    return Date(timeIntervalSince1970: TimeInterval(Double(updatedAt) / 1000.0))
                }()
                let itemServiceTypeID: ServiceTypeID? = {
                    if let id = item.serviceTypeID {
                        return UUID(uuidString: id)
                    }
                    return nil
                }()
                let icon: ExchangeData2.Icon? = item.icon
                let iconType: IconType = {
                    guard let icon else { return .brand }
                    let iconType = icon.selected
                    switch iconType {
                    case .iconCollection: return IconType.brand
                    case .label: return IconType.label
                    }
                }()
                let iconTypeID: IconTypeID = {
                    guard let iconString = icon?.iconCollection.id else { return .default }
                    return UUID(uuidString: iconString) ?? .default
                }()
                let labelColor: TintColor = {
                    guard let colorString = icon?.label?.backgroundColor,
                          let tintColor = TintColor.fromImportString(colorString) else { return .random }
                    return tintColor
                }()
                let labelTitle: String = {
                    if let title = icon?.label?.text {
                        return title
                    }
                    return item.name.twoLetters
                }()
                let badgeColor: TintColor? = {
                    guard let colorString = item.badge?.color else { return nil }
                    return TintColor.fromImportString(colorString)
                }()
                let otpAuth: String? = item.otp.link
                
                let sectionID: UUID? = {
                    guard let groupId = item.groupId, let secID = UUID(uuidString: groupId),
                          sections.contains(where: { $0.sectionID == secID.uuidString }) else { return nil }
                    return secID
                }()
                
                if item.otp.tokenType?.uppercased() == "STEAM" {
                    // TODO: Add support for Steam
                    return nil
                }
                
                let tokenType = TokenType.create(item.otp.tokenType)
                
                let secret = item.secret.sanitazeSecret()
                guard secret.isValidSecret() else { return nil }
                
                return ServiceData(
                    name: item.name.sanitazeName(),
                    secret: secret,
                    serviceTypeID: itemServiceTypeID,
                    additionalInfo: item.otp.account?.sanitizeInfo(),
                    rawIssuer: item.otp.issuer,
                    modifiedAt: modificationDate,
                    createdAt: modificationDate,
                    tokenPeriod: Period.create(item.otp.period),
                    tokenLength: Digits.create(item.otp.digits),
                    badgeColor: badgeColor,
                    iconType: iconType,
                    iconTypeID: iconTypeID,
                    labelColor: labelColor,
                    labelTitle: labelTitle,
                    algorithm: Algorithm.create(item.otp.algorithm),
                    isTrashed: false,
                    trashingDate: nil,
                    counter: item.otp.counter,
                    tokenType: tokenType,
                    source: .link,
                    otpAuth: otpAuth,
                    order: item.order.position,
                    sectionID: sectionID
                )
            }
    }
    
    func parseAEGIS(_ data: AEGISData) -> [ServiceData] {
        Log("ImportFromFileInteractor - parseAEGIS", module: .interactor)
        let date = Date()
        var current = Set<String>()
        return data.db.entries
            .filter({ entry in
                self.shouldImport(&current, secret: entry.info.secret)
            })
            .compactMap { entry -> ServiceData? in
                guard let digits = Digits(rawValue: entry.info.digits),
                      entry.info.secret.isValidSecret()
                else { return nil }
                
                var period: Period?
                
                if let perdiodValue = entry.info.period {
                    guard let periodParsed = Period(rawValue: perdiodValue) else { return nil }
                    period = periodParsed
                }
                
                let secret = entry.info.secret.sanitazeSecret()
                guard secret.isValidSecret() else { return nil }
                
                let serviceDef = serviceDefinitionInteractor.findService(using: entry.issuer)
                let iconTypeID = serviceDef?.iconTypeID
                let iconType: IconType = {
                    if iconTypeID == nil {
                        return .label
                    }
                    return .brand
                }()
                return ServiceData(
                    name: entry.name.sanitazeName(),
                    secret: secret,
                    serviceTypeID: serviceDef?.serviceTypeID,
                    additionalInfo: entry.note?.sanitizeInfo(),
                    rawIssuer: entry.issuer,
                    modifiedAt: date,
                    createdAt: date,
                    tokenPeriod: period,
                    tokenLength: digits,
                    badgeColor: nil,
                    iconType: iconType,
                    iconTypeID: iconTypeID ?? .default,
                    labelColor: .random,
                    labelTitle: entry.name.twoLetters,
                    algorithm: entry.info.algo.toAlgoritm,
                    isTrashed: false,
                    trashingDate: nil,
                    counter: entry.info.counter,
                    tokenType: entry.type.toTokenType,
                    source: .link,
                    otpAuth: nil,
                    order: nil,
                    sectionID: nil
                )
            }
    }
    
    func parseLastPass(_ data: LastPassData) -> [ServiceData] {
        Log("ImportFromFileInteractor - parseLastPass", module: .interactor)
        
        var current = Set<String>()
        
        return data.accounts
            .filter({ entry in
                self.shouldImport(&current, secret: entry.secret)
            })
            .compactMap { acc in
                guard let digits = Digits(rawValue: acc.digits),
                      let period = Period(rawValue: acc.timeStep),
                      acc.secret.isValidSecret()
                else { return nil }
                
                let secret = acc.secret.sanitazeSecret()
                guard secret.isValidSecret() else { return nil }
                let algo = Algorithm(rawValue: acc.algorithm.uppercased())
                
                let serviceDef = serviceDefinitionInteractor.findService(using: acc.issuerName)
                let iconTypeID = serviceDef?.iconTypeID
                let iconType: IconType = {
                    if iconTypeID == nil {
                        return .label
                    }
                    return .brand
                }()
                return ServiceData(
                    name: acc.userName.sanitazeName(),
                    secret: secret,
                    serviceTypeID: serviceDef?.serviceTypeID,
                    additionalInfo: nil,
                    rawIssuer: acc.issuerName,
                    modifiedAt: acc.creationTimestamp,
                    createdAt: acc.creationTimestamp,
                    tokenPeriod: period,
                    tokenLength: digits,
                    badgeColor: nil,
                    iconType: iconType,
                    iconTypeID: iconTypeID ?? .default,
                    labelColor: .random,
                    labelTitle: acc.userName.twoLetters,
                    algorithm: algo ?? .defaultValue,
                    isTrashed: false,
                    trashingDate: nil,
                    counter: 0,
                    tokenType: .totp,
                    source: .link,
                    otpAuth: nil,
                    order: nil,
                    sectionID: nil
                )
            }
    }
    
    func parseRaivo(_ data: [RaivoData]) -> [ServiceData] {
        Log("ImportFromFileInteractor - parseRaivo", module: .interactor)
        
        let date = Date()
        var current = Set<String>()
        
        return data
            .filter({ entry in
                self.shouldImport(&current, secret: entry.secret)
            })
            .compactMap { acc in
                guard
                    let rawDigits = Int(acc.digits),
                    let digits = Digits(rawValue: rawDigits),
                    let kind = TokenType(rawValue: acc.kind.uppercased()),
                    let algo = Algorithm(rawValue: acc.algorithm.uppercased()),
                    let counter = Int(acc.counter),
                    let rawTimer = Int(acc.timer),
                    let period = Period(rawValue: rawTimer)
                else { return nil }
                
                let secret = acc.secret.sanitazeSecret()
                guard secret.isValidSecret() else { return nil }
                
                let name: String = {
                    let name = acc.issuer.sanitazeName()
                        .replacingOccurrences(of: "+", with: " ")
                    if name.isEmpty {
                        return modifyInteractor.createNameForUnknownService()
                    }
                    return name
                }()
                
                let serviceDef = serviceDefinitionInteractor.findService(using: acc.issuer)
                let iconTypeID = serviceDef?.iconTypeID
                let iconType: IconType = {
                    if iconTypeID == nil {
                        return .label
                    }
                    return .brand
                }()
                return ServiceData(
                    name: name,
                    secret: secret,
                    serviceTypeID: serviceDef?.serviceTypeID,
                    additionalInfo: acc.account.sanitizeInfo(),
                    rawIssuer: acc.issuer,
                    modifiedAt: date,
                    createdAt: date,
                    tokenPeriod: period,
                    tokenLength: digits,
                    badgeColor: nil,
                    iconType: iconType,
                    iconTypeID: iconTypeID ?? .default,
                    labelColor: .random,
                    labelTitle: name.twoLetters,
                    algorithm: algo,
                    isTrashed: false,
                    trashingDate: nil,
                    counter: counter,
                    tokenType: kind,
                    source: .link,
                    otpAuth: nil,
                    order: nil,
                    sectionID: nil
                )
            }
    }
    
    func parseAndOTP(_ data: [AndOTPData]) -> [ServiceData] {
        Log("ImportFromFileInteractor - parseAndOTP", module: .interactor)
        
        let date = Date()
        var current = Set<String>()
        
        return data
            .filter({ entry in
                self.shouldImport(&current, secret: entry.secret)
            })
            .compactMap { acc -> ServiceData? in
                let secret = acc.secret.sanitazeSecret()
                
                guard secret.isValidSecret() else { return nil }
                
                let issuer = acc.issuer
                let additionalInfo = acc.label?.sanitizeInfo()
                
                guard let digits: Digits = {
                    if let digits = acc.digits {
                        return Digits(rawValue: digits)
                    }
                    return .defaultValue
                }() else { return nil }
                
                let kind = TokenType.create(acc.type?.uppercased())
                
                guard let algo: Algorithm = {
                    if let algo = acc.algorithm?.uppercased() {
                        return Algorithm(rawValue: algo)
                    }
                    return .defaultValue
                }() else { return nil }
                
                let counter = acc.counter ?? 0
                let period = Period.create(acc.period)
                
                let name: String = {
                    if let name = issuer?.sanitazeName()
                        .replacingOccurrences(of: "+", with: " "), !name.isEmpty {
                        return name
                    }
                    return modifyInteractor.createNameForUnknownService()
                }()
                
                let serviceDef: ServiceDefinition? = {
                    if let issuer {
                        return serviceDefinitionInteractor.findService(using: issuer)
                    }
                    return nil
                }()
                let iconTypeID = serviceDef?.iconTypeID
                let iconType: IconType = {
                    if iconTypeID == nil {
                        return .label
                    }
                    return .brand
                }()
                
                return ServiceData(
                    name: name,
                    secret: secret,
                    serviceTypeID: serviceDef?.serviceTypeID,
                    additionalInfo: additionalInfo,
                    rawIssuer: issuer,
                    modifiedAt: date,
                    createdAt: date,
                    tokenPeriod: period,
                    tokenLength: digits,
                    badgeColor: nil,
                    iconType: iconType,
                    iconTypeID: iconTypeID ?? .default,
                    labelColor: .random,
                    labelTitle: name.twoLetters,
                    algorithm: algo,
                    isTrashed: false,
                    trashingDate: nil,
                    counter: counter,
                    tokenType: kind,
                    source: .link,
                    otpAuth: nil,
                    order: nil,
                    sectionID: nil
                )
            }
    }
    
    func importFromAuthenticatorProFileFormat(_ data: Data) -> ImportFromFileAuthenticatorPro {
        guard let string = String(data: data, encoding: .utf8) else { return .cantReadFile }
        var current = Set<String>()
        
        let lines = string.split(separator: "\n")
            .map({ String($0) })
            .compactMap({ URL(string: $0) })
            .filter({ $0.scheme == "otpauth" })
        
        let codes = lines.compactMap({ Code.parseURL($0) })
            .filter({ entry in
                self.shouldImport(&current, secret: entry.secret)
            })
        guard !codes.isEmpty else { return .cantReadFile }
        
        return .success(codes)
    }
    
    func parseAuthenticatorPro(_ data: [Code]) -> [ServiceData] {
        Log("ImportFromFileInteractor - AutenticatorPro", module: .interactor)
        
        let date = Date()
        var current = Set<String>()
        
        return data
            .filter({ entry in
                self.shouldImport(&current, secret: entry.secret)
            })
            .compactMap { code -> ServiceData? in
                let secret = code.secret.sanitazeSecret()
                
                guard secret.isValidSecret() else { return nil }
                
                let issuer = code.issuer
                let additionalInfo = code.label?.sanitizeInfo()
                let digits = code.digits ?? .defaultValue
                let kind = code.tokenType
                let algo = code.algorithm ?? .defaultValue
                let counter = code.counter ?? 0
                let period = code.period ?? .defaultValue
                
                let name: String = {
                    if let name = issuer?.sanitazeName()
                        .replacingOccurrences(of: "+", with: " "), !name.isEmpty {
                        return name
                    }
                    return modifyInteractor.createNameForUnknownService()
                }()
                
                let serviceDef: ServiceDefinition? = {
                    if let issuer {
                        return serviceDefinitionInteractor.findService(using: issuer)
                    }
                    return nil
                }()
                let iconTypeID = serviceDef?.iconTypeID
                let iconType: IconType = {
                    if iconTypeID == nil {
                        return .label
                    }
                    return .brand
                }()
                
                return ServiceData(
                    name: name,
                    secret: secret,
                    serviceTypeID: serviceDef?.serviceTypeID,
                    additionalInfo: additionalInfo,
                    rawIssuer: issuer,
                    modifiedAt: date,
                    createdAt: date,
                    tokenPeriod: period,
                    tokenLength: digits,
                    badgeColor: nil,
                    iconType: iconType,
                    iconTypeID: iconTypeID ?? .default,
                    labelColor: .random,
                    labelTitle: name.twoLetters,
                    algorithm: algo,
                    isTrashed: false,
                    trashingDate: nil,
                    counter: counter,
                    tokenType: kind,
                    source: .link,
                    otpAuth: nil,
                    order: nil,
                    sectionID: nil
                )
            }
    }
    
    private func shouldImport(_ set: inout Set<String>, secret: String) -> Bool {
        if set.contains(secret) {
            return false
        }
        set.insert(secret)
        return true
    }
}

private extension AEGISData.Entry.Info.Algo {
    var toAlgoritm: Algorithm {
        switch self {
        case .sha1: return .SHA1
        case .sha256: return .SHA256
        case .sha512: return .SHA512
        }
    }
}

private extension AEGISData.Entry.EntryType {
    var toTokenType: TokenType {
        switch self {
        case .hotp: return .hotp
        case .totp: return .totp
        }
    }
}
