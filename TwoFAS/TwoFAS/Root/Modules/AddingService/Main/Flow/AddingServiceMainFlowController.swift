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

protocol AddingServiceMainFlowControllerParent: AnyObject {
    func mainDismiss()
    func mainToToken(serviceData: ServiceData)
    func mainToAddManually()
    func mainToGallery()
    func mainToGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func mainToLastPassSummary(importable: Int, total: Int, codes: [Code])
    func mainToSendLogs(auditID: UUID)
    func mainToPushPermissions(for extensionID: ExtensionID)
    func mainToTwoFASWebExtensionPairing(for extensionID: ExtensionID)
    func mainToGuides()
}

protocol AddingServiceMainFlowControlling: AnyObject {
    func toToken(serviceData: ServiceData)
    func close()
    func toAddManually()
    func toAppSettings()
    func toGuides()
    
    func toGeneralError()
    func toDuplicatedCode(forceAdd: @escaping Callback)
    func toAppStore()
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func toLastPassSummary(importable: Int, total: Int, codes: [Code])
    func toGallery()
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID)
    func toSendLogs(auditID: UUID)
    func toPushPermissions(for extensionID: ExtensionID)
    func toRename(currentName: String, secret: String)
}

final class AddingServiceMainFlowController: FlowController {
    private weak var parent: AddingServiceMainFlowControllerParent?
    
    static func embed(
        in viewController: UIViewController & AddingServiceViewControlling,
        parent: AddingServiceMainFlowControllerParent
    ) {
        let view = AddingServiceMainViewController()
        let flowController = AddingServiceMainFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.addingServiceMainModuleInteractor()
        
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
        parent?.mainDismiss()
    }
    
    func toAddManually() {
        parent?.mainToAddManually()
    }
    
    func toAppSettings() {
        parent?.mainDismiss()
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func toGuides() {
        parent?.mainToGuides()
    }
    
    func toGeneralError() {
        let alert = UIAlertController.makeSimple(
            with: T.Tokens.thisQrCodeIsInavlid,
            message: T.Tokens.scanQrCodeTitle,
            buttonTitle: T.Commons.ok,
            finished: { [weak self] in self?.viewController.presenter.handleResumeCamera() }
        )
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toDuplicatedCode(forceAdd: @escaping Callback) {
        let alert = UIAlertController(
            title: T.Commons.warning,
            message: T.Tokens.serviceAlreadyExists,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.yes, style: .destructive, handler: { [weak self] _ in
            forceAdd()
            self?.viewController.presenter.handleResumeCamera()
        }))
        alert.addAction(UIAlertAction(title: T.Commons.no, style: .cancel, handler: { [weak self] _ in
            self?.viewController.presenter.handleResumeCamera()
        }))

        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toAppStore() {
        let alert = UIAlertController.makeSimple(
            with: T.Tokens.qrCodeLeadsToAppStore,
            message: T.Tokens.scanQrCodeTitle,
            buttonTitle: T.Commons.ok,
            finished: { [weak self] in self?.viewController.presenter.handleResumeCamera() }
        )
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toGallery() {
        parent?.mainToGallery()
    }
    
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code]) {
        parent?.mainToGoogleAuthSummary(importable: importable, total: total, codes: codes)
    }
    
    func toLastPassSummary(importable: Int, total: Int, codes: [Code]) {
        parent?.mainToLastPassSummary(importable: importable, total: total, codes: codes)
    }
    
    func toPushPermissions(for extensionID: ExtensionID) {
        parent?.mainToPushPermissions(for: extensionID)
    }
    
    func toTwoFASWebExtensionPairing(for extensionID: ExtensionID) {
        parent?.mainToTwoFASWebExtensionPairing(for: extensionID)
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
    
    func toSendLogs(auditID: UUID) {
        parent?.mainToSendLogs(auditID: auditID)
    }
}
