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
import Data

protocol UserIconInfoFlowControllerParent: AnyObject {}

protocol UserIconInfoFlowControlling: AnyObject {
    func toSocial()
    func toShare()
}

final class UserIconInfoFlowController: FlowController {
    private weak var parent: UserIconInfoFlowControllerParent?

    static func push(
        on navigationController: UINavigationController,
        parent: UserIconInfoFlowControllerParent
    ) {
        let view = UserIconInfoViewController()
        let flowController = UserIconInfoFlowController(viewController: view)
        flowController.parent = parent
        
        let presenter = UserIconInfoPresenter(
            flowController: flowController
        )
        
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension UserIconInfoFlowController: UserIconInfoFlowControlling {
    func toSocial() {
        UIApplication.shared.open(SocialChannel.discord.url, completionHandler: nil)
    }
    
    func toShare() {
        let vc = ShareActivityController.createWithText(T.Tokens.requestIconProviderMessage)
        _viewController.present(vc, animated: true, completion: nil)
    }
}
