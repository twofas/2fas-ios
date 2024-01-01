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
import Data
import Common

protocol IntroductionFlowControllerParent: AnyObject {
    func introductionHasFinished()
}

protocol IntroductionFlowControlling: AnyObject {
    func toClose()
    func toCloudInfo()
    func toTOS()
}

final class IntroductionFlowController: FlowController {
    private weak var parent: IntroductionFlowControllerParent?
    
    static func setAsRoot(
        in navigationController: UINavigationController,
        parent: IntroductionFlowControllerParent
    ) {
        let view = IntroductionViewController()
        let flowController = IntroductionFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.introductionModuleInteractor()
        
        let presenter = IntroductionPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        navigationController.setViewControllers([view], animated: false)
    }
}

extension IntroductionFlowController: IntroductionFlowControlling {
    func toClose() {
        parent?.introductionHasFinished()
    }
    
    func toCloudInfo() {
        let vc = IntroductionCloudInfoViewController()
        vc.close = { [weak self] in
            self?._viewController.dismiss(animated: true)
        }
        vc.configureAsModal()
        
        _viewController.present(vc, animated: true)
    }
    
    func toTOS() {
        UIApplication.shared.open(Config.tosURL, completionHandler: nil)
    }
}
