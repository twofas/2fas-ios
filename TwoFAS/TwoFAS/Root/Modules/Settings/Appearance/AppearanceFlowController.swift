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

protocol AppearanceFlowControllerParent: AnyObject {}

protocol AppearanceFlowControlling: AnyObject {
    func close()
}

final class AppearanceFlowController: FlowController {
    private weak var parent: AppearanceFlowControllerParent?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: AppearanceFlowControllerParent
    ) {
        let hosting = create(parent: parent, showsBackButton: false)
        navigationController.setViewControllers([hosting], animated: false)
    }

    static func push(
        in navigationController: UINavigationController,
        parent: AppearanceFlowControllerParent
    ) {
        let hosting = create(parent: parent, showsBackButton: true)
        navigationController.pushRootViewController(hosting, animated: true)
    }

    private static func create(
        parent: AppearanceFlowControllerParent,
        showsBackButton: Bool
    ) -> UIViewController {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = AppearanceFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.appearanceModuleInteractor()
        let presenter = AppearancePresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.showsBackButton = showsBackButton
        hosting.rootView = AnyView(AppearanceView(presenter: presenter))
        return hosting
    }
}

extension AppearanceFlowController: AppearanceFlowControlling {
    func close() {
        _viewController?.navigationController?.popViewController(animated: true)
    }
}
