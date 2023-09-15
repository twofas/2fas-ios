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

protocol ExternalImportFlowControllerParent: AnyObject {}

protocol ExternalImportFlowControlling: AnyObject {
    func toAegis()
    func toRaivo()
    func toLastPass()
    func toGoogleAuth()
    func toAndOTP()
    func toAuthenticatorPro()
}

final class ExternalImportFlowController: FlowController {
    private weak var parent: ExternalImportFlowControllerParent?
    private weak var navigationController: UINavigationController?
    private var galleryViewController: UIViewController?
    private var importer: ImporterOpenFileHeadlessFlowController?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: ExternalImportFlowControllerParent
    ) {
        let view = ExternalImportViewController()
        let flowController = ExternalImportFlowController(viewController: view)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let presenter = ExternalImportPresenter(
            flowController: flowController
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    static func push(
        in navigationController: UINavigationController,
        parent: ExternalImportFlowControllerParent
    ) {
        let view = ExternalImportViewController()
        let flowController = ExternalImportFlowController(viewController: view)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let presenter = ExternalImportPresenter(
            flowController: flowController
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushRootViewController(view, animated: true)
    }
}

extension ExternalImportFlowController: ExternalImportFlowControlling {
    func toAegis() {
        guard let navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: true)
        ExternalImportInstructionsFlowController.push(
            in: navigationController,
            parent: self,
            service: .aegis
        )
    }
    
    func toRaivo() {
        guard let navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: true)
        ExternalImportInstructionsFlowController.push(
            in: navigationController,
            parent: self,
            service: .raivo
        )
    }
    
    func toLastPass() {
        guard let navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: true)
        ExternalImportInstructionsFlowController.push(
            in: navigationController,
            parent: self,
            service: .lastPass
        )
    }
    
    func toGoogleAuth() {
        guard let navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: true)
        ExternalImportInstructionsFlowController.push(
            in: navigationController,
            parent: self,
            service: .googleAuth
        )
    }
    
    func toAndOTP() {
        guard let navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: true)
        ExternalImportInstructionsFlowController.push(
            in: navigationController,
            parent: self,
            service: .andOTP
        )
    }
    
    func toAuthenticatorPro() {
        guard let navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: true)
        ExternalImportInstructionsFlowController.push(
            in: navigationController,
            parent: self,
            service: .authenticatorPro
        )
    }
}

extension ExternalImportFlowController: ExternalImportInstructionsFlowControllerParent {
    func instructionsClose() {
        navigationController?.popViewController(animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    func instructionsOpenFile() {
        guard let navigationController else { return }
        importer = ImporterOpenFileHeadlessFlowController.present(on: navigationController, parent: self, url: nil)
    }
    
    func instructionsCamera() {
        guard let navigationController else { return }
        CameraScannerFlowController.present(
            on: navigationController,
            parent: self
        )
    }
    
    func instructionsGallery() {
        guard let navigationController else { return }
        galleryViewController = SelectFromGalleryFlowController.present(
            on: navigationController,
            applyOverlay: true,
            parent: self
        )
    }
}

extension ExternalImportFlowController: CameraScannerFlowControllerParent {
    func cameraScannerDidFinish() { end() }
    func cameraScannerServiceWasCreated(serviceData: ServiceData) { end() }
}

extension ExternalImportFlowController: SelectFromGalleryFlowControllerParent {
    func galleryDidFinish() { endGallery() }
    func galleryDidCancel() { endGallery() }
    func galleryServiceWasCreated(serviceData: ServiceData) { endGallery() }
    func galleryToSendLogs(auditID: UUID) { endGallery() }
}

extension ExternalImportFlowController: ImporterOpenFileHeadlessFlowControllerParent {
    func importerClose() {
        importer = nil
        end()
    }
}

private extension ExternalImportFlowController {
    func endGallery() {
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.galleryViewController = nil
        }
    }
    
    func end() {
        navigationController?.dismiss(animated: true)
    }
}
