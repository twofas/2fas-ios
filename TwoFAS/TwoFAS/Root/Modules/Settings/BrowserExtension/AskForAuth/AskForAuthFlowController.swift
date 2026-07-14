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
import Data

protocol AskForAuthFlowControllerParent: AnyObject {
    func askForAuthAllow(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest)
    func askForAuthDeny(tokenRequestID: String)
}

protocol AskForAuthFlowControlling: AnyObject {
    func toAuth(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest)
    func toCancel(tokenRequestID: String)
}

final class AskForAuthFlowController: FlowController {
    private weak var parent: AskForAuthFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: AskForAuthFlowControllerParent,
        auth: WebExtensionAwaitingAuth,
        pair: PairedAuthRequest
    ) {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        let flowController = AskForAuthFlowController(viewController: hosting)
        flowController.parent = parent
        let presenter = AskForAuthPresenter(
            flowController: flowController,
            auth: auth,
            pair: pair
        )
        hosting.rootView = AnyView(
            AskForAuthView(
                action: presenter.handleAction,
                cancel: presenter.handleCancel,
                domain: presenter.domain
            )
        )
        hosting.configureAsModal()

        viewController.present(hosting, animated: true, completion: nil)
    }
}

extension AskForAuthFlowController: AskForAuthFlowControlling {
    func toAuth(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        parent?.askForAuthAllow(auth: auth, pair: pair)
    }
    
    func toCancel(tokenRequestID: String) {
        parent?.askForAuthDeny(tokenRequestID: tokenRequestID)
    }
}
