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
import Protection
import Common

extension MainRepositoryImpl {
    var isPINSet: Bool {
        protectionModule.codeStorage.isSet
    }
    
    var currentCodeLength: Int {
        protectionModule.codeStorage.currentType.intValue
    }
    
    func isPINCorrect(_ code: [Int]) -> Bool {
        let PINCode = Protection.PIN.create(with: code)
        return protectionModule.codeStorage.validate(withPIN: PINCode)
    }
    
    var appLockAttempts: AppLockAttempts? {
        userDefaultsRepository.appLockAttempts
    }
    
    func setAppLockAttempts(_ value: AppLockAttempts) {
        userDefaultsRepository.setAppLockAttempts(value)
    }
    
    var biometryType: BiometryType {
        guard protectionModule.biometricAuth.isAvailable else { return .none }
        if protectionModule.biometricAuth.biometryType == .touchID {
            return .touchID
        } else if protectionModule.biometricAuth.biometryType == .faceID {
            return .faceID
        }
        return .none
    }
    
    var isBiometryAvailable: Bool {
        protectionModule.biometricAuth.isAvailable
    }
    
    var isBiometryEnabled: Bool {
        protectionModule.biometricAuth.isEnabled
    }
    
    func enableBiometry() {
        protectionModule.biometricAuth.enable()
    }

    func disableBiometry() {
        protectionModule.biometricAuth.disable()
    }
    
    var appLockBlockTime: AppLockBlockTime? {
        userDefaultsRepository.appLockBlockTime
    }
    
    func setAppLockBlockTime(_ value: AppLockBlockTime) {
        userDefaultsRepository.setAppLockBlockTime(value)
    }
    
    func setPINOff() {
        protectionModule.codeStorage.remove()
        disableBiometry()
    }
    
    var pinType: PINType? {
        protectionModule.codeStorage.currentType.pinType
    }
    
    func validatePIN(_ PIN: String) -> Bool {
        protectionModule.codeStorage.validate(withPIN: PIN)
    }
    
    func savePIN(_ PIN: String, typeOfPIN: PINType) {
        protectionModule.codeStorage.save(PINValue: PIN, codeType: typeOfPIN.codeType)
    }
    
    // MARK: - App Lock
    
    var lockAppUntil: Date? {
        userDefaultsRepository.lockAppUntil
    }
    
    func setLockAppUntil(date: Date) {
        userDefaultsRepository.setLockAppUntil(date: date)
    }
    
    func clearLockAppUntil() {
        userDefaultsRepository.clearLockAppUntil()
    }
    
    // MARK: - App clear
    
    func clearAllUserDefaults() {
        userDefaultsRepository.clearAll()
    }
    
    // MARK: - Other
    func securityApplicationDidBecomeActive() {
        security.applicationDidBecomeActive()
    }
    
    func securityApplicationWillEnterForeground() {
        security.applicationWillEnterForeground()
    }
    
    func securityLockApplication() {
        security.lockApplication()
    }
    
    var securityIsAuthenticationRequired: Bool {
        security.isAuthenticationRequired
    }
}

private extension PINType {
    var codeType: Protection.CodeType {
        switch self {
        case .digits4: return .PIN4
        case .digits6: return .PIN6
        }
    }
}

private extension Protection.CodeType {
    var pinType: PINType {
        switch self {
        case .PIN4: return .digits4
        case .PIN6: return .digits6
        }
    }
}
