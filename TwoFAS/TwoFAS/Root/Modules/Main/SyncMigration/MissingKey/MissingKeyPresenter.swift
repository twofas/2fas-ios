//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

final class MissingKeyPresenter: ObservableObject {
    @Published var isWorking = false

    private let flowController: MissingKeyFlowControlling
    private let interactor: MissingKeyModuleInteracting
    private let encryptionError: CloudState.NotAvailableReason.EncryptionError

    var title: String {
        switch encryptionError {
        case .missingSystemKey:
            "The system encryption key is missing"
        case .missingUserKey:
            "Your encryption password key is missing"
        case .missingAllKeys:
            "All encryption keys are missing"
        case .cantCreateEncryptionElements:
            "Can't create the encryption keys"
        }
    }

    init(
        flowController: MissingKeyFlowControlling,
        interactor: MissingKeyModuleInteracting,
        encryptionError: CloudState.NotAvailableReason.EncryptionError
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.encryptionError = encryptionError
    }
}

extension MissingKeyPresenter {
    func onImport() {
        flowController.toImportKeys()
    }

    func onClearBackup() {
        flowController.toClearBackupConfirmation { [weak self] in
            self?.confirmClearBackup()
        }
    }

    func close() {
        flowController.close()
    }
}

private extension MissingKeyPresenter {
    func confirmClearBackup() {
        isWorking = true
        interactor.eraseBackupAndCreateNewKeys { [weak self] in
            self?.flowController.resolve()
        }
    }
}
