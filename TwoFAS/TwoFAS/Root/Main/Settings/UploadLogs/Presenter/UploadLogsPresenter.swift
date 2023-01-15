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

final class UploadLogsPresenter {
    weak var view: UploadLogsViewControlling?
    
    private let flowController: UploadLogsFlowControlling
    private let interactor: UploadLogsModuleInteracting
    
    private var initialized = false
    
    init(flowController: UploadLogsFlowControlling, interactor: UploadLogsModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension UploadLogsPresenter {
    func viewWillAppear() {
        guard !initialized else { return }
        initialized = true
        
        if let uuid = interactor.passedUUID {
            view?.setCode(uuid)
        } else {
            view?.setForEdit(clearCode: false)
        }
    }
    
    func handleClose() {
        flowController.toClose()
    }
    
    func handleSend(_ uuid: UUID) {
        view?.disableClose()
        view?.showSpinner()
        interactor.sendLogs(for: uuid) { [weak self] result in
            switch result {
            case .success: self?.flowController.toSuccess()
            case .failure(let failure):
                let canRetry = failure == .server || failure == .noInternet
                || (failure == .notExists && self?.interactor.passedUUID == nil)
                self?.flowController.toFailure(reason: failure, canRetry: canRetry)
            }
            self?.view?.hideSpinner()
            self?.view?.enableClose()
        }
    }
    
    func handleClear(clearCode: Bool) {
        view?.setForEdit(clearCode: clearCode)
    }
}
