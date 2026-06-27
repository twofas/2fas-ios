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

protocol LabelComposeFlowControllerParent: AnyObject {
    func labelComposeSave(title: String, color: TintColor)
}

protocol LabelComposeFlowControlling: AnyObject {
    func toSave(title: String, color: TintColor)
    func close()
}

final class LabelComposeFlowController: FlowController {
    private weak var parent: LabelComposeFlowControllerParent?
    private weak var navigationController: UINavigationController?

    static func present(
        title: String,
        color: TintColor,
        on navigationController: UINavigationController,
        parent: LabelComposeFlowControllerParent
    ) {
        let hostingController = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        let flowController = LabelComposeFlowController(viewController: hostingController)
        flowController.parent = parent
        flowController.navigationController = navigationController

        let presenter = LabelComposePresenter(
            flowController: flowController,
            title: title,
            color: color
        )

        hostingController.rootView = AnyView(LabelComposeView(presenter: presenter))
        hostingController.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor

        navigationController.pushViewController(hostingController, animated: true)
    }
}

extension LabelComposeFlowController: LabelComposeFlowControlling {
    func toSave(title: String, color: TintColor) {
        parent?.labelComposeSave(title: title, color: color)
    }

    func close() {
        navigationController?.popViewController(animated: true)
    }
}
