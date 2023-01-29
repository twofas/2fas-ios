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

protocol MainTabViewControlling: AnyObject {
    func setView(_ viewPath: ViewPath)
    func scrollToTokensTop()
    func setSettingsView(_ settingsViewPath: ViewPath.Settings?)
    func scrollToNewsTop()
    func preloadNews()
}

final class MainTabViewController: UITabBarController {
    var presenter: MainTabPresenter! {
        didSet {
            presenter.viewDidLoad()
        }
    }
    
    private var tokensVC: TokensViewController? {
        (viewControllers?[safe: ViewPath.main.index] as? UINavigationController)?
            .viewControllers.first as? TokensViewController
    }
    
    private var settingsVC: SettingsViewController? {
        viewControllers?[safe: ViewPath.settings(option: nil).index] as? SettingsViewController
    }
    
    private var newsVC: NewsViewController? {
        (viewControllers?[safe: ViewPath.news.index] as? UINavigationController)?
            .viewControllers.first as? NewsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeStyling()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            changeStyling()
        }
    }
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NotificationBottomOffset.offset = tabBar.frame.height
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            viewControllers?.forEach({ vc in
                vc.willMove(toParent: nil)
            })
        }
        
        super.willMove(toParent: parent)
    }
    
    func changeViewPath(_ viewPath: ViewPath) {
        presenter.handleChangeViewPath(viewPath)
    }
}

extension MainTabViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let viewPath: ViewPath = {
            if selectedIndex == 0 {
                return .main
            } else if selectedIndex == 1 {
                return .settings(option: settingsVC?.currentView)
            }
            return .news
        }()
        presenter.handleDidSelectViewPath(viewPath)
    }
}

extension MainTabViewController: MainTabViewControlling {
    func setView(_ viewPath: ViewPath) {
        selectedIndex = viewPath.index
    }
    
    func scrollToTokensTop() {
        tokensVC?.scrollToTop()
    }
    
    func setSettingsView(_ settingsViewPath: ViewPath.Settings?) {
        // Delay so tab bar will have time to load properly the whole view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.settingsVC?.navigateToView(settingsViewPath)
        }
    }
    
    func scrollToNewsTop() {
        newsVC?.scrollToTop()
    }
    
    func preloadNews() {
        newsVC?.presenter.handleInitialLoad()
    }
}

private extension ViewPath {
    var index: Int {
        switch self {
        case .main: return 0
        case .settings: return 1
        case .news: return 2
        }
    }
}
