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

protocol AddingServiceManuallyFlowControllerParent: AnyObject {
    func addingServiceManuallyToClose(_ serviceData: ServiceData)
    func addingServiceManuallyToCancel()
}

protocol AddingServiceManuallyFlowControlling: AnyObject {
    func toClose(_ serviceData: ServiceData)
    func toClose()
    func toAlgorithmSelection(selectedOption: Algorithm?)
    func toRefreshTimeSelection(selectedOption: Period?)
    func toDigitsSelection(selectedOption: Digits?)
    func toInitialCounterInput(currentValue: Int?)
}

final class AddingServiceManuallyFlowController: FlowController {
    private weak var parent: AddingServiceManuallyFlowControllerParent?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: AddingServiceManuallyFlowControllerParent,
        name: String?
    ) {
        let view = AddingServiceManuallyViewController()
        let flowController = AddingServiceManuallyFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.addingServiceManuallyModuleInteractor()
        
        let presenter = AddingServiceManuallyPresenter(
            flowController: flowController,
            interactor: interactor,
            providedName: name
        )
        view.presenter = presenter
        presenter.view = view
                
        navigationController.setViewControllers([view], animated: true)
    }
}

extension AddingServiceManuallyFlowController {
    var viewController: AddingServiceManuallyViewController { _viewController as! AddingServiceManuallyViewController }
}

extension AddingServiceManuallyFlowController: AddingServiceManuallyFlowControlling {
    func toClose(_ serviceData: ServiceData) {
        parent?.addingServiceManuallyToClose(serviceData)
    }
    
    func toClose() {
        parent?.addingServiceManuallyToCancel()
    }
    
    func toAlgorithmSelection(selectedOption: Algorithm?) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceAlgorithmFlowController.push(
            on: navi,
            parent: self,
            selectedOption: selectedOption
        )
    }
    
    func toRefreshTimeSelection(selectedOption: Period?) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceRefreshTimeFlowController.push(
            on: navi,
            parent: self,
            selectedOption: selectedOption
        )
    }
    
    func toDigitsSelection(selectedOption: Digits?) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceNumberOfDigitsFlowController.push(
            on: navi,
            parent: self,
            selectedOption: selectedOption
        )
    }
    
    func toInitialCounterInput(currentValue: Int?) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceCounterFlowController.push(
            on: navi,
            parent: self,
            currentValue: currentValue
        )
    }
}

extension AddingServiceManuallyFlowController: ComposeServiceNumberOfDigitsFlowControllerParent {
    func didChangeNumberOfDigits(_ digits: Digits) {
        viewController.presenter.handleDigitsSelection(digits)
        viewController.navigationController?.popViewController(animated: true)
    }
}

extension AddingServiceManuallyFlowController: ComposeServiceCounterFlowControllerParent {
    func didChangeCounter(_ counter: Int) {
        viewController.presenter.handleInitialCounter(counter)
        viewController.navigationController?.popViewController(animated: true)
    }
}

extension AddingServiceManuallyFlowController: ComposeServiceAlgorithmFlowControllerParent {
    func didChangeAlgorithm(_ algorithm: Algorithm) {
        viewController.presenter.handleAlgorithmSelection(algorithm)
        viewController.navigationController?.popViewController(animated: true)
    }
}

extension AddingServiceManuallyFlowController: ComposeServiceRefreshTimeFlowControllerParent {
    func didChangeRefreshTime(_ refreshTime: Period) {
        viewController.presenter.handleRefreshTimeSelection(refreshTime)
        viewController.navigationController?.popViewController(animated: true)
    }
}
