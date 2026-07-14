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
import SwiftUI
import Common

protocol BrowserExtensionServiceFlowControllerParent: AnyObject {
    func unpairService(with id: String)
}

protocol BrowserExtensionServiceFlowControlling: AnyObject {
    func toUnpairingService(with id: String)
    func close()
}

final class BrowserExtensionServiceFlowController: FlowController {
    private weak var parent: BrowserExtensionServiceFlowControllerParent?

    static func present(
        in navigationController: UINavigationController,
        parent: BrowserExtensionServiceFlowControllerParent,
        name: String,
        date: String,
        id: String
    ) {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = BrowserExtensionServiceFlowController(viewController: hosting)
        flowController.parent = parent
        let presenter = BrowserExtensionServicePresenter(
            flowController: flowController,
            name: name,
            date: date,
            id: id
        )
        hosting.rootView = AnyView(BrowserExtensionServiceView(presenter: presenter))
        navigationController.pushViewController(hosting, animated: true)
    }
}

extension BrowserExtensionServiceFlowController: BrowserExtensionServiceFlowControlling {
    func toUnpairingService(with id: String) {
        parent?.unpairService(with: id)
    }

    func close() {
        _viewController?.navigationController?.popViewController(animated: true)
    }
}
