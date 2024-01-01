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
import Storage
import Common
import Data

final class AuthRequestsPresenter {
    weak var flowController: AuthRequestsFlowControlling?
    private let interactor: AuthRequestsModuleInteracting
    
    init(interactor: AuthRequestsModuleInteracting) {
        self.interactor = interactor
        interactor.awaitingRequests = { [weak self] in self?.handleNextRequest() }
    }
}

extension AuthRequestsPresenter {
    func handleRefresh() {
        if let last = interactor.lastSavedNotification() {
            switch last {
            case .refreshList:
                interactor.fetchAuthRequests(authFromAppFor: nil)
            case .authInApp(let tokenRequesID):
                handleAuthorizeFromApp(for: tokenRequesID)
            }
            interactor.clearLastSavedNotification()
        } else {
            interactor.fetchAuthRequests(authFromAppFor: nil)
        }
    }
    
    func handleNextRequest() {
        guard let next = interactor.nextAuth() else { return }
        switch next {
        case .askForAuth(let auth, let pair):
            flowController?.toAskUserForAuthorization(auth: auth, pair: pair)
        case .pairWithService(let auth):
            flowController?.toServiceSelection(auth: auth)
        case .expired:
            flowController?.toAuthorizationFailure(reason: T.Browser.requestExpired)
        case .automatically(let auth, let pair):
            interactor.handleAuth(
                .automatically(auth: auth, pair: pair),
                selectedSecret: nil,
                save: false
            ) { [weak self] result in
                switch result {
                case .success: self?.flowController?.toAuthorizationSuccess()
                case .failure(let error):
                    self?.flowController?.toAuthorizationFailure(reason: error.localizedDescription)
                }
            }
        }
    }
    
    func handleServiceSelection(_ serviceData: ServiceData, auth: WebExtensionAwaitingAuth, save: Bool) {
        interactor.handleAuth(
            .pairWithService(auth: auth),
            selectedSecret: serviceData.secret,
            save: save
        ) { [weak self] result in
            switch result {
            case .success: self?.flowController?.toAuthorizationSuccess()
            case .failure(let error): self?.flowController?.toAuthorizationFailure(reason: error.localizedDescription)
            }
        }
    }
    
    func handleAuthorizeFromApp(for tokenRequestID: String) {
        interactor.clearLastSavedNotification()
        interactor.fetchAuthRequests(authFromAppFor: tokenRequestID)
    }
    
    func handleUserAuthorized(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        interactor.handleAuth(
            .askForAuth(auth: auth, pair: pair),
            selectedSecret: nil,
            save: false
        ) { [weak self] result in
            switch result {
            case .success: self?.flowController?.toAuthorizationSuccess()
            case .failure(let error): self?.flowController?.toAuthorizationFailure(reason: error.localizedDescription)
            }
        }
    }
    
    func handleSkip(for tokenRequestID: String) {
        interactor.skip(tokenRequestID: tokenRequestID)
        handleNextRequest()
    }
    
    func handleClearList() {
        interactor.clearList()
    }
}
