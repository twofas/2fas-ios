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

protocol AddingServiceManuallyFlowControllerParent: AnyObject {}

protocol AddingServiceManuallyFlowControlling: AnyObject {
    func toToken(_ serviceData: ServiceData)
}

final class AddingServiceManuallyFlowController: FlowController {
    private weak var parent: AddingServiceManuallyFlowControllerParent?
    private weak var container: (UIViewController & AddingServiceViewControlling)?
    
    static func embed(
        in viewController: UIViewController & AddingServiceViewControlling,
        parent: AddingServiceManuallyFlowControllerParent
    ) {
        let view = AddingServiceManuallyViewController()
        let flowController = AddingServiceManuallyFlowController(viewController: view)
        flowController.parent = parent
        flowController.container = viewController
        
        view.heightChange = { [weak viewController] height in
            viewController?.updateHeight(height)
        }
        
        let interactor = InteractorFactory.shared.addingServiceManuallyModuleInteractor()
        
        let presenter = AddingServiceManuallyPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        viewController.embedViewController(view)
    }
}

extension AddingServiceManuallyFlowController: AddingServiceManuallyFlowControlling {
    func toToken(_ serviceData: ServiceData) {
        guard let container else { return }
        AddingServiceTokenFlowController.embed(in: container, parent: self, serviceData: serviceData)
    }
}

extension AddingServiceManuallyFlowController: AddingServiceTokenFlowControllerParent {
}
