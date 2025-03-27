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

protocol SyncMigrationToNewestVersionFlowControllerParent: AnyObject {
    func closeMigrationToNewestVersion()
}

protocol SyncMigrationToNewestVersionFlowControlling: AnyObject {
    func close()
}

enum SyncMigrationToNewestVersionFlowResult {
    case success
    case error(CloudState.NotAvailableReason)
}

final class SyncMigrationToNewestVersionFlowController: FlowController {
    private weak var parent: SyncMigrationToNewestVersionFlowControllerParent?

    static func showAsRoot(
        in viewController: UIViewController,
        parent: SyncMigrationToNewestVersionFlowControllerParent
    ) -> (SyncMigrationToNewestVersionFlowResult) -> Void {
        let view = SyncMigrationToNewestVersionViewController()
        let flowController = SyncMigrationToNewestVersionFlowController(viewController: view)
        flowController.parent = parent
        let presenter = SyncMigrationToNewestVersionPresenter(
            flowController: flowController
        )
        view.presenter = presenter

        view.modalPresentationStyle = .fullScreen
        viewController.present(view, animated: true)
        
        return presenter.callback
    }
}

extension SyncMigrationToNewestVersionFlowController: SyncMigrationToNewestVersionFlowControlling {
    func close() {
        parent?.closeMigrationToNewestVersion()
    }
}
