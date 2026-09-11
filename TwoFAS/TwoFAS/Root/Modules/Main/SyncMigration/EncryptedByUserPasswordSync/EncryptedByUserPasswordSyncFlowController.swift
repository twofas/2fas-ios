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
import Data

protocol EncryptedByUserPasswordSyncFlowControllerParent: AnyObject {
    func closeEncryptedByUser()
}

protocol EncryptedByUserPasswordSyncFlowControlling: AnyObject {
    func close()
    func toChangePassword()
}

enum EncryptedByUserPasswordSyncType {
    enum Next {
        case removePassword
        case changePassword
    }
    case enterPassword
    case verifyPassword(Next)
}

final class EncryptedByUserPasswordSyncFlowController: FlowController {
    private weak var parent: EncryptedByUserPasswordSyncFlowControllerParent?

    static func showAsRoot(
        in viewController: UIViewController,
        parent: EncryptedByUserPasswordSyncFlowControllerParent
    ) -> (MigrationResult) -> Void {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor
        let flowController = EncryptedByUserPasswordSyncFlowController(viewController: hosting)
        let interactor = ModuleInteractorFactory.shared.encryptedByUserPasswordSyncModuleInteractor()
        flowController.parent = parent
        let presenter = EncryptedByUserPasswordSyncPresenter(
            flowController: flowController,
            interactor: interactor,
            flowType: .enterPassword
        )
        hosting.rootView = AnyView(EncryptedByUserPasswordSyncView(presenter: presenter))

        hosting.configureAsModal()
        viewController.present(hosting, animated: true)

        return presenter.callback
    }

    static func setAsRoot(
        in navigationController: UINavigationController,
        parent: EncryptedByUserPasswordSyncFlowControllerParent,
        actionType: EncryptedByUserPasswordSyncType
    ) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        hosting.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor
        let flowController = EncryptedByUserPasswordSyncFlowController(viewController: hosting)
        let interactor = ModuleInteractorFactory.shared.encryptedByUserPasswordSyncModuleInteractor()
        flowController.parent = parent
        let presenter = EncryptedByUserPasswordSyncPresenter(
            flowController: flowController,
            interactor: interactor,
            flowType: actionType
        )
        hosting.rootView = AnyView(EncryptedByUserPasswordSyncView(presenter: presenter))

        navigationController.pushRootViewController(hosting, animated: false)
    }
}

extension EncryptedByUserPasswordSyncFlowController: EncryptedByUserPasswordSyncFlowControlling {
    func close() {
        parent?.closeEncryptedByUser()
    }

    func toChangePassword() {
        guard let navi = _viewController?.navigationController else { return }
        BackupSetPasswordFlowController.push(in: navi, parent: self, flowType: .changePassword)
    }
}

extension EncryptedByUserPasswordSyncFlowController: BackupSetPasswordFlowControllerParent {
    func closeSetPassword() {
        parent?.closeEncryptedByUser()
    }
}
