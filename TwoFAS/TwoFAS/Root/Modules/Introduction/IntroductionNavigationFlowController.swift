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

protocol IntroductionNavigationFlowControllerParent: AnyObject {
    func introductionHasFinished(introViewController: UIViewController)
}

final class IntroductionNavigationFlowController: NavigationFlowController {
    private weak var parent: IntroductionNavigationFlowControllerParent?
    
    static func embedAsRoot(
        in viewController: UIViewController,
        parent: IntroductionNavigationFlowControllerParent
    ) {
        let flowController = IntroductionNavigationFlowController()
        flowController.parent = parent
        
        let navi = CommonNavigationControllerFlow(flowController: flowController)
        flowController.navigationController = navi

        navi.willMove(toParent: viewController)
        viewController.addChild(navi)
        viewController.view.addSubview(navi.view)
        navi.view.pinToParent()
        navi.didMove(toParent: viewController)
        
        IntroductionFlowController.setAsRoot(in: navi, parent: flowController)
    }
}

extension IntroductionNavigationFlowController: IntroductionFlowControllerParent {
    func introductionHasFinished() {
        guard let navigationController else { return }
        parent?.introductionHasFinished(introViewController: navigationController)
    }
}
