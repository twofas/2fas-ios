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
import UIKit

protocol LabelComposeFlowControllerParent: AnyObject {
    func labelComposeSave(title: String, color: TintColor)
}

protocol LabelComposeFlowControlling: AnyObject {
    func toSave(title: String, color: TintColor)
}

final class LabelComposeFlowController: FlowController {
    private weak var parent: LabelComposeFlowControllerParent?

    static func present(
        title: String,
        color: TintColor,
        on navigationController: UINavigationController,
        parent: LabelComposeFlowControllerParent
    ) {
        let view = LabelComposeViewController()
        let flowController = LabelComposeFlowController(viewController: view)
        flowController.parent = parent
        
        let presenter = LabelComposePresenter(
            flowController: flowController,
            title: title,
            color: color
        )
        view.presenter = presenter
        presenter.view = view
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension LabelComposeFlowController: LabelComposeFlowControlling {
    func toSave(title: String, color: TintColor) {
        parent?.labelComposeSave(title: title, color: color)
    }    
}
