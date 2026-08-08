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

protocol BackupManageEncryptionFlowControllerParent: AnyObject {
    func backupManageEncryptionClose()
}

protocol BackupManageEncryptionFlowControlling: AnyObject {
    func close()
    func toDeleteBackup()
    func toSetPassword()
    func toChangePassword()
    func toRemovePassword()
}

final class BackupManageEncryptionFlowController: FlowController {
    private weak var parent: BackupManageEncryptionFlowControllerParent?
    private var navigationController: UINavigationController? { _viewController?.navigationController }

    static func push(
        in navigationController: UINavigationController,
        parent: BackupManageEncryptionFlowControllerParent
    ) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = BackupManageEncryptionFlowController(viewController: hosting)
        flowController.parent = parent
        let presenter = BackupManageEncryptionPresenter(
            flowController: flowController,
            interactor: ModuleInteractorFactory
                .shared.backupManageEncryptionModuleInteractor())
        hosting.rootView = AnyView(BackupManageEncryptionView(presenter: presenter))

        navigationController.pushViewController(hosting, animated: true)
    }
}

extension BackupManageEncryptionFlowController: BackupManageEncryptionFlowControlling {
    func close() {
        _viewController?.navigationController?.popViewController(animated: true)
    }

    func toDeleteBackup() {
        guard let vc = _viewController else { return }
        BackupDeleteFlowController.present(on: vc, parent: self)
    }

    func toSetPassword() {
        guard let vc = _viewController else { return }
        BackupSetPasswordFlowController.present(
            in: vc,
            parent: self,
            flowType: .setPassword
        )
    }

    func toChangePassword() {
        guard let vc = _viewController else { return }
        EncryptedByUserPasswordSyncNavigationFlowController
            .present(
                on: vc,
                parent: self,
                actionType: .verifyPassword(.changePassword)
            )
    }

    func toRemovePassword() {
        guard let vc = _viewController else { return }
        EncryptedByUserPasswordSyncNavigationFlowController
            .present(
                on: vc,
                parent: self,
                actionType: .verifyPassword(.removePassword)
            )
    }
}

extension BackupManageEncryptionFlowController: BackupSetPasswordFlowControllerParent {
    func closeSetPassword() {
        _viewController?.dismiss(animated: true)
    }
}

extension BackupManageEncryptionFlowController: BackupDeleteFlowControllerParent {
    func closeDeleteBackup(didDelete: Bool) {
        _viewController?.dismiss(animated: true)
        if didDelete {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension BackupManageEncryptionFlowController: EncryptedByUserPasswordSyncNavigationFlowControllerParent {
    func closeEncryptedByUserPasswordSync() {
        _viewController?.dismiss(animated: true)
    }
}
