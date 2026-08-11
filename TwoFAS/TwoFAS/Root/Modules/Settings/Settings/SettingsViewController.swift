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

final class SettingsViewController: UIViewController, ContentNavigationControllerHideNavibar {
    var presenter: SettingsPresenter!
    weak var menu: SettingsMenuFlowControllerChild? {
        didSet {
            if let savedViewPath {
                // Launch/restore: only remember the selection. The collapse/expand
                // reconciliation (post-layout) places it — menu root when collapsed,
                // detail column when expanded — so we don't push it here, where the
                // split's collapsed state isn't reliable yet.
                menu?.restoreSelection(savedViewPath)
                self.savedViewPath = nil
            }
            if isMenuPositionPending {
                setMenuPosition()
                isMenuPositionPending = false
            }
        }
    }
    
    private let split = PrimaryNavigationLayoutFixingSplitViewController(style: .doubleColumn)
    
    private let preferredPrimaryColumnWidthFraction: Double = 0.28
    private let minimumPrimaryColumnWidth: Double = 320
    private let maximumPrimaryColumnWidth: Double = 380
    private let minimumSecondaryColumnWidth: Double = 640
    
    let navigationNavi = CommonNavigationController()
    let contentNavi = CommonNavigationController()
    
    private var routingCollapsedOverride: Bool?
    var isCollapsed: Bool { routingCollapsedOverride ?? split.isCollapsed }

    /// Records which layout the content is being routed into for the duration of a
    /// collapse/expand transition, so pushes land in the correct column.
    func beginLayoutTransition(collapsed: Bool) {
        routingCollapsedOverride = collapsed
    }

    private var lastCollapsedState: Bool?

    private var isMenuPositionPending = false
    
    private var savedViewPath: ViewPath.Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #unavailable(iOS 26.0) {
            navigationNavi.navigationBar.isTranslucent = false
            contentNavi.navigationBar.isTranslucent = false
        }
        navigationNavi.delegate = self
        
        presenter.viewDidLoad()
        
        setupSplit()
        
        registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (self: Self, _) in
            self.reconcileForCollapsedStateIfNeeded()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateSize(width: size.width)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(shouldRefresh),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        updateSize(width: view.frame.size.width)
        reconcileForCollapsedStateIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSize(width: view.frame.size.width)
        reconcileForCollapsedStateIfNeeded()
    }

    func showRevealButton() {
        guard menu != nil else {
            isMenuPositionPending = true
            return
        }
        setMenuPosition()
    }
    
    func hideRevealButton() {
        menu?.hideSidebarReveal()
    }
    
    func navigateToView(_ viewPath: ViewPath.Settings?) {
        guard lastCollapsedState != nil, let menuVC = menu else {
            // The split hasn't reconciled its real collapsed state yet
            // (launch/restore, before the first layout). Only remember the target
            // as the selected module; the first collapse/expand reconciliation
            // places it — menu root when collapsed, detail column when expanded.
            if let menu {
                menu.restoreSelection(viewPath)
            } else {
                savedViewPath = viewPath
            }
            return
        }
        if viewPath == nil, isCollapsed {
            navigationNavi.popToRootViewController(animated: true)
            return
        }
        let vp = viewPath ?? .backup
        let force = !isCollapsed && contentNavi.viewControllers.isEmpty
        menuVC.handleNavigateToViewPath(vp, force: force)
    }
    
    var currentView: ViewPath.Settings? {
        menu?.currentViewPath
    }
    
    @objc
    private func revealMenu() {
        presenter.handleRevealMenu()
    }
    
    @objc
    private func shouldRefresh() {
        split.reload()
    }
    
    private func updateSize(width: CGFloat) {
        let newSizeClass: UIUserInterfaceSizeClass = width < minimumSecondaryColumnWidth ? .compact : .regular

        guard newSizeClass != split.traitCollection.horizontalSizeClass else { return }

        split.traitOverrides.horizontalSizeClass = newSizeClass
        split.reload()
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
        split.presentsWithGesture = false
        
        split.setViewController(navigationNavi, for: .primary)
        split.setViewController(contentNavi, for: .secondary)
        split.setViewController(navigationNavi, for: .compact)
    }
    
    /// The settings split decides compact/regular via a width-based trait override
    private func reconcileForCollapsedStateIfNeeded() {
        guard traitCollection.horizontalSizeClass != .unspecified else { return }

        updateNavigationBarVisibility()
        applyLargeTitleIfNeeded()

        let width = view.frame.size.width
        guard width > 0 else { return }

        let collapsed = width < minimumSecondaryColumnWidth
        guard collapsed != lastCollapsedState else { return }
        lastCollapsedState = collapsed

        if collapsed {
            presenter.handleCollapse()
        } else {
            presenter.handleExpansion()
        }
    }
    
    /// Both columns always show their native navigation bar. This is what makes
    /// the native title + back button appear when collapsed to a single column
    /// (or when launching already collapsed); a conditional hide here raced the
    /// split's collapse state and left the bar hidden with no back button.
    private func updateNavigationBarVisibility() {
        navigationNavi.setNavigationBarHidden(false, animated: false)
        contentNavi.setNavigationBarHidden(false, animated: false)
    }

    private func applyLargeTitleIfNeeded() {
        guard #available(iOS 26.0, *) else { return }
        let width = view.frame.size.width
        guard width > 0 else { return }
        let isCompact = width < minimumSecondaryColumnWidth
        navigationNavi.navigationBar.prefersLargeTitles = isCompact
        contentNavi.navigationBar.prefersLargeTitles = isCompact
    }

    private func setMenuPosition() {
        menu?.showSidebarReveal { [weak self] in
            self?.revealMenu()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SettingsViewController: SettingsViewControlling {}

extension SettingsViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        if viewController == navigationController.viewControllers.first {
            presenter.handleShowingRootMenu()
        }
    }
}

extension SettingsViewController: UISplitViewControllerDelegate {
    func splitViewController(
        _ svc: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        // swiftlint:disable line_length
        Log("Settings Split View collapsing into: primary: \(proposedTopColumn == UISplitViewController.Column.primary), secondary: \(proposedTopColumn == UISplitViewController.Column.secondary), compact: \(proposedTopColumn == UISplitViewController.Column.compact)", module: .ui)
        // swiftlint:enable line_length
        presenter.handleCollapse()

        return .primary
    }

    func splitViewController(
        _ svc: UISplitViewController,
        displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode
    ) -> UISplitViewController.DisplayMode {
        Log("Settings Split View expanding into into: \(proposedDisplayMode.rawValue)", module: .ui)

        presenter.handleExpansion()

        return .oneBesideSecondary
    }

    func splitViewController(
        _ svc: UISplitViewController,
        willChangeTo displayMode: UISplitViewController.DisplayMode
    ) {
        // Legacy iOS ≤18 workaround only; iOS 26 relies on native display-mode handling.
        guard #unavailable(iOS 26.0) else { return }
        if !svc.isCollapsed, displayMode != .oneBesideSecondary {
            DispatchQueue.main.async {
                svc.preferredDisplayMode = .oneBesideSecondary
            }
        }
    }
}

final class PrimaryNavigationLayoutFixingSplitViewController: UISplitViewController {
    private var primaryColumnFrameKVOToken: NSKeyValueObservation?
    private var primaryColumnSafeAreaInsetsKVOToken: NSKeyValueObservation?
    private var fixedViewController: UIViewController?
    
    override func setViewController(_ vc: UIViewController?, for column: UISplitViewController.Column) {
        super.setViewController(vc, for: column)
        // The manual safe-area fix-up is a legacy iOS ≤18 workaround; iOS 26 uses
        // the plain split behavior.
        guard #unavailable(iOS 26.0) else { return }
        guard column == .primary, let viewController = vc else { return }

        fixedViewController = viewController
        
        primaryColumnFrameKVOToken = viewController.view.observe(\.frame) { [weak self, weak viewController] _, _ in
            guard let viewController else { return }
            self?.applyCorrectLayoutIfNeeded(toPrimaryColumnViewController: viewController)
        }
        primaryColumnSafeAreaInsetsKVOToken = viewController
            .view
            .observe(\.safeAreaInsets) { [weak self, weak viewController] _, _ in
                guard let viewController, let self else { return }
                self.applyCorrectLayoutIfNeeded(toPrimaryColumnViewController: viewController)
            }
    }
    
    func reload() {
        guard #unavailable(iOS 26.0) else { return }
        guard let vc = fixedViewController else {
            return
        }

        applyCorrectLayoutIfNeeded(toPrimaryColumnViewController: vc)
    }
    
    private func applyCorrectLayoutIfNeeded(
        toPrimaryColumnViewController primaryColumnViewController: UIViewController
    ) {
        guard /*!isCollapsed, */view.bounds.intersects(primaryColumnViewController.view.frame) else {
            // The primary column view controller's view is not visible, so
            // we do not need to make any adjustments.
            return
        }
        
        applyCorrectSafeAreaInsets(to: primaryColumnViewController)
        if let childNavigationController = primaryColumnViewController.children.first as? UINavigationController {
            // Mark the navigation bar as needing layout to ensure that a
            // fresh layout pass occurs, which makes sure that
            // `displayModeButtonItem` is visible.
            childNavigationController.navigationBar.setNeedsLayout()
        }
    }
    
    private func applyCorrectSafeAreaInsets(to viewController: UIViewController) {
        guard
            let correctHorizontalSafeAreaInsets = self.correctHorizontalSafeAreaInsets(
                forPrimaryColumnView: viewController.view
            ) else { return }
        
        if viewController.view.safeAreaInsets.left != correctHorizontalSafeAreaInsets.left {
            viewController.additionalSafeAreaInsets.left = 0
            viewController.additionalSafeAreaInsets.left =
            correctHorizontalSafeAreaInsets.left - viewController.view.safeAreaInsets.left
        } else if viewController.view.safeAreaInsets.right != correctHorizontalSafeAreaInsets.right {
            viewController.additionalSafeAreaInsets.right = 0
            viewController.additionalSafeAreaInsets.right =
            correctHorizontalSafeAreaInsets.right - viewController.view.safeAreaInsets.right
        }
    }
    
    private func correctHorizontalSafeAreaInsets(forPrimaryColumnView primaryColumnView: UIView) -> UIEdgeInsets? {
        let requiredHorizontalSafeAreaInset = primaryColumnView.bounds.width - primaryColumnWidth
        guard requiredHorizontalSafeAreaInset >= 0 else {
            // `primaryColumnWidth` is greater than the primary column view's
            // width. This can occur during expansion of the split view from a
            // collapsed state e.g when the user resizes the app in the iOS
            // multi-tasking Split View. As such, we cannot determine the
            // correct safe area insets, so return `nil` and wait for the next
            // layout pass when the primary column has been sized correctly.
            return nil
        }
        
        // Create the `primaryColumnView` frame in the split view's coordinate
        // space.
        let convertedPrimaryColumnViewFrame = view.convert(primaryColumnView.bounds, from: primaryColumnView)
        
        if convertedPrimaryColumnViewFrame.origin.x < 0 {
            // The primary column view is positioned to the left of the split
            // view, so we need to adjust its left safe area inset to
            // compensate.
            return UIEdgeInsets(top: 0, left: requiredHorizontalSafeAreaInset, bottom: 0, right: 0)
        } else if convertedPrimaryColumnViewFrame.maxX > view.bounds.maxX {
            // The primary column view is positioned to the right of the split
            // view, so we need to adjust its right safe area inset to
            // compensate.
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: requiredHorizontalSafeAreaInset)
        }
        return .zero
    }
}
