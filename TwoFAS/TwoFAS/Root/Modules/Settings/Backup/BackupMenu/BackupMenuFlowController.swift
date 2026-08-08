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

protocol BackupMenuFlowControllerParent: AnyObject {
    func showFAQ()
}

protocol BackupMenuFlowControlling: AnyObject {
    func toFAQ()
    func toFileImport()
    func toFileExport()
    func toManageAppleWatch()
    func toManageBackup()
    func toAdvanced()
    func close()
}

final class BackupMenuFlowController: FlowController {
    private weak var parent: BackupMenuFlowControllerParent?

    private var importer: ImporterOpenFileHeadlessFlowController?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: BackupMenuFlowControllerParent
    ) {
        let hosting = create(parent: parent)
        navigationController.setViewControllers([hosting], animated: false)
    }

    static func push(
        in navigationController: UINavigationController,
        parent: BackupMenuFlowControllerParent
    ) {
        let hosting = create(parent: parent)
        navigationController.pushRootViewController(hosting, animated: true)
    }

    private static func create(
        parent: BackupMenuFlowControllerParent
    ) -> UIViewController {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = BackupMenuFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.backupMenuModuleInteractor()
        let presenter = BackupMenuPresenter(
            flowController: flowController,
            interactor: interactor
        )
        hosting.rootView = AnyView(BackupMenuView(presenter: presenter))
        return hosting
    }
}

extension BackupMenuFlowController: BackupMenuFlowControlling {
    func toFAQ() {
        parent?.showFAQ()
    }

    func toFileImport() {
        guard let vc = _viewController else { return }
        importer = ImporterOpenFileHeadlessFlowController.present(on: vc, parent: self, url: nil)
    }

    func toFileExport() {
        guard let vc = _viewController else { return }
        ExporterMainScreenFlowController.present(on: vc, parent: self)
    }

    func toManageAppleWatch() {
        guard let vc = _viewController else { return }
        ManageWatchFlowController.present(on: vc, parent: self)
    }

    func toManageBackup() {
        guard let navigationController = _viewController?.navigationController else { return }
        BackupManageEncryptionFlowController.push(in: navigationController, parent: self)
    }

    func toAdvanced() {
        guard let navigationController = _viewController?.navigationController else { return }
        BackupAdvancedFlowController.push(in: navigationController, parent: self)
    }

    func close() {
        _viewController?.navigationController?.popViewController(animated: true)
    }
}

extension BackupMenuFlowController: ManageWatchFlowControllerParent {
    func closeManageFlow() {
        _viewController?.dismiss(animated: true, completion: nil)
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
        _viewController?.dismiss(animated: true) { [weak self] in
            self?.importer = nil
        }
    }
}

extension BackupMenuFlowController: ExporterMainScreenFlowControllerParent {
    func closeExporter() {
        _viewController?.dismiss(animated: true, completion: nil)
    }
}

extension BackupMenuFlowController: BackupManageEncryptionFlowControllerParent {
    func backupManageEncryptionClose() {
        _viewController?.navigationController?.popViewController(animated: true)
    }
}

extension BackupMenuFlowController: BackupAdvancedFlowControllerParent {
    func backupAdvancedClose() {
        _viewController?.navigationController?.popViewController(animated: true)
    }
}
