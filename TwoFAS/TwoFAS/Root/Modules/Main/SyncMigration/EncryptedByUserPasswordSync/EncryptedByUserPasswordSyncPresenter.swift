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
    @Published var isCheckingPassword = false
    @Published var wrongPassword = false
    @Published var isDone = false
    @Published var migrationFailureReason: CloudState.NotAvailableReason?
    @Published var password: String = "" {
        didSet {
            checkPasswordEnabled = password.count > Config.minSyncPasswordLength &&
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
    
    init(
        flowController: EncryptedByUserPasswordSyncFlowControlling,
        interactor: EncryptedByUserPasswordSyncModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension EncryptedByUserPasswordSyncPresenter {
    func close() {
        flowController.close()
    }
    
    func onCheckPassword() {
        isCheckingPassword = true
        interactor.setPassword(password)
    }
}

private extension EncryptedByUserPasswordSyncPresenter {
    func toSuccess() {
        migrationFailureReason = nil
        wrongPassword = false
        isCheckingPassword = false
        isDone = true
    }
    
    func toFailure(_ reason: CloudState.NotAvailableReason) {
        if reason == .cloudEncryptedUser {
            migrationFailureReason = nil
            wrongPassword = true
            
            return
        }
        
        migrationFailureReason = reason
        wrongPassword = false
        
        isCheckingPassword = false
    }
}
