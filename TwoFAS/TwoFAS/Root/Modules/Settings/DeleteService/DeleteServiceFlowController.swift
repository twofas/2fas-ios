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

protocol DeleteServiceFlowControllerParent: AnyObject {
    func didDeleteService()
    func closeDeletingService()
}

protocol DeleteServiceFlowControlling: AnyObject {
    func toDeleteService()
    func toClose()
}

final class DeleteServiceFlowController: FlowController {
    private weak var parent: DeleteServiceFlowControllerParent?
    private let modalHost = AdaptiveModalHost()

    static func present(
        on viewController: UIViewController,
        parent: DeleteServiceFlowControllerParent,
        serviceData: ServiceData
    ) {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        let flowController = DeleteServiceFlowController(viewController: hosting)
        flowController.parent = parent

        let interactor = ModuleInteractorFactory.shared.deleteServiceInteractor()
        let presenter = DeleteServicePresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.serviceData = serviceData

        hosting.rootView = AnyView(
            DeleteServiceView(
                action: { presenter.handleDelete() },
                cancel: { presenter.handleCancel() },
                onHeightChange: { [weak flowController] height in
                    flowController?.modalHost.setContentHeight(height)
                }
            )
        )
        // A centered card at the measured content height in regular width; in compact the
        // same height drives the bottom sheet's detent. SheetContent's fillViewport
        // stretches and centers the content inside whatever it gets.
        flowController.modalHost.presentAsFormSheet(hosting, on: viewController)
    }
}

extension DeleteServiceFlowController: DeleteServiceFlowControlling {
    func toDeleteService() {
        parent?.didDeleteService()
    }

    func toClose() {
        parent?.closeDeletingService()
    }
}
