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

protocol SelectFromGalleryFlowControllerParent: AnyObject {
    func galleryDidFinish()
    func galleryDidImport(count: Int)
    func galleryDidCancel()
    func galleryServiceWasCreated(serviceData: ServiceData)
    func galleryToSendLogs(auditID: UUID)
}

protocol SelectFromGalleryFlowControlling: AnyObject {
    func toNoCodesFound()
    func toErrorWhileScanning()
    func toSelectCode(from codes: [Code])
    func toDuplicatedCode(forceAdd: @escaping Callback)
    func toDidAddCode(serviceData: ServiceData)
    func toDidImport(count: Int)
    func toAppStore()
    func toCancel()
    func toGoogleAuthSummary(importable: Int, total: Int, codes: [Code])
    func toLastPassSummary(importable: Int, total: Int, codes: [Code])
    func toRename(currentName: String, secret: String)
    func toSendLogs(auditID: UUID)
}

final class SelectFromGalleryFlowController: FlowController {
    private weak var parent: SelectFromGalleryFlowControllerParent?
    private weak var parentViewController: UIViewController?
    private var applyOverlay = false
    
    static func present(
        on viewController: UIViewController,
        applyOverlay: Bool,
        parent: SelectFromGalleryFlowControllerParent
    ) -> UIViewController {
        let view = SelectFromGalleryViewController()
        let flowController = SelectFromGalleryFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.selectFromGalleryModuleInteractor()
        let presenter = SelectFromGalleryPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        flowController.parentViewController = viewController
        flowController.applyOverlay = applyOverlay
        flowController.presentPicker()
        
        return view
    }
    
    var viewController: SelectFromGalleryViewController { _viewController as! SelectFromGalleryViewController }
}

extension SelectFromGalleryFlowController: SelectFromGalleryFlowControlling {
    func toNoCodesFound() {
        let ac = AlertController(
            title: T.Tokens.noQrCodesFound,
            message: T.Tokens.noCorrectQrCodeFoundTitle,
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(
            title: T.Commons.ok,
            style: .cancel) { [weak self] _ in self?.toCancel() }
        )
        ac.addAction(UIAlertAction(
            title: T.Commons.retry,
            style: .default) { [weak self] _ in self?.presentPicker() }
        )
        ac.show(animated: true, completion: nil)
    }
    
    func toErrorWhileScanning() {
        let errorView = CameraError.generalEror.view { [weak self] in
            self?.dismissModalAndTryAgain()
        } cancel: { [weak self] in
            self?.dismissModal()
        }
        
        let vc = UIHostingController(rootView: errorView)
        configureViewController(vc)
        parentViewController?.present(vc, animated: true, completion: nil)
    }
    
    func toSelectCode(from codes: [Code]) {
        let ac = AlertController(
            title: T.Tokens.selectService,
            message: T.Tokens.addingServiceQuestionTitle,
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(
            title: T.Commons.cancel,
            style: .cancel) { [weak self] _ in self?.toCancel() }
        )
        codes.forEach { code in
            ac.addAction(UIAlertAction(
                title: code.summarizeDescription ?? T.Browser.unkownName,
                style: .destructive
            ) { [weak self] _ in
                self?.viewController.presenter.handleSelectedCode(code)
            })
        }
        ac.show(animated: true, completion: nil)
    }
    
    func toDuplicatedCode(forceAdd: @escaping Callback) {
        let errorView = CameraError.duplicatedCode.view { [weak self] in
            forceAdd()
            self?.dismissModal()
        } cancel: { [weak self] in
            self?.dismissModal()
        }
        
        let vc = UIHostingController(rootView: errorView)
        configureViewController(vc)
        parentViewController?.present(vc, animated: true, completion: nil)
    }
    
    func toDidAddCode(serviceData: ServiceData) {
        let advice = SelectFromGalleryAdvice { [weak self] in
            self?.parent?.galleryServiceWasCreated(serviceData: serviceData)
        }
        let vc = UIHostingController(rootView: advice)
        vc.configureAsPhoneFullscreenModal()
        parentViewController?.present(vc, animated: true, completion: nil)
    }
    
    func toDidImport(count: Int) {
        parent?.galleryDidImport(count: count)
    }
    
    func toAppStore() {
        let errorView = CameraError.appStore.view { [weak self] in
            self?.dismissModalAndTryAgain()
        } cancel: { [weak self] in
            self?.dismissModal()
        }
        
        let vc = UIHostingController(rootView: errorView)
        configureViewController(vc)
        parentViewController?.present(vc, animated: true, completion: nil)
    }
    
    func toCancel() {
        parent?.galleryDidCancel()
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
            },
            cancel: { [weak self] in
                self?.dismissModal()
            })
        
        let vc = UIHostingController(rootView: google)
        configureViewController(vc)
        parentViewController?.present(vc, animated: true, completion: nil)
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
        configureViewController(vc)
        parentViewController?.present(vc, animated: true, completion: nil)
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
        
        parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    func toSendLogs(auditID: UUID) {
        parent?.galleryToSendLogs(auditID: auditID)
    }
}

private extension SelectFromGalleryFlowController {
    func dismissModal() {
        parentViewController?.dismiss(animated: true) { [weak self] in
            self?.toCancel()
        }
    }
    
    func dismissModalAndTryAgain() {
        parentViewController?.dismiss(animated: true) { [weak self] in
            self?.presentPicker()
        }
    }
    
    func presentPicker() {
        let picker = viewController.createImagePicker()
        parentViewController?.present(picker, animated: true)
    }
    
    func configureViewController(_ vc: UIViewController) {
        if applyOverlay {
            vc.view.backgroundColor = Theme.Colors.cameraOverlay
        } else {
            vc.view.backgroundColor = .clear
        }
        vc.configureAsModal()
    }
}
