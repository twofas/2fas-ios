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

import UIKit
import Common
import Data

final class BackupSetPasswordPresenter: ObservableObject {
    @Published var isApplyingChanges = false
    @Published var isDone = false
    @Published var continueButtonEnabled = false
    @Published var migrationError: String?
    @Published var validationError: String?
    
    @Published var isFocused1 = false
    @Published var isFocused2 = false
    
    @Published var password1: String = "" {
        didSet {
            validate()
        }
    }
    @Published var password2: String = "" {
        didSet {
            validate()
        }
    }
    
    lazy var callback: (MigrationResult) -> Void = { [weak self] result in
        switch result {
        case .success: self?.toSuccess()
        case .error(let reason): self?.toFailure(reason)
        }
    }
    private let flowController: BackupSetPasswordFlowControlling
    private let interactor: BackupSetPasswordModalInteracting
    private let flowType: BackupSetPasswordType
    
    var isSettingPassword: Bool {
        switch flowType {
        case .setPassword: true
        case .changePassword: false
        }
    }
    
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
}

extension BackupSetPasswordPresenter {
    func close() {
        flowController.close()
    }
    
    func applyChanges() {
        isApplyingChanges = true
        interactor.setPassword(password1)
    }
}

private extension BackupSetPasswordPresenter {
    func validate() {
        func checkLength(_ string: String) -> Bool {
            string.count >= Config.minSyncPasswordLength &&
            string.count <= Config.maxSyncPasswordLength
        }
        func validCharacters(_ string: String) -> Bool {
            string.rangeOfCharacter(from: Config.PasswordCharacterSet.characterSet.inverted) == nil
        }
        
        validationError = nil
        continueButtonEnabled = false
        
        guard !password1.isEmpty && !password2.isEmpty else {
            return
        }
        
        if !checkLength(password1) || !checkLength(password2) {
            validationError = "Password must be \(Config.minSyncPasswordLength)-\(Config.maxSyncPasswordLength) characters long"
            return
        }
        if !validCharacters(password1) || !validCharacters(password2) {
            validationError = "Password may only contain letters, numbers, space and symbols."
            return
        }
        if password1 != password2 {
            validationError = "Passwords do not match"
            return
        }
        continueButtonEnabled = true
    }
    
    func toSuccess() {
        validationError = nil
        migrationError = nil
        isApplyingChanges = false
        isDone = true
    }
    
    func toFailure(_ reason: CloudState.NotAvailableReason) {
        validationError = nil
        migrationError = nil
        isApplyingChanges = false

        migrationError = reason.description
    }
}
