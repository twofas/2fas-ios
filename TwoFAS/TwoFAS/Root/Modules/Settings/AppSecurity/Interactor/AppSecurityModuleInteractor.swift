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
import Data
import Common

protocol AppSecurityModuleInteracting: AnyObject {
    var isPINSet: Bool { get }
    var limitOfTrials: AppLockAttempts { get }
    var biometryType: BiometryType { get }
    var isBiometryEnabled: Bool { get }
    var isBiometryAllowed: Bool { get }
    var currentPINType: PINType { get }
    var isPasscodeRequried: Bool { get }
    
    func toggleBiometry()
    
    func setPINOff()
    func savePIN(_ PIN: String, typeOfPIN: PINType)
    
    func saveInitialAuthorization()
    var shouldShowInitialAuthorization: Bool { get }
}

final class AppSecurityModuleInteractor {
    private let protectionInteractor: ProtectionInteracting
    private let appLockStateInteractor: AppLockStateInteracting
    private let mdmInteractor: MDMInteracting
    
    private var isAuthorized = false
    
    init(
        protectionInteractor: ProtectionInteracting,
        appLockStateInteractor: AppLockStateInteracting,
        mdmInteractor: MDMInteracting
    ) {
        self.protectionInteractor = protectionInteractor
        self.appLockStateInteractor = appLockStateInteractor
        self.mdmInteractor = mdmInteractor
    }
}

extension AppSecurityModuleInteractor: AppSecurityModuleInteracting {
    var isPINSet: Bool { protectionInteractor.isPINSet }
    var limitOfTrials: AppLockAttempts { appLockStateInteractor.appLockAttempts }
    var biometryType: BiometryType { protectionInteractor.biometryType }
    var isBiometryEnabled: Bool { protectionInteractor.isBiometryEnabled }
    var isBiometryAllowed: Bool { !mdmInteractor.isBiometryBlocked }
    var currentPINType: PINType { protectionInteractor.pinType ?? .digits4 }
    var isPasscodeRequried: Bool { mdmInteractor.isPasscodeRequried }
    
    func toggleBiometry() {
        guard protectionInteractor.isBiometryAvailable else { return }
        if isBiometryEnabled {
            protectionInteractor.disableBiometry()
        } else {
            protectionInteractor.enableBiometry()
        }
    }
    
    func setPINOff() {
        protectionInteractor.setPINOff()
    }
    
    func savePIN(_ PIN: String, typeOfPIN: PINType) {
        protectionInteractor.savePIN(PIN, typeOfPIN: typeOfPIN)
    }
    
    func saveInitialAuthorization() {
        isAuthorized = true
    }
    
    var shouldShowInitialAuthorization: Bool {
        !isAuthorized && isPINSet
    }
}
