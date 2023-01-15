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

protocol ComposeServiceAdvancedEditFlowControllerParent: AnyObject {
    func advancedEditDidChange(settings: ComposeServiceAdvancedSettings)
}

protocol ComposeServiceAdvancedEditFlowControlling: AnyObject {
    func toAlgorithm(_ algorithm: Algorithm?)
    func toRefreshTime(_ refreshTime: Period?)
    func toNumberOfDigits(_ numberOfDigits: Digits?)
    func toCounter(_ counter: Int?)
    func toSettingsUpdate(_ settings: ComposeServiceAdvancedSettings)
}

final class ComposeServiceAdvancedEditFlowController: FlowController {
    private weak var parent: ComposeServiceAdvancedEditFlowControllerParent?
    
    static func present(
        in navigationController: UINavigationController,
        parent: ComposeServiceAdvancedEditFlowControllerParent,
        settings: ComposeServiceAdvancedSettings
    ) {
        let view = ComposeServiceAdvancedEditViewController()
        let flowController = ComposeServiceAdvancedEditFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = InteractorFactory.shared.composeServiceAdvancedEditModuleInteractor(settings: settings)
        let presenter = ComposeServiceAdvancedEditPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        
        view.presenter = presenter

        navigationController.pushViewController(view, animated: true)
    }
}

extension ComposeServiceAdvancedEditFlowController {
    var viewController: ComposeServiceAdvancedEditViewController {
        _viewController as! ComposeServiceAdvancedEditViewController
    }
}

extension ComposeServiceAdvancedEditFlowController: ComposeServiceAdvancedEditFlowControlling {
    func toAlgorithm(_ algorithm: Algorithm?) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceAlgorithmFlowController.push(on: navi, parent: self, selectedOption: algorithm)
    }
    
    func toRefreshTime(_ refreshTime: Period?) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceRefreshTimeFlowController.push(on: navi, parent: self, selectedOption: refreshTime)
    }
    
    func toNumberOfDigits(_ numberOfDigits: Digits?) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceNumberOfDigitsFlowController.push(on: navi, parent: self, selectedOption: numberOfDigits)
    }
    
    func toCounter(_ counter: Int?) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceCounterFlowController.push(on: navi, parent: self, currentValue: counter)
    }
    
    func toSettingsUpdate(_ settings: ComposeServiceAdvancedSettings) {
        parent?.advancedEditDidChange(settings: settings)
    }
}

extension ComposeServiceAdvancedEditFlowController: ComposeServiceNumberOfDigitsFlowControllerParent {
    func didChangeNumberOfDigits(_ digits: Digits) {
        viewController.presenter.handleNumberOfDigits(digits)
    }
}

extension ComposeServiceAdvancedEditFlowController: ComposeServiceRefreshTimeFlowControllerParent {
    func didChangeRefreshTime(_ refreshTime: Period) {
        viewController.presenter.handleRefreshTime(refreshTime)
    }
}

extension ComposeServiceAdvancedEditFlowController: ComposeServiceAlgorithmFlowControllerParent {
    func didChangeAlgorithm(_ algorithm: Algorithm) {
        viewController.presenter.handleAlgorithm(algorithm)
    }
}

extension ComposeServiceAdvancedEditFlowController: ComposeServiceCounterFlowControllerParent {
    func didChangeCounter(_ counter: Int) {
        viewController.presenter.handleCounter(counter)
        viewController.navigationController?.popViewController(animated: true)
    }
}
