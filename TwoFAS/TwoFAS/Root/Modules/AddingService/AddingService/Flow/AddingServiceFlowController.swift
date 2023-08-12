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

protocol AddingServiceFlowControllerParent: AnyObject {
    func addingServiceDismiss()
}

protocol AddingServiceFlowControlling: AnyObject {
    func toMain()
}

final class AddingServiceFlowController: FlowController {
    private weak var parent: AddingServiceFlowControllerParent?
    
    static func present(
        on viewController: UIViewController,
        parent: AddingServiceFlowControllerParent
    ) {
        let view = AddingServiceViewController()
        let flowController = AddingServiceFlowController(viewController: view)
        flowController.parent = parent
        
        let presenter = AddingServicePresenter(flowController: flowController)
        view.presenter = presenter
        presenter.view = view
        
        viewController.present(view, animated: true)
    }
}

extension AddingServiceFlowController {
    var viewController: AddingServiceViewController { _viewController as! AddingServiceViewController }
}

extension AddingServiceFlowController: AddingServiceFlowControlling {
    func toMain() {
        AddingServiceMainFlowController.embed(in: viewController, parent: self)
    }
}

extension AddingServiceFlowController: AddingServiceMainFlowControllerParent {
    func mainToToken(serviceData: ServiceData) {
        AddingServiceTokenFlowController.embed(in: viewController, parent: self, serviceData: serviceData)
    }
    
    func mainToDismiss() {
        parent?.addingServiceDismiss()
    }
}

extension AddingServiceFlowController: AddingServiceTokenFlowControllerParent {}
