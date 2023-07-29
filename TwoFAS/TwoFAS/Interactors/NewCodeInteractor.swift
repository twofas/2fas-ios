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
import CodeSupport
import Storage
import Common

protocol NewCodeInteracting: AnyObject {
    typealias NameCallback = (String) -> Void
    typealias ServiceWasCreated = (ServiceData?) -> Void
    
    var serviceWasCreated: ((ServiceData) -> Void)? { get set }
    var shouldRename: ((String, String) -> Void)? { get set }
    
    func addCode(_ code: Code)
    func addCodes(_ codes: [Code])
    func codeExists(_ code: Code) -> Bool
    func filterImportableCodes(_ codes: [Code]) -> [Code]
    func service(for secret: String) -> ServiceData?
    func renameService(newName: String, secret: String)
    func cancelRenaming(secret: String)
}

final class NewCodeInteractor {
    private enum NameType {
        case known(String)
        case unknown(String)
    }
    private let interactorModify: ServiceModifyInteracting
    private let interactorTrashed: TrashingServiceInteracting
    private let serviceDefinitionDatabase: ServiceDefinitionInteracting
    
    var serviceWasCreated: ((ServiceData) -> Void)?
    var shouldRename: ((String, String) -> Void)?
    
    init(
        interactorModify: ServiceModifyInteracting,
        interactorTrashed: TrashingServiceInteracting,
        serviceDefinition: ServiceDefinitionInteracting
    ) {
        self.interactorModify = interactorModify
        self.interactorTrashed = interactorTrashed
        self.serviceDefinitionDatabase = serviceDefinition
    }
}

extension NewCodeInteractor: NewCodeInteracting {
    func addCode(_ code: Code) {
        let shouldAskForName = addCodeAskForName(code)
                
        if shouldAskForName {
            handleAskForName(for: code.secret)
        } else {
            notifyServiceWasCreated(secret: code.secret)
        }
    }
    
    func codeExists(_ code: Code) -> Bool {
        let check = interactorModify.serviceExists(for: code.secret)
        return check == .yes
    }
    
    func filterImportableCodes(_ codes: [Code]) -> [Code] {
        codes.filter { !codeExists($0) }
    }
    
    func addCodes(_ codes: [Code]) {
        codes.forEach {
            _ = addCodeAskForName($0)
        }
    }
    
    func service(for secret: String) -> ServiceData? {
        interactorModify.service(for: secret)
    }
    
    func renameService(newName: String, secret: String) {
        guard let serviceData = interactorModify.service(for: secret) else { return }
        renameService(serviceData, newName: newName)
        notifyServiceWasCreated(secret: secret)
    }
    
    func cancelRenaming(secret: String) {
        notifyServiceWasCreated(secret: secret)
    }
}

private extension NewCodeInteractor {
    private func addCodeAskForName(_ code: Code) -> Bool {
        Log("NewCodeInteractor - addCode", module: .interactor)
        switch interactorModify.serviceExists(for: code.secret) {
        case .yes:
            Log("NewCodeInteractor - service already exists", module: .interactor)
            return false
        case .trashed:
            Log("NewCodeInteractor - service is in trash. Deleting", module: .interactor)
            interactorTrashed.deleteService(for: code.secret)
        default:
            break
        }
        
        let serviceDefinition: ServiceDefinition? = findServiceTypeID(for: code)
        let additionalInfoValue = additionalInfo(for: code, serviceDefinition: serviceDefinition)
        
        var shouldAskForName = false
        let codeName: String
        
        switch createName(for: code, serviceDefinition: serviceDefinition) {
        case .known(let str):
            codeName = str
        case .unknown(let str):
            codeName = str
            shouldAskForName = true
        }
        
        logEvent(for: code, serviceDefinition: serviceDefinition)
        
        Log("NewCodeInteractor - adding service. Should ask for name: \(shouldAskForName)", module: .interactor)
        
        interactorModify.addService(
            name: codeName,
            secret: code.secret,
            serviceTypeID: serviceDefinition?.serviceTypeID,
            additionalInfo: additionalInfoValue?.sanitizeInfo(),
            rawIssuer: code.issuer,
            otpAuth: code.otpAuth,
            tokenPeriod: code.period,
            tokenLength: code.digits ?? .defaultValue,
            badgeColor: nil,
            iconType: .brand,
            iconTypeID: serviceDefinition?.iconTypeID ?? .default,
            labelColor: .lightBlue,
            labelTitle: codeName.twoLetters,
            algorithm: code.algorithm ?? .defaultValue,
            counter: code.counter,
            tokenType: code.tokenType,
            source: .link
        )
        
        return shouldAskForName
    }
    
    private func createName(for code: Code, serviceDefinition: ServiceDefinition?) -> NameType {
        if let serviceDefinition {
            return .known(serviceDefinition.name)
        }
        
        if let issuer = code.issuer, !issuer.isEmpty {
            return .known(issuer)
        } else if let label = code.label, let service = serviceAndValue(from: label)?.service {
            return .known(service)
        }
        return .unknown(createUnknownName())
    }
    
    private func additionalInfo(for code: Code, serviceDefinition: ServiceDefinition?) -> String? {
        guard let label = code.label else { return nil }
        
        if let serviceDefinition,
           let def = serviceDefinition.matchingRules?.first(where: { $0.field == .account }),
           def.matcher == .regex {
            return def.matchRegex(for: label)
        }
        
        return serviceAndValue(from: label)?.value
    }
    
    private func handleAskForName(for secret: String) {
        guard let serviceData = interactorModify.service(for: secret) else { return }
        shouldRename?(serviceData.name, serviceData.secret)
    }
    
    private func renameService(_ serviceData: ServiceData, newName: String) {
        Log("NewCodeInteractor - renameService", module: .interactor)
        interactorModify.renameService(serviceData, newName: newName)
    }
    
    private func notifyServiceWasCreated(secret: String) {
        guard let serviceData = interactorModify.service(for: secret) else { return }
        serviceWasCreated?(serviceData)
    }
    
    private func logEvent(for code: Code, serviceDefinition: ServiceDefinition?) {
        if let serviceDefinition {
            AppEventLog(.supportedCodeAdded(serviceDefinition.name))
        } else {
            if let issuer = code.issuer {
                AppEventLog(.missingIssuer(issuer))
            }
        }
    }
    
    private func createUnknownName() -> String {
        T.Commons.service + " " + String(interactorModify.obtainNextUnknownCodeCounter())
    }
    
    private func serviceAndValue(from name: String?) -> (service: String?, value: String?)? {
        guard let name, name.count > 1 else { return nil }
        
        let path: String = {
            if name.contains("/") {
                let pathStart = name.index(name.startIndex, offsetBy: 1)
                return String(name[pathStart...])
            } else {
                return name
            }
        }()
        guard let pathDecoded = path.removingPercentEncoding else { return nil }
        
        let splitPathArray = pathDecoded.split(separator: ":")
        
        var service: String?
        var value: String?
        
        if splitPathArray.count == 2 {
            service = String(splitPathArray[0]).trimmingCharacters(in: .whitespaces)
            value = String(splitPathArray[1]).trimmingCharacters(in: .whitespaces)
        } else {
            let str = String(splitPathArray[0]).trimmingCharacters(in: .whitespaces)
            if str.isEmailValid() {
                value = str
            } else {
                service = str
            }
        }
        
        return (service, value)
    }
    
    private func findServiceTypeID(for code: Code) -> ServiceDefinition? {
        let definitions = serviceDefinitionDatabase.all()
        if let issuer = code.issuer {
            for def in definitions {
                if let issuerList = def.issuer {
                    for iss in issuerList {
                        if iss.lowercased() == issuer.lowercased() {
                            return def
                        }
                    }
                }
                
                if let issuerRules = def.matchingRules?.filter({ $0.field == .issuer }), !issuerRules.isEmpty {
                    for rule in issuerRules {
                        if rule.isMatching(for: issuer) {
                            return def
                        }
                    }
                }
            }
        }
        
        if let label = code.label {
            for def in definitions {
                if let labelRules = def.matchingRules?.filter({ $0.field == .label }), !labelRules.isEmpty {
                    for rule in labelRules {
                        if rule.isMatching(for: label) {
                            return def
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
