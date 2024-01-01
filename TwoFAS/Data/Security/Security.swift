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

public typealias PIN = Protection.PIN

final class Security: SecurityProtocol {
    weak var delegate: SecurityDelegate?

    private let codeStorage: CodeStorage
    private let biometric: BiometricAuth

    private let bioLimit: Int = 3
    
    private var isUserLoggedIn = false
    private var authCount: Int = 0
    private var bioAuthCount: Int = 0
    private var timer: Timer?
    private var appInBackground = false

    private(set) var isAuthenticatingUsingBiometric = false
    
    init(biometric: BiometricAuth, codeStorage: CodeStorage) {
        self.biometric = biometric
        self.codeStorage = codeStorage
                
        biometric.delegate = self
    }
    
    var interactor: AppLockStateInteracting?
    var isAuthenticationRequired: Bool { isPINAuthEnabled && !isUserLoggedIn }
    
    func authSuccessfully() {
        isUserLoggedIn = true
        clearAuth()
        clearBio()
    }
    
    func authFailed() {
        authCount += 1
        if authCount == interactor?.appLockAttempts.value {
            lockBio()
            interactor?.lockApp()
            delegate?.securityLockUI()
        }
    }
    
    var canAuthorize: Bool { interactor?.isAppLocked == false }
    
    var currentCodeType: Protection.CodeType { codeStorage.currentType }
    
    func verifyPIN(_ PIN: Protection.PIN) -> Bool {
        let verify = codeStorage.validate(withPIN: PIN)
        return verify
    }
    
    func savePIN(PINValue: String, codeType: Protection.CodeType) {
        codeStorage.save(PINValue: PINValue, codeType: codeType)
    }
    
    var isPINAuthEnabled: Bool {
        codeStorage.isSet
    }
    
    func disablePINAuth() {
        codeStorage.remove()
    }
    
    func enableBioAuth() {
        assert(biometric.isAvailable)
        biometric.enable()
    }
    func disableBioAuth() {
        biometric.disable()
    }
    
    var isBioAuthAvailable: Bool {
        biometric.isAvailable
    }
    
    var isBioAuthEnabled: Bool {
        biometric.isEnabled
    }
    
    func authenticateUsingBioAuthIfPossible(reason: String) {
        guard
            !appInBackground && isBioAuthEnabled && isBioAuthAvailable && !isAuthenticatingUsingBiometric
        else { return }
        
        bioAuthCount += 1
        if bioAuthCount >= bioLimit {
            return
        }
        isAuthenticatingUsingBiometric = true
        biometric.authenticate(reason: reason)
    }
    
    func applicationWillEnterForeground() {
        appInBackground = false
        
        if interactor?.isAppLocked == true {
            delegate?.securityLockUI()
        } else {
            unlock()
        }
        delegate?.retryBioAuthIfNecessary()
    }
    
    func applicationDidEnterBackground() {
        appInBackground = true
        clearTimer()
    }
    
    func applicationDidBecomeActive() {
        if interactor?.isAppLocked == true {
            startTimer()
        }
    }
    
    //
    func lockApplication() {
        isUserLoggedIn = false
    }
    
    // MARK: - Private
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            
            if self.interactor?.isAppLocked == false {
                timer.invalidate()
                self.timer = nil
                self.unlock()
            }
        })
    }
    
    private func clearTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerFinished() {
        clearTimer()
    }
    
    private func unlock() {
        delegate?.securityUnlockUI()
        clearBio()
        clearAuth()
    }
    
    private func clearBio() {
        bioAuthCount = 0
    }
    
    private func clearAuth() {
        authCount = 0
    }
    
    private func lockBio() {
        bioAuthCount = bioLimit
    }
}

extension Security: BiometricAuthDelegate {
    func bioAuthSuccess() {
        isAuthenticatingUsingBiometric = false
        delegate?.securityBioAuthSuccess()
        clearBio()
        clearAuth()
    }
    
    func bioAuthFailed() {
        isAuthenticatingUsingBiometric = false
        delegate?.securityBioAuthFailure()
    }
    
    func bioAuthUserCancelled() {
        isAuthenticatingUsingBiometric = false
        lockBio()
    }
}
