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
import Common
import Data

protocol BackupChangeEncryptionFlowControllerParent: AnyObject {
    func closeChangeEncryption()
}

protocol BackupChangeEncryptionFlowControlling: AnyObject {
    func close()
}

final class BackupChangeEncryptionFlowController: FlowController {
    private weak var parent: BackupChangeEncryptionFlowControllerParent?

    static func present(
        on viewController: UIViewController,
        parent: BackupChangeEncryptionFlowControllerParent
    ) {
        let view = BackupChangeEncryptionViewController()
        let flowController = BackupChangeEncryptionFlowController(viewController: view)
        let interactor = ModuleInteractorFactory.shared.backupChangeEncryptionModuleInteractor()
        flowController.parent = parent
        let presenter = BackupChangeEncryptionPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter

        view.modalPresentationStyle = .fullScreen
        viewController.present(view, animated: true)        
    }
}

extension BackupChangeEncryptionFlowController: BackupChangeEncryptionFlowControlling {
    func close() {
        parent?.closeChangeEncryption()
    }
}
