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
import SwiftUI
import Common

protocol IntroductionFlowControllerParent: AnyObject {
    func introductionHasFinished()
}

protocol IntroductionFlowControlling: AnyObject {
    func toClose()
    func toTOS()
}

final class IntroductionFlowController: FlowController {
    private weak var parent: IntroductionFlowControllerParent?
    
    static func setAsRoot(
        in navigationController: UINavigationController,
        parent: IntroductionFlowControllerParent
    ) {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        hosting.view.layer.contentsFormat = .RGBA16Float
        hosting.view.backgroundColor = AppColor.backgroundsPrimary.uiColor
        let flowController = IntroductionFlowController(viewController: hosting)
        flowController.parent = parent

        let interactor = ModuleInteractorFactory.shared.introductionModuleInteractor()

        let presenter = IntroductionPresenter(
            flowController: flowController,
            interactor: interactor
        )
        hosting.rootView = AnyView(IntroductionView(presenter: presenter))

        navigationController.setViewControllers([hosting], animated: false)
    }
}

extension IntroductionFlowController: IntroductionFlowControlling {
    func toClose() {
        parent?.introductionHasFinished()
    }
    
    func toTOS() {
        UIApplication.shared.open(Config.tosURL, completionHandler: nil)
    }
}
