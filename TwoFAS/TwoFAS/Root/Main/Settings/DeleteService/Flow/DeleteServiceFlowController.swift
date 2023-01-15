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
    
    static func present(
        on viewController: UIViewController,
        parent: DeleteServiceFlowControllerParent,
        serviceData: ServiceData
    ) {
        let view = DeleteServiceViewController()
        let flowController = DeleteServiceFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = InteractorFactory.shared.deleteServiceInteractor()
        let presenter = DeleteServicePresenter(
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

extension DeleteServiceFlowController: DeleteServiceFlowControlling {
    func toDeleteService() {
        parent?.didDeleteService()
    }
    
    func toClose() {
        parent?.closeDeletingService()
    }
}
