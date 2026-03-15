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

final class BackupManageEncryptionPresenter: ObservableObject {
    weak var view: BackupManageEncryptionViewControlling?
    
    private let flowController: BackupManageEncryptionFlowControlling
    let interactor: BackupManageEncryptionModuleInteracting
    
    var isSyncing: Bool {
        interactor.isSyncing
    }
    
    init(flowController: BackupManageEncryptionFlowControlling, interactor: BackupManageEncryptionModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        interactor.reload = { [weak self] in
            self?.reload()
        }
    }
}

extension BackupManageEncryptionPresenter {
    func viewWillAppear() {
        reload()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        let menu = buildMenu()
        guard let section = menu[safe: indexPath.section],
              let cell = section.cells[safe: indexPath.row]
        else {
            reload()
            return
        }
        
        switch cell.action {
        case .encrypt: flowController.toSetPassword()
        case .decrypt: flowController.toRemovePassword()
        case .recrypt: flowController.toChangePassword()
        case .clear: flowController.toDeleteBackup()
        }
    }
}

private extension BackupManageEncryptionPresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
