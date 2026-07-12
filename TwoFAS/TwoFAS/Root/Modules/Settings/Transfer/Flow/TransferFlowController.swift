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
import Data

protocol TransferFlowControllerParent: AnyObject {}

protocol TransferFlowControlling: AnyObject {
    // MARK: - Import
    func toAegis()
    func toRaivo()
    func toLastPass()
    func toGoogleAuth()
    func toAndOTP()
    func toAuthenticatorPro()
    func toOpenTXTFile()
    // MARK: - Export
    func toSaveOTPAuthFile()
    func toExportQRCodes()
    func toSetupPIN()
    func toShareOTPAuthFileContents(_ url: URL, completion: @escaping () -> Void)
    func toShareQRCodes(_ url: URL, completion: @escaping () -> Void)
    func toError(_ message: String)
    func close()
}

final class TransferFlowController: FlowController {
    private weak var parent: TransferFlowControllerParent?
    private weak var navigationController: UINavigationController?
    private var galleryViewController: UIViewController?
    private var importer: ImporterOpenFileHeadlessFlowController?
    fileprivate var presenter: TransferPresenter?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: TransferFlowControllerParent
    ) {
        let hosting = create(parent: parent, showsBackButton: false, navigationController: navigationController)
        navigationController.setViewControllers([hosting], animated: false)
    }

    static func push(
        in navigationController: UINavigationController,
        parent: TransferFlowControllerParent
    ) {
        let hosting = create(parent: parent, showsBackButton: true, navigationController: navigationController)
        navigationController.pushRootViewController(hosting, animated: true)
    }

    private static func create(
        parent: TransferFlowControllerParent,
        showsBackButton: Bool,
        navigationController: UINavigationController
    ) -> UIViewController {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = TransferFlowController(viewController: hosting)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let interactor = ModuleInteractorFactory.shared.transferModuleInteractor()
        let presenter = TransferPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.showsBackButton = showsBackButton
        flowController.presenter = presenter
        hosting.rootView = AnyView(TransferView(presenter: presenter))
        return hosting
    }
}

extension TransferFlowController: TransferFlowControlling {
    // MARK: - Import
    func toAegis() { pushInstructions(service: .aegis) }
    func toRaivo() { pushInstructions(service: .raivo) }
    func toLastPass() { pushInstructions(service: .lastPass) }
    func toGoogleAuth() { pushInstructions(service: .googleAuth) }
    func toAndOTP() { pushInstructions(service: .andOTP) }
    func toAuthenticatorPro() { pushInstructions(service: .authenticatorPro) }
    func toOpenTXTFile() { pushInstructions(service: .otpAuthFile) }

    // MARK: - Export
    func toSaveOTPAuthFile() {
        guard let vc = _viewController else { return }
        ExportQuestionFlowController.present(on: vc, parent: self, exportType: .file)
    }

    func toExportQRCodes() {
        guard let vc = _viewController else { return }
        ExportQuestionFlowController.present(on: vc, parent: self, exportType: .qr)
    }

    func toSetupPIN() {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(
            title: T.Commons.notice,
            message: T.Settings.exportPinNeeded,
            preferredStyle: .alert
        )
        let setPIN = UIAlertAction(title: T.Commons.set, style: .destructive) { _ in
            NotificationCenter.default.post(name: .switchToSetupPIN, object: nil)
        }

        let cancel = UIAlertAction(title: T.Commons.cancel, style: .cancel)
        alert.addAction(setPIN)
        alert.addAction(cancel)
        vc.present(alert, animated: true, completion: nil)
    }

    func toShareOTPAuthFileContents(_ url: URL, completion: @escaping () -> Void) {
        guard let vc = _viewController else { return }
        let activityVC = activityVC(
            for: url,
            title: T.Settings.exportTitleTokens,
            completion: completion
        )
        vc.present(activityVC, animated: true, completion: nil)
    }

    func toShareQRCodes(_ url: URL, completion: @escaping () -> Void) {
        guard let vc = _viewController else { return }
        let activityVC = activityVC(
            for: url,
            title: T.Settings.exportTitleQrCodes,
            completion: completion
        )
        vc.present(activityVC, animated: true, completion: nil)
    }

    func toError(_ message: String) {
        guard let vc = _viewController else { return }
        let alert = UIAlertController.makeSimple(with: T.Commons.error, message: message)
        vc.present(alert, animated: true, completion: nil)
    }

    func close() {
        _viewController?.navigationController?.popViewController(animated: true)
    }
}

private extension TransferFlowController {
    func pushInstructions(service: ExternalImportService) {
        guard let navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: true)
        ExternalImportInstructionsFlowController.push(
            in: navigationController,
            parent: self,
            service: service
        )
    }
}

extension TransferFlowController: ExternalImportInstructionsFlowControllerParent {
    func instructionsClose() {
        closeInstructions()
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

extension TransferFlowController: CameraScannerFlowControllerParent {
    func cameraScannerDidFinish() { end() }
    func cameraScannerDidImport(count: Int) {
        navigationController?.dismiss(animated: true) { [weak self] in
            self?.showSummary(count: count)
        }
    }
    func cameraScannerServiceWasCreated(serviceData: ServiceData) { end() }
}

extension TransferFlowController: SelectFromGalleryFlowControllerParent {
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

extension TransferFlowController: ImporterOpenFileHeadlessFlowControllerParent {
    func importerCloseOnSucessfulImport() {
        navigationController?.setNavigationBarHidden(false, animated: false)
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

private extension TransferFlowController {
    func closeInstructions(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
            self?.closeInstructions(animated: false)
        }))
        alert.addAction(UIAlertAction(title: T.Commons.close, style: .cancel, handler: { [weak self] _ in
            self?.instructionsClose()
        }))
        navigationController?.present(alert, animated: true)
    }

    func activityVC(for url: URL, title: String, completion: @escaping () -> Void) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.title = title
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .markupAsPDF,
            .openInIBooks,
            .postToFacebook,
            .postToVimeo,
            .postToFlickr,
            .postToTencentWeibo,
            .postToTwitter,
            .postToWeibo
        ]

        if let popover = activityVC.popoverPresentationController, let view = UIApplication.keyWindow {
            let bounds = view.bounds
            popover.permittedArrowDirections = .init(rawValue: 0)
            popover.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 1, height: 2)
            popover.sourceView = view
        }

        activityVC.completionWithItemsHandler = { _, _, _, _ in
            completion()
        }

        return activityVC
    }
}

extension TransferFlowController: ExportQuestionFlowControllerParent {
    func closeExporter(export: Bool, exportType: ExportQuestionType) {
        _viewController?.dismiss(animated: true)
        guard export else {
            return
        }
        switch exportType {
        case .file:
            presenter?.handleSaveOTPAuthFile()
        case .qr:
            presenter?.handleExportQRCodes()
        }
    }
}
