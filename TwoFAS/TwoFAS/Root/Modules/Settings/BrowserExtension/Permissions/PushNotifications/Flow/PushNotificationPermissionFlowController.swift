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

import Foundation
import UIKit

protocol PushNotificationPermissionFlowControllerParent: AnyObject {
    func pushNotificationsDidEnd()
}

protocol PushNotificationPermissionFlowControlling: AnyObject {
    func toFinish()
}

final class PushNotificationPermissionFlowController: FlowController {
    private weak var parent: PushNotificationPermissionFlowControllerParent?
    
    static func show(
        on viewController: UIViewController,
        parent: PushNotificationPermissionFlowControllerParent
    ) {
        let view = PushNotificationPermissionViewController()
        let flowController = PushNotificationPermissionFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.pushNotificationPermissionModuleInteractor()
        let presenter = PushNotificationPermissionPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        view.configureAsModal()
        view.modalPresentationStyle = .fullScreen
        
        viewController.present(view, animated: true)
    }
    
    static func push(
        on navigationController: UINavigationController,
        parent: PushNotificationPermissionFlowControllerParent
    ) {
        let view = PushNotificationPermissionViewController()
        let flowController = PushNotificationPermissionFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.pushNotificationPermissionModuleInteractor()
        let presenter = PushNotificationPermissionPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension PushNotificationPermissionFlowController: PushNotificationPermissionFlowControlling {
    func toFinish() {
        parent?.pushNotificationsDidEnd()
    }
}
