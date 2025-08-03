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

final class ExportTokensPresenter {
    weak var view: ExportTokensViewControlling?
    
    private let flowController: ExportTokensFlowControlling
    private let interactor: ExportTokensModuleInteracting
    
    init(flowController: ExportTokensFlowControlling, interactor: ExportTokensModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
    
    func viewWillAppear() {
        reload()
        if !interactor.hasServices {
            view?.lock()
        }
    }
    
    func handleSelection(at indexPath: IndexPath) {
        guard interactor.hasPIN else {
            flowController.toSetupPIN()
            return
        }
        let menu = buildMenu()
        guard
            let section = menu[safe: indexPath.section],
            let cell = section.cells[safe: indexPath.row]
        else { return }
        
        switch cell.action {
        case .copyToClipboard:
            flowController.toCopyToClipboard()
        case .saveOTPAuthFile:
            flowController.toSaveOTPAuthFile()
        case .exportQRCodes:
            flowController.toExportQRCodes()
        }
    }
    
    func handleBecomeActive() {
        reload()
    }
}

extension ExportTokensPresenter {
    func handleCopyToClipboard() {
        interactor.copyToClipBoardGenertedCodes()
    }
    
    func handleSaveOTPAuthFile() {
        let contents = interactor.generateOTPAuthCodes()
        flowController.toShareOTPAuthFileContents(contents)
    }
    
    func handleExportQRCodes() {
        view?.exporting()
        Task {
            let urls = await interactor.generateQRCodeFiles()
            Task { @MainActor in
                flowController.toShareQRCodes(urls) { [weak self] in
                    self?.interactor.cleanupTemporaryFiles(urls: urls)
                }
                view?.unlock()
            }
        }
    }
}

private extension ExportTokensPresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
