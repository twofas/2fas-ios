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

final class ComposeServiceCategorySelectionPresenter {
    weak var view: ComposeServiceCategorySelectionViewControlling?
    
    private let flowController: ComposeServiceCategorySelectionFlowControlling
    let interactor: ComposeServiceCategorySelectionModuleInteracting
    
    init(
        flowController: ComposeServiceCategorySelectionFlowControlling,
        interactor: ComposeServiceCategorySelectionModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }
    
    func viewWillAppear() {
        reload()
    }
        
    func handleSelection(at indexPath: IndexPath) {
        let menu = buildMenu()
        guard let option = menu.cells[safe: indexPath.row] else { return }
        let sectionID = option.sectionID
        flowController.toChangeSection(sectionID)
        interactor.setSelection(sectionID)
        reload()
    }
    
    func handleSectionAdded(with title: String) {
        interactor.addSection(with: title)
        reload()
    }
    
    func handleAddSection() {
        flowController.toCreateSection()
    }
}

private extension ComposeServiceCategorySelectionPresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
