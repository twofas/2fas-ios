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
    
}

final class MainSplitViewController: UIViewController {
    var presenter: MainSplitPresenter!
    
    let split = PrimaryNavigationLayoutFixingSplitViewController(style: .doubleColumn)
    let navigationNavi = CommonNavigationController()
    let contentNavi = CommonNavigationController()
    
    private let preferredPrimaryColumnWidthFraction: Double = 0.26
    private let minimumPrimaryColumnWidth: Double = 260
    private let maximumPrimaryColumnWidth: Double = 300
    
    var isCollapsed: Bool { split.isCollapsed }
    var isInitialConfigRead = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationNavi.navigationBar.isTranslucent = false
        contentNavi.navigationBar.isTranslucent = false
        
        presenter.viewDidLoad()
        
        setupSplit()
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
        setInitialTrait()
    }
    
    func navigateToView(_ viewPath: ViewPath.Settings?) {
        guard let viewPath else {
            if isCollapsed {
                navigationNavi.popToRootViewController(animated: true)
            }
            return
        }
        (navigationNavi.viewControllers.first as? SettingsMenuViewController)?
            .presenter.handleNavigateToViewPath(viewPath)
    }
    
    var currentView: ViewPath.Settings? {
        (navigationNavi.viewControllers.first as? SettingsMenuViewController)?
            .presenter.currentViewPath
    }
    
    @objc
    private func shouldRefresh() {
        split.reload()
    }

    private func setupSplit() {
        split.delegate = self

        addChild(split)
        view.addSubview(split.view)
        split.view.frame = self.view.bounds
        split.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        split.didMove(toParent: self)
        
        split.preferredDisplayMode = .oneOverSecondary
        split.preferredPrimaryColumnWidthFraction = preferredPrimaryColumnWidthFraction
        split.minimumPrimaryColumnWidth = minimumPrimaryColumnWidth
        split.maximumPrimaryColumnWidth = maximumPrimaryColumnWidth
        split.preferredSplitBehavior = .tile
        split.primaryBackgroundStyle = .sidebar
        split.presentsWithGesture = true
        
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainSplitViewController: MainSplitViewControlling {}

//extension MainSplitViewController: UINavigationControllerDelegate {
//    func navigationController(
//        _ navigationController: UINavigationController,
//        didShow viewController: UIViewController,
//        animated: Bool
//    ) {
//    }
//}

extension MainSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(
        _ svc: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column
    ) -> UISplitViewController.Column {
        // swiftlint:disable line_length
        Log("Main Split View collapsing into: primary: \(proposedTopColumn == UISplitViewController.Column.primary), secondary: \(proposedTopColumn == UISplitViewController.Column.secondary), compact: \(proposedTopColumn == UISplitViewController.Column.compact)", module: .ui)
        // swiftlint:enable line_length
        presenter.handleCollapse()
        
        return .primary
    }

    func splitViewController(
        _ svc: UISplitViewController,
        displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode
    ) -> UISplitViewController.DisplayMode {
        Log("Main Split View expanding into into: \(proposedDisplayMode.rawValue)", module: .ui)
        
        presenter.handleExpansion()
        
        return proposedDisplayMode
    }
}
