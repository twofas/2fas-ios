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
import CodeSupport
import Common
import SwiftUI
import Storage

protocol CameraScannerNavigationFlowControllerParent: AnyObject {
    func cameraScannerDidFinish()
    func cameraScannerServiceWasCreated(serviceData: ServiceData)
}

final class CameraScannerNavigationFlowController: NavigationFlowController {
    private weak var parent: CameraScannerNavigationFlowControllerParent?
        
    static func present(
        on viewController: UIViewController,
        parent: CameraScannerNavigationFlowControllerParent
    ) {
        let flowController = CameraScannerNavigationFlowController()
        flowController.parent = parent

        let navi = CommonNavigationControllerFlow(flowController: flowController)
        navi.setNavigationBarHidden(true, animated: false)
        navi.modalPresentationStyle = .fullScreen
        navi.isModalInPresentation = true
        navi.definesPresentationContext = true
        
        CameraScannerFlowController.setRoot(in: navi, parent: flowController)
        
        viewController.present(navi, animated: true)
    }
}

extension CameraScannerNavigationFlowController: CameraScannerFlowControllerParent {
    func cameraScannerDidFinish() {
        parent?.cameraScannerDidFinish()
    }
    
    func cameraScannerServiceWasCreated(serviceData: ServiceData) {
        parent?.cameraScannerServiceWasCreated(serviceData: serviceData)
    }
}
