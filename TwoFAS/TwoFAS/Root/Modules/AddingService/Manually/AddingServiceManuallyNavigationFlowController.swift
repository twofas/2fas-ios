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
import Common

protocol AddingServiceManuallyNavigationFlowControllerParent: AnyObject {
    func addingServiceManuallyToClose(_ serviceData: ServiceData)
    func addingServiceManuallyToCancel()
}

final class AddingServiceManuallyNavigationFlowController: NavigationFlowController {
    private weak var parent: AddingServiceManuallyNavigationFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: AddingServiceManuallyNavigationFlowControllerParent,
        name: String?
    ) {
        let flowController = AddingServiceManuallyNavigationFlowController()
        flowController.parent = parent
        
        let navi = CommonNavigationControllerFlow(flowController: flowController)
        navi.configureAsModal()
        
        flowController.navigationController = navi
        
        AddingServiceManuallyFlowController.showAsRoot(
            in: navi,
            parent: flowController,
            name: name
        )
        
        viewController.present(navi, animated: true, completion: nil)
    }
}

extension AddingServiceManuallyNavigationFlowController: AddingServiceManuallyFlowControllerParent {
    func addingServiceManuallyToClose(_ serviceData: ServiceData) {
        parent?.addingServiceManuallyToClose(serviceData)
    }
    
    func addingServiceManuallyToCancel() {
        parent?.addingServiceManuallyToCancel()
    }
}
