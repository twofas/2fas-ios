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

protocol BrowserExtensionMainFlowControllerParent: AnyObject {}

protocol BrowserExtensionMainFlowControlling: AnyObject {
    func toInitialScreen()
    func toClearScreen()
    func toCamera()
    func toNameChange(_ currentName: String)
    func toService(name: String, date: String, id: String)
    func toCameraNotAvailable()
}

final class BrowserExtensionMainFlowController: FlowController {
    private weak var parent: BrowserExtensionMainFlowControllerParent?
    
    private var embeddedViewController: UIViewController?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: BrowserExtensionMainFlowControllerParent
    ) {
        let view = BrowserExtensionMainViewController()
        let flowController = BrowserExtensionMainFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.browserExtensionMainModuleInteractor()
        let presenter = BrowserExtensionMainPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    static func push(
        in navigationController: UINavigationController,
        parent: BrowserExtensionMainFlowControllerParent
    ) {
        let view = BrowserExtensionMainViewController()
        let flowController = BrowserExtensionMainFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.browserExtensionMainModuleInteractor()
        let presenter = BrowserExtensionMainPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        navigationController.pushRootViewController(view, animated: true)
    }
}

extension BrowserExtensionMainFlowController {
    var viewController: BrowserExtensionMainViewController { _viewController as! BrowserExtensionMainViewController }
    
    func dismiss() {
        viewController.dismiss(animated: true)
    }
}

extension BrowserExtensionMainFlowController: BrowserExtensionMainFlowControlling {
    func toInitialScreen() {
        guard embeddedViewController == nil else { return }
        embeddedViewController = BrowserExtensionIntroFlowController.embed(in: viewController, parent: self)
    }
    
    func toClearScreen() {
        guard let embeddedViewController else { return }
        embeddedViewController.removeFromParent()
        embeddedViewController.view.removeFromSuperview()
        self.embeddedViewController = nil
    }
    
    func toCamera() {
        CameraScannerNavigationFlowController.present(on: viewController, parent: self)
    }
    
    func toNameChange(_ currentName: String) {
        guard let navi = viewController.navigationController else { return }
        BrowserExtensionEditNameFlowController.push(on: navi, parent: self, currentName: currentName)
    }
    
    func toService(name: String, date: String, id: String) {
        guard let navi = viewController.navigationController else { return }
        BrowserExtensionServiceFlowController.present(in: navi, parent: self, name: name, date: date, id: id)
    }
    
    func toCameraNotAvailable() {
        let ac = AlertController.cameraNotAvailable
        ac.show(animated: true, completion: nil)
    }
}

extension BrowserExtensionMainFlowController: BrowserExtensionIntroFlowControllerParent {
    func browserExtensionIntroPairing() {
        toCamera()
    }
    
    func browserExtensionIntroClose() {
        dismiss() 
    }
}

extension BrowserExtensionMainFlowController: CameraScannerNavigationFlowControllerParent {
    func cameraScannerDidFinish() {
        viewController.presenter.handleRefresh()
        dismiss()
    }
    
    func cameraScannerDidImport(count: Int) {
        // not implemented
    }
    
    func cameraScannerServiceWasCreated(serviceData: ServiceData) {
        // not implemented
    }
}

extension BrowserExtensionMainFlowController: BrowserExtensionEditNameFlowControllerParent {
    func didChangeName(_ newName: String) {
        viewController.navigationController?.popViewController(animated: true)
        viewController.presenter.handleNameChange(newName)
    }
}

extension BrowserExtensionMainFlowController: BrowserExtensionServiceFlowControllerParent {
    func unpairService(with id: String) {
        viewController.navigationController?.popViewController(animated: true)
        viewController.presenter.handleServiceUnpairing(with: id)
    }
}
