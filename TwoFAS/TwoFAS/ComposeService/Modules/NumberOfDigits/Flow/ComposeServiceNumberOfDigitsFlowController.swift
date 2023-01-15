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

protocol ComposeServiceNumberOfDigitsFlowControllerParent: AnyObject {
    func didChangeNumberOfDigits(_ digits: Digits)
}

protocol ComposeServiceNumberOfDigitsFlowControlling: AnyObject {
    func toChangeNumberOfDigits(_ digits: Digits)
}

final class ComposeServiceNumberOfDigitsFlowController: FlowController {
    private weak var parent: ComposeServiceNumberOfDigitsFlowControllerParent?
    
    static func push(
        on navigationController: UINavigationController,
        parent: ComposeServiceNumberOfDigitsFlowControllerParent,
        selectedOption: Digits?
    ) {
        let view = ComposeServiceNumberOfDigitsViewController()
        let flowController = ComposeServiceNumberOfDigitsFlowController(viewController: view)
        flowController.parent = parent
        let presenter = ComposeServiceNumberOfDigitsPresenter(
            flowController: flowController,
            selectedOption: selectedOption
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension ComposeServiceNumberOfDigitsFlowController: ComposeServiceNumberOfDigitsFlowControlling {
    func toChangeNumberOfDigits(_ digits: Digits) {
        parent?.didChangeNumberOfDigits(digits)
    }
}
