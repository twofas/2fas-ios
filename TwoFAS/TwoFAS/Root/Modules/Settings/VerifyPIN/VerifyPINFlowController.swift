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
import SwiftUI
import Data
import Common

protocol VerifyPINFlowControllerParent: AnyObject {
    func hideVerifyPIN(for action: VerifyPINFlowController.Action)
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
        let hosting = build(parent: parent, action: action)
        navigationController.setViewControllers([hosting], animated: false)
    }

    static func add(
        to viewController: UIViewController,
        parent: VerifyPINFlowControllerParent,
        for action: Action
    ) {
        let hosting = build(parent: parent, action: action)
        hosting.willMove(toParent: viewController)
        viewController.view.addSubview(hosting.view)
        hosting.view.pinToParent()
        viewController.addChild(hosting)
        viewController.becomeFirstResponder()
    }

    static func present(
        on viewController: UIViewController,
        parent: VerifyPINFlowControllerParent
    ) {
        let hosting = build(parent: parent, action: .authorize)
        let navigation = CommonNavigationController(rootViewController: hosting)
        navigation.modalPresentationStyle = .fullScreen
        viewController.present(navigation, animated: true)
    }

    private static func build(parent: VerifyPINFlowControllerParent, action: Action) -> UIViewController {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = VerifyPINFlowController(viewController: hosting)
        flowController.parent = parent
        flowController.action = action
        let interactor = ModuleInteractorFactory.shared.verifyPINModuleInteractor()
        let presenter = VerifyPINPresenter(
            flowController: flowController,
            interactor: interactor
        )
        if case .authorize = action {
            presenter.leadingSymbol = .back
        }
        hosting.rootView = AnyView(VerifyPINView(presenter: presenter))
        return hosting
    }
}

extension VerifyPINFlowController: VerifyPINFlowControlling {
    func toClose() {
        guard let action else { return }
        parent?.hideVerifyPIN(for: action)
    }

    func toPinVerifiedCorrectly() {
        guard let action else { return }
        parent?.pinVerifiedCorrectly(for: action)
    }
}
