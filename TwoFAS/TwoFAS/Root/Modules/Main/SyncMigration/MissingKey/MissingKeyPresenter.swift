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
    /// The step where the backup password is entered
    @Published var isEnteringPassword = false
    @Published var password = "" {
        didSet {
            if password != oldValue { isPasswordWrong = false }
        }
    }
    @Published private(set) var isVerifyingPassword = false
    @Published private(set) var isPasswordWrong = false

    var canCheckPassword: Bool { !password.isEmpty && !isVerifyingPassword }

    private let flowController: MissingKeyFlowControlling
    private let interactor: MissingKeyModuleInteracting
    private let encryptionError: CloudState.NotAvailableReason.EncryptionError

    var title: String {
        switch encryptionError {
        case .missingSystemKey: T.Backup.missingKeyTitleSystem
        case .missingUserKey: T.Backup.missingKeyTitleUser
        case .missingAllKeys: T.Backup.missingKeyTitleAll
        case .cantCreateEncryptionElements: T.Backup.errorCantCreateKeys
        }
    }

    var canEnterPassword: Bool {
        switch encryptionError {
        case .missingUserKey, .missingAllKeys: true
        case .missingSystemKey, .cantCreateEncryptionElements: false
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

    func onEnterPassword() {
        password = ""
        isPasswordWrong = false
        isEnteringPassword = true
    }

    func onCheckPassword() {
        guard canCheckPassword else { return }
        isVerifyingPassword = true
        // The key is derived off the main thread – the progress stays live
        interactor.recoverWithPassword(password) { [weak self] recovered in
            guard let self else { return }
            isVerifyingPassword = false
            if recovered {
                password = ""
                flowController.resolve()
            } else {
                isPasswordWrong = true
            }
        }
    }

    func onClearBackup() {
        flowController.toClearBackupConfirmation { [weak self] in
            self?.confirmClearBackup()
        }
    }

    func close() {
        // Not in the middle of erasing the backup or checking the password – the result has to be shown
        guard !isWorking, !isVerifyingPassword else { return }
        flowController.close()
    }
}

private extension MissingKeyPresenter {
    func confirmClearBackup() {
        isWorking = true
        interactor.eraseBackupAndCreateNewKeys { [weak self] erased in
            guard let self else { return }
            isWorking = false
            if erased {
                flowController.resolve()
            } else {
                flowController.toClearBackupFailed()
            }
        }
    }
}
