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
import UniformTypeIdentifiers
import Data

protocol ImporterOpenFileHeadlessFlowControllerParent: AnyObject {
    func importerClose()
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
    
    private var isNaviPresented = false
    
    static func present(
        on viewController: UIViewController,
        parent: ImporterOpenFileHeadlessFlowControllerParent,
        url: URL?
    ) -> ImporterOpenFileHeadlessFlowController {
        let flowController = ImporterOpenFileHeadlessFlowController(viewController: viewController)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.importerOpenFileModuleInteractor(url: url)
        let presenter = ImporterOpenFilePresenter(
            flowController: flowController,
            interactor: interactor
        )
        
        flowController.presenter = presenter
        
        let navi = RootNavigationController(rootViewController: UIViewController())
        navi.configureAsModal()
        navi.rootFlowController = flowController
        navi.isNavigationBarHidden = true
        flowController.navigationController = navi
        
        presenter.start()
        
        return flowController
    }
}

extension ImporterOpenFileHeadlessFlowController: ImporterOpenFileHeadlessFlowControlling {
    func toClose() {
        parent?.importerClose()
    }
    
    func toPreimportSummary(
        countNew: Int,
        countTotal: Int,
        sections: [CommonSectionData],
        services: [ServiceData],
        externalImportService: ExternalImportService
    ) {
        showNavigationController { [weak self, weak navigationController] animated in
            guard let self, let navigationController else { return }
            
            ImporterPreimportSummaryFlowController.push(
                in: navigationController,
                parent: self,
                countNew: countNew,
                countTotal: countTotal,
                sections: sections,
                services: services,
                externalImportService: externalImportService,
                animated: animated
            )
        }
    }
    
    func toFileError(error: ImporterOpenFileError) {
        showNavigationController { [weak self, weak navigationController] animated in
            guard let self, let navigationController else { return }
            
            ImporterFileErrorFlowController.push(
                in: navigationController,
                parent: self,
                fileError: error,
                animated: animated
            )
        }
    }
    
    func toFileIsEmpty() {
        showNavigationController { [weak self, weak navigationController] animated in
            guard let self, let navigationController else { return }
            
            ImporterFileErrorFlowController.push(
                in: navigationController,
                parent: self,
                fileError: .noNewServices,
                animated: animated
            )
        }
    }
    
    func toEnterPassword(for data: ExchangeDataFormat, externalImportService: ExternalImportService) {
        showNavigationController { [weak self, weak navigationController] animated in
            guard let self, let navigationController else { return }
            
            ImporterEnterPasswordFlowController.push(
                in: navigationController,
                parent: self,
                data: data,
                externalImportService: externalImportService,
                animated: animated
            )
        }
    }
}

extension ImporterOpenFileHeadlessFlowController: ImporterEnterPasswordFlowControllerParent {
    func hidePasswordImport() {
        parent?.importerClose()
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
        showNavigationController { [weak navigationController] _ in
            navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func toOpenFile() {
        let view = ImporterOpenFileViewController(forOpeningContentTypes: nil, asCopy: false)
        view.handleCantReadFile = { [weak self] in
            self?.toFileError(error: .cantReadFile(reason: nil))
        }
        view.handleFileOpen = { [weak self] url in
            self?.presenter.handleFileOpen(url)
        }
        view.handleCancelFileOpen = { [weak self] in
            self?.toClose()
        }
        _viewController.present(view, animated: true)
    }
}

extension ImporterOpenFileHeadlessFlowController: ImporterFileErrorFlowControllerParent {
    func hideFileError() {
        parent?.importerClose()
    }
}

extension ImporterOpenFileHeadlessFlowController: ImporterPreimportSummaryFlowControllerParent {
    func hidePreimportSummary() {
        parent?.importerClose()
    }
    
    func showImportSummary(count: Int) {
        let vc = createSummary(count: count)
        showNavigationController { [weak navigationController] _ in
            navigationController?.present(vc, animated: true, completion: nil)
        }
    }    
}

private extension ImporterOpenFileHeadlessFlowController {
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
            self?.parent?.importerClose()
        }
        return alert
    }
    
    func showNavigationController(completion: @escaping (Bool) -> Void) {
        guard !isNaviPresented, let navigationController else {
            completion(true)
            return
        }
        
        completion(false)
        _viewController.present(navigationController, animated: true) { [weak self] in
            self?.isNaviPresented = true
        }
    }
}
