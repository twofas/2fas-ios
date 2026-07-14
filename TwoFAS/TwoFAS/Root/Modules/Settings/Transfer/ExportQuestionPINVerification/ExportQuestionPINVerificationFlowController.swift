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

protocol ExportQuestionPINVerificationFlowControllerParent: AnyObject {
    func closePIN()
    func PINSuccess()
}

protocol ExportQuestionPINVerificationFlowControlling: AnyObject {
    func toClose()
    func toSuccess()
}

final class ExportQuestionPINVerificationFlowController: FlowController {
    private weak var parent: ExportQuestionPINVerificationFlowControllerParent?

    static func push(
        in navigationController: UINavigationController,
        parent: ExportQuestionPINVerificationFlowControllerParent
    ) {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = ExportQuestionPINVerificationFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.exportQuestionPINVerificationModuleInteractor()
        let presenter = ExportQuestionPINVerificationPresenter(
            flowController: flowController,
            interactor: interactor
        )
        hosting.rootView = AnyView(ExportQuestionPINVerificationView(presenter: presenter))

        navigationController.pushViewController(hosting, animated: true)
    }
}

extension ExportQuestionPINVerificationFlowController: ExportQuestionPINVerificationFlowControlling {
    func toClose() {
        parent?.closePIN()
    }

    func toSuccess() {
        parent?.PINSuccess()
    }
}
