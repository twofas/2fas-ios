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
import Storage
import Common

protocol ComposeServiceCategorySelectionFlowControllerParent: AnyObject {
    func didChangeSectionID(_ section: SectionID?)
}

protocol ComposeServiceCategorySelectionFlowControlling: AnyObject {
    func toChangeSection(_ sectionID: SectionID?)
    func close()
}

final class ComposeServiceCategorySelectionFlowController: FlowController {
    private weak var parent: ComposeServiceCategorySelectionFlowControllerParent?
    private weak var navigationController: UINavigationController?

    static func push(
        on navigationController: UINavigationController,
        parent: ComposeServiceCategorySelectionFlowControllerParent,
        selectedSection: SectionID?
    ) {
        let hostingController = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        let flowController = ComposeServiceCategorySelectionFlowController(viewController: hostingController)
        flowController.parent = parent
        flowController.navigationController = navigationController

        let interactor = ModuleInteractorFactory
            .shared
            .composeServiceCategorySelectionModuleInteractor(with: selectedSection)
        let presenter = ComposeServiceCategorySelectionPresenter(
            flowController: flowController,
            interactor: interactor
        )

        hostingController.rootView = AnyView(ComposeServiceCategorySelectionView(presenter: presenter))
        hostingController.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor

        navigationController.pushViewController(hostingController, animated: true)
    }
}

extension ComposeServiceCategorySelectionFlowController: ComposeServiceCategorySelectionFlowControlling {
    func toChangeSection(_ sectionID: SectionID?) {
        parent?.didChangeSectionID(sectionID)
    }

    func close() {
        navigationController?.popViewController(animated: true)
    }
}
