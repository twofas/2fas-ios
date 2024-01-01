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

protocol PushNotificationPermissionPlainFlowControllerParent: AnyObject {
    func pushNotificationsClose(extensionID: ExtensionID?)
}

protocol PushNotificationPermissionPlainFlowControlling: AnyObject {
    func close(extensionID: ExtensionID?)
}

final class PushNotificationPermissionPlainFlowController: FlowController {
    private weak var parent: PushNotificationPermissionPlainFlowControllerParent?
    
    static func push(
        on navigationController: UINavigationController,
        parent: PushNotificationPermissionPlainFlowControllerParent,
        extensionID: ExtensionID?
    ) {
        let view = PushNotificationPermissionViewController()
        let flowController = PushNotificationPermissionPlainFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.pushNotificationPermissionModuleInteractor()
        let presenter = PushNotificationPermissionPresenter(
            flowController: flowController,
            interactor: interactor,
            extensionID: extensionID
        )
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
    
    static func setRoot(
        in navigationController: UINavigationController,
        parent: PushNotificationPermissionPlainFlowControllerParent,
        extensionID: ExtensionID?
    ) {
        let view = PushNotificationPermissionViewController()
        let flowController = PushNotificationPermissionPlainFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.pushNotificationPermissionModuleInteractor()
        let presenter = PushNotificationPermissionPresenter(
            flowController: flowController,
            interactor: interactor,
            extensionID: extensionID
        )
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
}

extension PushNotificationPermissionPlainFlowController {
    var viewController: PushNotificationPermissionViewController {
        _viewController as! PushNotificationPermissionViewController
    }
}

extension PushNotificationPermissionPlainFlowController: PushNotificationPermissionPlainFlowControlling {
    func close(extensionID: ExtensionID?) {
        parent?.pushNotificationsClose(extensionID: extensionID)
    }
}
