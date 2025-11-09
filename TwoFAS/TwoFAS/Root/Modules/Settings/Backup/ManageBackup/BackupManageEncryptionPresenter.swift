//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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

final class BackupManageEncryptionPresenter {
    weak var view: BackupManageEncryptionViewControlling?
    
    private let flowController: BackupManageEncryptionFlowControlling
    let interactor: BackupManageEncryptionModuleInteracting
    
    init(flowController: BackupManageEncryptionFlowControlling, interactor: BackupManageEncryptionModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension BackupManageEncryptionPresenter {
    func viewWillAppear() {
        reload()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        let menu = buildMenu()
        guard let section = menu[safe: indexPath.section],
              let cell = section.cells[safe: indexPath.row],
              let action = cell.action
        else {
            reload()
            return
        }
        
        switch action {
        case .encrypt: print(">>> encrypt")
        case .decrypt: print(">>> decrypt")
        case .recrypt: print(">>> recrypt")
        case .clear: print(">>> clear")
        }
    }
}

private extension BackupManageEncryptionPresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
