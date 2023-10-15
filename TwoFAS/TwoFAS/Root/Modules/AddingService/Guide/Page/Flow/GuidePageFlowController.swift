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
import Data

protocol GuidePageFlowControllerParent: AnyObject {
    func guidePageToPage(pageNumber: Int, in menu: GuideDescription.MenuPosition)
    func guidePageToAddManually(with data: String?)
    func guidePageToCodeScanner()
}

protocol GuidePageFlowControlling: AnyObject {
    func toPage(pageNumber: Int, in menu: GuideDescription.MenuPosition)
    func toAddManually(with data: String?)
    func toCodeScanner()
}

final class GuidePageFlowController: FlowController {
    private weak var parent: GuidePageFlowControllerParent?
    
    static func push(
        on navigationController: UINavigationController,
        parent: GuidePageFlowControllerParent,
        menu: GuideDescription.MenuPosition,
        pageNumber: Int
    ) {
        let view = GuidePageViewController()
        let flowController = GuidePageFlowController(viewController: view)
        flowController.parent = parent
        
        let presenter = GuidePagePresenter(
            flowController: flowController,
            menu: menu,
            pageNumber: pageNumber
        )
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension GuidePageFlowController: GuidePageFlowControlling {
    func toPage(pageNumber: Int, in menu: GuideDescription.MenuPosition) {
        parent?.guidePageToPage(pageNumber: pageNumber, in: menu)
    }
    
    func toAddManually(with data: String?) {
        parent?.guidePageToAddManually(with: data)
    }
    
    func toCodeScanner() {
        parent?.guidePageToCodeScanner()
    }
}
