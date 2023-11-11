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

protocol LoginCoordinatorDelegate: AnyObject {
    func authorized()
    func cancelled()
}

protocol LoginModuleInteracting: AnyObject {
    var isLocked: Bool { get }
    var isAfterWrongPIN: Bool { get }
    var lockTime: Int? { get }
    
    func checkState()
    func checkBio()
    
    var updateState: Callback? { get set }
    var correctPIN: Callback? { get set }
    
    var codeLength: Int { get }
    var hasInput: Bool { get }
    var inputCount: Int { get }
    
    func reset()
    func addNumber(_ number: Int)
    func deleteNumber()
}

final class LoginModuleInteractor {
    var updateState: Callback?
    var correctPIN: Callback?
    
    private var numbers: [Int] = []
    private(set) var isLocked = false
    private(set) var isAfterWrongPIN = false

    private let textChangeTime: Int = 3
    
    private let timer = CountdownTimer()
    //    private let appLockStateInteractor: AppLockStateInteracting

    fileprivate let security: SecurityProtocol

    init(
        security: SecurityProtocol,
        resetApp: Callback? = nil,
        leftButtonDescription: String? = nil,
        appLockStateInteractor: AppLockStateInteracting
    ) {
        self.security = security
        //        self.appLockStateInteractor = appLockStateInteractor
                
        timer.timerFinished = { [weak self] in
            DispatchQueue.main.async {
                self?.timerFinished()
            }
        }
    }
    
    func checkState() {
        isLocked = !security.canAuthorize
    }
    
    func checkBio() {
        guard security.canAuthorize && UIApplication.shared.applicationState != .background else { return }
        security.authenticateUsingBioAuthIfPossible(reason: T.Security.confirmYouAreDeviceOwner)
    }
}

extension LoginModuleInteractor: LoginModuleInteracting {
    var lockTime: Int? {
        nil //appLockStateInteractor.appLockRemainingSeconds
    }
    
    var codeLength: Int {
        0 // interactor -> security.currentCodeType.intValue
    }
    
    var hasInput: Bool {
        !numbers.isEmpty
    }
    
    var inputCount: Int {
        numbers.count
    }
    
    func reset() {
        clear()
    }
    
    func addNumber(_ number: Int) {
        numbers.append(number)
        if numbers.count == codeLength {
            verify()
        }
    }
    
    func deleteNumber() {
        _ = numbers.popLast()
    }
}

private extension LoginModuleInteractor {
    func clear() {
        numbers = []
    }
    
    func verify() {
        let code = PIN.create(with: numbers)
        let codeIsCorrect = security.verifyPIN(code)
        if codeIsCorrect {
            security.authSuccessfully()
            correctPIN?()
        } else {
            clear()
            isAfterWrongPIN = true
            timer.start(with: textChangeTime)
            updateState?()
            security.authFailed()
        }
    }
    
    func lock() {
        clear()
        isAfterWrongPIN = false
        isLocked = true
        updateState?()
    }
    
    func unlock() {
        clear()
        isAfterWrongPIN = false
        isLocked = false
        updateState?()
    }
    
    func timerFinished() {
        isAfterWrongPIN = false
        guard !isLocked else { return }
        updateState?()
    }
}

//extension LoginViewModel: SecurityDelegate {
//    func securityBioAuthSuccess() {
//        security.authSuccessfully()
//        delegate?.userWasAuthenticated()
//    }
//    
//    func securityBioAuthFailure() {
//        // use code instead. Do nothing
//    }
//    
//    func securityLockUI() {
//        delegate?.lockUI()
//    }
//    
//    func securityUnlockUI() {
//        delegate?.unlockUI()
//    }
//    
//    func retryBioAuthIfNecessary() {
//        guard security.canAuthorize else { return }
//        bioAuth()
//    }
//}
