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

protocol ComposeServiceNavigationFlowControllerParent: AnyObject {
    func composeServiceDidFinish()
    func composeServiceWasCreated(serviceData: ServiceData)
    func composeServiceServiceWasModified()
    func composeServiceServiceWasDeleted()
}

protocol ComposeServiceNavigationFlowControlling: AnyObject {
    func toClose()
}

final class ComposeServiceNavigationFlowController: NavigationFlowController {
    private weak var parent: ComposeServiceNavigationFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: ComposeServiceNavigationFlowControllerParent,
        serviceData: ServiceData?,
        gotoIconEdit: Bool,
        freshlyAdded: Bool
    ) {
        let flowController = ComposeServiceNavigationFlowController()
        flowController.parent = parent

        let navi = CommonNavigationControllerFlow(flowController: flowController)
        navi.configureAsLargeModal()
        
        flowController.navigationController = navi
        
        ComposeServiceFlowController.present(
            in: navi,
            parent: flowController,
            serviceData: serviceData,
            gotoIconEdit: gotoIconEdit,
            freshlyAdded: freshlyAdded
        )
        
        viewController.present(navi, animated: true, completion: nil)
    }
}

extension ComposeServiceNavigationFlowController: ComposeServiceFlowControllerParent {
    func composeServiceDidFinish() {
        parent?.composeServiceDidFinish()
    }
    
    func composeServiceWasCreated(serviceData: ServiceData) {
        parent?.composeServiceWasCreated(serviceData: serviceData)
    }
    
    func composeServiceServiceWasModified() {
        parent?.composeServiceServiceWasModified()
    }
    
    func composeServiceServiceWasDeleted() {
        parent?.composeServiceServiceWasDeleted()
    }
}
