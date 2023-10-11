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

protocol GuideSelectorNavigationFlowControllerParent: AnyObject {
    func closeGuideSelector()
    func guideToAddManually(with data: String?)
    func guideToCodeScanner()
}

final class GuideSelectorNavigationFlowController: NavigationFlowController {
    private weak var parent: GuideSelectorNavigationFlowControllerParent?
    
    static func show(
        on viewController: UIViewController,
        parent: GuideSelectorNavigationFlowControllerParent
    ) {
        let flowController = GuideSelectorNavigationFlowController()
        flowController.parent = parent

        let navi = CommonNavigationControllerFlow(flowController: flowController)
        navi.configureAsLargeModal()
        
        flowController.navigationController = navi
        
        GuideSelectorFlowController.present(
            in: navi,
            parent: flowController
        )
        
        viewController.present(navi, animated: true, completion: nil)
    }
}

extension GuideSelectorNavigationFlowController: GuideSelectorFlowControllerParent {
    func guideSelectorToGuideMenu(_ guide: GuideDescription) {
        GuideMenuFlowController.push(on: navigationController, parent: self, guide: guide)
    }
    
    func guideSelectorClose() {
        parent?.closeGuideSelector()
    }
}

extension GuideSelectorNavigationFlowController: GuideMenuFlowControllerParent {
    func guideMenuToMenuPosition(_ menu: GuideDescription.MenuPosition) {
        GuidePageFlowController.push(on: navigationController, parent: self, menu: menu, pageNumber: 0)
    }
}

extension GuideSelectorNavigationFlowController: GuidePageFlowControllerParent {
    func guidePageToPage(pageNumber: Int, in menu: GuideDescription.MenuPosition) {
        GuidePageFlowController.push(on: navigationController, parent: self, menu: menu, pageNumber: pageNumber)
    }
    
    func guidePageToAddManually(with data: String?) {
        parent?.guideToAddManually(with: data)
    }
    
    func guidePageToCodeScanner() {
        parent?.guideToCodeScanner()
    }
}
