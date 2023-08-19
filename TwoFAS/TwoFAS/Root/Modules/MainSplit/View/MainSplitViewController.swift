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

protocol MainSplitViewControlling: AnyObject {
    func updateTabBarPath(_ viewPath: ViewPath)
    func updateMenuPath(_ viewPath: ViewPath)
    func updateNewsBadge()
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
    var newsViewController: NewsViewController?
    
    var tokensTabNavi: UINavigationController?
    var newsTabNavi: UINavigationController?
    
    var isCollapsed: Bool { split.isCollapsed }
    var isInitialConfigRead = false
    
    private var changingState = false
    private var menu: MainMenuViewController? {
        navigationNavi.viewControllers.first as? MainMenuViewController
    }
    var tabBar: MainTabViewController? {
        split.viewController(for: .compact) as? MainTabViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSplit()
        presenter.viewDidLoad()
        menu?.loadViewIfNeeded()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setInitialTrait()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(shouldRefresh),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
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
        
        split.view.tintColor = Theme.Colors.Fill.theme
        view.tintColor = Theme.Colors.Fill.theme
        view.backgroundColor = .clear
        split.view.backgroundColor = .clear
    }
    
    // swiftlint:disable line_length
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        // swiftlint:enable line_length
        super.willTransition(to: newCollection, with: coordinator)

        updateDisplayMode()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateDisplayMode()
    }
    
    private func setInitialTrait() {
        guard traitCollection.horizontalSizeClass != .unspecified, !isInitialConfigRead else { return }
        
        isInitialConfigRead = true
        if traitCollection.horizontalSizeClass == .compact {
            presenter.handleCollapse()
        } else {
            presenter.handleExpansion()
        }
    }
    
    private func updateDisplayMode() {
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
    
    func updateNewsBadge() {
        tabBar?.presenter.handleUpdateNewsBadge()
        menu?.presenter.handleUpdateNewsBadge()
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
        if displayMode == .secondaryOnly {
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
