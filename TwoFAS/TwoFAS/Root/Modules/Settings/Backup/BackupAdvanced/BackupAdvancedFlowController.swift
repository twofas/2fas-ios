//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

protocol BackupAdvancedFlowControllerParent: AnyObject {}

protocol BackupAdvancedFlowControlling: AnyObject {
    func toDeleteBackup()
    func toExportKeys(url: URL)
    func toKeysError(_ message: String)
    func toImportKeys()
}

final class BackupAdvancedFlowController: FlowController {
    private weak var parent: BackupAdvancedFlowControllerParent?
    private var navigationController: UINavigationController? { _viewController?.navigationController }
    private var importKeysFlow: ImportKeysFlowController?

    static func push(
        in navigationController: UINavigationController,
        parent: BackupAdvancedFlowControllerParent
    ) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = BackupAdvancedFlowController(viewController: hosting)
        flowController.parent = parent
        let presenter = BackupAdvancedPresenter(
            flowController: flowController,
            interactor: ModuleInteractorFactory.shared.backupAdvancedModuleInteractor()
        )
        hosting.rootView = AnyView(BackupAdvancedView(presenter: presenter))

        navigationController.pushViewController(hosting, animated: true)
    }
}

extension BackupAdvancedFlowController: BackupAdvancedFlowControlling {
    func toDeleteBackup() {
        guard let vc = _viewController else { return }
        BackupDeleteFlowController.present(on: vc, parent: self)
    }

    func toExportKeys(url: URL) {
        guard let vc = _viewController else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = vc.view
            popover.sourceRect = CGRect(
                x: vc.view.bounds.midX,
                y: vc.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        vc.present(activityVC, animated: true)
    }

    func toKeysError(_ message: String) {
        guard let vc = _viewController else { return }
        let alert = UIAlertController(title: T.Commons.error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .default))
        vc.present(alert, animated: true)
    }

    func toImportKeys() {
        guard let vc = _viewController else { return }
        let flow = ImportKeysFlowController.make(presentingOn: vc, parent: self, showWarning: true)
        importKeysFlow = flow
        flow.start()
    }
}

extension BackupAdvancedFlowController: ImportKeysFlowControllerParent {
    func importKeysDidFinish(success: Bool) {
        importKeysFlow = nil
        guard success, let vc = _viewController else { return }
        let alert = UIAlertController(
            title: nil,
            message: T.Commons.done,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .default))
        vc.present(alert, animated: true)
    }

    func importKeysDidCancel() {
        importKeysFlow = nil
    }
}

extension BackupAdvancedFlowController: BackupDeleteFlowControllerParent {
    func closeDeleteBackup(didDelete: Bool) {
        _viewController?.dismiss(animated: true)
        if didDelete {
            navigationController?.popViewController(animated: true)
        }
    }
}
