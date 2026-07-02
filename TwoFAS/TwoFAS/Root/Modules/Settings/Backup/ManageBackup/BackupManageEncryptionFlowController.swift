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
    private weak var navigationController: UINavigationController?
    
    static func push(
        in navigationController: UINavigationController,
        parent: BackupManageEncryptionFlowControllerParent
    ) {
        let viewController = BackupManageEncryptionViewController()
        let flowController = BackupManageEncryptionFlowController(viewController: viewController)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let presenter = BackupManageEncryptionPresenter(
            flowController: flowController,
            interactor: ModuleInteractorFactory
                .shared.backupManageEncryptionModuleInteractor())
        viewController.presenter = presenter
        presenter.view = viewController
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension BackupManageEncryptionFlowController {
    var viewController: BackupManageEncryptionViewController {
        _viewController as! BackupManageEncryptionViewController
    }
}

extension BackupManageEncryptionFlowController: BackupManageEncryptionFlowControlling {
    func close() {
        parent?.backupManageEncryptionClose()
    }
    
    func toDeleteBackup() {
        BackupDeleteFlowController.present(on: viewController, parent: self)
    }
    
    func toSetPassword() {
        BackupSetPasswordFlowController.present(
            in: viewController,
            parent: self,
            flowType: .setPassword
        )
    }
    
    func toChangePassword() {
        EncryptedByUserPasswordSyncNavigationFlowController
            .present(
                on: viewController,
                parent: self,
                actionType: .verifyPassword(.changePassword)
            )
    }
    
    func toRemovePassword() {
        EncryptedByUserPasswordSyncNavigationFlowController
            .present(
                on: viewController,
                parent: self,
                actionType: .verifyPassword(.removePassword)
            )
    }
}

extension BackupManageEncryptionFlowController: BackupSetPasswordFlowControllerParent {
    func closeSetPassword() {
        viewController.dismiss(animated: true)
    }
}

extension BackupManageEncryptionFlowController: BackupDeleteFlowControllerParent {
    func closeDeleteBackup(didDelete: Bool) {
        viewController.dismiss(animated: true)
        if didDelete {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension BackupManageEncryptionFlowController: EncryptedByUserPasswordSyncNavigationFlowControllerParent {
    func closeEncryptedByUserPasswordSync() {
        viewController.dismiss(animated: true)
    }
}
