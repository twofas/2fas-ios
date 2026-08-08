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

@Observable
final class BackupMenuPresenter {
    var sections: [BackupMenuSection] = []

    private let flowController: BackupMenuFlowControlling
    let interactor: BackupMenuModuleInteracting

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    init(flowController: BackupMenuFlowControlling, interactor: BackupMenuModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        interactor.reload = { [weak self] in self?.reload() }

        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(handleAppBecomeActive),
            name: .refreshTabContent,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(handleSyncDate),
            name: .syncCompletedSuccessfuly,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func viewWillAppear() {
        interactor.startMonitoring()
        reload()
    }

    func viewWillDisappear() {
        interactor.stopMonitoring()
    }

    func handleSelection(_ action: BackupNavigationAction) {
        switch action {
        case .importFile:
            flowController.toFileImport()
        case .exportFile:
            guard interactor.exportEnabled else { return }
            flowController.toFileExport()
        case .manageAppleWatch:
            flowController.toManageAppleWatch()
        case .manageBackup:
            guard interactor.isCloudBackupSynced else { return }
            flowController.toManageBackup()
        case .advanced:
            flowController.toAdvanced()
        case .reloadKeys:
            interactor.reloadKeys()
        }
    }

    func handleToggle(_ toggle: BackupNavigationToggle) {
        switch toggle {
        case .backup:
            interactor.toggleBackup()
        }
    }

    func handleBack() {
        flowController.close()
    }
}

private extension BackupMenuPresenter {
    func reload() {
        sections = buildMenu()
    }

    @objc func handleAppBecomeActive() {
        reload()
    }

    @objc func handleSyncDate() {
        reload()
    }
}
