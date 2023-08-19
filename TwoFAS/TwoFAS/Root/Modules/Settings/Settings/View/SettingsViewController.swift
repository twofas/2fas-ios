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

final class SettingsViewController: UIViewController, ContentNavigationControllerHideNavibar {
    var presenter: SettingsPresenter!
    weak var menu: SettingsMenuViewController? {
        didSet {
            if let savedViewPath {
                menu?.presenter.handleNavigateToViewPath(savedViewPath)
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
    
    var isCollapsed: Bool { split.isCollapsed }
    var isInitialConfigRead = false
    
    private var isMenuPositionPending = false
    
    private var savedViewPath: ViewPath.Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationNavi.navigationBar.isTranslucent = false
        contentNavi.navigationBar.isTranslucent = false
        navigationNavi.delegate = self
        
        presenter.viewDidLoad()
        
        setupSplit()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setInitialTrait()
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSize(width: view.frame.size.width)
    }
    
    func showRevealButton() {
        guard let menu else {
            isMenuPositionPending = true
            return
        }
        setMenuPosition()
    }
    
    func hideRevealButton() {
        menu?.navigationItem.leftBarButtonItem = nil
    }
    
    func navigateToView(_ viewPath: ViewPath.Settings?) {
        var vp: ViewPath.Settings = .backup
        if let viewPath {
            vp = viewPath
        } else {
            if isCollapsed {
                navigationNavi.popToRootViewController(animated: true)
                return
            }
        }
        if let menuVC = menu {
            menuVC.presenter.handleNavigateToViewPath(vp)
        } else {
            savedViewPath = vp
        }
    }
    
    var currentView: ViewPath.Settings? {
        menu?.presenter.currentViewPath
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
        var current: UITraitCollection = split.traitCollection
        
        if width < minimumSecondaryColumnWidth {
            Log("SettingsViewController - setting: compact")
            current = UITraitCollection(
                traitsFrom: [traitCollection, UITraitCollection(horizontalSizeClass: .compact)]
            )
        } else {
            Log("SettingsViewController - setting: regular")
            current = UITraitCollection(
                traitsFrom: [traitCollection, UITraitCollection(horizontalSizeClass: .regular)]
            )
        }
        
        guard current != split.traitCollection else { return }
        
        setOverrideTraitCollection(current, forChild: split)
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
    
    private func setInitialTrait() {
        guard traitCollection.horizontalSizeClass != .unspecified, !isInitialConfigRead else { return }
        
        isInitialConfigRead = true
        if traitCollection.horizontalSizeClass == .compact {
            presenter.handleCollapse()
        } else {
            presenter.handleExpansion()
        }
    }
    
    private func setMenuPosition() {
        menu?.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "sidebar.left"),
            style: .plain,
            target: self,
            action: #selector(revealMenu)
        )
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
        
        return proposedDisplayMode
    }
}

final class PrimaryNavigationLayoutFixingSplitViewController: UISplitViewController {
    private var primaryColumnFrameKVOToken: NSKeyValueObservation?
    private var primaryColumnSafeAreaInsetsKVOToken: NSKeyValueObservation?
    private var fixedViewController: UIViewController?
    
    override func setViewController(_ vc: UIViewController?, for column: UISplitViewController.Column) {
        super.setViewController(vc, for: column)
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
