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
import Data

protocol MainTabViewControlling: AnyObject {
    func setView(_ viewPath: ViewPath)
    func scrollToTokensTop()
    func setSettingsView(_ settingsViewPath: ViewPath.Settings?)
}

final class MainTabViewController: UITabBarController {
    var presenter: MainTabPresenter!
    weak var tokensNavi: UINavigationController?
    weak var settingsView: SettingsViewController?
    private let settingsContainer = UIViewController()
    
    private var internalTabs: [UITab] = []

    private static let transparentPixelImage: UIImage = {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        return renderer.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        .withRenderingMode(.alwaysOriginal)
    }()

    private let plusButton = UIButton(type: .system)
    private var plusButtonCenterXConstraint: NSLayoutConstraint?
    private var plusButtonCenterYConstraint: NSLayoutConstraint?
    private var plusButtonWidthConstraint: NSLayoutConstraint?
    private var plusButtonHeightConstraint: NSLayoutConstraint?

    private var didSetupTabs = false

    private var tokensVC: TokensViewController? {
        (tabs[safe: ViewPath.main.index]?.viewController as? UINavigationController)?
            .viewControllers.first as? TokensViewController
    }

    private var settingsVC: SettingsViewController? {
        settingsView
    }

    func attachSettings(_ settings: SettingsViewController) {
        settingsView = settings
        guard settings.parent !== settingsContainer else { return }
        if settings.parent != nil {
            settings.willMove(toParent: nil)
            settings.view.removeFromSuperview()
            settings.removeFromParent()
        }
        settingsContainer.addChild(settings)
        settings.view.frame = settingsContainer.view.bounds
        settings.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        settingsContainer.view.addSubview(settings.view)
        settings.didMove(toParent: settingsContainer)
    }

    func detachSettings() {
        guard let settings = settingsView, settings.parent === settingsContainer else { return }
        settings.willMove(toParent: nil)
        settings.view.removeFromSuperview()
        settings.removeFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            self.changeStyling()
        }

        delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addingServiceVisibilityDidChange),
            name: .addingServiceVisibilityDidChange,
            object: nil
        )
    }

    @objc
    private func addingServiceVisibilityDidChange() {
        guard #available(iOS 26.0, *) else { return }
        animatePlusButton(disabled: presenter.isAddingServiceVisible)
    }

    @available(iOS 26.0, *)
    private func animatePlusButton(disabled: Bool) {
        let targetTint: UIColor = disabled ? .systemGray3 : .systemRed
        plusButton.isUserInteractionEnabled = !disabled
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: { [self] in
                plusButton.tintColor = targetTint
            }
        )
    }
    
    func setup() {
        guard !didSetupTabs else { return }
        didSetupTabs = true

        let tokensTab = UITab(
            title: T.Commons.tokens,
            image: UIImage(systemName: "lock.badge.clock.fill"),
            identifier: "tokens"
        ) { [weak self] _ in
            self?.tokensNavi ?? UIViewController()
        }

        let settingsTab = UITab(
            title: T.Settings.settings,
            image: UIImage(systemName: "gear"),
            identifier: "settings"
        ) { [weak self] _ in
            self?.settingsContainer ?? UIViewController()
        }

        if #available(iOS 26.0, *) {
            let spacerTab = UISearchTab { _ in UIViewController() }
            spacerTab.title = ""
            spacerTab.image = Self.transparentPixelImage
            spacerTab.automaticallyActivatesSearch = false
            spacerTab.isEnabled = false
            internalTabs = [tokensTab, settingsTab, spacerTab]
        } else {
            internalTabs = [tokensTab, settingsTab]
        }
        tabs = internalTabs

        tabBar.tintColor = .systemRed

        if #available(iOS 26.0, *) {
            setupPlusButton()
        }
    }

    @available(iOS 26.0, *)
    private func setupPlusButton() {
        var config = UIButton.Configuration.prominentGlass()
        config.image = UIImage(systemName: "plus")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 22, weight: .semibold)

        plusButton.configuration = config
        plusButton.tintColor = .systemRed
        plusButton.addAction(UIAction { [weak self] _ in
            self?.handleAddTabTapped()
        }, for: .touchUpInside)

        plusButton.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(plusButton)

        let centerX = plusButton.centerXAnchor.constraint(equalTo: tabBar.leadingAnchor)
        let centerY = plusButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor)
        let width = plusButton.widthAnchor.constraint(equalToConstant: 56)
        let height = plusButton.heightAnchor.constraint(equalToConstant: 56)
        plusButtonCenterXConstraint = centerX
        plusButtonCenterYConstraint = centerY
        plusButtonWidthConstraint = width
        plusButtonHeightConstraint = height

        NSLayoutConstraint.activate([width, height, centerX, centerY])

        plusButton.isHidden = true
    }

    @available(iOS 26.0, *)
    private func alignPlusButtonToSpacerTab() {
        guard tabBar.window != nil,
              let auxiliary = findSubview(in: tabBar, classNameContains: "AuxiliaryView") else {
            plusButton.isHidden = true
            return
        }
        let target = findSubview(in: auxiliary, classNameContains: "TabButton") ?? auxiliary
        let frameInTabBar = target.convert(target.bounds, to: tabBar)
        guard frameInTabBar.width > 0, frameInTabBar.height > 0 else {
            plusButton.isHidden = true
            return
        }
        plusButtonCenterXConstraint?.constant = frameInTabBar.midX
        plusButtonCenterYConstraint?.constant = frameInTabBar.midY
        plusButtonWidthConstraint?.constant = frameInTabBar.width
        plusButtonHeightConstraint?.constant = frameInTabBar.height

        tabBar.bringSubviewToFront(plusButton)
        tabBar.layoutIfNeeded()

        if plusButton.isHidden {
            let isAddingVisible = presenter.isAddingServiceVisible
            plusButton.tintColor = isAddingVisible ? .systemGray3 : .systemRed
            plusButton.isUserInteractionEnabled = !isAddingVisible
            plusButton.isHidden = false
        }

        if let window = view.window {
            let rectInWindow = plusButton.convert(plusButton.bounds, to: window)
            presenter.savePlusButtonRect(rectInWindow)
        }
    }

    private func findSubview(in root: UIView, classNameContains needle: String) -> UIView? {
        for sub in root.subviews {
            if String(describing: type(of: sub)).contains(needle) {
                return sub
            }
            if let match = findSubview(in: sub, classNameContains: needle) {
                return match
            }
        }
        return nil
    }

    private func handleAddTabTapped() {
        presenter.handleAddService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        
        changeStyling()
    }
    
    private func changeStyling() {
        guard #unavailable(iOS 26.0) else { return }

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

        if #available(iOS 26.0, *) {
            alignPlusButtonToSpacerTab()
        } else {
            NotificationBottomOffset.offset = tabBar.frame.height
        }
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
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelectTab selectedTab: UITab,
        previousTab: UITab?
    ) {
        if #available(iOS 26.0, *), selectedTab is UISearchTab {
            return
        }
        let viewPath: ViewPath = {
            if #available(iOS 26.0, *) {
                if selectedTab === internalTabs.first {
                    return .main
                }
                return .settings(option: settingsVC?.currentView)
            } else {
                if selectedIndex == 0 {
                    return .main
                }
                return .settings(option: settingsVC?.currentView)
            }
        }()
        presenter.handleDidSelectViewPath(viewPath)
    }
//    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        if #available(iOS 26.0, *), selectedTab is UISearchTab {
//            return
//        }
//        let viewPath: ViewPath = {
//            if #available(iOS 26.0, *) {
//                if let selected = selectedTab, selected === internalTabs.first {
//                    return .main
//                }
//                return .settings(option: settingsVC?.currentView)
//            } else {
//                if selectedIndex == 0 {
//                    return .main
//                }
//                return .settings(option: settingsVC?.currentView)
//            }
//        }()
//        presenter.handleDidSelectViewPath(viewPath)
//    }
}

extension MainTabViewController: MainTabViewControlling {
    func setView(_ viewPath: ViewPath) {
        if #available(iOS 26.0, *), internalTabs.indices.contains(viewPath.index) {
            let tab = internalTabs[viewPath.index]
            selectedTab = tab
            DispatchQueue.main.async { [weak self] in
                self?.selectedTab = tab
            }
        } else {
            selectedIndex = viewPath.index
        }
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
}

private extension ViewPath {
    var index: Int {
        switch self {
        case .main: return 0
        case .settings: return 1
        }
    }
}
