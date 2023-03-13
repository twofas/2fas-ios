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

protocol BrowserExtensionPairingFlowControllerParent: AnyObject {
    func pairingSuccess()
    func pairingAlreadyPaired()
    func pairingError()
}

protocol BrowserExtensionPairingFlowControlling: AnyObject {
    func toError(_ error: PairingWebExtensionError)
    func toAlreadyPaired()
    func toSuccess()
}

final class BrowserExtensionPairingFlowController: FlowController {
    private weak var parent: BrowserExtensionPairingFlowControllerParent?
    
    static func push(
        in navigationController: UINavigationController,
        parent: BrowserExtensionPairingFlowControllerParent,
        with extensionID: ExtensionID
    ) {
        let view = BrowserExtensionPairingViewController()
        let flowController = BrowserExtensionPairingFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.browserExtensionPairingModuleInteractor(extensionID: extensionID)
        let presenter = BrowserExtensionPairingPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension BrowserExtensionPairingFlowController: BrowserExtensionPairingFlowControlling {
    func toError(_ error: PairingWebExtensionError) {
        // TODO: Pass error!
        parent?.pairingError()
    }
    
    func toAlreadyPaired() {
        parent?.pairingAlreadyPaired()
    }
    
    func toSuccess() {
        parent?.pairingSuccess()
    }
}
