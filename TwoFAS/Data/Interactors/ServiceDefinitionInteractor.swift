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

import UIKit
import Common

public protocol ServiceDefinitionInteracting: AnyObject {
    func serviceDefinition(using serviceTypeID: ServiceTypeID) -> ServiceDefinition?
    func serviceName(for serviceTypeID: ServiceTypeID?) -> String?
    
    func name(for iconTypeID: IconTypeID) -> String?
    func iconTypeID(for serviceTypeID: ServiceTypeID?) -> UIImage
    func grouppedList() -> [IconDescriptionGroup]
    func all() -> [ServiceDefinition]
    
    func findService(using issuer: String) -> ServiceDefinition?
    func findLegacyService(using string: String) -> ServiceTypeID?
    func findLegacyIcon(using string: String) -> IconTypeID?
    func findServices(byTag searchText: String) -> [ServiceDefinition]
    func findServicesByTagOrIssuer(_ searchText: String, exactMatch: Bool, useTags: Bool) -> [ServiceDefinition]
    func findServices(domain searchText: String) -> [ServiceDefinition]
    
    func otpAuth(from serviceData: ServiceData) -> String
}

final class ServiceDefinitionInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension ServiceDefinitionInteractor: ServiceDefinitionInteracting {
    func serviceDefinition(using serviceTypeID: ServiceTypeID) -> ServiceDefinition? {
        mainRepository.serviceDefinition(using: serviceTypeID)
    }
    
    func serviceName(for serviceTypeID: ServiceTypeID?) -> String? {
        mainRepository.serviceName(for: serviceTypeID)
    }
    
    func name(for iconTypeID: IconTypeID) -> String? {
        mainRepository.iconName(for: iconTypeID)
    }
    
    func iconTypeID(for serviceTypeID: ServiceTypeID?) -> UIImage {
        mainRepository.iconTypeID(for: serviceTypeID)
    }
    
    func grouppedList() -> [IconDescriptionGroup] {
        mainRepository.grouppedList()
    }
    
    func all() -> [ServiceDefinition] {
        mainRepository.allServiceDefinitions()
    }
    
    func findService(using issuer: String) -> ServiceDefinition? {
        mainRepository.findService(using: issuer)
    }
    
    func findLegacyService(using string: String) -> ServiceTypeID? {
        mainRepository.findLegacyService(using: string)
    }
    
    func findLegacyIcon(using string: String) -> IconTypeID? {
        mainRepository.findLegacyIcon(using: string)
    }
    
    func findServices(byTag searchText: String) -> [ServiceDefinition] {
        mainRepository.findServices(byTag: searchText)
    }
    
    func findServicesByTagOrIssuer(_ searchText: String, exactMatch: Bool, useTags: Bool) -> [ServiceDefinition] {
        mainRepository.findServicesByTagOrIssuer(searchText, exactMatch: exactMatch, useTags: useTags)
    }
    
    func findServices(domain searchText: String) -> [ServiceDefinition] {
        mainRepository.findServices(domain: searchText)
    }
    
    /// Format: otpauth://{tokenType}/{label}?secret={secret}&issuer={issuer}&algorithm={algorithm}&digits={digits}&period={period}&counter={counter}
    func otpAuth(from serviceData: ServiceData) -> String {
        if let otpAuth = serviceData.otpAuth {
            let value = replaceHidden(in: otpAuth, with: serviceData.secret)
            return value
        }
        
        let scheme = "otpauth"
        let tokenType = serviceData.tokenType.rawValue.lowercased()
        
        let label: String = {
            if let additionalInfo = serviceData.additionalInfo, !additionalInfo.isEmpty {
                return additionalInfo.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? additionalInfo
            } else if let issuer = serviceData.rawIssuer, !issuer.isEmpty {
                return issuer.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? issuer
            } else {
                return serviceData.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ??
                    serviceData.name
            }
        }()
        let issuer: String? = {
            if let issuer = serviceData.rawIssuer {
                return issuer
            }
            if let serviceTypeID = serviceData.serviceTypeID {
                return mainRepository.serviceDefinition(using: serviceTypeID)?.issuer?.first
            }
            return nil
        }()
        
        var queryItems: [String] = []
        
        let secret = serviceData.secret.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? serviceData.secret
        queryItems.append("secret=\(secret)")
        
        if let issuer, !issuer.isEmpty {
            let issuerParam = issuer.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? issuer
            queryItems.append("issuer=\(issuerParam)")
        }
        
        if serviceData.algorithm != .SHA1 {
            queryItems.append("algorithm=\(serviceData.algorithm.rawValue)")
        }
        
        if serviceData.tokenLength != .digits6 {
            queryItems.append("digits=\(serviceData.tokenLength.rawValue)")
        }
        
        if serviceData.tokenType == .totp, let period = serviceData.tokenPeriod, period != .period30 {
            queryItems.append("period=\(period.rawValue)")
        }
        
        if serviceData.tokenType == .hotp, let counter = serviceData.counter {
            queryItems.append("counter=\(counter)")
        }
        
        let queryString = queryItems.joined(separator: "&")
        let path = "\(scheme)://\(tokenType)/\(label)?\(queryString)"
        
        return path
    }
}

private extension ServiceDefinitionInteractor {
    func replaceHidden(in source: String, with replacement: String) -> String {
        source.replacingOccurrences(of: Config.hiddenSecret, with: replacement)
    }
}
