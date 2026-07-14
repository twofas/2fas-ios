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

protocol AuthRequestsFlowControllerParent: AnyObject {
    func authRequestShowServiceSelection(auth: WebExtensionAwaitingAuth)
    func authRequestAskUserForAuthorization(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest)
}

protocol AuthRequestsFlowControlling: AnyObject {
    func toAuthorizationSuccess()
    func toAuthorizationFailure(reason: String?)
    func toServiceSelection(auth: WebExtensionAwaitingAuth)
    func toAskUserForAuthorization(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest)
}

protocol AuthRequestsFlowControllerChild: AnyObject {
    func refresh()
    func didCancelServiceSelection(for tokenRequestID: String)
    func didSelectService(_ serviceData: ServiceData, auth: WebExtensionAwaitingAuth, save: Bool)
    func authorizeFromApp(for tokenRequestID: String)
    func authorize(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest)
    func skip(for tokenRequestID: String)
    func clearList()
}

final class AuthRequestsFlowController {
    private weak var parent: AuthRequestsFlowControllerParent?
    private var presenter: AuthRequestsPresenter?
    
    static func create(
        parent: AuthRequestsFlowControllerParent
    ) -> AuthRequestsFlowControllerChild {
        let flowController = AuthRequestsFlowController()
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.authRequestsModuleInteractor()
        let presenter = AuthRequestsPresenter(
            interactor: interactor
        )
        flowController.presenter = presenter
        presenter.flowController = flowController
        
        return flowController
    }
}

extension AuthRequestsFlowController: AuthRequestsFlowControlling {
    func toAuthorizationSuccess() {
        HUDNotification.presentSuccess(title: T.Browser.codeSuccessTitle) { [weak self] in
            self?.presenter?.handleNextRequest()
        }
    }
    
    func toAuthorizationFailure(reason: String?) {
        let err: String = {
            if let reason {
                return " \(reason)"
            }
            return ""
        }()
        HUDNotification.presentFailure(title: T.Browser.codeFailure(err)) { [weak self] in
            self?.presenter?.handleNextRequest()
        }
    }
    
    func toServiceSelection(auth: WebExtensionAwaitingAuth) {
        parent?.authRequestShowServiceSelection(auth: auth)
    }
    
    func toAskUserForAuthorization(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        parent?.authRequestAskUserForAuthorization(auth: auth, pair: pair)
    }
}

extension AuthRequestsFlowController: AuthRequestsFlowControllerChild {
    func refresh() {
        presenter?.handleRefresh()
    }
    
    func didCancelServiceSelection(for tokenRequestID: String) {
        presenter?.handleSkip(for: tokenRequestID)
    }
    
    func didSelectService(_ serviceData: ServiceData, auth: WebExtensionAwaitingAuth, save: Bool) {
        presenter?.handleServiceSelection(serviceData, auth: auth, save: save)
    }
    
    func authorizeFromApp(for tokenRequestID: String) {
        presenter?.handleAuthorizeFromApp(for: tokenRequestID)
    }
    
    func authorize(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        presenter?.handleUserAuthorized(auth: auth, pair: pair)
    }
    
    func skip(for tokenRequestID: String) {
        presenter?.handleSkip(for: tokenRequestID)
    }
    
    func clearList() {
        presenter?.handleClearList()
    }
}
