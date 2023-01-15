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

protocol UploadLogsFailureFlowControllerParent: AnyObject {
    func uploadLogsFailureClose()
    func uploadLogsFailureRetry(clearCode: Bool)
}

protocol UploadLogsFailureFlowControlling: AnyObject {
    func toClose()
    func toRetry(clearCode: Bool)
}

final class UploadLogsFailureFlowController: FlowController {
    private weak var parent: UploadLogsFailureFlowControllerParent?
    
    static func push(
        in navigationController: UINavigationController,
        error: UploadLogsModuleInteractorError,
        canRetry: Bool,
        parent: UploadLogsFailureFlowControllerParent
    ) {
        let view = UploadLogsFailureViewController()
        let flowController = UploadLogsFailureFlowController(viewController: view)
        flowController.parent = parent
        
        let presenter = UploadLogsFailurePresenter(
            flowController: flowController,
            error: error,
            canRetry: canRetry
        )
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension UploadLogsFailureFlowController: UploadLogsFailureFlowControlling {
    func toClose() {
        parent?.uploadLogsFailureClose()
    }
    
    func toRetry(clearCode: Bool) {
        parent?.uploadLogsFailureRetry(clearCode: clearCode)
    }
}
