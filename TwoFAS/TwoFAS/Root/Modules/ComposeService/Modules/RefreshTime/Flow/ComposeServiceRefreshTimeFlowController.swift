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

protocol ComposeServiceRefreshTimeFlowControllerParent: AnyObject {
    func didChangeRefreshTime(_ refreshTime: Period)
}

protocol ComposeServiceRefreshTimeFlowControlling: AnyObject {
    func toChangeRefreshTime(_ refreshTime: Period)
}

final class ComposeServiceRefreshTimeFlowController: FlowController {
    private weak var parent: ComposeServiceRefreshTimeFlowControllerParent?
    
    static func push(
        on navigationController: UINavigationController,
        parent: ComposeServiceRefreshTimeFlowControllerParent,
        selectedOption: Period?
    ) {
        let view = ComposeServiceRefreshTimeViewController()
        let flowController = ComposeServiceRefreshTimeFlowController(viewController: view)
        flowController.parent = parent
        let presenter = ComposeServiceRefreshTimePresenter(
            flowController: flowController,
            selectedOption: selectedOption
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension ComposeServiceRefreshTimeFlowController: ComposeServiceRefreshTimeFlowControlling {
    func toChangeRefreshTime(_ refreshTime: Period) {
        parent?.didChangeRefreshTime(refreshTime)
    }
}
