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

protocol ComposeServiceWebExtensionFlowControllerParent: AnyObject {
    func webExtensionDidFinish()
}

protocol ComposeServiceWebExtensionFlowControlling: AnyObject {
    func toQuestion(with authRequest: PairedAuthRequest)
    func toFinish()
}

final class ComposeServiceWebExtensionFlowController: FlowController {
    private weak var parent: ComposeServiceWebExtensionFlowControllerParent?
    
    static func present(
        in navigationController: UINavigationController,
        parent: ComposeServiceWebExtensionFlowControllerParent,
        secret: String
    ) {
        let view = ComposeServiceWebExtensionViewController()
        let flowController = ComposeServiceWebExtensionFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.composeServiceWebExtensionModuleInteractor(secret: secret)
        let presenter = ComposeServiceWebExtensionPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        
        view.presenter = presenter

        navigationController.pushViewController(view, animated: true)
    }
}

extension ComposeServiceWebExtensionFlowController {
    var viewController: ComposeServiceWebExtensionViewController {
        _viewController as! ComposeServiceWebExtensionViewController
    }
}

extension ComposeServiceWebExtensionFlowController: ComposeServiceWebExtensionFlowControlling {
    func toQuestion(with authRequest: PairedAuthRequest) {
        let alert = UIAlertController(
            title: T.Browser.deletingExtensionPairingTitle,
            message: T.Browser.deletingExtensionPairingContent(authRequest.domain),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: T.Commons.delete, style: .destructive, handler: { [weak self] _ in
            self?.viewController.presenter.handleDeletition(of: authRequest)
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toFinish() {
        parent?.webExtensionDidFinish()
    }
}
