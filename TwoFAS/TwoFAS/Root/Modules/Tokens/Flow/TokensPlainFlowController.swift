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
    func tokensSwitchToSettingsTrash()
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
    // MARK: Initial screen
    func toFileImport()
    func toHelp()
    func toTrash()
    // MARK: Link actions
    func toIncorrectCode()
    func toDuplicatedCode(forceAdd: @escaping Callback, cancel: @escaping Callback)
    func toShowShouldAddCode(with descriptionText: String?)
    func toShouldRenameService(currentName: String, secret: String)
    // MARK: News
    func toNotifications()
    // MARK: Import
    func toShowSummmary(count: Int)
    // MARK: Pass cell
    func toPassStore()
    // MARK: Sync alerts
    func toAllServicesRemoved(completion: @escaping Callback)
}

final class TokensPlainFlowController: FlowController {
    private weak var parent: TokensPlainFlowControllerParent?
    // The presentation host for modals/alerts: the main tab-bar container. Only
    // UIViewController API is used, so the concrete container type is irrelevant.
    private weak var presentationHost: UIViewController?
    // Provides the view the "add service" card zooms out of.
    private var addServiceSourceView: () -> UIView? = { nil }
    private var galleryViewController: UIViewController?

    static func setup(
        presentationHost: UIViewController,
        parent: TokensPlainFlowControllerParent,
        addServiceSourceView: @escaping () -> UIView? = { nil }
    ) -> TokensViewController {
        let view = TokensViewController()
        let flowController = TokensPlainFlowController(viewController: view)
        flowController.parent = parent
        flowController.presentationHost = presentationHost
        flowController.addServiceSourceView = addServiceSourceView
        let interactor = ModuleInteractorFactory.shared.tokensModuleInteractor()
        let presenter = TokensPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        return view
    }
    
    private func presentAlertOnMainSplitViewController(_ alert: UIAlertController) {
        guard let presentationHost else { return }

        if AddingServiceFlowController.isPresented(on: presentationHost),
           let presentedViewController = presentationHost.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                presentationHost.present(alert, animated: true)
            }
        } else {
            presentationHost.present(alert, animated: true)
        }
    }
}

extension TokensPlainFlowController: TokensPlainFlowControlling {
    // MARK: - Service
    
    func toAddService() {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
        AddingServiceFlowController.present(
            on: presentationHost,
            parent: self,
            zoomSourceView: addServiceSourceView()
        )
    }
    
    func toDeleteService(serviceData: ServiceData) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
        TrashServiceFlowController.present(on: presentationHost, parent: self, serviceData: serviceData)
    }
    
    func toShowEditingService(with serviceData: ServiceData, freshlyAdded: Bool = false, gotoIconEdit: Bool = false) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
        ComposeServiceNavigationFlowController.present(
            on: presentationHost,
            parent: self,
            serviceData: serviceData,
            gotoIconEdit: gotoIconEdit,
            freshlyAdded: freshlyAdded
        )
    }
    
    func toServiceWasCreated(_ serviceData: ServiceData) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
        
        FirstCodeAddedStatsController.markStats() // TODO: Move to MainRepository and proper interactor
        AddingServiceTokenFlowController.present(on: presentationHost, parent: self, serviceData: serviceData)
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
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
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
        
        presentationHost.present(alert, animated: true, completion: nil)
    }
    
    func toRenameSection(current name: String, callback: @escaping (String) -> Void) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
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
        
        presentationHost.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Initial screen

    func toFileImport() {
        parent?.tokensSwitchToSettingsExternalImport()
    }
    
    func toHelp() {
        UIApplication.shared.open(
            URL(string: "https://2fas.com/how-to-enable-2fa")!,
            options: [:],
            completionHandler: nil
        )
    }
    
    func toTrash() {
        parent?.tokensSwitchToSettingsTrash()
    }
    
    // MARK: - Link actions
    func toDuplicatedCode(forceAdd: @escaping Callback, cancel: @escaping Callback) {
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
            
        presentAlertOnMainSplitViewController(alert)
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

        presentAlertOnMainSplitViewController(alert)
    }
    
    func toIncorrectCode() {
        let alert = UIAlertController(
            title: T.Commons.warning,
            message: T.Tokens.thisQrCodeIsInavlid,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel, handler: { _ in }))

        presentAlertOnMainSplitViewController(alert)
    }
    
    func toShouldRenameService(currentName: String, secret: String) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
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
        
        presentationHost.present(alert, animated: true)
    }
    
    // MARK: - Notifications
    func toNotifications() {
        // Present on the top-most controller in the window so it works regardless
        // of which container hosts the tokens screen (legacy split or tab bar).
        let host: UIViewController = presentationHost ?? viewController
        var top: UIViewController = host
        while let presented = top.presentedViewController {
            top = presented
        }
        NewsPlainFlowController.present(on: top, parent: self, sourceView: viewController.newsButtonSourceView)
    }
    
    // MARK: - Import
    func toShowSummmary(count: Int) {
        dismiss(actions: [.finishedFlow, .newData, .sync]) { [weak self] in
            self?.showSummary(count: count)
        }
    }
    
    // MARK: - Pass cell
    func toPassStore() {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/app/id6504464955")!)
    }

    func toAllServicesRemoved(completion: @escaping Callback) {
        let alert = UIAlertController(
            title: T.Backup.movedToTrashTitle,
            message: T.Backup.movedToTrashMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .default, handler: { _ in completion() }))
        presentAlertOnMainSplitViewController(alert)
    }
}

extension TokensPlainFlowController {
    var viewController: TokensViewController { _viewController as! TokensViewController }
}

private extension TokensPlainFlowController {
    func dismiss(actions: Set<TokensExternalAction> = [.finishedFlow], completion: Callback? = nil) {
        presentationHost?.dismiss(animated: true) { [weak self] in
            if actions.contains(.refreshImmidiately) {
                self?.viewController.presenter.handleExternalAction(actions)
                completion?()
            } else {
                completion?()
                self?.viewController.presenter.handleExternalAction(actions)
            }
        }
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
    func galleryWillShow(alongside coordinator: UIViewControllerTransitionCoordinator?) {}
    func galleryWillCancel(alongside coordinator: UIViewControllerTransitionCoordinator?) {}

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
    
    func composeServiceServiceWasModified() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            let alert = UIAlertController.makeSimple(
                with: T.Commons.info,
                message: T.Notifications.serviceAlreadyModifiedTitle
            )
            self?.presentationHost?.present(alert, animated: true)
        }
    }
    
    func composeServiceServiceWasDeleted() {
        dismiss(actions: [.continuesFlow]) { [weak self] in
            let alert = UIAlertController.makeSimple(
                with: T.Commons.info,
                message: T.Notifications.serviceAlreadyRemovedTitle
            )
            self?.presentationHost?.present(alert, animated: true)
        }
    }
}

extension TokensPlainFlowController: AddingServiceFlowControllerParent {
    func addingServiceDismiss() {
        dismiss()
    }

    func addingServiceGalleryDidImport(count: Int) {
        dismiss(actions: [.finishedFlow, .newData, .sync]) { [weak self] in
            self?.galleryViewController = nil
            self?.showSummary(count: count)
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

    func addingServiceToToken(_ serviceData: ServiceData) {
        dismiss(actions: [.newData, .refreshImmidiately, .sync]) { [weak self] in
            self?.toServiceWasCreated(serviceData)
        }
    }
}

private extension TokensPlainFlowController {
    func showGoogleAuthSummary(importable: Int, total: Int, codes: [Code]) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
        
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
        presentationHost.present(vc, animated: true, completion: nil)
    }
    
    func showLastPassSummary(importable: Int, total: Int, codes: [Code]) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
        
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
        presentationHost.present(vc, animated: true, completion: nil)
    }
    
    func showPushPermission(for extensionID: ExtensionID) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
        PushNotificationPermissionNavigationFlowController.show(
            on: presentationHost,
            parent: self,
            extensionID: extensionID
        )
    }
    
    func showWebPairing(for extensionID: ExtensionID) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
        BrowserExtensionPairingNavigationFlowController.show(
            on: presentationHost,
            parent: self,
            extensionID: extensionID
        )
    }
    
    func showSummary(count: Int) {
        guard let presentationHost, presentationHost.presentedViewController == nil else { return }
        let alert = AlertControllerDismissFlow(
            title: T.Backup.importCompletedSuccessfuly,
            message: T.Backup.servicesImportedCount(count),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        presentationHost.present(alert, animated: true)
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

extension TokensPlainFlowController: NewsPlainFlowControllerParent {
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
