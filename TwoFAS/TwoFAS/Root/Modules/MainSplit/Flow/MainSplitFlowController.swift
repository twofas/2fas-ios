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
    func navigationSwitchedToTokens()
    func navigationSwitchedToSettings()
    func navigationSwitchedToSettingsExternalImport()
}

protocol MainSplitFlowControlling: AnyObject {
    func toInitialConfiguration()
    func toCompact()
    func toExpanded()
}

final class MainSplitFlowController: FlowController {
    private weak var parent: MainSplitFlowControllerParent?
    
    static func showAsRoot(
        in viewController: MainViewController,
        parent: MainSplitFlowControllerParent
    ) {
        let view = MainSplitViewController()
        let flowController = MainSplitFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = InteractorFactory.shared.mainSplitModuleInteractor()

        let presenter = MainSplitPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view

        viewController.addChild(view)
        view.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.addSubview(view.view)
        view.didMove(toParent: viewController)
        viewController.splitView = view
        
        view.tokensViewController = TokensPlainFlowController
            .setup(mainSplitViewController: view, parent: flowController)
        view.settingsViewController = SettingsFlowController
            .setup(parent: flowController)
        view.newsViewController = NewsPlainFlowController
            .setup(parent: flowController)
    }
}

extension MainSplitFlowController {
    var viewController: MainSplitViewController { _viewController as! MainSplitViewController }
}

extension MainSplitFlowController: MainSplitFlowControlling {
    func toInitialConfiguration() {
        let navi = MainTabFlowController.insertAsCompact(into: viewController.split, parent: self)
        MainMenuFlowController.showAsRoot(in: viewController.navigationNavi, parent: self)
        viewController.tokensTabNavi = navi.tokensNavi
        viewController.newsTabNavi = navi.newsNavi
    }
    
    func toCompact() {
        guard
            let tokensNavi = viewController.tokensTabNavi,
            let newsNavi = viewController.newsTabNavi,
            let tokensViewController = viewController.tokensViewController,
            let settingsViewController = viewController.settingsViewController,
            let newsViewController = viewController.newsViewController
        else { return }
        TokensPlainFlowController.showAsTab(viewController: tokensViewController, in: tokensNavi)
        NewsPlainFlowController.showAsTab(viewController: newsViewController, in: newsNavi)
        viewController.tabBar?.presenter.resetViewPath()
        viewController.tabBar?.setViewControllers([tokensNavi, settingsViewController, newsNavi], animated: false)
    }
    
    func toExpanded() {
        guard
            let tokensNavi = viewController.tokensTabNavi,
            let newsNavi = viewController.newsTabNavi
        else { return }
        tokensNavi.setViewControllers([], animated: false)
        newsNavi.setViewControllers([], animated: false)
        viewController.tabBar?.setViewControllers([tokensNavi, newsNavi], animated: false)
    }
}

extension MainSplitFlowController: MainTabFlowControllerParent {
    func tabNavigatedToViewPath(_ viewPath: ViewPath) {
        viewController.presenter.handlePathWasUpdated(to: viewPath)
    }
    
    func tabReady() {
        viewController.presenter.handleRestoreNavigation()
    }
    
    func tabToTokens() {
        parent?.navigationSwitchedToTokens()
    }
}

extension MainSplitFlowController: MainMenuFlowControllerParent {
    func mainMenuToMain() {
        guard let tokens = viewController.tokensViewController else { return }
        viewController.presenter.handlePathWasUpdated(to: .main)
        guard viewController.contentNavi.viewControllers.first != tokens else { return }

        TokensPlainFlowController.showAsRoot(viewController: tokens, in: viewController.contentNavi)

        parent?.navigationSwitchedToTokens()
    }
    
    func mainMenuToSettings() {
        guard let settings = viewController.settingsViewController else { return }
        
        let settingsPath = viewController.presenter.handleSettingsViewPath()
        viewController.presenter.handlePathWasUpdated(to: .settings(option: settingsPath))
        
        guard viewController.contentNavi.viewControllers.first != settings else {
            settings.navigateToView(settingsPath)
            return
        }
        
        SettingsFlowController.showAsRoot(
            viewController: settings,
            in: viewController.contentNavi,
            navigateToPath: settingsPath
        )
    }
    
    func mainMenuToNews() {
        guard let news = viewController.newsViewController else { return }
        viewController.presenter.handlePathWasUpdated(to: .news)
        guard viewController.contentNavi.viewControllers.first != news else { return }
        
        NewsPlainFlowController.showAsRoot(viewController: news, in: viewController.contentNavi)
    }
    
    func mainMenuIsReady() {
        viewController.presenter.handleRestoreNavigation()
    }
}

extension MainSplitFlowController: TokensPlainFlowControllerParent {
    func tokensSwitchToTokensTab() {
        parent?.navigationSwitchedToTokens()
    }
    
    func tokensSwitchToSettingsExternalImport() {
        parent?.navigationSwitchedToSettingsExternalImport()
    }
}

extension MainSplitFlowController: SettingsFlowControllerParent {
    func settingsToUpdateCurrentPosition(_ viewPath: ViewPath.Settings?) {
        viewController.presenter.handlePathWasUpdated(to: .settings(option: viewPath))
    }
    
    func settingsToRevealMenu() {
        UIView.animate(withDuration: Theme.Animations.Timing.quick) {
            self.viewController.split.preferredDisplayMode = .oneBesideSecondary
        }        
    }
}

extension MainSplitFlowController: NewsPlainFlowControllerParent {}
