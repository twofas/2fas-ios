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

final class BrowserExtensionServicePresenter {
    weak var view: BrowserExtensionServiceViewControlling?
    
    private let flowController: BrowserExtensionServiceFlowControlling
    let name: String
    let date: String
    private let id: String
    
    init(flowController: BrowserExtensionServiceFlowControlling, name: String, date: String, id: String) {
        self.flowController = flowController
        self.name = name
        self.date = date
        self.id = id
    }
}

extension BrowserExtensionServicePresenter {
    func viewWillAppear() {
        reload()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        let menu = buildMenu()
        guard let cell = menu[safe: indexPath.section]?.cells[safe: indexPath.row], cell.kind == .unpair else { return }
        flowController.toUnpairQuestion()
    }
    
    func handleUnpair() {
        flowController.toUnpairingService(with: id)
    }
}

private extension BrowserExtensionServicePresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
