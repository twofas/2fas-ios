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

final class ComposeServiceAdvancedSummaryPresenter {
    weak var view: ComposeServiceAdvancedSummaryViewControlling?
    
    private let flowController: ComposeServiceAdvancedSummaryFlowControlling
    let interactor: ComposeServiceAdvancedSummaryModuleInteracting
    
    init(
        flowController: ComposeServiceAdvancedSummaryFlowControlling,
        interactor: ComposeServiceAdvancedSummaryModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension ComposeServiceAdvancedSummaryPresenter {
    func viewWillAppear() {
        reload()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        let menu = buildMenu()
        guard let cell = menu.cells[safe: indexPath.row] else { return }
        if cell.copyValue {
            interactor.copyCounter()
        }
    }
}

private extension ComposeServiceAdvancedSummaryPresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
