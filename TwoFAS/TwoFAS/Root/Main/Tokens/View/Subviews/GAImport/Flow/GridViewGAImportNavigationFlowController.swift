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

protocol GridViewGAImportNavigationFlowControllerParent: AnyObject {
    func gaImportDidFinish()
    func gaChooseQR()
    func gaScanQR()
}

protocol GridViewGAImportNavigationFlowControlling: AnyObject {
    func toClose()
}

final class GridViewGAImportNavigationFlowController: NavigationFlowController {
    private weak var parent: GridViewGAImportNavigationFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: GridViewGAImportNavigationFlowControllerParent
    ) {
        let flowController = GridViewGAImportNavigationFlowController()
        flowController.parent = parent

        let navi = CommonNavigationControllerFlow(flowController: flowController)
        navi.configureAsLargeModal()
        
        flowController.navigationController = navi
        
        GridViewGAImportFlowController.present(in: navi, parent: flowController)
        
        viewController.present(navi, animated: true, completion: nil)
    }
}

extension GridViewGAImportNavigationFlowController: GridViewGAImportFlowControllerParent {
    func gaImportDidFinish() {
        parent?.gaImportDidFinish()
    }
    
    func gaChooseQR() {
        parent?.gaChooseQR()
    }
    
    func gaScanQR() {
        parent?.gaScanQR()
    }
}
