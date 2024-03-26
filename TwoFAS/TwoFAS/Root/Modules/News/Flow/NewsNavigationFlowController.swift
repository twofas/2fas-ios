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

protocol NewsNavigationFlowControllerParent: AnyObject {
    func newsClose()
    func newsToBackup()
}

final class NewsNavigationFlowController: NavigationFlowController {
    private weak var parent: NewsNavigationFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: NewsNavigationFlowControllerParent
    ) {
        let flowController = NewsNavigationFlowController()
        flowController.parent = parent
        
        let naviController = CommonNavigationControllerFlow(flowController: flowController)
        flowController.navigationController = naviController
        
        NewsPlainFlowController.showAsRoot(in: naviController, parent: flowController)

        naviController.configureAsLargeModal()
        viewController.present(naviController, animated: true)
    }
}

extension NewsNavigationFlowController: NewsPlainFlowControllerParent {
    func newsClose() {
        parent?.newsClose()
    }
    
    func newsToBackup() {
        parent?.newsToBackup()
    }
}
