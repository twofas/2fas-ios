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
import CodeSupport

enum ImportFromFileError: Error {
    case cantReadFile(reason: String?)
}

enum ImportFromFileParsing {
    enum AEGISParseResult {
        case error
        case encrypted
        case newerVersion
        case success(AEGISData)
    }
    case twoFAS(ExchangeDataFormat)
    case aegis(AEGISParseResult)
}

enum ImportFromFileTwoFASCheck {
    case newerSchema
    case encrypted
    case unencrypted
}

enum ImportFromFileAEGISParse {
    case newerSchema
    case encrypted
    case error
    case success([ServiceData])
}

enum ImportFromFileTwoFASDecrypt {
    case success(ExchangeDataServices)
    case wrongPassword
    case cantReadFile
}

protocol ImportFromFileInteracting: AnyObject {
    func openFile(_ url: URL, completion: @escaping (Result<Data, ImportFromFileError>) -> Void)
    func parseContent(_ data: Data) -> ImportFromFileParsing?
    //
    func checkTwoFAS(_ data: ExchangeDataFormat) -> ImportFromFileTwoFASCheck
    func decryptTwoFAS(_ data: ExchangeDataFormat, password: String) -> ImportFromFileTwoFASDecrypt
    func parseSectionsTwoFAS(_ data: ExchangeDataFormat) -> [CommonSectionData]
    func parseTwoFASServices(with services: ExchangeDataServices, sections: [CommonSectionData]) -> [ServiceData]
    //
    func countNewServices(_ services: [ServiceData]) -> Int
    func importServices(_ services: [ServiceData], sections: [CommonSectionData]) -> Int
    func parseAEGIS(_ data: AEGISData) -> [ServiceData]
}

final class ImportFromFileInteractor {
    private let mainRepository: MainRepository
    private let jsonDecoder = JSONDecoder()
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting
    
    init(mainRepository: MainRepository, serviceDefinitionInteractor: ServiceDefinitionInteracting) {
        self.mainRepository = mainRepository
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
    }
}

extension ImportFromFileInteractor: ImportFromFileInteracting {
    func openFile(_ url: URL, completion: @escaping (Result<Data, ImportFromFileError>) -> Void) {
        Log("ImportFromFileInteractor - open file, url: \(url)", module: .interactor)
        mainRepository.openFile(url: url) { result in
            switch result {
            case .success(let data): completion(.success(data))
            case .failure(let error):
                switch error {
                case .cantReadFile(let reason): completion(.failure(.cantReadFile(reason: reason)))
                }
            }
        }
    }
    
    func parseContent(_ data: Data) -> ImportFromFileParsing? {
        Log("ImportFromFileInteractor - parseContent", module: .interactor)
        if let services = try? jsonDecoder.decode(ExchangeData2.self, from: data),
           services.schemaVersion == ExchangeConsts.schemaVersionV3 {
            return .twoFAS(.twoFASV3(services))
        }
        
        if let services = try? jsonDecoder.decode(ExchangeData.self, from: data) {
            return .twoFAS(.twoFAS(services))
        }
        
        do {
            let services = try jsonDecoder.decode(AEGISData.self, from: data)
            return .aegis(.success(services))
        } catch {
            guard let error = error as? AEGISDataParseError else {
                return nil
            }
            switch error {
            case .encrypted: return .aegis(.encrypted)
            case .newerVersion: return .aegis(.newerVersion)
            case .error: return .aegis(.error)
            }
        }
    }
    
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
        case .twoFASV3(let servicesList):
            return parseTwoFASServicesV3(with: servicesList, sections: sections)
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
                          let tintColor = TintColor.fromImportString(colorString) else { return .lightBlue }
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
                    additionalInfo: item.otp.account,
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
    
    func parseTwoFASServicesV3(with services: [ExchangeData2.Service], sections: [CommonSectionData]) -> [ServiceData] {
        Log("Parsing 2FAS Backup File V3", module: .interactor)
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
                          let tintColor = TintColor.fromImportString(colorString) else { return .lightBlue }
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
                
                let secret = item.secret.sanitazeSecret()
                guard secret.isValidSecret() else { return nil }
                
                return ServiceData(
                    name: item.name.sanitazeName(),
                    secret: secret,
                    serviceTypeID: itemServiceTypeID,
                    additionalInfo: item.otp.account,
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
                    otpAuth: otpAuth,
                    order: item.order.position,
                    sectionID: sectionID
                )
            }
    }
    
    // MARK: -
    
    func countNewServices(_ services: [ServiceData]) -> Int {
        let value = mainRepository.countNewServices(from: services)
        Log("ImportFromFileInteractor - countNewServices: \(value)", module: .interactor)
        return value
    }
    
    func importServices(_ services: [ServiceData], sections: [CommonSectionData]) -> Int {
        mainRepository.importServices(services, sections: sections)
    }
    
    func parseAEGIS(_ data: AEGISData) -> [ServiceData] {
        Log("ImportFromFileInteractor - parseAEGIS", module: .interactor)
        let date = Date()
        return data.db.entries.compactMap { entry in
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
            return ServiceData(
                name: entry.name.sanitazeName(),
                secret: secret,
                serviceTypeID: serviceDef?.serviceTypeID,
                additionalInfo: entry.note,
                rawIssuer: entry.issuer,
                modifiedAt: date,
                createdAt: date,
                tokenPeriod: period,
                tokenLength: digits,
                badgeColor: nil,
                iconType: .brand,
                iconTypeID: serviceDef?.iconTypeID ?? .default,
                labelColor: .lightBlue,
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
