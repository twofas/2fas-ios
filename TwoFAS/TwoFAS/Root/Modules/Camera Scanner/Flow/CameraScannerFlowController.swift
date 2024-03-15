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
import Data
import Common
import SwiftUI
import Storage

protocol CameraScannerFlowControllerParent: AnyObject {
    func cameraScannerDidFinish()
    func cameraScannerDidImport(count: Int)
    func cameraScannerServiceWasCreated(serviceData: ServiceData)
}

protocol CameraScannerFlowControlling: AnyObject {
    func toGeneralError()
    func toDuplicatedCode(forceAdd: @escaping Callback)
    func toAppStore()
    func toGallery()
    func toFinish()
    func toImportSummary(count: Int)
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func toLastPassSummary(importable: Int, total: Int, codes: [Code])
    func toCameraError(_ error: String)
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID)
    func toSendLogs(auditID: UUID)
    func toPushPermissions(extensionID: ExtensionID)
    func toRename(currentName: String, secret: String)
    func toServiceWasCreated(serviceData: ServiceData)
    func toCameraNotAvailable()
}

final class CameraScannerFlowController: FlowController {
    private weak var parent: CameraScannerFlowControllerParent?
    private var galleryViewController: UIViewController?
    
    static func present(
        on viewController: UIViewController,
        parent: CameraScannerFlowControllerParent
    ) {
        let view = CameraScannerViewController()
        let flowController = CameraScannerFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.cameraScannerModuleInteractor()
        let presenter = CameraScannerPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        view.modalPresentationStyle = .fullScreen
        view.isModalInPresentation = true
        
        viewController.present(view, animated: true)
    }
    
    static func setRoot(
        in navigationController: UINavigationController,
        parent: CameraScannerFlowControllerParent
    ) {
        let view = CameraScannerViewController()
        let flowController = CameraScannerFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.cameraScannerModuleInteractor()
        let presenter = CameraScannerPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
}

extension CameraScannerFlowController: CameraScannerFlowControlling {
    func toGeneralError() {
        let errorView = CameraError.generalEror.view(with: { [weak self] in
            self?.dismissModal()
        }, cancel: nil)
        let vc = UIHostingController(rootView: errorView)
        vc.view.backgroundColor = .clear
        vc.configureAsModal()
        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toDuplicatedCode(forceAdd: @escaping Callback) {
        let errorView = CameraError.duplicatedCode.view(with: { [weak self] in
            forceAdd()
            self?.dismissModal()
        }, cancel: nil)
        let vc = UIHostingController(rootView: errorView)
        vc.view.backgroundColor = .clear
        vc.configureAsModal()
        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toAppStore() {
        let errorView = CameraError.appStore.view(with: { [weak self] in
            self?.dismissModal()
        }, cancel: nil)
        let vc = UIHostingController(rootView: errorView)
        vc.view.backgroundColor = .clear
        vc.configureAsModal()
        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toGallery() {
        galleryViewController = SelectFromGalleryFlowController.present(
            on: viewController,
            applyOverlay: false,
            parent: self
        )
    }
    
    func toFinish() {
        parent?.cameraScannerDidFinish()
    }
    
    func toImportSummary(count: Int) {
        parent?.cameraScannerDidImport(count: count)
    }
    
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code]) {
        let google = CameraGoogleAuth(
            importedCount: importable,
            totalCount: total,
            action: { [weak self] in
                if importable == 0 {
                    self?.dismissModal()
                } else {
                    self?.viewController.presenter.handleGoogleAuthImport(codes)
                }
            }, cancel: { [weak self] in
                self?.dismissModal()
            })
        
        let vc = UIHostingController(rootView: google)
        vc.view.backgroundColor = .clear
        vc.configureAsModal()
        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toLastPassSummary(importable: Int, total: Int, codes: [Code]) {
        let lastPass = CameraLastPass(
            importedCount: importable,
            totalCount: total,
            action: { [weak self] in
                if importable == 0 {
                    self?.dismissModal()
                } else {
                    self?.viewController.presenter.handleLastPassImport(codes)
                }
            }, cancel: { [weak self] in
                self?.dismissModal()
            })
        
        let vc = UIHostingController(rootView: lastPass)
        vc.view.backgroundColor = .clear
        vc.configureAsModal()
        viewController.present(vc, animated: true, completion: nil)
    }
    
    func toCameraError(_ error: String) {
        let alert = UIAlertController.makeSimple(
            with: T.Commons.error,
            message: error,
            buttonTitle: T.Commons.ok,
            finished: { [weak self] in self?.toFinish() }
        )
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toCameraNotAvailable() {
        let ac = AlertController.cameraNotAvailable
        viewController.present(ac, animated: true)
    }
    
    func toPushPermissions(extensionID: ExtensionID) {
        guard let navi = viewController.navigationController else { return }
        navi.setNavigationBarHidden(true, animated: false)
        PushNotificationPermissionPlainFlowController.push(on: navi, parent: self, extensionID: extensionID)
    }
    
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID) {
        guard let navi = viewController.navigationController else { return }
        navi.setNavigationBarHidden(true, animated: false)
        BrowserExtensionPairingPlainFlowController.push(in: navi, parent: self, with: extensionID)
    }
    
    func toRename(currentName: String, secret: String) {
        let alert = AlertControllerPromptFactory.create(
            title: T.Tokens.enterServiceName,
            message: nil,
            actionName: T.Commons.rename,
            defaultText: currentName,
            inputConfiguration: .name,
            action: { [weak self] newName in
                self?.viewController.presenter.handleRename(newName: newName, secret: secret)
            }, cancel: { [weak self] in
                self?.viewController.presenter.handleCancelRename(secret: secret)
            }, verify: { serviceName in
                ServiceRules.isServiceNameValid(serviceName: serviceName)
            })
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toServiceWasCreated(serviceData: ServiceData) {
        parent?.cameraScannerServiceWasCreated(serviceData: serviceData)
    }
    
    func toSendLogs(auditID: UUID) {
        UploadLogsNavigationFlowController.present(on: viewController, auditID: auditID, parent: self)
    }
}

extension CameraScannerFlowController {
    var viewController: CameraScannerViewController { _viewController as! CameraScannerViewController }
    
    func dismissModal() {
        viewController.dismiss(animated: true) { [weak self] in
            self?.viewController.presenter.handleResumeScanning()
        }
    }
}

extension CameraScannerFlowController: PushNotificationPermissionPlainFlowControllerParent {
    func pushNotificationsClose(extensionID: ExtensionID?) {
        guard let extensionID else {
            toFinish()
            return
        }
        toTwoFASWebExtensionPairing(for: extensionID)
    }
}

extension CameraScannerFlowController: SelectFromGalleryFlowControllerParent {
    func galleryDidImport(count: Int) {
        parent?.cameraScannerDidImport(count: count)
        galleryViewController = nil
    }
    
    func galleryServiceWasCreated(serviceData: ServiceData) {
        parent?.cameraScannerServiceWasCreated(serviceData: serviceData)
        galleryViewController = nil
    }
    
    func galleryDidFinish() {
        toFinish()
        galleryViewController = nil
    }
    
    func galleryDidCancel() {
        viewController.presenter.handleGalleryCancelled()
        galleryViewController = nil
    }
    
    func galleryToSendLogs(auditID: UUID) {
        toSendLogs(auditID: auditID)
        galleryViewController = nil
    }
}

extension CameraScannerFlowController: BrowserExtensionPairingPlainFlowControllerParent {
    func pairingSuccess() {
        guard let navi = viewController.navigationController else { return }
        navi.setNavigationBarHidden(true, animated: false)
        BrowserExtensionSuccessFlowController.push(in: navi, parent: self)
    }
    
    func pairingError() {
        guard let navi = viewController.navigationController else { return }
        navi.setNavigationBarHidden(true, animated: false)
        BrowserExtensionFailureFlowController.push(in: navi, parent: self)
    }
    
    func pairingAlreadyPaired() {
        guard let navi = viewController.navigationController else { return }
        navi.setNavigationBarHidden(true, animated: false)
        BrowserExtensionPairingAlreadyPairedFlowController.push(in: navi, parent: self)
    }
}

extension CameraScannerFlowController: BrowserExtensionFailureFlowControllerParent {
    func browserExtensionFailureClose() {
        toFinish()
    }
    
    func browserExtensionFailurePairing() {
        guard let navi = viewController.navigationController else { return }
        navi.popToRootViewController(animated: true)
        viewController.presenter.handleResumeScanning()
    }
}

extension CameraScannerFlowController: BrowserExtensionPairingAlreadyPairedFlowControllerParent {
    func browserExtensionAlreadyPairedClose() {
        toFinish()
        NotificationCenter.default.post(name: .switchToBrowserExtension, object: nil)
    }
}

extension CameraScannerFlowController: BrowserExtensionSuccessFlowControllerParent {
    func browserExtensionSuccessClose() {
        toFinish()
        NotificationCenter.default.post(name: .switchToBrowserExtension, object: nil)
    }
}

extension CameraScannerFlowController: UploadLogsNavigationFlowControllerParent {
    func uploadLogsClose() {
        toFinish()
    }
}
