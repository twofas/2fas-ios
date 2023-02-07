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

protocol MainTabFlowControllerParent: AnyObject {
    func tabNavigatedToViewPath(_ viewPath: ViewPath)
    func tabReady()
    func tabToTokens()
}

protocol MainTabFlowControlling: AnyObject {
    func toMainChangedViewPath(_ viewPath: ViewPath)
    func toTabIsReady()
}

final class MainTabFlowController: FlowController {
    private weak var parent: MainTabFlowControllerParent?
    
    static func insertAsCompact(
        into split: UISplitViewController,
        parent: MainTabFlowControllerParent
    ) {
        let view = MainTabViewController()
        let flowController = MainTabFlowController(viewController: view)
        flowController.parent = parent
        let presenter = MainTabPresenter(
            flowController: flowController
        )
        view.presenter = presenter
        presenter.view = view

        TokensNavigationFlowController.showAsATab(in: view, parent: flowController)
        SettingsFlowController.showAsATab(in: view, parent: flowController)
        NewsFlowController.showAsATab(in: view, parent: flowController)
        
        split.setViewController(view, for: .compact)
    }
}

extension MainTabFlowController {
    var viewController: MainTabViewController { _viewController as! MainTabViewController }
}

extension MainTabFlowController: MainTabFlowControlling {
    func toMainChangedViewPath(_ viewPath: ViewPath) {
        parent?.tabNavigatedToViewPath(viewPath)
    }
    
    func toTabIsReady() {
        parent?.tabReady()
    }
}

extension MainTabFlowController: TokensNavigationFlowControllerParent {
    func tokensSwitchToTokensTab() {
        parent?.tabToTokens()
    }
}

extension MainTabFlowController: SettingsFlowControllerParent {
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?) {
        parent?.tabNavigatedToViewPath(.settings(option: viewPath))
        viewController.presenter.handleSettingsChangedViewPath(viewPath)
    }
}
extension MainTabFlowController: NewsFlowControllerParent {}
