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

protocol BrowserExtensionIntroFlowControllerParent: AnyObject {
    func browserExtensionIntroClose()
    func browserExtensionIntroPairing()
}

protocol BrowserExtensionIntroFlowControlling: AnyObject {
    func toClose()
    func toCamera()
    func toInfo()
    func toCameraNotAvailable()
    func toPushNotifications()
}

final class BrowserExtensionIntroFlowController: FlowController {
    private weak var parent: BrowserExtensionIntroFlowControllerParent?
    private weak var navigationController: UINavigationController?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: BrowserExtensionIntroFlowControllerParent
    ) {
        let view = BrowserExtensionIntroViewController()
        let flowController = BrowserExtensionIntroFlowController(viewController: view)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let interactor = InteractorFactory.shared.browserExtensionIntroModuleInteractor()
        let presenter = BrowserExtensionIntroPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    static func push(
        in navigationController: UINavigationController,
        parent: BrowserExtensionIntroFlowControllerParent
    ) {
        let view = BrowserExtensionIntroViewController()
        let flowController = BrowserExtensionIntroFlowController(viewController: view)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let interactor = InteractorFactory.shared.browserExtensionIntroModuleInteractor()
        let presenter = BrowserExtensionIntroPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: false)
    }
    
    static func embed(
        in viewController: UIViewController,
        parent: BrowserExtensionIntroFlowControllerParent
    ) -> UIViewController {
        let navi = UINavigationController()
        let view = BrowserExtensionIntroViewController()
        let flowController = BrowserExtensionIntroFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.browserExtensionIntroModuleInteractor()
        let presenter = BrowserExtensionIntroPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        view.hideNavibar = true
        navi.setViewControllers([view], animated: false)
        flowController.navigationController = navi
        
        viewController.addChild(navi)
        viewController.view.addSubview(navi.view)
        navi.view.pinToParent()
        navi.didMove(toParent: viewController)
        
        return navi
    }
}

extension BrowserExtensionIntroFlowController {
    var viewController: BrowserExtensionIntroViewController { _viewController as! BrowserExtensionIntroViewController }
}

extension BrowserExtensionIntroFlowController: BrowserExtensionIntroFlowControlling {
    func toClose() {
        parent?.browserExtensionIntroClose()
    }
    
    func toPushNotifications() {
        Log("Presenting Push Notification Permissions")
        guard let navigationController else { return }
        PushNotificationPermissionPlainFlowController.push(on: navigationController, parent: self, extensionID: nil)
    }
    
    func toCamera() {
        parent?.browserExtensionIntroPairing()
    }
    
    func toInfo() {
        UIApplication.shared.open(URL(string: T.Browser.moreInfoLink)!, options: [:], completionHandler: nil)
    }
    
    func toCameraNotAvailable() {
        let ac = AlertController.cameraNotAvailable
        ac.show(animated: true, completion: nil)
    }
}

extension BrowserExtensionIntroFlowController: PushNotificationPermissionPlainFlowControllerParent {
    func pushNotificationsClose(extensionID: ExtensionID?) {
        navigationController?.popToRootViewController(animated: true)
        viewController.presenter.handlePushNotificationClosed()
    }
}
