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

protocol AppLockFlowControllerParent: AnyObject {
    func didChangeAppLockValue()
}

protocol AppLockFlowControlling: AnyObject {
    func toValueChanged()
}

final class AppLockFlowController: FlowController {
    private weak var parent: AppLockFlowControllerParent?
    
    static func push(
        on navigationController: UINavigationController,
        parent: AppLockFlowControllerParent
    ) {
        let view = AppLockViewController()
        let flowController = AppLockFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.appLockModuleInteractor()
        let presenter = AppLockPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension AppLockFlowController: AppLockFlowControlling {
    func toValueChanged() {
        parent?.didChangeAppLockValue()
    }
}
