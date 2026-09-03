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
}

final class TransferFlowController: FlowController {
    private weak var parent: TransferFlowControllerParent?
    private var modalNavigationController: UINavigationController?
    private var galleryViewController: UIViewController?
    private var importer: ImporterOpenFileHeadlessFlowController?
    private var exportLoadingViewController: UIViewController?
    fileprivate var presenter: TransferPresenter?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: TransferFlowControllerParent
    ) {
        let hosting = create(parent: parent)
        navigationController.setViewControllers([hosting], animated: false)
    }

    static func push(
        in navigationController: UINavigationController,
        parent: TransferFlowControllerParent
    ) {
        let hosting = create(parent: parent)
        navigationController.pushRootViewController(hosting, animated: true)
    }

    private static func create(
        parent: TransferFlowControllerParent
    ) -> UIViewController {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        let flowController = TransferFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.transferModuleInteractor()
        let presenter = TransferPresenter(
            flowController: flowController,
            interactor: interactor
        )
        flowController.presenter = presenter
        hosting.rootView = AnyView(TransferView(presenter: presenter))
        return hosting
    }
}

extension TransferFlowController: TransferFlowControlling {
    // MARK: - Import
    func toAegis() { presentInstructions(service: .aegis) }
    func toRaivo() { presentInstructions(service: .raivo) }
    func toLastPass() { presentInstructions(service: .lastPass) }
    func toGoogleAuth() { presentInstructions(service: .googleAuth) }
    func toAndOTP() { presentInstructions(service: .andOTP) }
    func toAuthenticatorPro() { presentInstructions(service: .authenticatorPro) }
    func toOpenTXTFile() { presentInstructions(service: .otpAuthFile) }

    // MARK: - Export
    func toSaveOTPAuthFile() {
        presentExportQuestion(exportType: .file)
    }

    func toExportQRCodes() {
        presentExportQuestion(exportType: .qr)
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
        presentExportActivity(for: url, title: T.Settings.exportTitleTokens, completion: completion)
    }

    func toShareQRCodes(_ url: URL, completion: @escaping () -> Void) {
        presentExportActivity(for: url, title: T.Settings.exportTitleQrCodes, completion: completion)
    }

    func toError(_ message: String) {
        dismissModal { [weak self] in
            guard let self, let vc = self._viewController else { return }
            let alert = UIAlertController.makeSimple(with: T.Commons.error, message: message)
            vc.present(alert, animated: true, completion: nil)
        }
    }
}

private extension TransferFlowController {
    func presentInstructions(service: ExternalImportService) {
        guard let presentingViewController = _viewController else { return }
        let navi = makeModalNavigationController()
        ExternalImportInstructionsFlowController.push(
            in: navi,
            parent: self,
            service: service
        )
        presentingViewController.present(navi, animated: true)
    }

    func presentExportQuestion(exportType: ExportQuestionType) {
        guard let presentingViewController = _viewController else { return }
        let navi = makeModalNavigationController()
        ExportQuestionFlowController.push(in: navi, parent: self, exportType: exportType)
        presentingViewController.present(navi, animated: true)
    }

    func makeModalNavigationController() -> UINavigationController {
        let navi = CommonNavigationController()
        navi.configureAsModal()
        modalNavigationController = navi
        return navi
    }

    func dismissModal(completion: (() -> Void)? = nil) {
        guard modalNavigationController != nil else {
            completion?()
            return
        }
        _viewController?.dismiss(animated: true) { [weak self] in
            self?.modalNavigationController = nil
            self?.exportLoadingViewController = nil
            completion?()
        }
    }

    func dismissInnerModal(completion: (() -> Void)? = nil) {
        modalNavigationController?.dismiss(animated: true, completion: completion)
    }
}

extension TransferFlowController: ExternalImportInstructionsFlowControllerParent {
    func instructionsClose() {
        dismissModal()
    }

    func instructionsOpenFile(service: ExternalImportService) {
        guard let modalNavigationController else { return }
        importer = ImporterOpenFileHeadlessFlowController
            .present(
                on: modalNavigationController,
                parent: self,
                url: nil,
                importingOTPAuthFile: service == .otpAuthFile
            )
    }

    func instructionsCamera() {
        guard let modalNavigationController else { return }
        CameraScannerFlowController.present(
            on: modalNavigationController,
            parent: self
        )
    }

    func instructionsGallery() {
        guard let modalNavigationController else { return }
        galleryViewController = SelectFromGalleryFlowController.present(
            on: modalNavigationController,
            applyOverlay: true,
            parent: self
        )
    }
}

extension TransferFlowController: CameraScannerFlowControllerParent {
    func cameraScannerDidFinish() { dismissInnerModal() }
    func cameraScannerDidImport(count: Int) {
        dismissInnerModal { [weak self] in
            self?.showSummary(count: count)
        }
    }
    func cameraScannerServiceWasCreated(serviceData: ServiceData) { dismissInnerModal() }
}

extension TransferFlowController: SelectFromGalleryFlowControllerParent {
    func galleryWillShow(alongside coordinator: UIViewControllerTransitionCoordinator?) {}
    func galleryWillCancel(alongside coordinator: UIViewControllerTransitionCoordinator?) {}

    /// The cancel arrives with the picker already off screen, so only the
    /// reference needs releasing — a dismiss issued here would land on the
    /// instructions modal itself and close the whole flow.
    func galleryDidCancel() { galleryViewController = nil }
    func galleryServiceWasCreated(serviceData: ServiceData) { endGallery() }
    func galleryDidImport(count: Int) {
        dismissInnerModal { [weak self] in
            self?.galleryViewController = nil
            self?.showSummary(count: count)
        }
    }
}

extension TransferFlowController: ImporterOpenFileHeadlessFlowControllerParent {
    func importerCloseOnSucessfulImport() {
        importer = nil
        dismissInnerModal { [weak self] in
            self?.dismissModal()
        }
    }

    func importerClose() {
        importer = nil
        dismissInnerModal()
    }
}

private extension TransferFlowController {
    func endGallery() {
        dismissInnerModal { [weak self] in
            self?.galleryViewController = nil
        }
    }

    func showSummary(count: Int) {
        let alert = AlertControllerDismissFlow(
            title: T.Backup.importCompletedSuccessfuly,
            message: T.Backup.servicesImportedCount(count),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.tokens, style: .default, handler: { [weak self] _ in
            NotificationCenter.default.post(name: .switchToTokens, object: nil)
            self?.dismissModal()
        }))
        alert.addAction(UIAlertAction(title: T.Commons.close, style: .cancel, handler: { [weak self] _ in
            self?.dismissModal()
        }))
        modalNavigationController?.present(alert, animated: true)
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
        guard export else {
            dismissModal()
            return
        }

        presentExportLoading { [weak self] in
            switch exportType {
            case .file:
                self?.presenter?.handleSaveOTPAuthFile()
            case .qr:
                self?.presenter?.handleExportQRCodes()
            }
        }
    }
}

private extension TransferFlowController {
    func presentExportLoading(completion: @escaping () -> Void) {
        guard let modalNavigationController else {
            completion()
            return
        }
        let hosting = UIHostingController(
            rootView: AnyView(
                TFLoadingView(title: T.Backup.migrationSubtitle)
                    .navigationBarBackButtonHidden()
            )
        )
        hosting.view.backgroundColor = AppColor.backgroundsPrimary.uiColor
        hosting.navigationItem.setHidesBackButton(true, animated: false)
        exportLoadingViewController = hosting

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        modalNavigationController.pushViewController(hosting, animated: true)
        CATransaction.commit()
    }

    func presentExportActivity(for url: URL, title: String, completion: @escaping () -> Void) {
        guard let presentingVC = exportLoadingViewController ?? _viewController else { return }
        let activityVC = activityVC(for: url, title: title) { [weak self] in
            completion()
            self?.dismissModal()
        }
        presentingVC.present(activityVC, animated: true, completion: nil)
    }
}
