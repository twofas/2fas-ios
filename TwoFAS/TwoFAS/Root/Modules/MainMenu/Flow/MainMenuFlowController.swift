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

protocol MainMenuFlowControllerParent: AnyObject {}

protocol MainMenuFlowControlling: AnyObject {
//    func toMain()
//    func toMainSection(_ sectionOffset: Int)
//    func toSettings()
//    func toNews()
}

final class MainMenuFlowController: FlowController {
    private weak var parent: MainMenuFlowControllerParent?
    
    static func insert(
        into split: UISplitViewController,
        parent: MainMenuFlowControllerParent
    ) {
        let view = MainMenuViewController()
        let flowController = MainMenuFlowController(viewController: view)
        flowController.parent = parent

        let interactor = InteractorFactory.shared.mainMenuModuleInteractor()
        
        let presenter = MainMenuPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view

        split.setViewController(view, for: .primary)
    }
}

extension MainMenuFlowController {
    var viewController: MainMenuViewController { _viewController as! MainMenuViewController }
}

extension MainMenuFlowController: MainMenuFlowControlling {
    
}
