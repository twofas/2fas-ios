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

protocol AppleWatchFlowControllerParent: AnyObject {
    func toBackup()
}

protocol AppleWatchFlowControlling: AnyObject {
    func toSystemWatchApp()
    func toBackup()
}

final class AppleWatchFlowController: FlowController {
    private weak var parent: AppleWatchFlowControllerParent?
    private weak var navigationController: UINavigationController?

    static func push(
        in navigationController: UINavigationController,
        parent: AppleWatchFlowControllerParent
    ) {
        let viewController = AppleWatchViewController()
        let flowController = AppleWatchFlowController(viewController: viewController)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let presenter = AppleWatchPresenter(flowController: flowController)
        viewController.presenter = presenter

        navigationController.pushRootViewController(viewController, animated: true)
    }
}

extension AppleWatchFlowController: AppleWatchFlowControlling {
    func toSystemWatchApp() {
        if let url = URL(string: "itms-watchs://") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func toBackup() {
        parent?.toBackup()
    }
}
