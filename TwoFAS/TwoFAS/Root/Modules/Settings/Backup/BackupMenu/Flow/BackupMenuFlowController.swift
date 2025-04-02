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

protocol BackupMenuFlowControllerParent: AnyObject {
    func showFAQ()
}

protocol BackupMenuFlowControlling: AnyObject {
    func toFAQ()
    func toFileImport()
    func toFileExport()
    func toDeleteCloudBackup()
}

final class BackupMenuFlowController: FlowController {
    private weak var parent: BackupMenuFlowControllerParent?
    
    private var importer: ImporterOpenFileHeadlessFlowController?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: BackupMenuFlowControllerParent
    ) {
        let view = BackupMenuViewController()
        let flowController = BackupMenuFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.backupMenuModuleInteractor()
        let presenter = BackupMenuPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    static func push(
        in navigationController: UINavigationController,
        parent: BackupMenuFlowControllerParent
    ) {
        let view = BackupMenuViewController()
        let flowController = BackupMenuFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.backupMenuModuleInteractor()
        let presenter = BackupMenuPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushRootViewController(view, animated: true)
    }
}

extension BackupMenuFlowController: BackupMenuFlowControlling {
    func toFAQ() {
        parent?.showFAQ()
    }
    
    func toFileImport() {
        importer = ImporterOpenFileHeadlessFlowController.present(on: viewController, parent: self, url: nil)
    }
    
    func toFileExport() {
        ExporterMainScreenFlowController.present(on: viewController, parent: self)
    }
    
    func toDeleteCloudBackup() {
        BackupDeleteFlowController.present(on: viewController, parent: self)
    }
}

extension BackupMenuFlowController: ImporterOpenFileHeadlessFlowControllerParent {
    func importerCloseOnSucessfulImport() {
        handleImporterClose()
    }
    
    func importerClose() {
        handleImporterClose()
    }
    
    private func handleImporterClose() {
        viewController.dismiss(animated: true) { [weak self] in
            self?.importer = nil
        }
    }
}

extension BackupMenuFlowController: ExporterMainScreenFlowControllerParent {
    func closeExporter() {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension BackupMenuFlowController: BackupDeleteFlowControllerParent {
    func hideDeleteBackup() {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension BackupMenuFlowController {
    var viewController: BackupMenuViewController { _viewController as! BackupMenuViewController }
}
