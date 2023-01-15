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

final class NotificationPresenter {
    weak var view: NotificationViewControlling?
    
    private let interactor = NotificationInteractor()
    
    private var domain: String?
    private var extensionID: ExtensionID?
    private var tokenRequestID: String?
    
    func handleReceivedRequest(for domain: String, extensionID: ExtensionID, tokenRequestID: String) {
        interactor.checkReadiness(for: domain, extensionID: extensionID) { [weak self] result in
            switch result {
            case .success:
                self?.domain = domain
                self?.extensionID = extensionID
                self?.tokenRequestID = tokenRequestID
                if self?.interactor.isPINSet == true {
                    self?.view?.displayQuestionForwardToApp(
                        domain: domain,
                        extensionName: self?.interactor.browserName(for: extensionID) ?? ""
                    )
                } else {
                    self?.view?.displayQuestion(
                        domain: domain,
                        extensionName: self?.interactor.browserName(for: extensionID) ?? ""
                    )
                }
            case .failure(let error):
                switch error {
                case .notPairedWithDomain: self?.view?.displayNotPaired()
                case .noServicesExists: self?.view?.displayNoServices()
                default: self?.view?.displayError(.generalProblem)
                }
                print("Error while checking readiness: \(error)")
            }
        }
    }
    
    func handleAuthorization() {
        guard let domain, let extensionID, let tokenRequestID else {
            view?.displayError(.generalProblem)
            return
        }
        view?.showSpinner()
        interactor.send2FAToken(
            for: domain,
            extensionID: extensionID,
            tokenRequestID: tokenRequestID
        ) { [weak self] result in
            self?.view?.hideSpinner()
            switch result {
            case .success: self?.view?.displaySuccess()
            case .failure(let error):
                switch error {
                case .noInternet: self?.view?.displayError(.noInternet)
                default: self?.view?.displayError(.authProblem)
                }
            }
        }
    }
}
