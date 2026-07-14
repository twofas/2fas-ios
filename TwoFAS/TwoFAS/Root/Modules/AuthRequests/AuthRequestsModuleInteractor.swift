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
import Data

protocol AuthRequestsModuleInteracting: AnyObject {
    var noAwaitingRequests: Callback? { get set }
    var awaitingRequests: Callback? { get set }
    
    func fetchAuthRequests(authFromAppFor tokenRequestID: String?)
    func nextAuth() -> AuthRequestsModuleInteractorKind?
    func handleAuth(
        _ req: AuthRequestsModuleInteractorKind,
        selectedSecret: String?,
        save: Bool,
        completion: @escaping (Result<Void, AuthRequestsModuleInteractorError>) -> Void
    )
    func skip(tokenRequestID: String)
    
    func lastSavedNotification() -> LastSavedNotification?
    func clearLastSavedNotification()
    
    func clearList()
}

enum AuthRequestsModuleInteractorError: Error {
    case noInternet
    case serverError
    case notPaired
    case tokenError
    case noServiceSelected
}

enum AuthRequestsModuleInteractorKind {
    case askForAuth(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest)
    case automatically(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest)
    case expired
    case pairWithService(auth: WebExtensionAwaitingAuth)
}

final class AuthRequestsModuleInteractor {
    var noAwaitingRequests: Callback?
    var awaitingRequests: Callback?
    
    private let webExtensionAuthInteractor: WebExtensionAuthInteracting
    private let tokenGeneratorInteractor: TokenGeneratorInteracting
    private let pairingWebExtensionInteractor: PairingWebExtensionInteracting
    private let webExtensionEncryptionInteractor: WebExtensionEncryptionInteracting
    private let pushNotificationInteractor: PushNotificationInteracting
    
    private var reqAuths = [AuthRequestsModuleInteractorKind]()
    private var isAuthorizing = false
    
    init(
        webExtensionAuthInteractor: WebExtensionAuthInteracting,
        tokenGeneratorInteractor: TokenGeneratorInteracting,
        pairingWebExtensionInteractor: PairingWebExtensionInteracting,
        webExtensionEncryptionInteractor: WebExtensionEncryptionInteracting,
        pushNotificationInteractor: PushNotificationInteracting
    ) {
        self.webExtensionAuthInteractor = webExtensionAuthInteractor
        self.tokenGeneratorInteractor = tokenGeneratorInteractor
        self.pairingWebExtensionInteractor = pairingWebExtensionInteractor
        self.webExtensionEncryptionInteractor = webExtensionEncryptionInteractor
        self.pushNotificationInteractor = pushNotificationInteractor
    }
}

extension AuthRequestsModuleInteractor: AuthRequestsModuleInteracting {
    func fetchAuthRequests(authFromAppFor tokenRequestID: String?) {
        Log(
            "AuthRequestsModuleInteractor - fetchAuthRequests. isAuthorizing: \(isAuthorizing)",
            module: .moduleInteractor
        )
        guard !isAuthorizing else { return }
        isAuthorizing = true
        webExtensionAuthInteractor.listAwaitingAuthRequests { [weak self] result in
            switch result {
            case .success(let reqs):
                self?.clear()
                self?.sortRequests(reqs, authFromAppFor: tokenRequestID)
            case .failure:
                self?.clear()
                self?.isAuthorizing = false
            }
        }
    }
    
    func nextAuth() -> AuthRequestsModuleInteractorKind? {
        Log("AuthRequestsModuleInteractor - nextAuth", module: .moduleInteractor)
        guard !reqAuths.isEmpty else {
            Log("AuthRequestsModuleInteractor - nextAuth - empty", module: .moduleInteractor)
            isAuthorizing = false
            noAwaitingRequests?()
            return nil
        }
        Log("AuthRequestsModuleInteractor - nextAuth - handling", module: .moduleInteractor)
        return reqAuths.removeFirst()
    }
    
    func skip(tokenRequestID: String) {
        Log("AuthRequestsModuleInteractor - skip", module: .moduleInteractor)
        webExtensionAuthInteractor.addIgnoredTokenRequestIDs(tokenRequestID)
    }
    
    func handleAuth(
        _ req: AuthRequestsModuleInteractorKind,
        selectedSecret: String?,
        save: Bool,
        completion: @escaping (Result<Void, AuthRequestsModuleInteractorError>) -> Void
    ) {
        Log("AuthRequestsModuleInteractor - handleAuth", module: .moduleInteractor)
        switch req {
        case .askForAuth(let auth, let pair), .automatically(let auth, let pair):
            Log("AuthRequestsModuleInteractor - handleAuth - authorize automatically", module: .moduleInteractor)
            authorizeAutomatically(
                with: auth.tokenRequestID,
                secret: pair.secret,
                extensionID: auth.extensionID,
                completion: completion
            )
        case .pairWithService(let auth):
            guard let selectedSecret else {
                Log(
                    "AuthRequestsModuleInteractor - handleAuth - failure. No service selected",
                    module: .moduleInteractor
                )
                completion(.failure(.noServiceSelected))
                return
            }
            Log("AuthRequestsModuleInteractor - handleAuth - authorize manually", module: .moduleInteractor)
            authorizeManually(
                with: auth.tokenRequestID,
                secret: selectedSecret,
                domain: auth.domain,
                extensionID: auth.extensionID,
                save: save,
                completion: completion
            )
        default: break
        }
    }
    
    func lastSavedNotification() -> LastSavedNotification? {
        pushNotificationInteractor.lastSavedNotification()
    }
    
    func clearLastSavedNotification() {
        pushNotificationInteractor.clearLastSavedNotification()
    }
    
    func clearList() {
        reqAuths = []
        isAuthorizing = false
    }
}

private extension AuthRequestsModuleInteractor {
    func sortRequests(_ reqs: [WebExtensionAwaitingAuth], authFromAppFor tokenRequestID: String? = nil) {
        guard !reqs.isEmpty else {
            isAuthorizing = false
            noAwaitingRequests?()
            return
        }
        
        let pairedExtensions = pairingWebExtensionInteractor.listAll().map { $0.extensionID }
        let ignored = webExtensionAuthInteractor.ignoredTokenRequestIDs()
        var filteredResq = reqs.filter { pairedExtensions.contains($0.extensionID) }
            .filter({ !ignored.contains($0.tokenRequestID) })
        
        if let tokenRequestID {
            if let index = filteredResq.firstIndex(where: { $0.tokenRequestID == tokenRequestID }) {
                filteredResq.move(fromOffsets: [index], toOffset: 0)
            } else {
                reqAuths.append(.expired)
                webExtensionAuthInteractor.addIgnoredTokenRequestIDs(tokenRequestID)
            }
        }
        
        filteredResq.forEach { auth in
            if let pair = webExtensionAuthInteractor.pairing(for: auth.domain, extensionID: auth.extensionID) {
                if auth.tokenRequestID == tokenRequestID {
                    reqAuths.append(.automatically(auth: auth, pair: pair))
                } else {
                    reqAuths.append(.askForAuth(auth: auth, pair: pair))
                }
            } else {
                reqAuths.append(.pairWithService(auth: auth))
            }
        }
        
        if reqAuths.isEmpty {
            isAuthorizing = false
            noAwaitingRequests?()
        } else {
            awaitingRequests?()
        }
    }
    
    func clear() {
        Log("AuthRequestsModuleInteractor - clear", module: .moduleInteractor)
        reqAuths.removeAll()
    }
    
    func authorizeAutomatically(
        with tokenRequestID: String,
        secret: String,
        extensionID: ExtensionID,
        completion: @escaping (Result<Void, AuthRequestsModuleInteractorError>) -> Void
    ) {
        Log("AuthRequestsModuleInteractor - authorizeAutomatically", module: .moduleInteractor)
        guard let token = tokenGeneratorInteractor.generateToken(for: secret) else {
            Log(
                "AuthRequestsModuleInteractor - authorizeAutomatically. Failure: token error",
                module: .moduleInteractor
            )
            completion(.failure(.tokenError))
            return
        }
        guard let publicKey = pairingWebExtensionInteractor.extensionData(for: extensionID)?.publicKey,
              let tokenData = token.data(using: .utf8),
              let encryptedToken = webExtensionEncryptionInteractor.encrypt(data: tokenData, publicKey: publicKey)
        else {
            Log(
                "AuthRequestsModuleInteractor - authorizeAutomatically. Failure: not paired",
                module: .moduleInteractor
            )
            completion(.failure(.notPaired))
            return
        }
        
        webExtensionAuthInteractor.authorize(
            tokenRequestID: tokenRequestID,
            token: encryptedToken.base64EncodedString(),
            extensionID: extensionID
        ) { [weak self] result in
            switch result {
            case .success:
                Log(
                    "AuthRequestsModuleInteractor - authorizeAutomatically. Success",
                    module: .moduleInteractor
                )
                self?.webExtensionAuthInteractor.addIgnoredTokenRequestIDs(tokenRequestID)
                completion(.success(Void()))
            case .failure(let error):
                Log(
                    "AuthRequestsModuleInteractor - authorizeAutomatically. Failure. Error: \(error)",
                    module: .moduleInteractor
                )
                switch error {
                case .serverError: completion(.failure(.serverError))
                case .noInternet: completion(.failure(.noInternet))
                default: completion(.failure(.serverError))
                }
            }
        }
    }
    
    func authorizeManually(
        with tokenRequestID: String,
        secret: String,
        domain: String,
        extensionID: ExtensionID,
        save: Bool,
        completion: @escaping (Result<Void, AuthRequestsModuleInteractorError>) -> Void
    ) {
        Log("AuthRequestsModuleInteractor - authorizeManually", module: .moduleInteractor)
        
        if save {
            webExtensionAuthInteractor.saveAuthPairing(for: domain, extensionID: extensionID, secret: secret)
        }
        
        guard let token = tokenGeneratorInteractor.generateToken(for: secret) else {
            completion(.failure(.tokenError))
            Log("AuthRequestsModuleInteractor - authorizeManually. Failure: token error", module: .moduleInteractor)
            return
        }
        
        guard let publicKey = pairingWebExtensionInteractor.extensionData(for: extensionID)?.publicKey,
              let tokenData = token.data(using: .utf8),
              let encryptedToken = webExtensionEncryptionInteractor.encrypt(data: tokenData, publicKey: publicKey)
        else {
            Log("AuthRequestsModuleInteractor - authorizeManually. Failure: not paired", module: .moduleInteractor)
            completion(.failure(.notPaired))
            return
        }
        
        webExtensionAuthInteractor.authorize(
            tokenRequestID: tokenRequestID,
            token: encryptedToken.base64EncodedString(),
            extensionID: extensionID
        ) { [weak self] result in
            switch result {
            case .success:
                Log("AuthRequestsModuleInteractor - authorizeManually. Success", module: .moduleInteractor)
                self?.webExtensionAuthInteractor.addIgnoredTokenRequestIDs(tokenRequestID)
                completion(.success(Void()))
            case .failure(let error):
                Log(
                    "AuthRequestsModuleInteractor - authorizeManually. Failure. Error: \(error)",
                    module: .moduleInteractor
                )
                switch error {
                case .serverError: completion(.failure(.serverError))
                case .noInternet: completion(.failure(.noInternet))
                default: completion(.failure(.serverError))
                }
            }
        }
    }
}
