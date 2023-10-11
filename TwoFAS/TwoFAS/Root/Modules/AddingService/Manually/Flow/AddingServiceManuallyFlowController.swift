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
}

protocol AddingServiceManuallyFlowControlling: AnyObject {
    func toClose(_ serviceData: ServiceData)
    func toInitialCounterInput()
    func toHelp()
}

final class AddingServiceManuallyFlowController: FlowController {
    private weak var parent: AddingServiceManuallyFlowControllerParent?
    private weak var container: (UIViewController & AddingServiceViewControlling)?
    
    static func embed(
        in viewController: UIViewController & AddingServiceViewControlling,
        parent: AddingServiceManuallyFlowControllerParent,
        name: String?
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
            interactor: interactor,
            providedName: name
        )
        view.presenter = presenter
        presenter.view = view
        
        viewController.embedViewController(view)
    }
}

extension AddingServiceManuallyFlowController {
    var viewController: AddingServiceManuallyViewController { _viewController as! AddingServiceManuallyViewController }
}

extension AddingServiceManuallyFlowController: AddingServiceManuallyFlowControlling {
    func toClose(_ serviceData: ServiceData) {
        parent?.addingServiceManuallyToClose(serviceData)
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
    
    func toHelp() {
        UIApplication.shared.open(URL(string: "https://support.2fas.com")!)
    }
}
