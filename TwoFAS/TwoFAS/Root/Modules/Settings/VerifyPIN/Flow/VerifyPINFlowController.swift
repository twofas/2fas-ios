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
import Data
import Common

protocol VerifyPINFlowControllerParent: AnyObject {
    func hideVerifyPIN()
    func pinVerifiedCorrectly(for action: VerifyPINFlowController.Action)
}

protocol VerifyPINFlowControlling: AnyObject {
    func toClose()
    func toPinVerifiedCorrectly()
}

final class VerifyPINFlowController: FlowController {
    enum Action {
        case disable
        case change(currentPINType: PINType)
        case authorize
    }
    
    private var action: Action?
    private weak var parent: VerifyPINFlowControllerParent?
    
    static func setRoot(
        on navigationController: UINavigationController,
        parent: VerifyPINFlowControllerParent,
        for action: Action
    ) {
        let view = VerifyPINViewController()
        let flowController = VerifyPINFlowController(viewController: view)
        flowController.parent = parent
        flowController.action = action
        let interactor = ModuleInteractorFactory.shared.verifyPINModuleInteractor()
        let presenter = VerifyPINPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.keyboard = view

        navigationController.setViewControllers([view], animated: false)
    }
    
    static func add(
        to viewController: UIViewController,
        parent: VerifyPINFlowControllerParent,
        for action: Action
    ) {
        let view = VerifyPINViewController()
        let flowController = VerifyPINFlowController(viewController: view)
        flowController.parent = parent
        flowController.action = action
        let interactor = ModuleInteractorFactory.shared.verifyPINModuleInteractor()
        let presenter = VerifyPINPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.keyboard = view

        view.willMove(toParent: viewController)
        viewController.view.addSubview(view.view)
        view.view.pinToParent()
        viewController.addChild(view)
    }
}

extension VerifyPINFlowController: VerifyPINFlowControlling {
    func toClose() {
        parent?.hideVerifyPIN()
    }
    
    func toPinVerifiedCorrectly() {
        guard let action else { return }
        parent?.pinVerifiedCorrectly(for: action)
    }
}
