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
import SwiftUI
import Common
import Data

protocol SelectServiceFlowControllerParent: AnyObject {
    func serviceSelectionDidSelect(_ serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth, save: Bool)
    func serviceSelectionCancelled(for tokenRequestID: String)
}

protocol SelectServiceFlowControlling: AnyObject {
    func toServiceSelection(with serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth, save: Bool)
    func toCancel(for tokenRequestID: String)
}

final class SelectServiceFlowController: FlowController {
    private weak var parent: SelectServiceFlowControllerParent?

    static func present(
        on viewController: UIViewController,
        parent: SelectServiceFlowControllerParent,
        authRequest: WebExtensionAwaitingAuth
    ) {
        let interactor = ModuleInteractorFactory.shared.selectServiceModuleInteractor()
        let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
        let flowController = SelectServiceFlowController(viewController: hostingController)
        flowController.parent = parent

        let presenter = SelectServicePresenter(
            interactor: interactor,
            flowController: flowController,
            authRequest: authRequest
        )

        hostingController.rootView = AnyView(SelectServiceView(presenter: presenter))
        hostingController.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor
        hostingController.configureAsLargeModal()
        viewController.present(hostingController, animated: true, completion: nil)
    }
}

extension SelectServiceFlowController: SelectServiceFlowControlling {
    func toServiceSelection(with serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth, save: Bool) {
        parent?.serviceSelectionDidSelect(serviceData, authRequest: authRequest, save: save)
    }

    func toCancel(for tokenRequestID: String) {
        parent?.serviceSelectionCancelled(for: tokenRequestID)
    }
}
