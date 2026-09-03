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

protocol TrashServiceFlowControllerParent: AnyObject {
    func didTrashService()
    func closeTrashService()
}

protocol TrashServiceFlowControlling: AnyObject {
    func toTrashService()
    func toClose()
}

final class TrashServiceFlowController: FlowController {
    private weak var parent: TrashServiceFlowControllerParent?
    private let modalHost = AdaptiveModalHost()

    static func present(
        on viewController: UIViewController,
        parent: TrashServiceFlowControllerParent,
        serviceData: ServiceData,
        anchor: (() -> UIView?)? = nil
    ) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        let flowController = TrashServiceFlowController(viewController: hosting)
        flowController.parent = parent

        let interactor = ModuleInteractorFactory.shared.trashServiceInteractor()
        let presenter = TrashServicePresenter(
            serviceData: serviceData,
            flowController: flowController,
            interactor: interactor
        )
        hosting.rootView = AnyView(
            TrashServiceView(presenter: presenter) { [weak flowController] height in
                flowController?.modalHost.setContentHeight(height)
            }
        )

        flowController.modalHost.presentAsPopover(hosting, on: viewController, anchor: anchor)
    }
}

extension TrashServiceFlowController: TrashServiceFlowControlling {
    func toClose() {
        parent?.closeTrashService()
    }

    func toTrashService() {
        parent?.didTrashService()
    }
}
