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

protocol NewPINFlowControllerParent: AnyObject {
    func hideNewPIN()
    func pinGathered(
        with PIN: String,
        pinType: PINType,
        action: NewPINFlowController.Action,
        step: NewPINFlowController.Step
    )
}

protocol NewPINFlowControlling: AnyObject {
    func toClose()
    func toPINGathered(with PIN: String, pinType: PINType)
    func toChangePINType()
}

final class NewPINFlowController: FlowController {
    enum Action {
        case create
        case change
    }
    enum Step {
        case first(pinType: PINType)
        case second(PIN: String, pinType: PINType)
    }
    private var action: Action?
    private var step: Step?
    private weak var parent: NewPINFlowControllerParent?
    
    static func setRoot(
        in navigationController: UINavigationController,
        parent: NewPINFlowControllerParent,
        pinType: PINType,
        lockNavigation: Bool
    ) {
        let view = NewPINViewController()
        let flowController = NewPINFlowController(viewController: view)
        flowController.parent = parent
        flowController.action = .create
        flowController.step = .first(pinType: pinType)
        let interactor = ModuleInteractorFactory.shared.newPINModuleInteractor(lockNavigation: lockNavigation)
        interactor.selectedPINType = pinType
        
        let presenter = NewPINPresenter(
            flowController: flowController,
            interactor: interactor
        )
        
        view.presenter = presenter
        presenter.isSecond = false
        presenter.action = .create
        presenter.keyboard = view
        presenter.view = view

        navigationController.setViewControllers([view], animated: false)
    }
    
    static func push(
        on navigationController: UINavigationController,
        parent: NewPINFlowControllerParent,
        action: Action,
        step: Step,
        lockNavigation: Bool
    ) {
        let view = NewPINViewController()
        let flowController = NewPINFlowController(viewController: view)
        flowController.parent = parent
        flowController.action = action
        flowController.step = step
        
        var isSecond = false
        var selectedPIN: String?
        var selectedPINType: PINType?
        
        if case Step.second(let PIN, let pinType) = step {
            isSecond = true
            selectedPIN = PIN
            selectedPINType = pinType
        } else if case Step.first(let pinType) = step {
            selectedPIN = nil
            selectedPINType = pinType
        }
        
        let interactor = ModuleInteractorFactory.shared.newPINModuleInteractor(lockNavigation: lockNavigation)
        interactor.selectedPIN = selectedPIN
        interactor.selectedPINType = selectedPINType
        
        let presenter = NewPINPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.isSecond = isSecond
        presenter.action = action
        view.presenter = presenter
        presenter.keyboard = view
        presenter.view = view

        navigationController.pushViewController(view, animated: true)
    }
}

extension NewPINFlowController {
    var viewController: NewPINViewController { _viewController as! NewPINViewController }
}

extension NewPINFlowController: NewPINFlowControlling {
    func toClose() {
        parent?.hideNewPIN()
    }
    
    func toPINGathered(with PIN: String, pinType: PINType) {
        guard let action, let step else { return }
        parent?.pinGathered(with: PIN, pinType: pinType, action: action, step: step)
    }
    
    func toChangePINType() {
        let alert = SelectPINLengthController.make(in: viewController.view) { [weak self] pinType in
            self?.viewController.presenter.handleSelectedPINType(pinType)
        }
        viewController.present(alert, animated: true)
    }
}
