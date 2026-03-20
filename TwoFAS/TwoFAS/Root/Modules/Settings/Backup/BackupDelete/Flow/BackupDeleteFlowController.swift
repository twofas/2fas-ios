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

protocol BackupDeleteFlowControllerParent: AnyObject {
    func closeDeleteBackup(didDelete: Bool)
}

protocol BackupDeleteFlowControlling: AnyObject {
    func toClose(didDelete: Bool)
    func toError(_ error: Error, completion: @escaping Callback)
}

final class BackupDeleteFlowController: FlowController {
    private weak var parent: BackupDeleteFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: BackupDeleteFlowControllerParent
    ) {
        let view = BackupDeleteViewController()
        let flowController = BackupDeleteFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.backupDeleteModuleInteractor()
        let presenter = BackupDeletePresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        view.configureAsModal()
        
        viewController.present(view, animated: true, completion: nil)
    }
}

extension BackupDeleteFlowController: BackupDeleteFlowControlling {
    func toClose(didDelete: Bool) {
        parent?.closeDeleteBackup(didDelete: didDelete)
    }
    
    func toError(_ error: Error, completion: @escaping Callback) {
        let alert = UIAlertController(
            title: T.Commons.error,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .default, handler: { _ in completion() }))
        _viewController.present(alert, animated: true)
    }
}
