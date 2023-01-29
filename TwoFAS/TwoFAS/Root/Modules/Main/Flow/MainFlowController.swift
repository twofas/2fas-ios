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

final class MainFlowController: FlowController {
    private var authRequestsFlowController: AuthRequestsFlowControllerChild?
    
    //authRequestsFlowController = AuthRequestsFlowController.create(parent: self)
    
    func toAuthRequestFetch() {
        authRequestsFlowController?.refresh()
    }
    
    func toClearAuthList() {
        authRequestsFlowController?.clearList()
    }
    
    func toAuthorize(for tokenRequestID: String) {
        authRequestsFlowController?.authorizeFromApp(for: tokenRequestID)
    }

    func toSecretSyncError(_ serviceName: String) {
        let alert = AlertControllerDismissFlow(
            title: T.Commons.error,
            message: T.Backup.incorrectSecret(serviceName),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        _viewController.present(alert, animated: true, completion: nil)
    }
    
    func toOpenFileImport(url: URL) {
        ImporterOpenFileFlowController.present(on: _viewController, parent: self, url: url)
    }
}

extension MainFlowController {
    var viewController: MainViewController { _viewController as! MainViewController }
}

extension MainFlowController: ImporterOpenFileFlowControllerParent {
    func closeImporter() {
        viewController.dismiss(animated: true) {
            NotificationCenter.default.post(name: .servicesWereUpdated, object: nil)
        }
    }
}

extension MainFlowController: TokensNavigationFlowControllerParent {
    func tokensSwitchToTokensTab() {
        viewController.presenter.handleSwitchToTokens()
    }
}

extension MainFlowController: SettingsFlowControllerParent {}
extension MainFlowController: NewsFlowControllerParent {}

extension MainFlowController: AuthRequestsFlowControllerParent {
    func authRequestAskUserForAuthorization(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        AskForAuthFlowController.present(on: viewController, parent: self, auth: auth, pair: pair)
    }
    
    func authRequestShowServiceSelection(auth: WebExtensionAwaitingAuth) {
        SelectServiceNavigationFlowController.present(on: viewController, parent: self, authRequest: auth)
    }
}

extension MainFlowController: SelectServiceNavigationFlowControllerParent {
    func serviceSelectionDidSelect(_ serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.didSelectService(serviceData, auth: authRequest)
        }
    }
    
    func serviceSelectionCancelled(for tokenRequestID: String) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.didCancelServiceSelection(for: tokenRequestID)
        }
    }
}

extension MainFlowController: AskForAuthFlowControllerParent {
    func askForAuthAllow(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.authorize(auth: auth, pair: pair)
        }
    }
    
    func askForAuthDeny(tokenRequestID: String) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.skip(for: tokenRequestID)
        }
    }
}


private extension MainFlowController {
    
// //        delegate = self

    
    
//    @objc private func switchToSetupPIN() {
//        mainViewController.selectedIndex = Indexes.settings.rawValue
//        guard
//            let settingsVC = mainViewController.viewControllers?[
//                safe: mainViewController.selectedIndex
//            ] as? SettingsViewController else { return }
//        // Delay so tab bar will have time to load properly the whole view
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            settingsVC.switchToSetupPIN()
//        }
//    }
//
//    @objc private func switchToBrowserExtension() {
//        mainViewController.selectedIndex = Indexes.settings.rawValue
//        guard
//            let settingsVC = mainViewController.viewControllers?[
//                safe: mainViewController.selectedIndex
//            ] as? SettingsViewController else { return }
//        // Delay so tab bar will have time to load properly the whole view
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            settingsVC.switchToBrowserExtension()
//        }
//    }
//
//    private func switchToTokensTab() {
//        mainViewController.selectedIndex = Indexes.main.rawValue
//    }
//
//    private func didSelectOffset(_ offset: Int) {
//        switch offset {
//        case Indexes.main.rawValue:
//            dependency.viewPath.set(.main)
//        case Indexes.settings.rawValue:
//            dependency.viewPath.set(.settings(option: nil))
//        case Indexes.news.rawValue:
//            dependency.viewPath.set(.news)
//        default:
//            assertionFailure("UITabBarController has more options than supported for ViewPath")
//        }
//    }
//
//    private func checkIfViewSwitchIsNecessary() {
//        guard let path = dependency.viewPath.get() else { return }
//        let index: Int
//        switch path {
//        case .main:
//            index = Indexes.main.rawValue
//        case .settings:
//            index = Indexes.settings.rawValue
//        case .news:
//            index = Indexes.news.rawValue
//        }
//        mainViewController.previousSelectedIndex = index
//        mainViewController.selectedIndex = index
//    }
    
    
    
    
//        let tokens = TokensNavigationFlowController.showAsATab(in: mainViewController, parent: self)
//
//        let settingsTab = SettingsFlowController.showAsATab(in: mainViewController, parent: self)
//
//        let newsTab = NewsFlowController.showAsATab(in: mainViewController, parent: self)
//
//        mainViewController.setViewControllers([tokens, settingsTab, newsTab], animated: false)
//        if let newsVC = newsTab.viewControllers.first as? NewsViewController {
//            newsVC.presenter.handleInitialLoad()
//        }
    
//    private func changeStyling() {
//        let app = tabBar.standardAppearance.copy()
//        app.backgroundColor = Theme.Colors.Fill.background
//        app.shadowColor = Theme.Colors.Line.secondaryLine
//        app.shadowImage = Asset.shadowLine.image
//            .resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .tile)
//
//        let tabBarItemAppearance = UITabBarItemAppearance()
//        tabBarItemAppearance.normal.titleTextAttributes = [
//            NSAttributedString.Key.foregroundColor: Theme.Colors.Controls.inactive,
//            NSAttributedString.Key.font: Theme.Fonts.tabBar
//        ]
//        tabBarItemAppearance.selected.titleTextAttributes = [
//            NSAttributedString.Key.foregroundColor: Theme.Colors.Controls.active,
//            NSAttributedString.Key.font: Theme.Fonts.tabBar
//        ]
//        tabBarItemAppearance.focused.titleTextAttributes = [
//            NSAttributedString.Key.foregroundColor: Theme.Colors.Controls.active,
//            NSAttributedString.Key.font: Theme.Fonts.tabBar
//        ]
//
//        tabBarItemAppearance.normal.badgeTextAttributes = [.foregroundColor: Theme.Colors.Fill.theme]
//        tabBarItemAppearance.selected.badgeTextAttributes = [.foregroundColor: Theme.Colors.Fill.theme]
//        tabBarItemAppearance.focused.badgeTextAttributes = [.foregroundColor: Theme.Colors.Fill.theme]
//
//        tabBarItemAppearance.normal.badgeBackgroundColor = .clear
//        tabBarItemAppearance.selected.badgeBackgroundColor = .clear
//        tabBarItemAppearance.focused.badgeBackgroundColor = .clear
//
//        app.compactInlineLayoutAppearance = tabBarItemAppearance
//        app.inlineLayoutAppearance = tabBarItemAppearance
//        app.stackedLayoutAppearance = tabBarItemAppearance
//
//        tabBar.standardAppearance = app
//    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        NotificationBottomOffset.offset = tabBar.frame.height
//    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        changeStyling()
//    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
//        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
//            changeStyling()
//        }
//    }
    
//    extension MainViewController: UITabBarControllerDelegate {
//        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//            //presenter.handleDidSelectTab(...) // add enum for that!, save position
//            if previousSelectedIndex == selectedIndex && selectedIndex == settingsIndex {
//                guard let settings = viewController as? SettingsViewController else { return }
//                settings.navigateToRoot()
//            }
//            if previousSelectedIndex != selectedIndex && selectedIndex == settingsIndex {
//                settingsEventController.tabSelected()
//            }
//            if previousSelectedIndex != selectedIndex && selectedIndex == mainIndex {
//                authRequestsFlowController?.refresh()
//            }
//            previousSelectedIndex = selectedIndex
//        }
//    }
    
//    override func willMove(toParent parent: UIViewController?) {
//        if parent == nil {
//            viewControllers?.forEach({ vc in
//                vc.willMove(toParent: nil)
//            })
//        }
//
//        super.willMove(toParent: parent)
//    }

}
