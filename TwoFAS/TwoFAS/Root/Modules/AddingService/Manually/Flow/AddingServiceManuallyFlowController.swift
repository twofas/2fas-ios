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

protocol AddingServiceManuallyFlowControllerParent: AnyObject {
    func addingServiceManuallyToClose(_ serviceData: ServiceData)
    func addingServiceManuallyToCancel()
}

protocol AddingServiceManuallyFlowControlling: AnyObject {
    func toClose(_ serviceData: ServiceData)
    func toClose()
    func toInitialCounterInput()
}

final class AddingServiceManuallyFlowController: FlowController {
    private weak var parent: AddingServiceManuallyFlowControllerParent?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: AddingServiceManuallyFlowControllerParent,
        name: String?
    ) {
        let view = AddingServiceManuallyViewController()
        let flowController = AddingServiceManuallyFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.addingServiceManuallyModuleInteractor()
        
        let presenter = AddingServiceManuallyPresenter(
            flowController: flowController,
            interactor: interactor,
            providedName: name
        )
        view.presenter = presenter
        presenter.view = view
                
        navigationController.setViewControllers([view], animated: true)
    }
}

extension AddingServiceManuallyFlowController {
    var viewController: AddingServiceManuallyViewController { _viewController as! AddingServiceManuallyViewController }
}

extension AddingServiceManuallyFlowController: AddingServiceManuallyFlowControlling {
    func toClose(_ serviceData: ServiceData) {
        parent?.addingServiceManuallyToClose(serviceData)
    }
    
    func toClose() {
        parent?.addingServiceManuallyToCancel()
    }
    
    func toInitialCounterInput() {
        let alert = AlertControllerPromptFactory.create(
            title: T.Tokens.initialCounter,
            message: nil,
            actionName: T.Commons.set,
            defaultText: "0",
            inputConfiguration: .intNumber,
            action: { [weak self] value in
                let int = Int(value) ?? 0
                self?.viewController.presenter.handleInitialCounter(int)
            },
            cancel: nil,
            verify: { value in
                guard let int = Int(value) else { return false }
                return int >= 0
            })
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
