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

protocol WidgetWarningFlowControllerParent: AnyObject {
    func hideWidgetWarning()
    func hideWidgetWarningAndEnable()
}

protocol WidgetWarningFlowControlling: AnyObject {
    func toClose()
    func toEnableAndClose()
}

final class WidgetWarningFlowController: FlowController {
    private weak var parent: WidgetWarningFlowControllerParent?

    static func present(
        on viewController: UIViewController,
        parent: WidgetWarningFlowControllerParent
    ) {
        let hostingController = UIHostingController(
            rootView: WidgetWarning(action: {}, cancel: {})
        )
        let flowController = WidgetWarningFlowController(viewController: hostingController)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.widgetWarningModuleInteractor()
        let presenter = WidgetWarningPresenter(
            flowController: flowController,
            interactor: interactor
        )
        hostingController.rootView = WidgetWarning(
            action: { presenter.handleEnableWidgets() },
            cancel: { presenter.handleCancel() }
        )
        hostingController.view.backgroundColor = .clear
        hostingController.configureAsModal()

        viewController.present(hostingController, animated: true, completion: nil)
    }
}

extension WidgetWarningFlowController: WidgetWarningFlowControlling {
    func toClose() {
        parent?.hideWidgetWarning()
    }
    
    func toEnableAndClose() {
        parent?.hideWidgetWarningAndEnable()
    }
}
