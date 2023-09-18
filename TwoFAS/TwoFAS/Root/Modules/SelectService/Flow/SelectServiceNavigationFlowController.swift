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

protocol SelectServiceNavigationFlowControllerParent: AnyObject {
    func serviceSelectionDidSelect(_ serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth, save: Bool)
    func serviceSelectionCancelled(for tokenRequestID: String)
}

final class SelectServiceNavigationFlowController: NavigationFlowController {
    private weak var parent: SelectServiceNavigationFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: SelectServiceNavigationFlowControllerParent,
        authRequest: WebExtensionAwaitingAuth
    ) {
        let flowController = SelectServiceNavigationFlowController()
        flowController.parent = parent

        let navi = CommonNavigationControllerFlow(flowController: flowController)
        navi.configureAsLargeModal()
        
        flowController.navigationController = navi
        
        SelectServiceFlowController.showAsRoot(
            in: navi,
            parent: flowController,
            authRequest: authRequest
        )
        
        viewController.present(navi, animated: true, completion: nil)
    }
}

extension SelectServiceNavigationFlowController: SelectServiceFlowControllerParent {
    func serviceSelectionDidSelect(_ serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth, save: Bool) {
        parent?.serviceSelectionDidSelect(serviceData, authRequest: authRequest, save: save)
    }
    
    func serviceSelectionCancelled(for tokenRequestID: String) {
        parent?.serviceSelectionCancelled(for: tokenRequestID)
    }
}
