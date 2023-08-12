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
import CodeSupport

protocol AddingServiceMainFlowControllerParent: AnyObject {
    func mainToToken(serviceData: ServiceData)
    func mainToDismiss()
}

protocol AddingServiceMainFlowControlling: AnyObject {
    func toToken(serviceData: ServiceData)
    func close()
    
    func toAddManually()
    func toAppSettings()
    func toGeneralError()
    func toDuplicatedCode(usedIn: String)
    func toAppStore()
    func toGallery()
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func toLastPassSummary(importable: Int, total: Int, codes: [Code])
    func toCameraError(_ error: String)
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID)
    func toSendLogs(auditID: UUID)
    func toPushPermissions()
    func toRename(currentName: String, secret: String)
}

final class AddingServiceMainFlowController: FlowController {
    private weak var parent: AddingServiceMainFlowControllerParent?
    private var galleryViewController: UIViewController? // MOVE TO PARENT!!!!
    
    static func embed(
        in viewController: UIViewController & AddingServiceViewControlling,
        parent: AddingServiceMainFlowControllerParent
    ) {
        let view = AddingServiceMainViewController()
        let flowController = AddingServiceMainFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = InteractorFactory.shared.addingServiceMainModuleInteractor()
        
        view.heightChange = { [weak viewController] height in
            viewController?.updateHeight(height)
        }
        
        let presenter = AddingServiceMainPresenter(flowController: flowController, interactor: interactor)
        view.presenter = presenter
        presenter.view = view
        
        viewController.embedViewController(view)
    }
}

extension AddingServiceMainFlowController {
    var viewController: AddingServiceMainViewController { _viewController as! AddingServiceMainViewController }
}

extension AddingServiceMainFlowController: AddingServiceMainFlowControlling {
    func toToken(serviceData: ServiceData) {
        parent?.mainToToken(serviceData: serviceData)
    }
    
    func close() {
        parent?.mainToDismiss()
    }
    
    func toAddManually() {
        
    }
    
    func toAppSettings() {
        // open system settings app view, check if we need to dismiss adding service on app show (camera)
    }
    
    func toGeneralError() {
//        let errorView = CameraError.generalEror.view(with: { [weak self] in
//            self?.dismissModal()
//        }, cancel: nil)
//        let vc = UIHostingController(rootView: errorView)
//        vc.view.backgroundColor = .clear
//        vc.configureAsModal()
//        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toDuplicatedCode(usedIn: String) {
//        let errorView = CameraError.duplicatedCode(usedIn: usedIn).view(with: { [weak self] in
//            self?.dismissModal()
//        }, cancel: nil)
//        let vc = UIHostingController(rootView: errorView)
//        vc.view.backgroundColor = .clear
//        vc.configureAsModal()
//        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toAppStore() {
//        let errorView = CameraError.appStore.view(with: { [weak self] in
//            self?.dismissModal()
//        }, cancel: nil)
//        let vc = UIHostingController(rootView: errorView)
//        vc.view.backgroundColor = .clear
//        vc.configureAsModal()
//        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toGallery() {
//        galleryViewController = SelectFromGalleryFlowController.present(
//            on: viewController,
//            applyOverlay: false,
//            parent: self
//        )
    }
    
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code]) {
//        let google = CameraGoogleAuth(
//            importedCount: importable,
//            totalCount: total,
//            action: { [weak self] in
//                if importable == 0 {
//                    self?.dismissModal()
//                } else {
//                    self?.viewController.presenter.handleGoogleAuthImport(codes)
//                }
//            }, cancel: { [weak self] in
//                self?.dismissModal()
//            })
//
//        let vc = UIHostingController(rootView: google)
//        vc.view.backgroundColor = .clear
//        vc.configureAsModal()
//        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toLastPassSummary(importable: Int, total: Int, codes: [Code]) {
//        let lastPass = CameraLastPass(
//            importedCount: importable,
//            totalCount: total,
//            action: { [weak self] in
//                if importable == 0 {
//                    self?.dismissModal()
//                } else {
//                    self?.viewController.presenter.handleLastPassImport(codes)
//                }
//            }, cancel: { [weak self] in
//                self?.dismissModal()
//            })
//
//        let vc = UIHostingController(rootView: lastPass)
//        vc.view.backgroundColor = .clear
//        vc.configureAsModal()
//        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toCameraError(_ error: String) {
//        let alert = UIAlertController.makeSimple(
//            with: T.Commons.error,
//            message: error,
//            buttonTitle: T.Commons.ok,
//            finished: { [weak self] in self?.toFinish() }
//        )
//        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toPushPermissions() {
//        guard let navi = viewController.navigationController else { return }
//        navi.setNavigationBarHidden(true, animated: false)
//        PushNotificationPermissionFlowController.push(on: navi, parent: self)
    }
    
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID) {
//        guard let navi = viewController.navigationController else { return }
//        navi.setNavigationBarHidden(true, animated: false)
//        BrowserExtensionPairingFlowController.push(in: navi, parent: self, with: extensionID)
    }
    
    func toRename(currentName: String, secret: String) {
//        let alert = AlertControllerPromptFactory.create(
//            title: T.Tokens.enterServiceName,
//            message: nil,
//            actionName: T.Commons.rename,
//            defaultText: currentName,
//            action: { [weak self] newName in
//                self?.viewController.presenter.handleRename(newName: newName, secret: secret)
//            }, cancel: { [weak self] in
//                self?.viewController.presenter.handleCancelRename(secret: secret)
//            }, verify: { serviceName in
//                ServiceRules.isServiceNameValid(serviceName: serviceName)
//            })
//
//        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toSendLogs(auditID: UUID) {
//        UploadLogsNavigationFlowController.present(on: viewController, auditID: auditID, parent: self)
    }
}

extension AddingServiceMainFlowController {
    func dismissModal() {
//        viewController.dismiss(animated: true) { [weak self] in
//            self?.viewController.presenter.handleResumeScanning()
//        }
    }
}

extension AddingServiceMainFlowController: PushNotificationPermissionFlowControllerParent {
    func pushNotificationsDidEnd() {
        viewController.presenter.handlePushNotificationEnded()
    }
}

extension AddingServiceMainFlowController: SelectFromGalleryFlowControllerParent {
    func galleryServiceWasCreated(serviceData: ServiceData) {
//        parent?.cameraScannerServiceWasCreated(serviceData: serviceData)
//        galleryViewController = nil
    }
    
    func galleryDidFinish() {
//        toFinish()
//        galleryViewController = nil
    }
    
    func galleryDidCancel() {
//        viewController.presenter.handleGalleryCancelled()
//        galleryViewController = nil
    }
    
    func galleryToSendLogs(auditID: UUID) {
//        toSendLogs(auditID: auditID)
//        galleryViewController = nil
    }
}

extension AddingServiceMainFlowController: BrowserExtensionPairingFlowControllerParent {
    func pairingSuccess() {
//        guard let navi = viewController.navigationController else { return }
//        navi.setNavigationBarHidden(true, animated: false)
//        BrowserExtensionSuccessFlowController.push(in: navi, parent: self)
    }
    
    func pairingError() {
//        guard let navi = viewController.navigationController else { return }
//        navi.setNavigationBarHidden(true, animated: false)
//        BrowserExtensionFailureFlowController.push(in: navi, parent: self)
    }
    
    func pairingAlreadyPaired() {
//        guard let navi = viewController.navigationController else { return }
//        navi.setNavigationBarHidden(true, animated: false)
//        BrowserExtensionPairingAlreadyPairedFlowController.push(in: navi, parent: self)
    }
}

extension AddingServiceMainFlowController: BrowserExtensionFailureFlowControllerParent {
    func browserExtensionFailureClose() {
        close()
    }
    
    func browserExtensionFailurePairing() {
//        guard let navi = viewController.navigationController else { return }
//        navi.popToRootViewController(animated: true)
//        viewController.presenter.handleResumeScanning()
    }
}

extension AddingServiceMainFlowController: BrowserExtensionPairingAlreadyPairedFlowControllerParent {
    func browserExtensionAlreadyPairedClose() {
        close()
        NotificationCenter.default.post(name: .switchToBrowserExtension, object: nil)
    }
}

extension AddingServiceMainFlowController: BrowserExtensionSuccessFlowControllerParent {
    func browserExtensionSuccessClose() {
        close()
        NotificationCenter.default.post(name: .switchToBrowserExtension, object: nil)
    }
}

extension AddingServiceMainFlowController: UploadLogsNavigationFlowControllerParent {
    func uploadLogsClose() {
        close() // TODO!
    }
}
