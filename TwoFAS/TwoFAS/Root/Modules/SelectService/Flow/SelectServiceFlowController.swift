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

protocol SelectServiceFlowControllerParent: AnyObject {
    func serviceSelectionDidSelect(_ serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth)
    func serviceSelectionCancelled(for tokenRequestID: String)
}

protocol SelectServiceFlowControlling: AnyObject {
    func toServiceSelection(with serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth)
    func toCancel(for tokenRequestID: String)
}

final class SelectServiceFlowController: FlowController {
    private weak var parent: SelectServiceFlowControllerParent?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: SelectServiceFlowControllerParent,
        authRequest: WebExtensionAwaitingAuth
    ) {
        let view = SelectServiceViewController()
        let flowController = SelectServiceFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.selectServiceModuleInteractor()
        let presenter = SelectServicePresenter(
            flowController: flowController,
            interactor: interactor,
            authRequest: authRequest
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
}

extension SelectServiceFlowController: SelectServiceFlowControlling {
    func toServiceSelection(with serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth) {
        parent?.serviceSelectionDidSelect(serviceData, authRequest: authRequest)
    }
    
    func toCancel(for tokenRequestID: String) {
        parent?.serviceSelectionCancelled(for: tokenRequestID)
    }
}
