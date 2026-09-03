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

import UIKit
import Common
import Data

protocol LoginModuleInteracting: AnyObject {
    var isLocked: Bool { get }
    var isLoggedOut: Bool { get }
    var lockTime: Int? { get }
    var codeLength: Int { get }
    /// Biometry the user can authenticate with right now; `.none` when it is disabled
    /// in the app or unavailable on the device.
    var availableBiometryType: BiometryType { get }

    func verify(numbers: [Int]) -> Bool
    func verifyUsingBiometry(reason: String, userInitiated: Bool, completion: @escaping (Bool) -> Void)
}

final class LoginModuleInteractor {
    private let loginInteractor: LoginInteracting
    private let appLockStateInteractor: AppLockStateInteracting
    private let appStateInteractor: AppStateInteracting
    private let protectionInteractor: ProtectionInteracting

    init(
        loginInteractor: LoginInteracting,
        appLockStateInteractor: AppLockStateInteracting,
        appStateInteractor: AppStateInteracting,
        protectionInteractor: ProtectionInteracting
    ) {
        self.loginInteractor = loginInteractor
        self.appLockStateInteractor = appLockStateInteractor
        self.appStateInteractor = appStateInteractor
        self.protectionInteractor = protectionInteractor
    }
}

extension LoginModuleInteractor: LoginModuleInteracting {
    var isLocked: Bool {
        loginInteractor.isLocked
    }
    
    var isLoggedOut: Bool {
        loginInteractor.isLoggedOut
    }
    
    var lockTime: Int? {
        appLockStateInteractor.appLockRemainingSeconds
    }
    
    var codeLength: Int {
        loginInteractor.codeLength
    }

    var availableBiometryType: BiometryType {
        // `biometryType` is already `.none` when the device can't evaluate biometrics.
        protectionInteractor.isBiometryEnabled ? protectionInteractor.biometryType : .none
    }

    func verify(numbers: [Int]) -> Bool {
        let code = PIN.create(with: numbers)
        let codeIsCorrect = loginInteractor.verifyPIN(code)
        if codeIsCorrect {
            loginInteractor.authSuccessfully()
            return true
        } else {
            loginInteractor.authFailed()
            return false
        }
    }
    
    func verifyUsingBiometry(reason: String, userInitiated: Bool, completion: @escaping (Bool) -> Void) {
        func checkResult(_ result: Bool) {
            switch result {
            case true:
                loginInteractor.authSuccessfully()
                completion(true)
            case false:
                completion(false)
            }
        }
        
        guard !loginInteractor.isLocked && UIApplication.shared.applicationState != .background else {
            completion(false)
            return
        }
        let authenticate = { [loginInteractor] in
            loginInteractor.authenticateUsingBiometry(
                reason: reason,
                userInitiated: userInitiated,
                completion: checkResult
            )
        }
        if appStateInteractor.willURLBeHandled {
            appStateInteractor.clearURLWillBeHandled()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: authenticate)
        } else {
            authenticate()
        }
    }
}
