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
import Data

protocol MainSplitViewControlling: AnyObject {
    func updateTabBarPath(_ viewPath: ViewPath)
    func updateMenuPath(_ viewPath: ViewPath)
    func notifyTokensVisible()
}

final class MainSplitViewController: UIViewController {
    var presenter: MainSplitPresenter!
    
    let split = PrimaryNavigationLayoutFixingSplitViewController(style: .doubleColumn)
    let navigationNavi = LargeNavigationController()
    let contentNavi = ContentNavigationController()
    
    private let preferredPrimaryColumnWidthFraction: Double = 0.26
    private let minimumPrimaryColumnWidth: Double = 260
    private let maximumPrimaryColumnWidth: Double = 300
    
    var tokensViewController: TokensViewController?
    var settingsViewController: SettingsViewController?
    
    var tokensTabNavi: UINavigationController?
    
    var isCollapsed: Bool { split.isCollapsed }
    var isInitialConfigRead = false
    
    private var changingState = false
    private var menu: MainMenuViewController? {
        navigationNavi.viewControllers.first as? MainMenuViewController
    }
    var tabBar: MainTabViewController? {
        split.viewController(for: .compact) as? MainTabViewController
    }

    private let smallPlusButton = UIButton(type: .system)
    private static let smallPlusButtonSize: CGFloat = 56
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSplit()
        presenter.viewDidLoad()
        menu?.loadViewIfNeeded()

        registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (self: Self, _) in
            self.setInitialTrait()
        }

        if #available(iOS 26.0, *) {
            setupSmallPlusButton()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(addingServiceVisibilityDidChange),
                name: .addingServiceVisibilityDidChange,
                object: nil
            )
        }
    }

    @available(iOS 26.0, *)
    private func setupSmallPlusButton() {
        var config = UIButton.Configuration.prominentGlass()
        config.image = UIImage(systemName: "plus")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 22, weight: .semibold)

        smallPlusButton.configuration = config
        smallPlusButton.tintColor = AppColor.accentsBrand.uiColor
        smallPlusButton.addAction(UIAction { [weak self] _ in
            self?.handleSmallPlusTapped()
        }, for: .touchUpInside)

        smallPlusButton.translatesAutoresizingMaskIntoConstraints = false
        smallPlusButton.isHidden = true
        view.addSubview(smallPlusButton)

        NSLayoutConstraint.activate([
            smallPlusButton.widthAnchor.constraint(equalToConstant: Self.smallPlusButtonSize),
            smallPlusButton.heightAnchor.constraint(equalToConstant: Self.smallPlusButtonSize),
            smallPlusButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            smallPlusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    @available(iOS 26.0, *)
    private func handleSmallPlusTapped() {
        tokensViewController?.presenter.handleAddService()
    }

    @objc
    private func addingServiceVisibilityDidChange() {
        guard #available(iOS 26.0, *) else { return }
        animateSmallPlusButton(disabled: presenter.isAddingServiceVisible)
    }

    @available(iOS 26.0, *)
    private func animateSmallPlusButton(disabled: Bool) {
        guard !smallPlusButton.isHidden else { return }
        let targetTint: UIColor = disabled ? AppColor.graysGray3.uiColor : AppColor.accentsBrand.uiColor
        smallPlusButton.isUserInteractionEnabled = !disabled
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: { [self] in
                smallPlusButton.tintColor = targetTint
            }
        )
    }

    @available(iOS 26.0, *)
    func updateSmallPlusButtonVisibility() {
        let isTokensRoot = tokensViewController != nil
            && contentNavi.viewControllers.first === tokensViewController
        let shouldShow = traitCollection.horizontalSizeClass != .compact && isTokensRoot
        smallPlusButton.isHidden = !shouldShow
        applyTokensBottomInset(shouldShow: shouldShow)
        if shouldShow {
            let isAddingVisible = presenter.isAddingServiceVisible
            smallPlusButton.tintColor = isAddingVisible ? AppColor.graysGray3.uiColor : AppColor.accentsBrand.uiColor
            smallPlusButton.isUserInteractionEnabled = !isAddingVisible
            view.layoutIfNeeded()
            let rectInWindow = smallPlusButton.convert(smallPlusButton.bounds, to: view.window)
            presenter.savePlusButtonRect(rectInWindow)
        }
    }

    @available(iOS 26.0, *)
    private func applyTokensBottomInset(shouldShow: Bool) {
        guard let tokensVC = tokensViewController else { return }
        let bottomInset: CGFloat = shouldShow ? Self.smallPlusButtonSize + 24 : 0
        if tokensVC.additionalSafeAreaInsets.bottom != bottomInset {
            tokensVC.additionalSafeAreaInsets.bottom = bottomInset
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(shouldRefresh),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(lockScreenIsInactive),
            name: .lockScreenIsInactive,
            object: nil
        )
        setInitialTrait()
        updateDisplayMode()
        presenter.viewWillAppear()
    }
    
    // Called from parent
    func navigateToView(_ viewPath: ViewPath) {
        presenter.handleNavigationUpdate(to: viewPath)
    }
    
    @objc
    private func shouldRefresh() {
        split.reload()
    }
    
    @objc func didBecomeActive() {
        presenter.didBecomeActive()
    }
    
    @objc func lockScreenIsInactive() {
        presenter.handleLockScreenIsInactive()
    }
    
    private func setupSplit() {
        split.delegate = self
        
        addChild(split)
        view.addSubview(split.view)
        split.view.frame = self.view.bounds
        split.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        split.didMove(toParent: self)
        
        split.preferredDisplayMode = .oneBesideSecondary
        split.preferredPrimaryColumnWidthFraction = preferredPrimaryColumnWidthFraction
        split.minimumPrimaryColumnWidth = minimumPrimaryColumnWidth
        split.maximumPrimaryColumnWidth = maximumPrimaryColumnWidth
        split.preferredSplitBehavior = .tile
        split.presentsWithGesture = true
        split.primaryBackgroundStyle = .sidebar
        
        split.setViewController(navigationNavi, for: .primary)
        split.setViewController(contentNavi, for: .secondary)
        
        split.view.tintColor = AppColor.accentsBrand.uiColor
        view.tintColor = AppColor.accentsBrand.uiColor
        view.backgroundColor = .clear
        split.view.backgroundColor = .clear
    }
    
    // swiftlint:disable line_length
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        // swiftlint:enable line_length
        super.willTransition(to: newCollection, with: coordinator)

        if newCollection.horizontalSizeClass != .unspecified {
            presenter.saveInCompact(newCollection.horizontalSizeClass == .compact)
        }

        updateDisplayMode()

        if #available(iOS 26.0, *) {
            coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                self?.updateSmallPlusButtonVisibility()
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateDisplayMode()
    }
    
    private func setInitialTrait() {
        guard traitCollection.horizontalSizeClass != .unspecified, !isInitialConfigRead else { return }

        isInitialConfigRead = true
        let compact = traitCollection.horizontalSizeClass == .compact
        presenter.saveInCompact(compact)
        if compact {
            presenter.handleCollapse()
        } else {
            presenter.handleExpansion()
        }
        if #available(iOS 26.0, *) {
            updateSmallPlusButtonVisibility()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 26.0, *) {
            updateSmallPlusButtonVisibility()
        }
    }
    
    private func updateDisplayMode() {
        if #available(iOS 26.0, *), !isAppNearFullScreen {
            // Split-screen / stage-manager mode on iOS 26: menu only as overlay
            split.preferredSplitBehavior = .overlay
            if presenter.isMenuPortraitOverlayCollapsed {
                guard split.preferredDisplayMode != .secondaryOnly else { return }
                split.preferredDisplayMode = .secondaryOnly
            } else {
                guard split.preferredDisplayMode != .oneOverSecondary else { return }
                split.preferredDisplayMode = .oneOverSecondary
            }
            return
        }

        if UIApplication.isLandscape {
            split.preferredSplitBehavior = .tile

            if presenter.isMenuLandscapeCollapsed {
                guard split.preferredDisplayMode != .secondaryOnly else { return }
                split.preferredDisplayMode = .secondaryOnly
            } else {
                guard split.preferredDisplayMode != .oneBesideSecondary else { return }
                split.preferredDisplayMode = .oneBesideSecondary
            }
        } else {
            split.preferredSplitBehavior = .overlay

            guard
                split.preferredDisplayMode != .oneOverSecondary &&
                split.preferredDisplayMode != .secondaryOnly
            else { return }

            if presenter.isMenuPortraitOverlayCollapsed {
                split.preferredDisplayMode = .secondaryOnly
            } else {
                split.preferredDisplayMode = .oneOverSecondary
            }
        }
    }

    private var isAppNearFullScreen: Bool {
        guard let window = view.window,
              let screenBounds = window.windowScene?.screen.bounds else { return true }
        let widthRatio = window.frame.width / screenBounds.width
        return widthRatio > 0.85
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainSplitViewController: MainSplitViewControlling {
    func updateTabBarPath(_ viewPath: ViewPath) {
        tabBar?.presenter.handleChangeViewPath(viewPath)
    }
    
    func updateMenuPath(_ viewPath: ViewPath) {
        menu?.presenter.handleChangeViewPath(viewPath)
    }
    
    func notifyTokensVisible() {
        // Highly possible that Tokens screen isn't loaded yet. Let's schedule a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: .tokensScreenIsVisible, object: nil)
        }
    }
}

extension MainSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(
        _ svc: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        // swiftlint:disable line_length
        Log("Main Split View collapsing into: primary: \(proposedTopColumn == UISplitViewController.Column.primary), secondary: \(proposedTopColumn == UISplitViewController.Column.secondary), compact: \(proposedTopColumn == UISplitViewController.Column.compact)", module: .ui)
        // swiftlint:enable line_length
        presenter.handleCollapse()
        
        return .compact
    }
    
    func splitViewController(
        _ svc: UISplitViewController,
        displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode
    ) -> UISplitViewController.DisplayMode {
        Log("Main Split View expanding into into: \(proposedDisplayMode.rawValue)", module: .ui)
        
        presenter.handleExpansion()
        
        return proposedDisplayMode
    }
    
    func splitViewController(
        _ svc: UISplitViewController,
        willChangeTo displayMode: UISplitViewController.DisplayMode
    ) {
        if displayMode == .secondaryOnly && UIDevice.isiPad {
            settingsViewController?.showRevealButton()
        } else {
            settingsViewController?.hideRevealButton()
        }
        
        if UIApplication.isLandscape {
            if displayMode == .secondaryOnly {
                presenter.handleLandscapeMenuCollapsed(true)
            } else if displayMode == .oneBesideSecondary {
                presenter.handleLandscapeMenuCollapsed(false)
            }
        }
        
        guard !UIApplication.isLandscape else { return }
        if svc.displayMode == .oneOverSecondary && displayMode == .secondaryOnly {
            presenter.handlePortraitMenuOverlayCollapsed(true)
        } else if svc.displayMode == .secondaryOnly && displayMode == .oneOverSecondary {
            presenter.handlePortraitMenuOverlayCollapsed(false)
        }
    }
}
