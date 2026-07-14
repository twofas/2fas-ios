//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
//  Contributed by Grzegorz Machnio. All rights reserved.
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
import SwiftUI

protocol AppleWatchFlowControllerParent: AnyObject {
    func switchToBackup()
}

protocol AppleWatchFlowControlling: AnyObject {
    func toSystemWatchApp()
    func switchToBackup()
    func toBack()
}

final class AppleWatchFlowController: FlowController {
    private weak var parent: AppleWatchFlowControllerParent?
    private weak var navigationController: UINavigationController?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: AppleWatchFlowControllerParent
    ) {
        let hosting = makeHosting(parent: parent, navigationController: navigationController)
        navigationController.setViewControllers([hosting], animated: false)
    }

    static func push(
        in navigationController: UINavigationController,
        parent: AppleWatchFlowControllerParent
    ) {
        let hosting = makeHosting(parent: parent, navigationController: navigationController)
        navigationController.pushRootViewController(hosting, animated: true)
    }

    private static func makeHosting(
        parent: AppleWatchFlowControllerParent,
        navigationController: UINavigationController
    ) -> UIHostingController<AnyView> {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.title = T.Settings.appleWatch
        let flowController = AppleWatchFlowController(viewController: hosting)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let presenter = AppleWatchPresenter(flowController: flowController)
        hosting.rootView = AnyView(AppleWatchView(presenter: presenter))
        return hosting
    }
}

extension AppleWatchFlowController: AppleWatchFlowControlling {
    func toSystemWatchApp() {
        if let url = URL(string: "itms-watchs://") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func switchToBackup() {
        parent?.switchToBackup()
    }

    func toBack() {
        _viewController.navigationController?.popViewController(animated: true)
    }
}
