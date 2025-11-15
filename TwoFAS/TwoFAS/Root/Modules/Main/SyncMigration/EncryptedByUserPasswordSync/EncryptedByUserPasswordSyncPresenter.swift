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

final class EncryptedByUserPasswordSyncPresenter: ObservableObject {
    @Published var isWorking = false
    @Published var wrongPassword = false
    @Published var isDone = false
    @Published var migrationFailureReason: CloudState.NotAvailableReason? = .cloudEncryptedSystem
    @Published var password: String = "" {
        didSet {
            checkPasswordEnabled = password.count >= Config.minSyncPasswordLength &&
            password.count <= Config.maxSyncPasswordLength
        }
    }
    @Published var checkPasswordEnabled = false
    
    lazy var callback: (MigrationResult) -> Void = { [weak self] result in
        switch result {
        case .success: self?.toSuccess()
        case .error(let reason): self?.toFailure(reason)
        }
    }
    private let flowController: EncryptedByUserPasswordSyncFlowControlling
    private let interactor: EncryptedByUserPasswordSyncModuleInteracting
    private let flowType: EncryptedByUserPasswordSyncType
    
    var isVerifyingPassword: Bool {
        switch flowType {
        case .enterPassword: false
        case .verifyPassword: true
        }
    }
    
    var isRemovingPassword: Bool {
        switch flowType {
        case .enterPassword: false
        case .verifyPassword(let reason):
            switch reason {
            case .changePassword: false
            case .removePassword: true
            }
        }
    }
    
    init(
        flowController: EncryptedByUserPasswordSyncFlowControlling,
        interactor: EncryptedByUserPasswordSyncModuleInteracting,
        flowType: EncryptedByUserPasswordSyncType
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.flowType = flowType
        
        interactor.syncSuccess = { [weak self] in self?.toSuccess() }
        interactor.syncFailure = { [weak self] in self?.toFailure($0) }
    }
}

extension EncryptedByUserPasswordSyncPresenter {
    func close() {
        flowController.close()
    }
    
    func onCheckPassword() {
        if isVerifyingPassword {
            if interactor.verifyPassword(password) {
                switch flowType {
                case .enterPassword: break
                case .verifyPassword(let next):
                    switch next {
                    case .changePassword:
                        flowController.toChangePassword()
                    case .removePassword:
                        isWorking = true
                        interactor.removePassword()
                    }
                }
            }
        } else {
            isWorking = true
            interactor.setPassword(password)
        }
    }
}

private extension EncryptedByUserPasswordSyncPresenter {
    func toSuccess() {
        migrationFailureReason = nil
        wrongPassword = false
        isWorking = false
        isDone = true
    }
    
    func toFailure(_ reason: CloudState.NotAvailableReason) {
        if reason == .cloudEncryptedUser {
            migrationFailureReason = nil
            wrongPassword = true
            isWorking = false
            return
        }
        
        migrationFailureReason = reason
        wrongPassword = false
        
        isWorking = false
    }
}
