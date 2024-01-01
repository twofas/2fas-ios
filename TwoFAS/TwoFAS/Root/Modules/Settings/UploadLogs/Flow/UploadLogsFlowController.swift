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

protocol UploadLogsFlowControllerParent: AnyObject {
    func closeUploadLogs()
}

protocol UploadLogsFlowControlling: AnyObject {
    func toClose()
    func toSuccess()
    func toFailure(reason error: UploadLogsModuleInteractorError, canRetry: Bool)
}

final class UploadLogsFlowController: FlowController {
    private weak var parent: UploadLogsFlowControllerParent?
    private weak var navigationController: UINavigationController?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        auditID: UUID?,
        parent: UploadLogsFlowControllerParent
    ) {
        let view = UploadLogsViewController()
        let flowController = UploadLogsFlowController(viewController: view)
        let interactor = ModuleInteractorFactory.shared.uploadLogsModuleInteractor(auditID: auditID)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let presenter = UploadLogsPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        navigationController.setViewControllers([view], animated: false)
    }
}

extension UploadLogsFlowController {
    var viewController: UploadLogsViewController { _viewController as! UploadLogsViewController }
}

extension UploadLogsFlowController: UploadLogsFlowControlling {
    func toClose() {
        parent?.closeUploadLogs()
    }
    
    func toSuccess() {
        guard let navigationController else { return }
        UploadLogsSuccessFlowController.push(in: navigationController, parent: self)
    }
    
    func toFailure(reason error: UploadLogsModuleInteractorError, canRetry: Bool) {
        guard let navigationController else { return }
        UploadLogsFailureFlowController.push(
            in: navigationController,
            error: error,
            canRetry: canRetry,
            parent: self
        )
    }
}

extension UploadLogsFlowController: UploadLogsSuccessFlowControllerParent {
    func uploadLogsSuccessClose() {
        parent?.closeUploadLogs()
    }
}

extension UploadLogsFlowController: UploadLogsFailureFlowControllerParent {
    func uploadLogsFailureClose() {
        parent?.closeUploadLogs()
    }
    
    func uploadLogsFailureRetry(clearCode: Bool) {
        viewController.presenter.handleClear(clearCode: clearCode)
        navigationController?.popToRootViewController(animated: true)
    }
}
