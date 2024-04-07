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

protocol AppSecurityFlowControllerParent: AnyObject {
    func appSecurityChaged()
}

protocol AppSecurityFlowControlling: AnyObject {
    func toChangeLimit()
    
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
    private weak var navigationController: UINavigationController?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: AppSecurityFlowControllerParent
    ) {
        let view = AppSecurityViewController()
        let flowController = AppSecurityFlowController(viewController: view)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let interactor = ModuleInteractorFactory.shared.appSecurityModuleInteractor()
        let presenter = AppSecurityPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    static func push(
        in navigationController: UINavigationController,
        parent: AppSecurityFlowControllerParent
    ) {
        let view = AppSecurityViewController()
        let flowController = AppSecurityFlowController(viewController: view)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let interactor = ModuleInteractorFactory.shared.appSecurityModuleInteractor()
        let presenter = AppSecurityPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushRootViewController(view, animated: true)
    }
}

extension AppSecurityFlowController: AppSecurityFlowControlling {
    func toChangeLimit() {
        guard let navigationController else { return }
        AppLockFlowController.push(on: navigationController, parent: self)
    }
    
    func toRepeatPassword(with PIN: String, typeOfPIN: PINType, action: PINAction) {
        guard let navi = viewController.presentedViewController as? UINavigationController else { return }
        let newAction: NewPINFlowController.Action = {
            switch action {
            case .create:
                return .create
            case .change:
                return .change
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
        let navi = navigationControllerForModal()
        NewPINFlowController.setRoot(in: navi, parent: self, pinType: pinType, lockNavigation: false)
        viewController.present(navi, animated: true, completion: nil)
    }
    
    func toVerifyPINForDisable() {
        let navi = navigationControllerForModal()
        VerifyPINFlowController.setRoot(on: navi, parent: self, for: .disable)
        viewController.present(navi, animated: true, completion: nil)
    }
    
    func toChangePIN(pinType: PINType) {
        let navi = navigationControllerForModal()
        VerifyPINFlowController.setRoot(on: navi, parent: self, for: .change(currentPINType: pinType))
        viewController.present(navi, animated: true, completion: nil)
    }
    
    func toInitialAuthorization() {
        VerifyPINFlowController.add(to: viewController, parent: self, for: .authorize)
    }
}

extension AppSecurityFlowController {
    var viewController: AppSecurityViewController { _viewController as! AppSecurityViewController }
    
    private func navigationControllerForModal() -> UINavigationController {
        let navi = RootNavigationController()
        navi.configureAsModal()
        return navi
    }
    
    func dismiss() {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension AppSecurityFlowController: AppLockFlowControllerParent {
    func didChangeAppLockValue() {
        viewController.presenter.handleAppLockValueUpdate()
    }
}

extension AppSecurityFlowController: VerifyPINFlowControllerParent {
    func hideVerifyPIN() {
        viewController.presenter.handleDidHidePINVerification()
        dismiss()
    }
    
    func pinVerifiedCorrectly(for action: VerifyPINFlowController.Action) {
        switch action {
        case .disable:
            viewController.presenter.handleDidVerifyPINDisabled()
            parent?.appSecurityChaged()
            dismiss()
        case .change(let currentPINType):
            guard let navi = viewController.presentedViewController as? UINavigationController else { return }
            NewPINFlowController.push(
                on: navi,
                parent: self,
                action: .change,
                step: .first(pinType: currentPINType),
                lockNavigation: false
            )
        case .authorize:
            viewController.presenter.handleInitialAutorization()
            guard let vc = viewController.children.first(where: { $0 is VerifyPINViewController }) else { return }
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
        viewController.presenter.handleNewPINHidden()
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
            case .create:
                return .create
            case .change:
                return .change
            }
        }()
        switch step {
        case .first:
            viewController.presenter.handleFirstPINCreationInput(with: PIN, typeOfPIN: pinType, action: newAction)
        case .second:
            viewController.presenter.handlePINCreationInput(with: PIN, typeOfPIN: pinType)
            parent?.appSecurityChaged()
            dismiss()
        }
    }
}
