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

protocol BrowserExtensionFailureFlowControllerParent: AnyObject {
    func browserExtensionFailureClose()
    func browserExtensionFailurePairing()
}

protocol BrowserExtensionFailureFlowControlling: AnyObject {
    func toClose()
    func toPairing()
    func toSupport()
}

final class BrowserExtensionFailureFlowController: FlowController {
    private weak var parent: BrowserExtensionFailureFlowControllerParent?
    
    static func push(
        in navigationController: UINavigationController,
        parent: BrowserExtensionFailureFlowControllerParent
    ) {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        let flowController = BrowserExtensionFailureFlowController(viewController: hosting)
        flowController.parent = parent

        let presenter = BrowserExtensionFailurePresenter(
            flowController: flowController
        )
        hosting.rootView = AnyView(
            BrowserExtensionPairingFailureView(
                action: presenter.handleAction,
                cancel: presenter.handleCancel,
                contactSupport: presenter.handleContactSupport
            )
        )

        navigationController.pushViewController(hosting, animated: true)
    }
}

extension BrowserExtensionFailureFlowController: BrowserExtensionFailureFlowControlling {
    func toClose() {
        parent?.browserExtensionFailureClose()
    }
    
    func toPairing() {
        parent?.browserExtensionFailurePairing()
    }
    
    func toSupport() {
        UIApplication.shared.open(URL(string: "https://2fas.com/contact")!, options: [:], completionHandler: nil)
    }
}
