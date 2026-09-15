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

protocol GuideSelectorFlowControllerParent: AnyObject {
    func guideSelectorClose()
    func guideSelectorAddManually(with data: String?)
    func guideSelectorCodeScanner()
}

protocol GuideSelectorFlowControlling: AnyObject {
    func toClose()
    func toGuideMenu(_ guide: GuideDescription)
}

final class GuideSelectorFlowController: FlowController {
    private weak var parent: GuideSelectorFlowControllerParent?
    private var router: GuideRouter?
    private var presenter: GuideSelectorPresenter?

    @discardableResult
    static func present(
        in navigationController: UINavigationController,
        parent: GuideSelectorFlowControllerParent
    ) -> GuideSelectorFlowController {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        let flowController = GuideSelectorFlowController(viewController: hosting)
        flowController.parent = parent

        let interactor = ModuleInteractorFactory.shared.guideSelectorModuleInteractor()
        let router = GuideRouter()
        router.flowController = flowController
        let presenter = GuideSelectorPresenter(
            flowController: router,
            interactor: interactor
        )
        flowController.router = router
        flowController.presenter = presenter

        hosting.rootView = AnyView(GuideSelectorView(presenter: presenter, router: router))
        hosting.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor

        navigationController.setViewControllers([hosting], animated: false)

        return flowController
    }

    // MARK: - Terminal actions (driven by the router)

    func close() {
        parent?.guideSelectorClose()
    }

    func addManually(with data: String?) {
        parent?.guideSelectorAddManually(with: data)
    }

    func codeScanner() {
        parent?.guideSelectorCodeScanner()
    }
}
