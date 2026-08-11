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

protocol ImporterOpenFileHeadlessFlowControllerParent: AnyObject {
    func importerClose()
    func importerCloseOnSucessfulImport()
}

protocol ImporterOpenFileHeadlessFlowControlling: AnyObject {
    func toClose()
    func toOpenFile()
    func toPreimportSummary(
        countNew: Int,
        countTotal: Int,
        sections: [CommonSectionData],
        services: [ServiceData],
        externalImportService: ExternalImportService
    )
    func toFileError(error: ImporterOpenFileError)
    func toFileIsEmpty()
    func toEnterPassword(for data: ExchangeDataFormat, externalImportService: ExternalImportService)
}

final class ImporterOpenFileHeadlessFlowController: FlowController {
    private weak var parent: ImporterOpenFileHeadlessFlowControllerParent?
    private var navigationController: UINavigationController?
    private var presenter: ImporterOpenFilePresenter!
    private var router: ImporterRouter!

    private var isNaviPresented = false

    static func present(
        on viewController: UIViewController,
        parent: ImporterOpenFileHeadlessFlowControllerParent,
        url: URL?,
        importingOTPAuthFile: Bool = false,
        isFromClipboard: Bool = false
    ) -> ImporterOpenFileHeadlessFlowController {
        let flowController = ImporterOpenFileHeadlessFlowController(viewController: viewController)
        flowController.parent = parent

        let interactor = ModuleInteractorFactory.shared.importerOpenFileModuleInteractor(
            url: url,
            importingOTPAuthFile: importingOTPAuthFile,
            isFromClipboard: isFromClipboard
        )

        let router = ImporterRouter()
        router.flowController = flowController
        flowController.router = router

        let presenter = ImporterOpenFilePresenter(
            flowController: router,
            interactor: interactor
        )
        flowController.presenter = presenter

        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(ImporterRootView(router: router)))
        let navi = RootNavigationController(rootViewController: hosting)
        navi.configureAsModal()
        navi.rootFlowController = flowController
        navi.isNavigationBarHidden = true
        flowController.navigationController = navi

        presenter.start()

        return flowController
    }

    // MARK: - Terminal actions (driven by the router)

    func close() {
        parent?.importerClose()
    }

    func presentModalIfNeeded() {
        guard !isNaviPresented, let navigationController else { return }
        isNaviPresented = true
        _viewController.present(navigationController, animated: true)
    }

    func presentDocumentPicker() {
        let view = ImporterOpenFileViewController(forOpeningContentTypes: nil, asCopy: false)
        view.handleCantReadFile = { [weak self] in
            self?.router.toFileError(error: .cantReadFile(reason: nil))
        }
        view.handleFileOpen = { [weak self] url in
            self?.presenter.handleFileOpen(url)
        }
        view.handleCancelFileOpen = { [weak self] in
            self?.close()
        }
        _viewController.present(view, animated: true)
    }

    func showWrongPassword() {
        let alert = UIAlertController(
            title: T.Commons.error,
            message: T.Backup.incorrectPassword,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel))
        (navigationController ?? _viewController).present(alert, animated: true, completion: nil)
    }

    func showImportSummary(count: Int) {
        let alert = AlertControllerDismissFlow(
            title: T.Backup.importCompletedSuccessfuly,
            message: T.Backup.servicesImportedCount(count),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        alert.didDisappear = { [weak self] _ in
            self?.parent?.importerCloseOnSucessfulImport()
        }
        (navigationController ?? _viewController).present(alert, animated: true, completion: nil)
    }
}
