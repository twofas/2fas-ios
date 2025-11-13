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

protocol BackupSetPasswordFlowControllerParent: AnyObject {
    func closeSetPassword()
}

protocol BackupSetPasswordFlowControlling: AnyObject {
    func close()
    func toChangePassword()
    func toRemovePassword()
}

enum BackupSetPasswordType {
    case setPassword
    case changePassword
}

final class BackupSetPasswordFlowController: FlowController {
    private weak var parent: BackupSetPasswordFlowControllerParent?
    
    static func showAsRoot(
        in viewController: UIViewController,
        parent: BackupSetPasswordFlowControllerParent,
        flowType: BackupSetPasswordType
    ) {
        let view = BackupSetPasswordViewController()
        let flowController = BackupSetPasswordFlowController(viewController: view)
        flowController.parent = parent
        let presenter = BackupSetPasswordPresenter(
            flowController: flowController,
            interactor: ModuleInteractorFactory.shared.backupSetPasswordModuleInteractor(),
            flowType: flowType
        )
        view.presenter = presenter
        
        view.configureAsModal()
        viewController.present(view, animated: true)
    }
}

extension BackupSetPasswordFlowController: BackupSetPasswordFlowControlling {
    func close() {
        parent?.closeSetPassword()
    }
    
    func toChangePassword() {
        
    }
    
    func toRemovePassword() {
        
    }
}
