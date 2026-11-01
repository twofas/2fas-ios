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

protocol AddingServiceManuallyFlowControllerParent: AnyObject {
    func addingServiceManuallyToClose(_ serviceData: ServiceData)
    func addingServiceManuallyToCancel()
}

protocol AddingServiceManuallyFlowControlling: AnyObject {
    func toClose(_ serviceData: ServiceData)
    func toClose()
    func toAdvancedSettings(_ settings: AddingServiceAdvancedSettings)
    func toIconEditor(_ value: IconEditorValue)
}

final class AddingServiceManuallyFlowController: FlowController {
    private weak var parent: AddingServiceManuallyFlowControllerParent?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: AddingServiceManuallyFlowControllerParent,
        name: String?
    ) {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        let flowController = AddingServiceManuallyFlowController(viewController: hosting)
        flowController.parent = parent

        let interactor = ModuleInteractorFactory.shared.addingServiceManuallyModuleInteractor()
        let router = AddingServiceManuallyRouter()
        router.flowController = flowController

        let presenter = AddingServiceManuallyPresenter(
            flowController: router,
            interactor: interactor,
            providedName: name
        )
        router.presenter = presenter

        hosting.rootView = AnyView(AddingServiceManuallyView(presenter: presenter, router: router))
        hosting.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor

        navigationController.setViewControllers([hosting], animated: true)
    }
}

extension AddingServiceManuallyFlowController {
    func close(_ serviceData: ServiceData) {
        parent?.addingServiceManuallyToClose(serviceData)
    }
    
    func cancel() {
        parent?.addingServiceManuallyToCancel()
    }

    func share(_ text: String) {
        let activityController = ShareActivityController.createWithText(text)
        _viewController.present(activityController, animated: true, completion: nil)
    }
}
