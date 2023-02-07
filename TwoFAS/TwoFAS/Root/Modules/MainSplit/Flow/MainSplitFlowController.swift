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

protocol MainSplitFlowControllerParent: AnyObject {
    func navigationNeedsRestoration()
    func navigatedToViewPath(_ viewPath: ViewPath)
    func navigationTabReady()
    func navigationSwitchToTokens()
}

protocol MainSplitFlowControlling: AnyObject {
     func toInitialConfiguration()
    func toNavigationNeedsRestoration()
}

final class MainSplitFlowController: FlowController {
    private weak var parent: MainSplitFlowControllerParent?
    
    static func showAsRoot(
        in viewController: UIViewController,
        parent: MainSplitFlowControllerParent
    ) {
        let view = MainSplitViewController()
        let flowController = MainSplitFlowController(viewController: view)
        flowController.parent = parent

        let presenter = MainSplitPresenter(
            flowController: flowController
        )
        view.presenter = presenter
        presenter.view = view

        viewController.addChild(view)
        view.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.addSubview(view.view)
        view.didMove(toParent: viewController)
    }
}

extension MainSplitFlowController {
    var viewController: MainSplitViewController { _viewController as! MainSplitViewController }
}

extension MainSplitFlowController: MainSplitFlowControlling {
    func toInitialConfiguration() {
        
        MainTabFlowController.insertAsCompact(into: viewController.split, parent: self)
        MainMenuFlowController.showAsRoot(in: viewController.navigationNavi, parent: self)

        parent?.navigationNeedsRestoration()
    }
    
    func toNavigationNeedsRestoration() {
        parent?.navigationNeedsRestoration()
    }
}

extension MainSplitFlowController: MainTabFlowControllerParent {
    func tabNavigatedToViewPath(_ viewPath: ViewPath) {
        parent?.navigatedToViewPath(viewPath)
    }
    
    func tabReady() {
        parent?.navigationTabReady()
    }
    
    func tabToTokens() {
        parent?.navigationSwitchToTokens()
    }
}

extension MainSplitFlowController: MainMenuFlowControllerParent{
    func mainMenuToMain() {
        parent?.navigatedToViewPath(.main)
        TokensPlainFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
    }
    
    func mainMenuToMainSection(_ sectionOffset: Int) {
        parent?.navigatedToViewPath(.main)
        // TODO: Add navigation to section!
    }
    
    func mainMenuToSettings() {
        parent?.navigatedToViewPath(.settings(option: nil))
        SettingsFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
    }
    
    func mainMenuToNews() {
        parent?.navigatedToViewPath(.news)
        NewsFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
    }
}

extension MainSplitFlowController: TokensPlainFlowControllerParent {
    func tokensSwitchToTokensTab() {
        parent?.navigationSwitchToTokens()
    }
}

extension MainSplitFlowController: SettingsFlowControllerParent {
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?) {
        parent?.navigatedToViewPath(.settings(option: viewPath))
    }
}

extension MainSplitFlowController: NewsFlowControllerParent {}
