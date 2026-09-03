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

protocol AppSecurityFlowControllerParent: AnyObject {
    func appSecurityChaged()
}

protocol AppSecurityFlowControlling: AnyObject {
    func toRepeatPassword(with PIN: String, typeOfPIN: PINType, action: AppSecurityFlowController.PINAction)
    func toCreatePIN(pinType: PINType)
    func toVerifyPINForDisable()
    func toChangePIN(pinType: PINType)

    func toInitialAuthorization()
}

final class AppSecurityFlowController: FlowController {
    enum PINAction {
        case create
        case change
    }

    private weak var parent: AppSecurityFlowControllerParent?
    fileprivate weak var presenter: AppSecurityPresenter?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: AppSecurityFlowControllerParent
    ) {
        let (hosting, flowController) = create(parent: parent)
        navigationController.setViewControllers([hosting], animated: false)
        flowController.presenter?.viewDidLoad()
    }

    static func push(
        in navigationController: UINavigationController,
        parent: AppSecurityFlowControllerParent
    ) {
        let (hosting, flowController) = create(parent: parent)
        navigationController.pushRootViewController(hosting, animated: true)
        flowController.presenter?.viewDidLoad()
    }

    private static func create(
        parent: AppSecurityFlowControllerParent
    ) -> (UIViewController, AppSecurityFlowController) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = AppSecurityFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.appSecurityModuleInteractor()
        let presenter = AppSecurityPresenter(
            flowController: flowController,
            interactor: interactor
        )
        flowController.presenter = presenter
        hosting.rootView = AnyView(AppSecurityView(presenter: presenter))
        return (hosting, flowController)
    }
}

extension AppSecurityFlowController: AppSecurityFlowControlling {
    func toRepeatPassword(with PIN: String, typeOfPIN: PINType, action: PINAction) {
        guard let navi = _viewController?.presentedViewController as? UINavigationController else { return }
        let newAction: NewPINFlowController.Action = {
            switch action {
            case .create: return .create
            case .change: return .change
            }
        }()
        NewPINFlowController.push(
            on: navi,
            parent: self,
            action: newAction,
            step: .second(PIN: PIN, pinType: typeOfPIN),
            lockNavigation: false
        )
    }

    func toCreatePIN(pinType: PINType) {
        guard let vc = _viewController else { return }
        let navi = navigationControllerForModal()
        NewPINFlowController.setRoot(in: navi, parent: self, pinType: pinType, lockNavigation: false)
        vc.present(navi, animated: true, completion: nil)
    }

    func toVerifyPINForDisable() {
        guard let vc = _viewController else { return }
        let navi = navigationControllerForModal()
        VerifyPINFlowController.setRoot(on: navi, parent: self, for: .disable)
        vc.present(navi, animated: true, completion: nil)
    }

    func toChangePIN(pinType: PINType) {
        guard let vc = _viewController else { return }
        let navi = navigationControllerForModal()
        VerifyPINFlowController.setRoot(on: navi, parent: self, for: .change(currentPINType: pinType))
        vc.present(navi, animated: true, completion: nil)
    }

    func toInitialAuthorization() {
        guard let vc = _viewController else { return }
        VerifyPINFlowController.add(to: vc, parent: self, for: .authorize)
    }
}

private extension AppSecurityFlowController {
    func navigationControllerForModal() -> UINavigationController {
        let navi = RootNavigationController()
        navi.configureAsModal()
        return navi
    }

    func dismiss() {
        _viewController?.dismiss(animated: true, completion: nil)
    }
}

extension AppSecurityFlowController: VerifyPINFlowControllerParent {
    func hideVerifyPIN(for action: VerifyPINFlowController.Action) {
        presenter?.handleDidHidePINVerification()
        switch action {
        case .disable, .change:
            dismiss()
        case .authorize:
            guard let vc = _viewController?.children.first else { return }
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
            vc.didMove(toParent: nil)
            _viewController?.navigationController?.popViewController(animated: true)
        }
    }

    func pinVerifiedCorrectly(for action: VerifyPINFlowController.Action) {
        switch action {
        case .disable:
            presenter?.handleDidVerifyPINDisabled()
            parent?.appSecurityChaged()
            dismiss()
        case .change(let currentPINType):
            guard let navi = _viewController?.presentedViewController as? UINavigationController else { return }
            NewPINFlowController.push(
                on: navi,
                parent: self,
                action: .change,
                step: .first(pinType: currentPINType),
                lockNavigation: false
            )
        case .authorize:
            presenter?.handleInitialAutorization()
            guard let vc = _viewController?.children.first else { return }
            UIView.animate(
                withDuration: Theme.Animations.Timing.quick,
                delay: 0,
                options: .transitionCrossDissolve,
                animations: { vc.view.alpha = 0 },
                completion: { _ in
                    vc.willMove(toParent: nil)
                    vc.view.removeFromSuperview()
                    vc.removeFromParent()
                    vc.didMove(toParent: nil)
                }
            )
        }
    }
}

extension AppSecurityFlowController: NewPINFlowControllerParent {
    func hideNewPIN() {
        presenter?.handleNewPINHidden()
        dismiss()
    }

    func pinGathered(
        with PIN: String,
        pinType: PINType,
        action: NewPINFlowController.Action,
        step: NewPINFlowController.Step
    ) {
        let newAction: AppSecurityFlowController.PINAction = {
            switch action {
            case .create: return .create
            case .change: return .change
            }
        }()
        switch step {
        case .first:
            presenter?.handleFirstPINCreationInput(with: PIN, typeOfPIN: pinType, action: newAction)
        case .second:
            presenter?.handlePINCreationInput(with: PIN, typeOfPIN: pinType)
            parent?.appSecurityChaged()
            dismiss()
        }
    }
}
