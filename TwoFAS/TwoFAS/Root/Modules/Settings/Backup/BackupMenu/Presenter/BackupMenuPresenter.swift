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

final class BackupMenuPresenter {
    weak var view: BackupMenuViewControlling?
    
    private let flowController: BackupMenuFlowControlling
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    let interactor: BackupMenuModuleInteracting
    
    init(flowController: BackupMenuFlowControlling, interactor: BackupMenuModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        interactor.reload = { [weak self] in self?.reload() }
    }
    
    func viewWillAppear() {
        interactor.startMonitoring()
        reload()
    }
    
    func viewWillDisappear() {
        interactor.stopMonitoring()
    }
    
    func handleNavigateToFAQ() {
        flowController.toFAQ()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        let menu = buildMenu()
        guard let section = menu[safe: indexPath.section],
              let cell = section.cells[safe: indexPath.row],
              let action = cell.action else { return }
        switch action {
        case .importFile:
            flowController.toFileImport()
        case .exportFile:
            guard interactor.exportEnabled else { return }
            flowController.toFileExport()
        case .deleteCloudBackup:
            flowController.toDeleteCloudBackup()
        }
    }
    
    func handleToggle(for indexPath: IndexPath) {
        let menu = buildMenu()
        guard let section = menu[safe: indexPath.section],
              let cell = section.cells[safe: indexPath.row],
              let accessory = cell.accessory?.kind else { return }
        switch accessory {
        case .backup:
            interactor.toggleBackup()
        }
    }
    
    func handleBecomeActive() {
        reload()
    }
    
    func handleSyncSuccessDateUpdate() {
        reload()
    }
}

private extension BackupMenuPresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
        if let error = interactor.error?.errorText {
            view?.showError(error)
        } else {
            view?.clearError()
        }
    }
}
