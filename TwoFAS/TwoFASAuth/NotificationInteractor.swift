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
import Storage
import Token
import NetworkStack

enum NotificationError: Error {
    case noServicesExists
    case noInternet
    case notRegistered
    case notPairedWithDomain
    case notPairedWithBrowser
    case noService
    case encryptionError
    case serverError
}

protocol NotificationInteracting: AnyObject {
    var isPINSet: Bool { get }
    func checkReadiness(
        for domain: String,
        extensionID: ExtensionID,
        completion: @escaping (Result<Void, NotificationError>) -> Void
    )
    func send2FAToken(
        for domain: String,
        extensionID: ExtensionID,
        tokenRequestID: String,
        completion: @escaping (Result<Void, NotificationError>) -> Void
    )
    func browserName(for extensionID: ExtensionID) -> String?
}

final class NotificationInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository = MainRepositoryImpl()) {
        self.mainRepository = mainRepository
    }
}

extension NotificationInteractor: NotificationInteracting {
    var isPINSet: Bool { mainRepository.isPINSet }
    
    func checkReadiness(
        for domain: String,
        extensionID: ExtensionID,
        completion: @escaping (Result<Void, NotificationError>) -> Void
    ) {
        guard mainRepository.hasAnyServices() else {
            completion(.failure(.noServicesExists))
            return
        }
        
        guard mainRepository.deviceID != nil else {
            completion(.failure(.notRegistered))
            return
        }
        
        guard pairedExtension(for: extensionID) != nil  else {
            completion(.failure(.notPairedWithBrowser))
            return
        }
        
        guard let pair = pairAuthRequest(for: domain, extensionID: extensionID) else {
            completion(.failure(.notPairedWithDomain))
            return
        }
        
        guard mainRepository.service(for: pair.secret) != nil  else {
            completion(.failure(.noService))
            return
        }
        
        completion(.success(()))
    }
    
    func send2FAToken(
        for domain: String,
        extensionID: ExtensionID,
        tokenRequestID: String,
        completion: @escaping (Result<Void, NotificationError>) -> Void
    ) {
        guard let deviceID = mainRepository.deviceID else {
            completion(.failure(.notRegistered))
            return
        }
        
        guard let pairedExtension = pairedExtension(for: extensionID) else {
            completion(.failure(.notPairedWithBrowser))
            return
        }
        
        guard let pairService = pairAuthRequest(for: domain, extensionID: extensionID) else {
            completion(.failure(.notPairedWithDomain))
            return
        }
        
        guard let serviceData = mainRepository.service(for: pairService.secret) else {
            completion(.failure(.noService))
            return
        }
        
        guard let tokenData = token(for: serviceData).data(using: .utf8),
              let encryptedToken = mainRepository.encryptRSA(data: tokenData, using: pairedExtension.publicKey) else {
            completion(.failure(.encryptionError))
            return
        }
        
        mainRepository.send2FAToken(
            for: deviceID,
            extensionID: extensionID,
            tokenRequestID: tokenRequestID,
            token: encryptedToken.base64EncodedString()
        ) { [weak self] result in
            switch result {
            case .success:
                self?.incrementCounterIfNeeded(for: serviceData)
                self?.mainRepository.updateAuthRequestUsage(for: pairService)
                completion(.success(()))
            case .failure(let err):
                switch err {
                case .noInternet: completion(.failure(.noInternet))
                case .connection: completion(.failure(.serverError))
                }
            }
        }
    }
    
    func browserName(for extensionID: ExtensionID) -> String? {
        guard let pairedExtension = pairedExtension(for: extensionID) else {
            return nil
        }
        return pairedExtension.name
    }
}

private extension NotificationInteractor {
    func incrementCounterIfNeeded(for service: ServiceData) {
        guard service.tokenType == .hotp else { return }
        mainRepository.incrementCounter(for: service.secret)
    }
    
    func pairedExtension(for extensionID: ExtensionID) -> PairedWebExtension? {
        mainRepository.listAllPairedExtensions()
            .first(where: { $0.extensionID == extensionID })
    }
    
    func pairAuthRequest(for domain: String, extensionID: ExtensionID) -> PairedAuthRequest? {
        mainRepository.listAllAuthRequests(for: domain, extensionID: extensionID).first
    }
    
    func token(for service: ServiceData) -> TokenValue {
        mainRepository.token(
            secret: service.secret,
            time: mainRepository.currentDate,
            digits: service.tokenLength,
            period: service.tokenPeriod ?? .defaultValue,
            algorithm: service.algorithm,
            counter: service.counter ?? TokenType.hotpDefaultValue,
            tokenType: service.tokenType
        )
    }
}
