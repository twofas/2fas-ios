//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

protocol NewPINNavigationFlowControllerParent: AnyObject {
    func pinGathered(
        with PIN: String,
        pinType: PINType
    )
}

protocol NewPINNavigationFlowControlling: AnyObject {}

final class NewPINNavigationFlowController: NavigationFlowController {
    private weak var parent: NewPINNavigationFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: NewPINNavigationFlowControllerParent
    ) {
        let flowController = NewPINNavigationFlowController()
        flowController.parent = parent

        let navi = CommonNavigationControllerFlow(flowController: flowController)
        navi.configureAsFullscreenModal()
        
        flowController.navigationController = navi
        
        NewPINFlowController.setRoot(in: navi, parent: flowController, pinType: .digits4, lockNavigation: true)
        
        viewController.present(navi, animated: true, completion: nil)
    }
}

extension NewPINNavigationFlowController: NewPINNavigationFlowControlling {}

extension NewPINNavigationFlowController: NewPINFlowControllerParent {
    func hideNewPIN() {}
    func pinGathered(
        with PIN: String,
        pinType: PINType,
        action: NewPINFlowController.Action,
        step: NewPINFlowController.Step
    ) {
        switch step {
        case .first:
            NewPINFlowController.push(
                on: navigationController,
                parent: self,
                action: .create,
                step: .second(PIN: PIN, pinType: pinType),
                lockNavigation: true
            )
        case .second(let PIN, let pinType):
            parent?.pinGathered(with: PIN, pinType: pinType)
        }
    }
}
