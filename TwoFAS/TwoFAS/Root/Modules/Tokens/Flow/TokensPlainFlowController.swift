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
import SwiftUI

protocol TokensPlainFlowControllerParent: AnyObject {
    func tokensSwitchToTokensTab()
    func tokensSwitchToSettingsExternalImport()
    func tokensSwitchToSettingsBackup()
}

protocol TokensPlainFlowControlling: AnyObject {
    // MARK: Service
    func toAddService()
    func toDeleteService(serviceData: ServiceData)
    func toShowEditingService(with serviceData: ServiceData, freshlyAdded: Bool, gotoIconEdit: Bool)
    func toServiceWasCreated(_ serviceData: ServiceData)
    // MARK: Section
    func toAskDeleteSection(_ callback: @escaping Callback)
    func toCreateSection(_ callback: @escaping (String) -> Void)
    func toRenameSection(current name: String, callback: @escaping (String) -> Void)
    // MARK: Camera
    func toShowCamera()
    func toCameraNotAvailable()
    // MARK: Initial screen
    func toFileImport()
    func toShowGallery()
    func toHelp()
    // MARK: Link actions
    func toIncorrectCode()
    func toDuplicatedCode(forceAdd: @escaping Callback, cancel: @escaping Callback)
    func toShowShouldAddCode(with descriptionText: String?)
    func toSendLogs(auditID: UUID)
    func toShouldRenameService(currentName: String, secret: String)
    // MARK: Sort
    func toShowSortTypes(selectedSortOption: SortType, callback: @escaping (SortType) -> Void)
    // MARK: News
    func toNotifications()
    // MARK: Import
    func toShowSummmary(count: Int)
}

final class TokensPlainFlowController: FlowController, TokensNavigationFlowControllerParent {
    private weak var parent: TokensPlainFlowControllerParent?
    private weak var mainSplitViewController: MainSplitViewController?
    private var galleryViewController: UIViewController?
    
    static func showAsTab(
        viewController: TokensViewController,
        in navigationController: UINavigationController
    ) {
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.setNavigationBarHidden(false, animated: false)
    }
    
    static func setup(
        mainSplitViewController: MainSplitViewController,
        parent: TokensPlainFlowControllerParent
    ) -> TokensViewController {
        let view = TokensViewController()
        let flowController = TokensPlainFlowController(viewController: view)
        flowController.parent = parent
        flowController.mainSplitViewController = mainSplitViewController
        let interactor = ModuleInteractorFactory.shared.tokensModuleInteractor()
        let presenter = TokensPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        return view
    }
    
    static func showAsRoot(
        viewController: TokensViewController,
        in navigationController: ContentNavigationController
    ) {
        navigationController.setRootViewController(viewController)
    }
}

extension TokensPlainFlowController: TokensPlainFlowControlling {
    // MARK: - Service
    
    func toAddService() {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        AddingServiceFlowController.present(on: mainSplitViewController, parent: self)
    }
    
    func toAddServiceManually(_ name: String?) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        AddingServiceManuallyNavigationFlowController.present(
            on: mainSplitViewController,
            parent: self,
            name: name
        )
    }
    
    func toDeleteService(serviceData: ServiceData) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        TrashServiceFlowController.present(on: mainSplitViewController, parent: self, serviceData: serviceData)
    }
    
    func toShowEditingService(with serviceData: ServiceData, freshlyAdded: Bool = false, gotoIconEdit: Bool = false) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        ComposeServiceNavigationFlowController.present(
            on: mainSplitViewController,
            parent: self,
            serviceData: serviceData,
            gotoIconEdit: gotoIconEdit,
            freshlyAdded: freshlyAdded
        )
    }
    
    func toServiceWasCreated(_ serviceData: ServiceData) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        
        FirstCodeAddedStatsController.markStats() // TODO: Move to MainRepository and proper interactor
        AddingServiceTokenFlowController.present(on: mainSplitViewController, parent: self, serviceData: serviceData)
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
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        let alert = AlertControllerPromptFactory.create(
            title: T.Tokens.addGroup,
            message: T.Tokens.groupName,
            actionName: T.Commons.add,
            defaultText: "",
            inputConfiguration: .name,
            action: { newName in
                callback(newName.trim())
            },
            cancel: nil,
            verify: { sectionName in
                ServiceRules.isSectionNameValid(sectionName: sectionName.trim())
            })
        
        mainSplitViewController.present(alert, animated: true, completion: nil)
    }
    
    func toRenameSection(current name: String, callback: @escaping (String) -> Void) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        let alert = AlertControllerPromptFactory.create(
            title: T.Commons.rename,
            message: T.Tokens.groupName,
            actionName: T.Commons.rename,
            defaultText: name,
            inputConfiguration: .name,
            action: { newName in
                callback(newName.trim())
            },
            cancel: nil,
            verify: { sectionName in
                ServiceRules.isSectionNameValid(sectionName: sectionName.trim())
            })
        
        mainSplitViewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Camera
    
    func toShowCamera() {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        CameraScannerNavigationFlowController.present(on: mainSplitViewController, parent: self)
    }
    
    func toCameraNotAvailable() {
        let ac = AlertController.cameraNotAvailable
        ac.show(animated: true, completion: nil)
    }
    
    // MARK: - Initial screen
    
    func toFileImport() {
        parent?.tokensSwitchToSettingsExternalImport()
    }
    
    func toShowGallery() {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        galleryViewController = SelectFromGalleryFlowController.present(
            on: mainSplitViewController,
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
    func toDuplicatedCode(forceAdd: @escaping Callback, cancel: @escaping Callback) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        
        let alert = UIAlertController(
            title: T.Commons.warning,
            message: T.Tokens.serviceAlreadyExists,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.yes, style: .destructive, handler: { [weak self] _ in
            self?.parent?.tokensSwitchToTokensTab()
            forceAdd()
        }))
        alert.addAction(UIAlertAction(title: T.Commons.no, style: .cancel, handler: { _ in
            cancel()
        }))

        mainSplitViewController.present(alert, animated: true)
    }
    
    func toShowShouldAddCode(with descriptionText: String?) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        let msg = T.Notifications.addCodeQuestionTitle(descriptionText ?? T.Browser.unkownName)
        let alert = UIAlertController(title: T.Notifications.addingCode, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel) { [weak self] _ in
            self?.viewController.presenter.handleClearStoredCode()
        })
        alert.addAction(UIAlertAction(title: T.Commons.add, style: .default) { [weak self] _ in
            self?.viewController.presenter.handleAddStoredCode()
        })
        
        mainSplitViewController.present(alert, animated: true)
    }
    
    func toIncorrectCode() {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        
        let alert = UIAlertController(
            title: T.Commons.warning,
            message: T.Tokens.thisQrCodeIsInavlid,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel, handler: { _ in }))

        mainSplitViewController.present(alert, animated: true)
    }
    
    func toSendLogs(auditID: UUID) {
        sendLogs(auditID: auditID)
    }
    
    func toShouldRenameService(currentName: String, secret: String) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        let alert = AlertControllerPromptFactory.create(
            title: T.Tokens.enterServiceName,
            message: nil,
            actionName: T.Commons.rename,
            defaultText: currentName,
            inputConfiguration: .name,
            action: { [weak self] newName in
                self?.viewController.presenter.handleRenameService(newName: newName, secret: secret)
            }, cancel: { [weak self] in
                self?.viewController.presenter.handleCancelRenaming(secret: secret)
            }, verify: { serviceName in
                ServiceRules.isServiceNameValid(serviceName: serviceName)
            }
        )
        
        mainSplitViewController.present(alert, animated: true)
    }
    
    // MARK: - Sort
    
    func toShowSortTypes(selectedSortOption: SortType, callback: @escaping (SortType) -> Void) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        
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
        mainSplitViewController.present(alertController, animated: true)
    }
    
    // MARK: - Notifications
    func toNotifications() {
        NewsNavigationFlowController.present(on: viewController, parent: self)
    }
    
    // MARK: - Import
    func toShowSummmary(count: Int) {
        dismiss(actions: [.finishedFlow, .newData, .sync]) { [weak self] in
            self?.showSummary(count: count)
        }
    }
}

extension TokensPlainFlowController {
    var viewController: TokensViewController { _viewController as! TokensViewController }
}

private extension TokensPlainFlowController {
    func dismiss(actions: Set<TokensExternalAction> = [.finishedFlow], completion: Callback? = nil) {
        mainSplitViewController?.dismiss(animated: true) { [weak self] in
            if actions.contains(.refreshImmidiately) {
                self?.viewController.presenter.handleExternalAction(actions)
                completion?()
            } else {
                completion?()
                self?.viewController.presenter.handleExternalAction(actions)
            }
        }
    }
    
    func sendLogs(auditID: UUID) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        UploadLogsNavigationFlowController.present(on: mainSplitViewController, auditID: auditID, parent: self)
    }
}

extension TokensPlainFlowController: CameraScannerNavigationFlowControllerParent {
    func cameraScannerDidImport(count: Int) {
        dismiss(actions: [.finishedFlow, .newData, .sync]) { [weak self] in
            self?.showSummary(count: count)
        }
    }
    
    func cameraScannerDidFinish() {
        dismiss(actions: [.finishedFlow, .newData, .sync])
    }
    
    func cameraScannerServiceWasCreated(serviceData: ServiceData) {
        parent?.tokensSwitchToTokensTab()
        dismiss(actions: [.finishedFlow, .addedService(serviceData: serviceData), .sync])
    }
}

extension TokensPlainFlowController: SelectFromGalleryFlowControllerParent {
    func galleryDidImport(count: Int) {
        dismiss(actions: [.finishedFlow, .newData, .sync]) { [weak self] in
            self?.galleryViewController = nil
            self?.showSummary(count: count)
        }
    }
    
    func galleryServiceWasCreated(serviceData: ServiceData) {
        parent?.tokensSwitchToTokensTab()
        dismiss(actions: [.finishedFlow, .addedService(serviceData: serviceData), .sync]) { [weak self] in
            self?.galleryViewController = nil
            self?.toServiceWasCreated(serviceData)
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
            self?.toAddService()
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
            self?.mainSplitViewController?.present(alert, animated: true)
        }
    }
    
    func composeServiceServiceWasDeleted() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            let alert = UIAlertController.makeSimple(
                with: T.Commons.info,
                message: T.Notifications.serviceAlreadyRemovedTitle
            )
            self?.mainSplitViewController?.present(alert, animated: true)
        }
    }
}

extension TokensPlainFlowController: UploadLogsNavigationFlowControllerParent {
    func uploadLogsClose() {
        dismiss()
    }
}

extension TokensPlainFlowController: AddingServiceManuallyNavigationFlowControllerParent {
    func addingServiceManuallyToClose(_ serviceData: ServiceData) {
        dismiss(actions: [.newData, .refreshImmidiately, .sync]) { [weak self] in
            self?.toServiceWasCreated(serviceData)
        }
    }
    
    func addingServiceManuallyToCancel() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.toAddService()
        }
    }
}

extension TokensPlainFlowController: AddingServiceFlowControllerParent {
    func addingServiceToManual(_ name: String?) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.toAddServiceManually(name)
        }
    }
    
    func addingServiceDismiss() {
        dismiss()
    }
    
    func addingServiceToGallery() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.toShowGallery()
        }
    }
    
    func addingServiceToGoogleAuthSummary(importable: Int, total: Int, codes: [Code]) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.showGoogleAuthSummary(importable: importable, total: total, codes: codes)
        }
    }
    
    func addingServiceToLastPassSummary(importable: Int, total: Int, codes: [Code]) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.showLastPassSummary(importable: importable, total: total, codes: codes)
        }
    }
    
    func addingServiceToSendLogs(auditID: UUID) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.toSendLogs(auditID: auditID)
        }
    }
    
    func addingServiceToPushPermissions(for extensionID: ExtensionID) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.showPushPermission(for: extensionID)
        }
    }
    
    func addingServiceToTwoFASWebExtensionPairing(for extensionID: ExtensionID) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.showWebPairing(for: extensionID)
        }
    }
    
    func addingServiceToGuides() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.showGuides()
        }
    }
    
    func addingServiceToToken(_ serviceData: ServiceData) {
        dismiss(actions: [.newData, .refreshImmidiately, .sync]) { [weak self] in
            self?.toServiceWasCreated(serviceData)
        }
    }
}

private extension TokensPlainFlowController {
    func showGoogleAuthSummary(importable: Int, total: Int, codes: [Code]) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        
        let google = CameraGoogleAuth(
            importedCount: importable,
            totalCount: total,
            action: { [weak self] in
                if importable == 0 {
                    self?.dismiss()
                } else {
                    self?.viewController.presenter.handleGoogleAuthImport(codes)
                }
            }, cancel: { [weak self] in
                self?.dismiss()
            })
        
        let vc = UIHostingController(rootView: google)
        vc.view.backgroundColor = .clear
        vc.configureAsModal()
        mainSplitViewController.present(vc, animated: true, completion: nil)
    }
    
    func showLastPassSummary(importable: Int, total: Int, codes: [Code]) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        
        let lastPass = CameraLastPass(
            importedCount: importable,
            totalCount: total,
            action: { [weak self] in
                if importable == 0 {
                    self?.dismiss()
                } else {
                    self?.viewController.presenter.handleLastPassImport(codes)
                }
            }, cancel: { [weak self] in
                self?.dismiss()
            })
        
        let vc = UIHostingController(rootView: lastPass)
        vc.view.backgroundColor = .clear
        vc.configureAsModal()
        mainSplitViewController.present(vc, animated: true, completion: nil)
    }
    
    func showPushPermission(for extensionID: ExtensionID) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        PushNotificationPermissionNavigationFlowController.show(
            on: mainSplitViewController,
            parent: self,
            extensionID: extensionID
        )
    }
    
    func showWebPairing(for extensionID: ExtensionID) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        BrowserExtensionPairingNavigationFlowController.show(
            on: mainSplitViewController,
            parent: self,
            extensionID: extensionID
        )
    }
    
    func showGuides() {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        GuideSelectorNavigationFlowController.show(
            on: mainSplitViewController,
            parent: self
        )
    }
    
    func showSummary(count: Int) {
        guard let mainSplitViewController, mainSplitViewController.presentedViewController == nil else { return }
        let alert = AlertControllerDismissFlow(
            title: T.Backup.importCompletedSuccessfuly,
            message: T.Backup.servicesImportedCount(count),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        mainSplitViewController.present(alert, animated: true)
    }
}

extension TokensPlainFlowController: PushNotificationPermissionNavigationFlowControllerParent {
    func pushNotificationsClose() {
        dismiss()
    }
}

extension TokensPlainFlowController: BrowserExtensionPairingNavigationFlowControllerParent {
    func browserExtensionPairingClose() {
        dismiss()
    }
}

extension TokensPlainFlowController: AddingServiceTokenFlowControllerParent {
    func addingServiceTokenClose(_ serviceData: ServiceData) {
        viewController.presenter.handleFocusOnService(serviceData)
    }
}

extension TokensPlainFlowController: NewsNavigationFlowControllerParent {
    func newsClose() {
        viewController.presenter.handleRefreshNewsStatus()
        dismiss()
    }
    
    func newsToBackup() {
        viewController.presenter.handleRefreshNewsStatus()
        dismiss { [weak self] in
            self?.parent?.tokensSwitchToSettingsBackup()
        }
    }
}

extension TokensPlainFlowController: GuideSelectorNavigationFlowControllerParent {
    func guideToAddManually(with name: String?) {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.toAddServiceManually(name)
        }
    }
    
    func guideToCodeScanner() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            self?.toAddService()
        }
    }
    
    func closeGuideSelector() {
        dismiss(actions: [.finishedFlow])
    }
}
