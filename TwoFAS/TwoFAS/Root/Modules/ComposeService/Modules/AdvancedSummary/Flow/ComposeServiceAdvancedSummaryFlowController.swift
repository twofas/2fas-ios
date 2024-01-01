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

protocol ComposeServiceAdvancedSummaryFlowControllerParent: AnyObject {
    func advancedSummaryDidFinish()
}

protocol ComposeServiceAdvancedSummaryFlowControlling: AnyObject {}

final class ComposeServiceAdvancedSummaryFlowController: FlowController {
    private weak var parent: ComposeServiceAdvancedSummaryFlowControllerParent?
    
    static func present(
        in navigationController: UINavigationController,
        parent: ComposeServiceAdvancedSummaryFlowControllerParent,
        settings: ComposeServiceAdvancedSettings
    ) {
        let view = ComposeServiceAdvancedSummaryViewController()
        let flowController = ComposeServiceAdvancedSummaryFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory
            .shared
            .composeServiceAdvancedSummaryModuleInteractor(settings: settings)
        let presenter = ComposeServiceAdvancedSummaryPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        
        view.presenter = presenter

        navigationController.pushViewController(view, animated: true)
    }
}

extension ComposeServiceAdvancedSummaryFlowController {
    var viewController: ComposeServiceAdvancedSummaryViewController {
        _viewController as! ComposeServiceAdvancedSummaryViewController
    }
}

extension ComposeServiceAdvancedSummaryFlowController: ComposeServiceAdvancedSummaryFlowControlling {}
