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
import LocalAuthentication
import Data
import Common

public protocol AppSecurityModuleInteracting: AnyObject {
    var isPINSet: Bool { get }
    var biometryType: BiometryType { get }
    var isBiometryEnabled: Bool { get }
    var isBiometryAllowed: Bool { get }
    var currentPINType: PINType { get }
    var isPasscodeRequried: Bool { get }

    var selectedAttempts: AppLockAttempts { get }
    var selectedBlockTime: AppLockBlockTime { get }
    var isLockoutAttemptsChangeBlocked: Bool { get }
    var isLockoutBlockTimeChangeBlocked: Bool { get }

    func setAttempts(_ value: AppLockAttempts)
    func setBlockTime(_ value: AppLockBlockTime)

    func disableBiometry()
    func requestBiometryEnable(reason: String) async -> Bool

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
    var biometryType: BiometryType { protectionInteractor.biometryType }
    var isBiometryEnabled: Bool { protectionInteractor.isBiometryEnabled }
    var isBiometryAllowed: Bool { !mdmInteractor.isBiometryBlocked }
    var currentPINType: PINType { protectionInteractor.pinType ?? .digits4 }
    var isPasscodeRequried: Bool { mdmInteractor.isPasscodeRequried }

    var selectedAttempts: AppLockAttempts { appLockStateInteractor.appLockAttempts }
    var selectedBlockTime: AppLockBlockTime { appLockStateInteractor.appLockBlockTime }
    var isLockoutAttemptsChangeBlocked: Bool { mdmInteractor.isLockoutAttemptsChangeBlocked }
    var isLockoutBlockTimeChangeBlocked: Bool { mdmInteractor.isLockoutBlockTimeChangeBlocked }

    func setAttempts(_ value: AppLockAttempts) {
        guard !isLockoutAttemptsChangeBlocked else { return }
        appLockStateInteractor.setAppLockAttempts(value)
    }

    func setBlockTime(_ value: AppLockBlockTime) {
        guard !isLockoutBlockTimeChangeBlocked else { return }
        appLockStateInteractor.setAppLockBlockTime(value)
    }

    func disableBiometry() {
        guard protectionInteractor.isBiometryAvailable else { return }
        protectionInteractor.disableBiometry()
    }

    func requestBiometryEnable(reason: String) async -> Bool {
        guard protectionInteractor.isBiometryAvailable else { return false }
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        appLockStateInteractor.biometryAuthenticationStarted()
        let success: Bool = await withCheckedContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, _ in
                continuation.resume(returning: success)
            }
        }
        appLockStateInteractor.biometryAuthenticationEnded()
        if success {
            protectionInteractor.enableBiometry()
        }
        return success
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
