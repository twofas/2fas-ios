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

import Foundation
import UIKit
import SwiftUI
import Common

protocol TrashFlowControllerParent: AnyObject {}

protocol TrashFlowControlling: AnyObject {
    func toDelete(with serviceData: ServiceData)
}

final class TrashFlowController: FlowController {
    private weak var parent: TrashFlowControllerParent?
    fileprivate var presenter: TrashPresenter?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: TrashFlowControllerParent
    ) {
        let hosting = create(parent: parent)
        navigationController.setViewControllers([hosting], animated: false)
    }

    static func push(
        in navigationController: UINavigationController,
        parent: TrashFlowControllerParent
    ) {
        let hosting = create(parent: parent)
        navigationController.pushRootViewController(hosting, animated: true)
    }

    private static func create(
        parent: TrashFlowControllerParent
    ) -> UIViewController {
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
        let flowController = TrashFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.trashModuleInteractor()
        let presenter = TrashPresenter(
            flowController: flowController,
            interactor: interactor
        )
        flowController.presenter = presenter
        hosting.rootView = AnyView(TrashView(presenter: presenter))
        return hosting
    }
}

extension TrashFlowController: TrashFlowControlling {
    func toDelete(with serviceData: ServiceData) {
        DeleteServiceFlowController.present(on: _viewController, parent: self, serviceData: serviceData)
    }
}

extension TrashFlowController: DeleteServiceFlowControllerParent {
    func didDeleteService() {
        presenter?.handleServiceListChanged()
        _viewController.dismiss(animated: true, completion: nil)
    }

    func closeDeletingService() {
        _viewController.dismiss(animated: true, completion: nil)
    }
}
