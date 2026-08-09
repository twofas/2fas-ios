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

protocol BrowserExtensionMainFlowControllerParent: AnyObject {}

protocol BrowserExtensionMainFlowControlling: AnyObject {
    func toInitialScreen()
    func toClearScreen()
    func toCamera()
    func toService(name: String, date: String, id: String)
    func toCameraNotAvailable()
    func close()
}

final class BrowserExtensionMainFlowController: FlowController {
    private weak var parent: BrowserExtensionMainFlowControllerParent?
    private weak var presenter: BrowserExtensionMainPresenter?

    private var embeddedViewController: UIViewController?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: BrowserExtensionMainFlowControllerParent
    ) {
        let hosting = create(parent: parent)
        navigationController.setViewControllers([hosting], animated: false)
    }

    static func push(
        in navigationController: UINavigationController,
        parent: BrowserExtensionMainFlowControllerParent
    ) {
        let hosting = create(parent: parent)
        navigationController.pushRootViewController(hosting, animated: true)
    }

    private static func create(
        parent: BrowserExtensionMainFlowControllerParent
    ) -> UIViewController {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = BrowserExtensionMainFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.browserExtensionMainModuleInteractor()
        let presenter = BrowserExtensionMainPresenter(
            flowController: flowController,
            interactor: interactor
        )
        flowController.presenter = presenter
        hosting.rootView = AnyView(BrowserExtensionMainView(presenter: presenter))
        return hosting
    }
}

private extension BrowserExtensionMainFlowController {
    func dismiss() {
        _viewController?.dismiss(animated: true)
    }
}

extension BrowserExtensionMainFlowController: BrowserExtensionMainFlowControlling {
    func toInitialScreen() {
        guard embeddedViewController == nil, let vc = _viewController else { return }
        embeddedViewController = BrowserExtensionIntroFlowController.embed(
            in: vc,
            parent: self
        )
    }

    func toClearScreen() {
        guard let embeddedViewController else { return }
        embeddedViewController.removeFromParent()
        embeddedViewController.view.removeFromSuperview()
        self.embeddedViewController = nil
    }

    func toCamera() {
        guard let vc = _viewController else { return }
        CameraScannerNavigationFlowController.present(on: vc, parent: self)
    }

    func toService(name: String, date: String, id: String) {
        guard let navi = _viewController?.navigationController else { return }
        BrowserExtensionServiceFlowController.present(in: navi, parent: self, name: name, date: date, id: id)
    }

    func toCameraNotAvailable() {
        let ac = AlertController.cameraNotAvailable
        ac.show(animated: true, completion: nil)
    }

    func close() {
        _viewController?.navigationController?.popViewController(animated: true)
    }
}

extension BrowserExtensionMainFlowController: BrowserExtensionIntroFlowControllerParent {
    func browserExtensionIntroPairing() {
        toCamera()
    }

    func browserExtensionIntroClose() {
        _viewController?.navigationController?.popViewController(animated: true)
    }
}

extension BrowserExtensionMainFlowController: CameraScannerNavigationFlowControllerParent {
    func cameraScannerDidFinish() {
        presenter?.handleRefresh()
        dismiss()
    }

    func cameraScannerDidImport(count: Int) {
        // not implemented
    }

    func cameraScannerServiceWasCreated(serviceData: ServiceData) {
        // not implemented
    }
}

extension BrowserExtensionMainFlowController: BrowserExtensionServiceFlowControllerParent {
    func unpairService(with id: String) {
        _viewController?.navigationController?.popViewController(animated: true)
        presenter?.handleServiceUnpairing(with: id)
    }
}
