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

protocol GuidePagesFlowControllerParent: AnyObject {
    func guidePageToAddManually(with data: String?)
    func guidePageToCodeScanner()
    func guideToMenu()
}

protocol GuidePagesFlowControlling: AnyObject {
    func toAddManually(with data: String?)
    func toCodeScanner()
    func toMenu()
}

final class GuidePagesFlowController: FlowController {
    private weak var parent: GuidePagesFlowControllerParent?
    
    static func push(
        on navigationController: UINavigationController,
        parent: GuidePagesFlowControllerParent,
        content: GuideDescription.MenuPosition
    ) {
        let view = GuidePagesViewController()
        let flowController = GuidePagesFlowController(viewController: view)
        flowController.parent = parent
        
        let presenter = GuidePagesPresenter(
            flowController: flowController,
            content: content
        )
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension GuidePagesFlowController: GuidePagesFlowControlling {
    func toAddManually(with data: String?) {
        parent?.guidePageToAddManually(with: data)
    }
    
    func toCodeScanner() {
        parent?.guidePageToCodeScanner()
    }
    
    func toMenu() {
        parent?.guideToMenu()
    }
}
