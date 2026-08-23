//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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
import Data

final class MainTabFlowController: FlowController {
    private weak var parent: MainSplitFlowControllerParent?
    private weak var tokensViewController: TokensViewController?
    private weak var settingsViewController: SettingsViewController?

    private let viewPathInteractor = InteractorFactory.shared.viewPathInteractor()

    static func showAsRoot(
        in mainViewController: MainViewController,
        parent: MainSplitFlowControllerParent
    ) {
        let container = MainTabSidebarViewController()
        let flowController = MainTabFlowController(viewController: container)
        flowController.parent = parent
        container.flowController = flowController

        let tokens = TokensPlainFlowController.setup(presentationHost: container, parent: flowController)
        let settings = SettingsFlowController.setup(parent: flowController)
        flowController.tokensViewController = tokens
        flowController.settingsViewController = settings

        let tokensNavi = CommonNavigationController(rootViewController: tokens)
        tokensNavi.setNavigationBarHidden(false, animated: false)

        container.configure(tokensNavigationController: tokensNavi, settingsViewController: settings)
        container.onSelect = { [weak flowController] path in
            flowController?.handleSelect(path)
        }
        container.onReselect = { [weak tokens, weak settings] path in
            switch path {
            case .main: tokens?.scrollToTop()
            case .settings: settings?.navigateToView(nil)
            }
        }
        container.onAddService = { [weak tokens] in
            NotificationCenter.default.post(name: .switchToTokens, object: nil)
            tokens?.presenter.handleAddService()
        }

        mainViewController.addChild(container)
        mainViewController.view.addSubview(container.view)
        container.view.pinToParent()
        container.didMove(toParent: mainViewController)
        mainViewController.splitView = container

        let restoredPath = flowController.viewPathInteractor.viewPath() ?? .main
        container.navigateToView(restoredPath, isRestoration: true)
        switch restoredPath {
        case .main: parent.navigationSwitchedToTokens()
        case .settings: parent.navigationSwitchedToSettings()
        }
    }

    private func handleSelect(_ path: ViewPath) {
        viewPathInteractor.setViewPath(path)
        switch path {
        case .main: parent?.navigationSwitchedToTokens()
        case .settings: parent?.navigationSwitchedToSettings()
        }
    }
}

extension MainTabFlowController {
    var viewController: MainTabSidebarViewController { _viewController as! MainTabSidebarViewController }
}

extension MainTabFlowController: TokensPlainFlowControllerParent {
    func tokensSwitchToTokensTab() {
        parent?.navigationSwitchedToTokens()
    }

    func tokensSwitchToSettingsExternalImport() {
        parent?.navigationSwitchedToSettingsExternalImport()
    }

    func tokensSwitchToSettingsBackup() {
        parent?.navigationSwitchedToSettingsBackup()
    }

    func tokensSwitchToSettingsTrash() {
        parent?.navigationSwitchedToSettingsTrash()
    }
}

extension MainTabFlowController: SettingsFlowControllerParent {
    func settingsToUpdateCurrentPosition(_ viewPath: ViewPath.Settings?) {
        viewPathInteractor.setViewPath(.settings(option: viewPath))
    }

    func settingsToRevealMenu() {
        // Not applicable: the sidebar is managed natively by UIKit.
    }
}

final class MainTabSidebarViewController: UITabBarController, MainNavigating {
    // Strong reference: the container owns its coordinator (see showAsRoot).
    var flowController: MainTabFlowController?
    private weak var tokensTab: UITab?
    private weak var settingsTab: UITab?
    private weak var settingsViewController: SettingsViewController?

    private let appState = InteractorFactory.shared.appStateInteractor()
    private let plusButton = UIButton(type: .system)
    private var didPerformInitialActiveNotify = false
    private var shouldFocusSearchOnActivation = true

    private static let transparentPixelImage: UIImage = {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        return renderer.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        .withRenderingMode(.alwaysOriginal)
    }()

    var onSelect: ((ViewPath) -> Void)?
    var onReselect: ((ViewPath) -> Void)?
    var onAddService: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifyAppBecameActive),
            name: .lockScreenIsInactive,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifyAppBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        // Floating glass "+" is an iOS 26 affordance; on iOS 18 the add action
        // lives in the tokens navigation bar (see updateNaviIcons).
        guard #available(iOS 26.0, *) else { return }
        setupPlusButton()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addingServiceVisibilityDidChange),
            name: .addingServiceVisibilityDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeStyling()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard #available(iOS 26.0, *) else { return }
        positionPlusButtonOverSearchSlot()
    }

    /// Branded tab bar appearance for iOS 18. On iOS 26 the Liquid Glass tab bar
    /// provides its own appearance, so this is skipped.
    private func changeStyling() {
        guard #unavailable(iOS 26.0) else { return }

        let app = tabBar.standardAppearance.copy()
        app.backgroundColor = AppColor.backgroundsPrimary.uiColor
        app.shadowColor = AppColor.separatorsOpaque.uiColor
        app.shadowImage = Asset.shadowLine.image
            .withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .tile)

        let tabBarFont = TextStyle.caption2.uiFont(.emphasized)
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: AppColor.labelsTertiary.uiColor,
            NSAttributedString.Key.font: tabBarFont
        ]
        tabBarItemAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: AppColor.accentsBrand.uiColor,
            NSAttributedString.Key.font: tabBarFont
        ]
        tabBarItemAppearance.focused.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: AppColor.accentsBrand.uiColor,
            NSAttributedString.Key.font: tabBarFont
        ]

        tabBarItemAppearance.normal.badgeTextAttributes = [.foregroundColor: AppColor.accentsBrand.uiColor]
        tabBarItemAppearance.selected.badgeTextAttributes = [.foregroundColor: AppColor.accentsBrand.uiColor]
        tabBarItemAppearance.focused.badgeTextAttributes = [.foregroundColor: AppColor.accentsBrand.uiColor]

        tabBarItemAppearance.normal.badgeBackgroundColor = .clear
        tabBarItemAppearance.selected.badgeBackgroundColor = .clear
        tabBarItemAppearance.focused.badgeBackgroundColor = .clear

        app.compactInlineLayoutAppearance = tabBarItemAppearance
        app.inlineLayoutAppearance = tabBarItemAppearance
        app.stackedLayoutAppearance = tabBarItemAppearance

        tabBar.standardAppearance = app
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didPerformInitialActiveNotify {
            didPerformInitialActiveNotify = true
            notifyAppBecameActive()
        }
        guard #available(iOS 26.0, *) else { return }
        // The auxiliary (search) slot gets its real frame asynchronously, after
        // the last layout pass, so poll briefly until it's ready.
        ensurePlusButtonPositioned(attempt: 0)
    }

    private func ensurePlusButtonPositioned(attempt: Int) {
        if positionPlusButtonOverSearchSlot() || attempt >= 20 { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.ensurePlusButtonPositioned(attempt: attempt + 1)
        }
    }

    /// The hidden `UISearchTab` renders in a trailing `_UITabBarAuxiliaryView`
    /// slot. Track that slot's frame and place the "+" exactly over it (1:1),
    /// so it stays correct on iPhone and iPad and moves with the tab bar.
    @discardableResult
    private func positionPlusButtonOverSearchSlot() -> Bool {
        guard tabBar.window != nil,
              let auxiliary = findSubview(in: tabBar, classNameContains: "AuxiliaryView") else {
            return false
        }
        let frameInTabBar = auxiliary.convert(auxiliary.bounds, to: tabBar)
        guard frameInTabBar.width > 0, frameInTabBar.height > 0 else { return false }

        plusButton.frame = frameInTabBar
        plusButton.isHidden = false
        tabBar.bringSubviewToFront(plusButton)

        if let window = view.window {
            appState.savePlusButtonRect(plusButton.convert(plusButton.bounds, to: window))
        }
        return true
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func configure(
        tokensNavigationController: UINavigationController,
        settingsViewController: SettingsViewController
    ) {
        self.settingsViewController = settingsViewController

        let tokensTab = UITab(
            title: T.Commons.tokens,
            image: UIImage(systemName: "lock.badge.clock.fill"),
            identifier: "tokens"
        ) { _ in tokensNavigationController }

        let settingsTab = UITab(
            title: T.Settings.settings,
            image: UIImage(systemName: "gear"),
            identifier: "settings"
        ) { [weak settingsViewController] _ in settingsViewController ?? UIViewController() }

        self.tokensTab = tokensTab
        self.settingsTab = settingsTab

        var allTabs: [UITab] = [tokensTab, settingsTab]
        if #available(iOS 26.0, *) {
            // A disabled, transparent "search" tab reserves a trailing slot; the
            // floating "+" is positioned 1:1 over it, so it lives inside the tab
            // bar and hides together with it.
            let spacerTab = UISearchTab { _ in UIViewController() }
            spacerTab.title = ""
            spacerTab.image = Self.transparentPixelImage
            spacerTab.automaticallyActivatesSearch = false
            spacerTab.isEnabled = false
            allTabs.append(spacerTab)
        }

        tabs = allTabs
        // Plain iOS-style tab bar on every width (no top-level split view).
        mode = .tabBar
        // iPad (iOS 18/26) renders a tab bar at the top by default. Force a
        // compact horizontal size class so the classic bottom tab bar is used
        // everywhere. Token columns are derived from the available width, not the
        // size class, so the grid still fills wide screens.
        traitOverrides.horizontalSizeClass = .compact
        tabBar.tintColor = AppColor.accentsBrand.uiColor
        view.tintColor = AppColor.accentsBrand.uiColor
        delegate = self
    }

    @available(iOS 26.0, *)
    private func setupPlusButton() {
        var config = UIButton.Configuration.prominentGlass()
        config.image = UIImage(systemName: "plus")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 22, weight: .semibold)
        // Brand-tinted glass fill with a contrasting (white) "+" glyph.
        config.baseForegroundColor = .white
        config.baseBackgroundColor = AppColor.accentsBrand.uiColor

        plusButton.configuration = config
        plusButton.tintColor = AppColor.accentsBrand.uiColor
        plusButton.addAction(UIAction { [weak self] _ in
            self?.onAddService?()
        }, for: .touchUpInside)

        // Frame is tracked to the search tab slot in `positionPlusButtonOverSearchSlot`.
        plusButton.translatesAutoresizingMaskIntoConstraints = true
        tabBar.addSubview(plusButton)
        plusButton.isHidden = true

        let isAddingVisible = appState.isAddingServiceVisible
        plusButton.tintColor = isAddingVisible ? AppColor.graysGray3.uiColor : AppColor.accentsBrand.uiColor
        plusButton.isUserInteractionEnabled = !isAddingVisible
    }

    @objc
    private func addingServiceVisibilityDidChange() {
        let disabled = appState.isAddingServiceVisible
        plusButton.isUserInteractionEnabled = !disabled
        UIView.animate(withDuration: 0.35) { [self] in
            plusButton.tintColor = disabled ? AppColor.graysGray3.uiColor : AppColor.accentsBrand.uiColor
        }
    }

    func navigateToView(_ viewPath: ViewPath) {
        navigateToView(viewPath, isRestoration: false)
    }

    func navigateToView(_ viewPath: ViewPath, isRestoration: Bool) {
        switch viewPath {
        case .main:
            if let tokensTab {
                selectedTab = tokensTab
            }
            notifyTokensVisible()
        case .settings(let option):
            if let settingsTab {
                selectedTab = settingsTab
            }
            settingsViewController?.navigateToView(option, isRestoration: isRestoration)
        }
    }

    private func notifyTokensVisible() {
        guard selectedTab === tokensTab else { return }
        // The tokens screen may not be loaded yet; a short delay lets it settle
        // (mirrors the pre-redesign split behavior). The receiver ignores the
        // event while a modal (e.g. the lock screen) is on top.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: .tokensScreenIsVisible, object: nil)
        }
    }

    @objc
    private func appDidEnterBackground() {
        shouldFocusSearchOnActivation = true
    }

    @objc
    private func notifyAppBecameActive() {
        var focusSearch = false
        if !appState.isLockScreenActive {
            focusSearch = shouldFocusSearchOnActivation
            shouldFocusSearchOnActivation = false
        }
        guard selectedTab === tokensTab else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: .tokensScreenIsVisible, object: nil)
            if focusSearch {
                NotificationCenter.default.post(name: .activeSearchShouldFocus, object: nil)
            }
        }
    }
}

extension MainTabSidebarViewController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelectTab selectedTab: UITab,
        previousTab: UITab?
    ) {
        if selectedTab is UISearchTab { return }
        let isReselection = selectedTab === previousTab
        if selectedTab === tokensTab {
            if isReselection {
                onReselect?(.main)
            } else {
                onSelect?(.main)
                notifyTokensVisible()
            }
        } else if selectedTab === settingsTab {
            let path = ViewPath.settings(option: settingsViewController?.currentView)
            if isReselection {
                onReselect?(path)
            } else {
                onSelect?(path)
            }
        }
    }
}
