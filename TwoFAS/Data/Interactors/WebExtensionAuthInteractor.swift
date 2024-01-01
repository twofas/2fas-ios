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

public struct WebExtensionAwaitingAuth: Equatable {
    public let tokenRequestID: String
    public let domain: String
    public let extensionID: ExtensionID
}

public enum WebExtensionAwaitingAuthError: Error {
    case noInternet
    case serverError
    case notRegistered
}

public enum WebExtensionAuthorizeError: Error {
    case noInternet
    case serverError
    case notRegistered
    case expired
}

public protocol WebExtensionAuthInteracting: AnyObject {
    func listAwaitingAuthRequests(
        completion: @escaping (Result<[WebExtensionAwaitingAuth], WebExtensionAwaitingAuthError>
        ) -> Void
    )
    func pairing(for domain: String, extensionID: ExtensionID) -> PairedAuthRequest?
    func pairings(for secret: String) -> [PairedAuthRequest]
    func delete(pairing: PairedAuthRequest)
    func deleteAll(for secret: String)
    func updateUsage(for pairing: PairedAuthRequest)
    func saveAuthPairing(for domain: String, extensionID: ExtensionID, secret: String)
    func authorize(
        tokenRequestID: String,
        token: String,
        extensionID: ExtensionID,
        completion: @escaping (Result<Void, WebExtensionAuthorizeError>
        ) -> Void
    )
    func addIgnoredTokenRequestIDs(_ id: String)
    func ignoredTokenRequestIDs() -> [String]
}

final class WebExtensionAuthInteractor {
    private let mainRepository: MainRepository
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension WebExtensionAuthInteractor: WebExtensionAuthInteracting {
    func listAwaitingAuthRequests(
        completion: @escaping (Result<[WebExtensionAwaitingAuth], WebExtensionAwaitingAuthError>
        ) -> Void
    ) {
        Log("WebExtensionAuthInteractor - listAwaitingAuthRequests", module: .interactor)
        guard let deviceID = mainRepository.deviceID else {
            Log("WebExtensionAuthInteractor - listAwaitingAuthRequests. Failure - not registered", module: .interactor)
            completion(.failure(.notRegistered))
            return
        }
        
        mainRepository.listAll2FARequests(for: deviceID) { result in
            switch result {
            case .success(let resultData):
                Log("WebExtensionAuthInteractor - listAwaitingAuthRequests. Success", module: .interactor)
                let authRequests = resultData
                    .filter({ $0.status == "pending" })
                    .compactMap({ auth -> WebExtensionAwaitingAuth? in
                        guard let url = URL(string: auth.domain), let host = url.host else { return nil }
                        return WebExtensionAwaitingAuth(
                            tokenRequestID: auth.tokenRequestId,
                            domain: host,
                            extensionID: auth.extensionId
                        )
                    })
                completion(.success(authRequests))
            case .failure(let error):
                Log(
                    "WebExtensionAuthInteractor - listAwaitingAuthRequests. Failure - error: \(error)",
                    module: .interactor
                )
                switch error {
                case .connection: completion(.failure(.serverError))
                case .noInternet: completion(.failure(.noInternet))
                }
            }
        }
    }
    
    func pairing(for domain: String, extensionID: ExtensionID) -> PairedAuthRequest? {
        mainRepository.listAllAuthRequests(for: domain, extensionID: extensionID).first
    }
    
    func pairings(for secret: String) -> [PairedAuthRequest] {
        mainRepository.listAllAuthRequests(for: secret)
    }
    
    func delete(pairing: PairedAuthRequest) {
        Log("WebExtensionAuthInteractor - delete pairing", module: .interactor)
        mainRepository.removeAuthRequest(pairing)
    }
    
    func deleteAll(for secret: String) {
        Log("WebExtensionAuthInteractor - delete all", module: .interactor)
        let auths = pairings(for: secret)
        mainRepository.removeAuthRequests(auths)
    }
    
    func updateUsage(for pairing: PairedAuthRequest) {
        Log("WebExtensionAuthInteractor - updateUsage", module: .interactor)
        mainRepository.updateAuthRequestUsage(for: pairing)
    }
    
    func saveAuthPairing(for domain: String, extensionID: ExtensionID, secret: String) {
        Log(
            "WebExtensionAuthInteractor - saveAuthPairing. Domain: \(domain), extensionID: \(extensionID)",
            module: .interactor
        )
        mainRepository.createAuthRequest(for: secret, extensionID: extensionID, domain: domain)
    }
    
    func authorize(
        tokenRequestID: String,
        token: String,
        extensionID: ExtensionID,
        completion: @escaping (Result<Void, WebExtensionAuthorizeError>) -> Void
    ) {
        Log(
            "WebExtensionAuthInteractor - authorize tokenRequestID, token, extensionID: \(extensionID)",
            module: .interactor
        )
        guard let deviceID = mainRepository.deviceID else {
            Log("WebExtensionAuthInteractor - authorize. Failure - not registered", module: .interactor)
            completion(.failure(.notRegistered))
            return
        }
        
        mainRepository.send2FAToken(
            for: deviceID,
            extensionID: extensionID,
            tokenRequestID: tokenRequestID,
            token: token
        ) { result in
            switch result {
            case .success:
                Log("WebExtensionAuthInteractor - authorize. Success", module: .interactor)
                completion(.success(Void()))
            case .failure(let error):
                Log("WebExtensionAuthInteractor - authorize. Failure - error: \(error)", module: .interactor)
                switch error {
                case .noInternet: completion(.failure(.noInternet))
                case .connection: completion(.failure(.serverError))
                }
            }
        }
    }
    
    func addIgnoredTokenRequestIDs(_ id: String) {
        Log("WebExtensionAuthInteractor - addIgnoredTokenRequestIDs", module: .interactor)
        mainRepository.addIgnoredTokenRequestIDs(id)
    }
    
    func ignoredTokenRequestIDs() -> [String] {
        mainRepository.ignoredTokenRequestIDs()
    }
}
