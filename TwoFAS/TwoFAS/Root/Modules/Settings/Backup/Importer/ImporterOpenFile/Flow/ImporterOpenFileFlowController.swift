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

protocol ImporterOpenFileFlowControllerParent: AnyObject {
    func closeImporter()
}

protocol ImporterOpenFileFlowControlling: AnyObject {
    func toClose()
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

final class ImporterOpenFileFlowController: FlowController {
    private weak var parent: ImporterOpenFileFlowControllerParent?
    private weak var navigationController: UINavigationController!
    
    static func present(
        on viewController: UIViewController,
        parent: ImporterOpenFileFlowControllerParent,
        url: URL?
    ) {
        let view = ImporterOpenFileViewController(forOpening: nil)
        let flowController = ImporterOpenFileFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.importerOpenFileModuleInteractor(url: url)
        let presenter = ImporterOpenFilePresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        let navi = RootNavigationController(rootViewController: view)
        navi.configureAsModal()
        navi.rootFlowController = flowController
        navi.isNavigationBarHidden = true

        flowController.navigationController = navi
        
        viewController.present(navi, animated: true, completion: nil)
    }
}

extension ImporterOpenFileFlowController: ImporterOpenFileFlowControlling {
    func toClose() {
        parent?.closeImporter()
    }
    
    func toPreimportSummary(
        countNew: Int,
        countTotal: Int,
        sections: [CommonSectionData],
        services: [ServiceData],
        externalImportService: ExternalImportService
    ) {
        ImporterPreimportSummaryFlowController.push(
            in: navigationController,
            parent: self,
            countNew: countNew,
            countTotal: countTotal,
            sections: sections,
            services: services,
            externalImportService: externalImportService
        )
    }
    
    func toFileError(error: ImporterOpenFileError) {
        ImporterFileErrorFlowController.push(in: navigationController, parent: self, fileError: error)
    }
    
    func toFileIsEmpty() {
        ImporterFileErrorFlowController.push(in: navigationController, parent: self, fileError: .noNewServices)
    }
    
    func toEnterPassword(for data: ExchangeDataFormat, externalImportService: ExternalImportService) {
        ImporterEnterPasswordFlowController.push(
            in: navigationController,
            parent: self,
            data: data,
            externalImportService: externalImportService
        )
    }
}

extension ImporterOpenFileFlowController: ImporterEnterPasswordFlowControllerParent {
    func hidePasswordImport() {
        parent?.closeImporter()
    }
    
    func showPreimportSummary(
        countNew: Int,
        countTotal: Int,
        sections: [CommonSectionData],
        services: [ServiceData],
        externalImportService: ExternalImportService
    ) {
        toPreimportSummary(
            countNew: countNew,
            countTotal: countTotal,
            sections: sections,
            services: services,
            externalImportService: externalImportService
        )
    }
    
    func showFileError(error: ImporterOpenFileError) {
        toFileError(error: error)
    }
    
    func showFileIsEmpty() {
        toFileIsEmpty()
    }
    
    func showWrongPassword() {
        let vc = createWrongPassword()
        navigationController.present(vc, animated: true, completion: nil)
    }
}

extension ImporterOpenFileFlowController: ImporterFileErrorFlowControllerParent {
    func hideFileError() {
        parent?.closeImporter()
    }
}

extension ImporterOpenFileFlowController: ImporterPreimportSummaryFlowControllerParent {
    func hidePreimportSummary() {
        parent?.closeImporter()
    }
    
    func showImportSummary(count: Int) {
        let vc = createSummary(count: count)
        navigationController.present(vc, animated: true, completion: nil)
    }    
}

private extension ImporterOpenFileFlowController {
    func createWrongPassword() -> UIViewController {
        let alert = UIAlertController(
            title: T.Commons.error,
            message: T.Backup.incorrectPassword,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: T.Commons.ok, style: .cancel)
        alert.addAction(cancel)
        return alert
    }
    
    func createSummary(count: Int) -> UIViewController {
        let alert = AlertControllerDismissFlow(
            title: T.Backup.importCompletedSuccessfuly,
            message: T.Backup.servicesImportedCount(count),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        alert.didDisappear = { [weak self] _ in
            self?.parent?.closeImporter()
        }
        return alert
    }
}
