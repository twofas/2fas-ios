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

protocol TokensPlainFlowControllerParent: AnyObject {
    func tokensSwitchToTokensTab()
}

protocol TokensPlainFlowControlling: AnyObject {
    // MARK: Service
    func toShowSelectAddingMethod(isCameraAvailable: Bool)
    func toDeleteService(serviceData: ServiceData)
    func toShowEditingService(with serviceData: ServiceData, freshlyAdded: Bool, gotoIconEdit: Bool)
    func toServiceWasCreated(_ serviceData: ServiceData)
    // MARK: Section
    func toAskDeleteSection(_ callback: @escaping Callback)
    func toCreateSection(_ callback: @escaping (String) -> Void)
    // MARK: Camera
    func toShowCamera()
    func toCameraNotAvailable()
    // MARK: Initial screen
    func toFileImport()
    func toImportGA()
    func toShowGallery()
    func toHelp()
    // MARK: Link actions
    func toCodeAlreadyExists()
    func toShowShouldAddCode(with descriptionText: String?)
    func toSendLogs(auditID: UUID)
    func toShouldRenameService(currentName: String, secret: String)
    // MARK: Sort
    func toShowSortTypes(selectedSortOption: SortType, callback: @escaping (SortType) -> Void)
}

final class TokensPlainFlowController: FlowController {
    private weak var parent: TokensPlainFlowControllerParent?
    private weak var naviViewController: UINavigationController!
    private var galleryViewController: UIViewController?
    
    @discardableResult
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: TokensPlainFlowControllerParent
    ) -> TokensViewController {
        let view = TokensViewController()
        let flowController = TokensPlainFlowController(viewController: view)
        flowController.parent = parent
        flowController.naviViewController = navigationController
        let interactor = InteractorFactory.shared.tokensModuleInteractor()
        let presenter = TokensPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
        navigationController.setNavigationBarHidden(false, animated: false)
        return view
    }
}

extension TokensPlainFlowController: TokensPlainFlowControlling {
    // MARK: - Service
    
    func toShowSelectAddingMethod(isCameraAvailable: Bool) {
        let qrCode = UIAlertAction(title: T.Commons.scanQrCode, style: .default) { [weak self] _ in
            if isCameraAvailable {
                self?.toShowCamera()
            } else {
                self?.toCameraNotAvailable()
            }
        }
        let gallery = UIAlertAction(title: T.Tokens.selectFromGallery, style: .default) { [weak self] _ in
            self?.toShowGallery()
        }
        let manually = UIAlertAction(title: T.Commons.enterCodeManually, style: .default) { [weak self] _ in
            self?.toShowAddingServiceManually()
        }
        
        let cancel = UIAlertAction(title: T.Commons.cancel, style: .cancel, handler: nil)
        
        let controller = UIAlertController(title: T.Tokens.chooseMethod, message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(qrCode)
        if !isCameraAvailable {
            controller.addAction(gallery)
        }
        controller.addAction(manually)
        controller.addAction(cancel)
        
        if let popover = controller.popoverPresentationController, let item = viewController.addButton {
            popover.barButtonItem = item
            popover.permittedArrowDirections = .up
        }
        
        naviViewController.present(controller, animated: true, completion: nil)
    }
    
    func toDeleteService(serviceData: ServiceData) {
        TrashServiceFlowController.present(on: naviViewController, parent: self, serviceData: serviceData)
    }
    
    func toShowEditingService(with serviceData: ServiceData, freshlyAdded: Bool = false, gotoIconEdit: Bool = false) {
        ComposeServiceNavigationFlowController.present(
            on: naviViewController,
            parent: self,
            serviceData: serviceData,
            gotoIconEdit: gotoIconEdit,
            freshlyAdded: freshlyAdded
        )
    }
    
    func toServiceWasCreated(_ serviceData: ServiceData) {
        FirstCodeAddedStatsController.markStats() // TODO: Move to MainRepository and proper interactor
        ServiceAddedFlowController.present(serviceData: serviceData, on: naviViewController, parent: self)
    }
    
    func toShowAddingServiceManually() {
        ComposeServiceNavigationFlowController.present(
            on: naviViewController,
            parent: self,
            serviceData: nil,
            gotoIconEdit: false,
            freshlyAdded: false
        )
    }
    
    // MARK: - Section
    
    func toAskDeleteSection(_ callback: @escaping Callback) {
        let ac = AlertController(
            title: T.Tokens.removingGroup,
            message: T.Tokens.allTokensMovedToGroupTitle,
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: T.Commons.delete, style: .destructive) { _ in callback() })
        ac.show(animated: true, completion: nil)
    }
    
    func toCreateSection(_ callback: @escaping (String) -> Void) {
        let alert = AlertControllerPromptFactory.create(
            title: T.Tokens.addGroup,
            message: T.Tokens.groupName,
            actionName: T.Commons.add,
            defaultText: "",
            action: { newName in
                callback(newName.trim())
            },
            cancel: nil,
            verify: { sectionName in
                ServiceRules.isSectionNameValid(sectionName: sectionName.trim())
            })
        
        naviViewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Camera
    
    func toShowCamera() {
        CameraScannerNavigationFlowController.present(on: naviViewController, parent: self)
    }
    
    func toCameraNotAvailable() {
        let ac = AlertController.cameraNotAvailable
        ac.show(animated: true, completion: nil)
    }
    
    // MARK: - Initial screen
    
    func toFileImport() {
        ImporterOpenFileFlowController.present(on: naviViewController, parent: self, url: nil)
    }
    
    func toImportGA() {
        GridViewGAImportNavigationFlowController.present(on: naviViewController, parent: self)
    }
    
    func toShowGallery() {
        galleryViewController = SelectFromGalleryFlowController.present(
            on: naviViewController,
            applyOverlay: true,
            parent: self
        )
    }
    
    func toHelp() {
        UIApplication.shared.open(
            URL(string: "https://2fas.com/how-to-enable-2fa")!,
            options: [:],
            completionHandler: nil
        )
    }
    
    // MARK: - Link actions
    
    func toCodeAlreadyExists() {
        let alert = UIAlertController.makeSimple(with: T.Commons.info, message: T.Notifications.tokenAlreadyAdded)
        naviViewController.present(alert, animated: true)
    }
    
    func toShowShouldAddCode(with descriptionText: String?) {
        let msg = T.Notifications.addCodeQuestionTitle(descriptionText ?? T.Browser.unkownName)
        let alert = UIAlertController(title: T.Notifications.addingCode, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel) { [weak self] _ in
            self?.viewController.presenter.handleClearStoredCode()
        })
        alert.addAction(UIAlertAction(title: T.Commons.add, style: .default) { [weak self] _ in
            self?.viewController.presenter.handleAddStoredCode()
        })
        
        naviViewController.present(alert, animated: true)
    }
    
    func toSendLogs(auditID: UUID) {
        sendLogs(auditID: auditID)
    }
    
    func toShouldRenameService(currentName: String, secret: String) {
        let alert = AlertControllerPromptFactory.create(
            title: T.Tokens.enterServiceName,
            message: nil,
            actionName: T.Commons.rename,
            defaultText: currentName,
            action: { [weak self] newName in
                self?.viewController.presenter.handleRenameService(newName: newName, secret: secret)
            }, cancel: { [weak self] in
                self?.viewController.presenter.handleCancelRenaming(secret: secret)
            }, verify: { serviceName in
                ServiceRules.isServiceNameValid(serviceName: serviceName)
            }
        )
        
        naviViewController.present(alert, animated: true)
    }
    
    // MARK: - Sort
    
    func toShowSortTypes(selectedSortOption: SortType, callback: @escaping (SortType) -> Void) {
        let preferredStyle: UIAlertController.Style = {
            if UIDevice.isiPad {
                return .alert
            }
            return .actionSheet
        }()
        let alertController = AlertController(title: T.Tokens.sortBy, message: nil, preferredStyle: preferredStyle)
        SortType.allCases.forEach { sortType in
            let action = UIAlertAction(title: sortType.localized, style: .default) { _ in
                callback(sortType)
            }
            action.setValue(sortType.image(forSelectedOption: selectedSortOption), forKey: "image")
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel, handler: { _ in }))
        naviViewController.present(alertController, animated: true)
    }
}

extension TokensPlainFlowController {
    var viewController: TokensViewController { _viewController as! TokensViewController }
}

private extension TokensPlainFlowController {
    func dismiss(actions: Set<TokensExternalAction> = [.finishedFlow], completion: Callback? = nil) {
        naviViewController.dismiss(animated: true) { [weak self] in
            completion?()
            self?.viewController.presenter.handleExternalAction(actions)
        }
    }
    
    func sendLogs(auditID: UUID) {
        UploadLogsNavigationFlowController.present(on: naviViewController, auditID: auditID, parent: self)
    }
}

extension TokensPlainFlowController: CameraScannerNavigationFlowControllerParent {
    func cameraScannerDidFinish() {
        dismiss(actions: [.finishedFlow, .newData, .sync])
    }

    func cameraScannerServiceWasCreated(serviceData: ServiceData) {
        parent?.tokensSwitchToTokensTab()
        dismiss(actions: [.finishedFlow, .addedService(serviceData: serviceData), .sync])
    }
}

extension TokensPlainFlowController: SelectFromGalleryFlowControllerParent {
    func galleryServiceWasCreated(serviceData: ServiceData) {
        parent?.tokensSwitchToTokensTab()
        dismiss(actions: [.finishedFlow, .addedService(serviceData: serviceData), .sync]) { [weak self] in
            self?.galleryViewController = nil
        }
    }
    
    func galleryDidFinish() {
        dismiss(actions: [.finishedFlow, .newData, .sync]) { [weak self] in
            self?.galleryViewController = nil
        }
    }
    
    func galleryDidCancel() {
        dismiss { [weak self] in
            self?.galleryViewController = nil
        }
    }
    
    func galleryToSendLogs(auditID: UUID) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.sendLogs(auditID: auditID)
            self?.galleryViewController = nil
        }
    }
}

extension TokensPlainFlowController: GridViewGAImportNavigationFlowControllerParent {
    func gaImportDidFinish() {
        dismiss(actions: [.finishedFlow, .newData, .sync])
    }
    
    func gaChooseQR() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.toShowGallery()
        }
    }
    
    func gaScanQR() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.viewController.presenter.handleShowCamera()
        }
    }
}

extension TokensPlainFlowController: TrashServiceFlowControllerParent {
    func didTrashService() {
        dismiss(actions: [.finishedFlow, .newData, .sync])
    }
    
    func closeTrashService() {
        dismiss()
    }
}

extension TokensPlainFlowController: ComposeServiceNavigationFlowControllerParent {
    func composeServiceDidFinish() {
        dismiss(actions: [.finishedFlow, .newData, .sync])
    }
    
    func composeServiceWasCreated(serviceData: ServiceData) {
        parent?.tokensSwitchToTokensTab()
        dismiss(actions: [.finishedFlow, .addedService(serviceData: serviceData), .sync])
    }
    
    func composeServiceServiceWasModified() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            let alert = UIAlertController.makeSimple(
                with: T.Commons.info,
                message: T.Notifications.serviceAlreadyModifiedTitle
            )
            self?.naviViewController.present(alert, animated: true)
        }
    }
    
    func composeServiceServiceWasDeleted() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            let alert = UIAlertController.makeSimple(
                with: T.Commons.info,
                message: T.Notifications.serviceAlreadyRemovedTitle
            )
            self?.naviViewController.present(alert, animated: true)
        }
    }
}

extension TokensPlainFlowController: ImporterOpenFileFlowControllerParent {
    func closeImporter() {
        dismiss(actions: [.finishedFlow, .newData])
    }
}

extension TokensPlainFlowController: UploadLogsNavigationFlowControllerParent {
    func uploadLogsClose() {
        dismiss()
    }
}

extension TokensPlainFlowController: ServiceAddedFlowControllerParent {
    func serviceAddedEditService(_ serviceData: ServiceData) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.toShowEditingService(with: serviceData, freshlyAdded: true)
        }
    }
    
    func serviceAddedEditIcon(_ serviceData: ServiceData) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.toShowEditingService(with: serviceData, freshlyAdded: true, gotoIconEdit: true)
        }
    }
    
    func serviceAddedClose() {
        dismiss()
    }
}
