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

final class BackupChangeEncryptionPresenter: ObservableObject {
    @Published var selectedEncryption: CloudEncryptionType = .system {
        didSet {
            updateApplyState()
        }
    }
    
    @Published var changingPassword = false
    @Published var isChangingEncryption = false
    @Published var migrationFailureReason: CloudState.NotAvailableReason?
    @Published var password: String = "" {
        didSet {
            updateApplyState()
        }
    }
    @Published var changePasswordEnabled = false
    
    private let flowController: BackupChangeEncryptionFlowControlling
    private let interactor: BackupChangeEncryptionModuleInteracting
    
    init(
        flowController: BackupChangeEncryptionFlowControlling,
        interactor: BackupChangeEncryptionModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
        
        interactor.syncSuccess = { [weak self] in self?.toSuccess() }
        interactor.syncFailure = { [weak self] in self?.toFailure($0) }
    }
}

extension BackupChangeEncryptionPresenter {
    func onAppear() {
        selectedEncryption = interactor.currentEncryption
        updateApplyState()
    }
    
    func close() {
        flowController.close()
    }
    
    func applyChange() {
        isChangingEncryption = true
        if selectedEncryption == .system {
            interactor.setSystemEncryption()
        } else {
            interactor.setCustomPassword(password)
        }
    }
}

private extension BackupChangeEncryptionPresenter {
    func toSuccess() {
        close()
    }
    
    func toFailure(_ reason: CloudState.NotAvailableReason) {
        migrationFailureReason = reason
        
        isChangingEncryption = false
    }
    
    func updateApplyState() {
        guard !isChangingEncryption else { return }
        func checkPassword() -> Bool {
            password.count > Config.minSyncPasswordLength &&
            password.count <= Config.maxSyncPasswordLength
        }
        changingPassword = {
            switch interactor.currentEncryption {
            case .system: false
            case .user: true
            }
        }()
        changePasswordEnabled = {
            switch interactor.currentEncryption {
            case .system:
                if selectedEncryption == .system {
                    return false
                }
                return checkPassword()
            case .user:
                if selectedEncryption == .user {
                    return checkPassword()
                }
                return true
            }
        }()
    }
}

extension CloudEncryptionType {
    var localized: String {
        switch self {
        case .system: T.Backup.systemKey
        case .user: T.Backup.customPassword
        }
    }
}
