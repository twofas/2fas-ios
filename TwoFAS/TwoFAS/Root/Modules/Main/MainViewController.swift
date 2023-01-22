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
import Storage
import Common

final class MainViewController: UITabBarController {
    typealias DidSelectOffset = (Int) -> Void
    var didSelectOffset: DidSelectOffset?
    var mainViewIsVisible: Callback?
    
    var previousSelectedIndex: Int = 0
    
    private let mainIndex: Int = 0
    private let settingsIndex: Int = 1
    private let settingsEventController = SettingsEventController()
    
    private var authRequestsFlowController: AuthRequestsFlowControllerChild?
    
    private var authRequestsFetched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        authRequestsFlowController = AuthRequestsFlowController.create(parent: self)
        settingsEventController.setup()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshAuthList),
            name: .pushNotificationRefreshAuthList,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshAuthList),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearAuthList),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authorizeFromApp),
            name: .pushNotificationAuthorizeFromApp,
            object: nil
        )
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewControllers?.forEach({ vc in
                vc.willMove(toParent: nil)
            })
        }
        
        super.willMove(toParent: parent)
    }
    
    // iOS 13.0 has a lot of bugs with Tab Bar styling, especially for Dark Mode.
    // It's necessary to manually refresh shadow image on changing the "mode" and assing
    // a non-template image with proper line colors
    private func changeStyling() {
        let app = tabBar.standardAppearance.copy()
        app.backgroundColor = Theme.Colors.Fill.background
        app.shadowColor = Theme.Colors.Line.secondaryLine
        app.shadowImage = Asset.shadowLine.image
            .resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .tile)
        
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.Colors.Controls.inactive,
            NSAttributedString.Key.font: Theme.Fonts.tabBar
        ]
        tabBarItemAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.Colors.Controls.active,
            NSAttributedString.Key.font: Theme.Fonts.tabBar
        ]
        tabBarItemAppearance.focused.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.Colors.Controls.active,
            NSAttributedString.Key.font: Theme.Fonts.tabBar
        ]
        
        tabBarItemAppearance.normal.badgeTextAttributes = [.foregroundColor: Theme.Colors.Fill.theme]
        tabBarItemAppearance.selected.badgeTextAttributes = [.foregroundColor: Theme.Colors.Fill.theme]
        tabBarItemAppearance.focused.badgeTextAttributes = [.foregroundColor: Theme.Colors.Fill.theme]
        
        tabBarItemAppearance.normal.badgeBackgroundColor = .clear
        tabBarItemAppearance.selected.badgeBackgroundColor = .clear
        tabBarItemAppearance.focused.badgeBackgroundColor = .clear
        
        app.compactInlineLayoutAppearance = tabBarItemAppearance
        app.inlineLayoutAppearance = tabBarItemAppearance
        app.stackedLayoutAppearance = tabBarItemAppearance
        
        tabBar.standardAppearance = app
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeStyling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainViewIsVisible?()
        
        guard !authRequestsFetched else { return }
        authRequestsFetched = true
        authRequestsFlowController?.refresh()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NotificationBottomOffset.offset = tabBar.frame.height
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            changeStyling()
        }
    }
    
    @objc
    private func clearAuthList() {
        authRequestsFlowController?.clearList()
    }
    
    @objc
    private func refreshAuthList() {
        authRequestsFlowController?.refresh()
    }
    
    @objc
    private func authorizeFromApp(notification: Notification) {
        guard let tokenRequestID = notification.userInfo?[
            Notification.pushNotificationAuthorizeFromAppData
        ] as? String else {
            refreshAuthList()
            return
        }
        
        authRequestsFlowController?.authorizeFromApp(for: tokenRequestID)
    }
}

extension MainViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        didSelectOffset?(selectedIndex)
        if previousSelectedIndex == selectedIndex && selectedIndex == settingsIndex {
            guard let settings = viewController as? SettingsViewController else { return }
            settings.navigateToRoot()
        }
        if previousSelectedIndex != selectedIndex && selectedIndex == settingsIndex {
            settingsEventController.tabSelected()
        }
        if previousSelectedIndex != selectedIndex && selectedIndex == mainIndex {
            authRequestsFlowController?.refresh()
        }
        previousSelectedIndex = selectedIndex
    }
}

extension MainViewController: AuthRequestsFlowControllerParent {
    func authRequestAskUserForAuthorization(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        AskForAuthFlowController.present(on: self, parent: self, auth: auth, pair: pair)
    }
    
    func authRequestShowServiceSelection(auth: WebExtensionAwaitingAuth) {
        SelectServiceNavigationFlowController.present(on: self, parent: self, authRequest: auth)
    }
}

extension MainViewController: SelectServiceNavigationFlowControllerParent {
    func serviceSelectionDidSelect(_ serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth) {
        dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.didSelectService(serviceData, auth: authRequest)
        }
    }
    
    func serviceSelectionCancelled(for tokenRequestID: String) {
        dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.didCancelServiceSelection(for: tokenRequestID)
        }
    }
}

extension MainViewController: AskForAuthFlowControllerParent {
    func askForAuthAllow(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.authorize(auth: auth, pair: pair)
        }
    }
    
    func askForAuthDeny(tokenRequestID: String) {
        dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.skip(for: tokenRequestID)
        }
    }
}
