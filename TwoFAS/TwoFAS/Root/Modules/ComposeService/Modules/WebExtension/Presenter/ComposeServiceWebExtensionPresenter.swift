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

final class ComposeServiceWebExtensionPresenter {
    weak var view: ComposeServiceWebExtensionViewControlling?
    
    private let flowController: ComposeServiceWebExtensionFlowControlling
    let interactor: ComposeServiceWebExtensionModuleInteracting
    
    init(
        flowController: ComposeServiceWebExtensionFlowControlling,
        interactor: ComposeServiceWebExtensionModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension ComposeServiceWebExtensionPresenter {
    func viewWillAppear() {
        reload()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        let sections = buildMenu()
        guard let cell = sections[safe: indexPath.section]?.cells[safe: indexPath.row] else { return }
        flowController.toQuestion(with: cell.authRequest)
    }
    
    func handleDeletition(of authRequest: PairedAuthRequest) {
        interactor.removePairing(authRequest)
        guard !interactor.listAll().isEmpty else {
            flowController.toFinish()
            return
        }
        reload()
    }
}

private extension ComposeServiceWebExtensionPresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
