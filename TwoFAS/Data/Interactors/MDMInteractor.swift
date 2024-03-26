//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

public protocol MDMInteracting: AnyObject {
    var isBackupBlocked: Bool { get }
    var isBiometryBlocked: Bool { get }
    var isBrowserExtensionBlocked: Bool { get }
    var isLockoutAttemptsChangeBlocked: Bool { get }
    var isLockoutBlockTimeChangeBlocked: Bool { get }
    var isPasscodeRequried: Bool { get }
    var shouldSetPasscode: Bool { get }
    
    func apply()
}

final class MDMInteractor {
    private let mainRepository: MainRepository
    private let pairingInteractor: PairingWebExtensionInteracting
    private let cloudBackupStateInteractor: CloudBackupStateInteracting
    
    private var syncDetermined = false
    private var syncDisabled = false
    
    init(
        mainRepository: MainRepository,
        pairingInteractor: PairingWebExtensionInteracting,
        cloudBackupStateInteractor: CloudBackupStateInteracting
    ) {
        self.mainRepository = mainRepository
        self.pairingInteractor = pairingInteractor
        self.cloudBackupStateInteractor = cloudBackupStateInteractor
        
        cloudBackupStateInteractor.stateChanged = { [weak self] in self?.syncStateDetermined() }
        cloudBackupStateInteractor.startMonitoring()
        if cloudBackupStateInteractor.isBackupEnabled {
            syncStateDetermined()
        }
    }
}

extension MDMInteractor: MDMInteracting {
    var isBackupBlocked: Bool {
        mainRepository.mdmIsBackupBlocked
    }
    
    var isBiometryBlocked: Bool {
        mainRepository.mdmIsBiometryBlocked
    }
    
    var isBrowserExtensionBlocked: Bool {
        mainRepository.mdmIsBrowserExtensionBlocked
    }
    
    var isLockoutAttemptsChangeBlocked: Bool {
        mainRepository.mdmLockoutAttempts != nil
    }
    
    var isLockoutBlockTimeChangeBlocked: Bool {
        mainRepository.mdmLockoutBlockTime != nil
    }
    
    var isPasscodeRequried: Bool {
        mainRepository.mdmIsPasscodeRequried
    }
    
    var shouldSetPasscode: Bool {
        isPasscodeRequried && !mainRepository.isPINSet
    }
    
    func apply() {
        if syncDetermined {
            disableSyncIfNecessary()
        }
        
        if isBiometryBlocked && mainRepository.isBiometryEnabled {
            Log("MDMInteractor - disabling Biometry", module: .interactor)
            mainRepository.disableBiometry()
        }
        
        if isBrowserExtensionBlocked && pairingInteractor.hasActiveBrowserExtension {
            Log("MDMInteractor - disabling Browser Extension", module: .interactor)
            pairingInteractor.disableExtension(completion: { _ in })
        }
        
        if let lockoutAttempts = mainRepository.mdmLockoutAttempts {
            Log("MDMInteractor - setting Lockout Attemtps", module: .interactor)
            mainRepository.setAppLockAttempts(lockoutAttempts)
        }
        
        if let blockTime = mainRepository.mdmLockoutBlockTime {
            Log("MDMInteractor - setting Lockout Block Time", module: .interactor)
            mainRepository.setAppLockBlockTime(blockTime)
        }
    }
}

private extension MDMInteractor {
    func syncStateDetermined() {
        guard !syncDetermined else { return }
        Log("MDMInteractor - syncStateDetermined", module: .interactor)
        syncDetermined = true
        cloudBackupStateInteractor.stopMonitoring()
        disableSyncIfNecessary()
    }
    
    func disableSyncIfNecessary() {
        Log(
            "MDMInteractor - disableSyncIfNecessary: Backup enabled: \(cloudBackupStateInteractor.isBackupEnabled)",
            module: .interactor
        )
        if isBackupBlocked && cloudBackupStateInteractor.isBackupEnabled && !syncDisabled {
            Log("MDMInteractor - disableSyncIfNecessary - Clearing", module: .interactor)
            syncDisabled = true
            mainRepository.clearBackup()
        }
    }
}
