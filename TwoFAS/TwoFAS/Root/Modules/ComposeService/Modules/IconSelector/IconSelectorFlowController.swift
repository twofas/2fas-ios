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

protocol IconSelectorFlowControllerParent: AnyObject {
    func iconSelectorDidSelect(iconTypeID: IconTypeID)
}

protocol IconSelectorFlowControlling: AnyObject {
    func toSelection(iconTypeID: IconTypeID)
    func toUserIcon()
    func toCompanyIcon()
    func close()
}

final class IconSelectorFlowController: FlowController {
    private weak var parent: IconSelectorFlowControllerParent?
    private weak var navigationController: UINavigationController?

    static func present(
        defaultIcon: IconTypeID?,
        selectedIcon: IconTypeID?,
        on navigationController: UINavigationController,
        parent: IconSelectorFlowControllerParent,
        animated: Bool
    ) {
        let interactor = ModuleInteractorFactory.shared.iconSelectorModuleInteractor(
            defaultIcon: defaultIcon,
            selectedIcon: selectedIcon
        )

        let hostingController = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        let flowController = IconSelectorFlowController(viewController: hostingController)
        flowController.parent = parent
        flowController.navigationController = navigationController

        let presenter = IconSelectorPresenter(
            flowController: flowController,
            interactor: interactor,
            selectedIconTypeID: selectedIcon
        )

        hostingController.rootView = AnyView(IconSelectorView(presenter: presenter))
        hostingController.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor

        navigationController.pushViewController(hostingController, animated: animated)
    }
}

extension IconSelectorFlowController: IconSelectorFlowControlling {
    func toSelection(iconTypeID: IconTypeID) {
        parent?.iconSelectorDidSelect(iconTypeID: iconTypeID)
    }

    func toUserIcon() {
        AppEventLog(.orderIconClick)
        AppEventLog(.orderIconAsUser)
        guard let navigationController else { return }
        UserIconInfoFlowController.push(on: navigationController, parent: self)
    }

    func toCompanyIcon() {
        AppEventLog(.orderIconClick)
        AppEventLog(.orderIconAsCompany)
        UIApplication.shared.open(
            URL(string: "https://2fas.com/your-branding/")!,
            options: [:],
            completionHandler: nil
        )
    }

    func close() {
        navigationController?.popViewController(animated: true)
    }
}

extension IconSelectorFlowController: UserIconInfoFlowControllerParent {}
