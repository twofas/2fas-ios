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
    
    static func present(
        on viewController: UIViewController,
        parent: TrashServiceFlowControllerParent,
        serviceData: ServiceData
    ) {
        let view = TrashServiceViewController()
        let flowController = TrashServiceFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.trashServiceInteractor()
        let presenter = TrashServicePresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.serviceData = serviceData
        presenter.view = view
        
        view.presenter = presenter
        view.configureAsModal()

        viewController.present(view, animated: true, completion: nil)
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
