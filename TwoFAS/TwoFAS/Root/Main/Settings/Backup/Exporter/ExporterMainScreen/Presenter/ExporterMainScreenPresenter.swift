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

final class ExporterMainScreenPresenter {
    let shouldSetPasswordDefaultValue = true
    
    private var setPassword = true
    
    private let flowController: ExporterMainScreenFlowControlling
    private let interactor: ExporterMainScreenModuleInteracting
    
    init(flowController: ExporterMainScreenFlowControlling, interactor: ExporterMainScreenModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension ExporterMainScreenPresenter {
    func handleExport() {
        if setPassword {
            flowController.toPasswordProtection()
        } else {
            if interactor.isPINSet {
                flowController.toPINKeyboard()
            } else {
                interactor.export(with: nil) { [weak self] url in
                    if let url {
                        self?.flowController.toExport(with: url)
                    } else {
                        self?.flowController.toExportError()
                    }
                }
            }
        }
    }
    
    func handleClose() {
        flowController.toClose()
    }
    
    func handleSetPassword(_ setPassword: Bool) {
        self.setPassword = setPassword
    }
}
