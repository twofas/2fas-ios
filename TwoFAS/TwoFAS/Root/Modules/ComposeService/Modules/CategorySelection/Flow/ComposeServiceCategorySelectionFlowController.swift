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
import Storage
import Common

protocol ComposeServiceCategorySelectionFlowControllerParent: AnyObject {
    func didChangeSectionID(_ section: SectionID?)
}

protocol ComposeServiceCategorySelectionFlowControlling: AnyObject {
    func toChangeSection(_ sectionID: SectionID?)
    func toCreateSection()
}

final class ComposeServiceCategorySelectionFlowController: FlowController {
    private weak var parent: ComposeServiceCategorySelectionFlowControllerParent?
    
    static func push(
        on navigationController: UINavigationController,
        parent: ComposeServiceCategorySelectionFlowControllerParent,
        selectedSection: SectionID?
    ) {
        let view = ComposeServiceCategorySelectionViewController()
        let flowController = ComposeServiceCategorySelectionFlowController(viewController: view)
        let interactor = InteractorFactory.shared.composeServiceCategorySelectionModuleInteractor(with: selectedSection)
        flowController.parent = parent
        let presenter = ComposeServiceCategorySelectionPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension ComposeServiceCategorySelectionFlowController {
    var viewController: ComposeServiceCategorySelectionViewController {
        _viewController as! ComposeServiceCategorySelectionViewController
    }
}

extension ComposeServiceCategorySelectionFlowController: ComposeServiceCategorySelectionFlowControlling {
    func toChangeSection(_ sectionID: SectionID?) {
        parent?.didChangeSectionID(sectionID)
    }
    
    func toCreateSection() {
        let alert = AlertControllerPromptFactory.create(
            title: T.Tokens.addGroup,
            message: T.Tokens.groupName,
            actionName: T.Commons.add,
            defaultText: "",
            inputConfiguration: .name,
            action: { [weak self] title in
                self?.viewController.presenter.handleSectionAdded(with: title.trim())
        },
            cancel: nil,
            verify: { sectionName in
                ServiceRules.isSectionNameValid(sectionName: sectionName.trim())
        })
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
