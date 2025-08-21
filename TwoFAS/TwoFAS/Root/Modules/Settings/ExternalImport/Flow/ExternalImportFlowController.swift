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
import Data

protocol ExternalImportFlowControllerParent: AnyObject {}

protocol ExternalImportFlowControlling: AnyObject {
    func toAegis()
    func toRaivo()
    func toLastPass()
    func toGoogleAuth()
    func toAndOTP()
    func toAuthenticatorPro()
    func toOpenTXTFile()
    func toReadFromClipboard()
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
    
    func toOpenTXTFile() {
        guard let navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: true)
        ExternalImportInstructionsFlowController.push(
            in: navigationController,
            parent: self,
            service: .otpAuthFile
        )
    }
    
    func toReadFromClipboard() {
        guard let navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: true)
        ExternalImportInstructionsFlowController.push(
            in: navigationController,
            parent: self,
            service: .clipboard
        )
    }
}

extension ExternalImportFlowController: ExternalImportInstructionsFlowControllerParent {
    func instructionsClose() {
        close()
    }
    
    func instructionsOpenFile(service: ExternalImportService) {
        guard let navigationController else { return }
        importer = ImporterOpenFileHeadlessFlowController
            .present(on: navigationController, parent: self, url: nil, importingOTPAuthFile: service == .otpAuthFile)
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
    
    func instructionsFromClipboard() {
        guard let navigationController else { return }
        importer = ImporterOpenFileHeadlessFlowController
            .present(
                on: navigationController,
                parent: self,
                url: nil,
                importingOTPAuthFile: true,
                isFromClipboard: true
            )
    }
}

extension ExternalImportFlowController: CameraScannerFlowControllerParent {
    func cameraScannerDidFinish() { end() }
    func cameraScannerDidImport(count: Int) {
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.showSummary(count: count)
        }
    }
    func cameraScannerServiceWasCreated(serviceData: ServiceData) { end() }
}

extension ExternalImportFlowController: SelectFromGalleryFlowControllerParent {
    func galleryDidFinish() { endGallery() }
    func galleryDidCancel() { endGallery() }
    func galleryServiceWasCreated(serviceData: ServiceData) { endGallery() }
    func galleryToSendLogs(auditID: UUID) { endGallery() }
    func galleryDidImport(count: Int) {
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.galleryViewController = nil
            self?.showSummary(count: count)
        }
    }
}

extension ExternalImportFlowController: ImporterOpenFileHeadlessFlowControllerParent {
    func importerCloseOnSucessfulImport() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.tabBarController?.tabBar.isHidden = false
        importer = nil
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    func importerClose() {
        importer = nil
        end()
    }
}

private extension ExternalImportFlowController {
    func close(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    func endGallery() {
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.galleryViewController = nil
        }
    }
    
    func end() {
        navigationController?.dismiss(animated: true)
    }
    
    func showSummary(count: Int) {
        let alert = AlertControllerDismissFlow(
            title: T.Backup.importCompletedSuccessfuly,
            message: T.Backup.servicesImportedCount(count),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.tokens, style: .default, handler: { [weak self] _ in
            NotificationCenter.default.post(name: .switchToTokens, object: nil)
            self?.close(animated: false)
        }))
        alert.addAction(UIAlertAction(title: T.Commons.close, style: .cancel, handler: { [weak self] _ in
            self?.instructionsClose()
        }))
        navigationController?.present(alert, animated: true)
    }
}
