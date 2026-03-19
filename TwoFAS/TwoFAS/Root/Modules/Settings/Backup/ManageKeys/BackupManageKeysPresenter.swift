//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//

import Foundation

final class BackupManageKeysPresenter: ObservableObject {
    weak var view: BackupManageKeysViewControlling?
    
    private let flowController: BackupManageKeysFlowControlling
    let interactor: BackupManageKeysModuleInteracting
    
    init(flowController: BackupManageKeysFlowControlling, interactor: BackupManageKeysModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension BackupManageKeysPresenter {
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
        case .exportKeys:
            interactor.exportKeys { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let url):
                    self.flowController.toExportKeys(url: url)
                case .failure(let error):
                    self.flowController.toKeysError(error.localizedDescription)
                }
            }
        case .importKeys:
            flowController.toImportKeysWarning { [weak self] in
                guard let self else { return }
                self.flowController.toAskEncryptionTypeForImport { [weak self] choice in
                    guard let self else { return }
                    switch choice {
                    case .systemKey:
                        self.flowController.toImportKeys { [weak self] url in
                            guard let self else { return }
                            self.runImportKeys(url: url, password: nil)
                        }
                    case .customPassword:
                        self.flowController.toCollectPasswordForImport { [weak self] password in
                            guard let self else { return }
                            self.flowController.toImportKeys { [weak self] url in
                                guard let self else { return }
                                self.runImportKeys(url: url, password: password)
                            }
                        }
                    }
                }
            }
        }
    }
}

private extension BackupManageKeysPresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
    
    func runImportKeys(url: URL, password: String?) {
        interactor.importKeys(url: url, password: password) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.flowController.importKeysSuccess()
            case .failure:
                self.flowController.toKeysImportError()
            }
        }
    }
}
