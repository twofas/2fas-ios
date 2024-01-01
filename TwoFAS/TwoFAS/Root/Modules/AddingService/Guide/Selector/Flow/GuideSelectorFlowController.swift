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

protocol GuideSelectorFlowControllerParent: AnyObject {
    func guideSelectorToGuideMenu(_ guide: GuideDescription)
    func guideSelectorClose()
}

protocol GuideSelectorFlowControlling: AnyObject {
    func toClose()
    func toGuideMenu(_ guide: GuideDescription)
}

final class GuideSelectorFlowController: FlowController {
    private weak var parent: GuideSelectorFlowControllerParent?
    
    static func present(
        in navigationController: UINavigationController,
        parent: GuideSelectorFlowControllerParent
    ) {
        let view = GuideSelectorViewController()
        let flowController = GuideSelectorFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.guideSelectorModuleInteractor()
        
        let presenter = GuideSelectorPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
}

extension GuideSelectorFlowController: GuideSelectorFlowControlling {
    func toClose() {
        parent?.guideSelectorClose()
    }
    
    func toGuideMenu(_ guide: GuideDescription) {
        parent?.guideSelectorToGuideMenu(guide)
    }
}
