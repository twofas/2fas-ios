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
import Common
import Data

@Observable
final class BackupSetPasswordPresenter {
    var password1: String = ""
    var password2: String = ""
    var password1Error: String?
    var password2Error: String?

    var isApplyingChanges = false
    var isDone = false
    var migrationError: String?

    var isContinueEnabled: Bool {
        !password1.isEmpty
            && !password2.isEmpty
            && password1Error == nil
            && password2Error == nil
            && password1 == password2
    }

    var isSettingPassword: Bool {
        switch flowType {
        case .setPassword: true
        case .changePassword: false
        }
    }

    var title: String {
        isSettingPassword ? T.Backup.setPassword : T.Backup.changePassword
    }

    var applyingChangesText: String {
        isSettingPassword ? T.Backup.settingPassword : T.Backup.changingPassword
    }

    private let flowController: BackupSetPasswordFlowControlling
    private let interactor: BackupSetPasswordModalInteracting
    private let flowType: BackupSetPasswordType

    init(
        flowController: BackupSetPasswordFlowControlling,
        interactor: BackupSetPasswordModalInteracting,
        flowType: BackupSetPasswordType
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.flowType = flowType

        interactor.syncSuccess = { [weak self] in
            self?.toSuccess()
        }
        interactor.syncFailure = { [weak self] reason in
            self?.toFailure(reason)
        }
    }

    func handleClose() {
        flowController.close()
    }

    func handleContinue() {
        if isDone {
            handleClose()
        } else {
            applyChanges()
        }
    }

    func handleFirstChanged(_ newValue: String) {
        password1Error = validate(newValue)
        checkMatch()
    }

    func handleSecondChanged(_ newValue: String) {
        password2Error = validate(newValue)
        checkMatch()
    }
}

private extension BackupSetPasswordPresenter {
    func validate(_ value: String) -> String? {
        guard !value.isEmpty else { return nil }
        if value.count < Config.minSyncPasswordLength || value.count > Config.maxSyncPasswordLength {
            return T.Backup.passwordLengthError(
                Config.minSyncPasswordLength,
                Config.maxSyncPasswordLength
            )
        }
        if value.rangeOfCharacter(from: Config.PasswordCharacterSet.characterSet.inverted) != nil {
            return T.Backup.passwordCharactersError
        }
        return nil
    }

    func checkMatch() {
        guard !password1.isEmpty, !password2.isEmpty,
              validate(password1) == nil, validate(password2) == nil else {
            if password2Error == T.Backup.passwordMatchError {
                password2Error = nil
            }
            return
        }
        if password1 != password2 {
            password2Error = T.Backup.passwordMatchError
        } else if password2Error == T.Backup.passwordMatchError {
            password2Error = nil
        }
    }

    func applyChanges() {
        guard isContinueEnabled else { return }
        isApplyingChanges = true
        interactor.setApplayinChanges()
        interactor.setPassword(password1)
    }

    func toSuccess() {
        password1Error = nil
        password2Error = nil
        migrationError = nil
        isApplyingChanges = false
        isDone = true
    }

    func toFailure(_ reason: CloudState.NotAvailableReason) {
        password1Error = nil
        password2Error = nil
        isApplyingChanges = false
        migrationError = reason.description
    }
}
