//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

import SwiftUI
import Common

@Observable
final class LoginPresenter {
    private let flowController: LoginFlowControlling
    private let interactor: LoginModuleInteracting
    private let notificationCenter: NotificationCenter
    let loginType: LoginType
    
    private let reason = T.Security.confirmYouAreDeviceOwner
    
    private let minute = 60
    private let twoMinutes = 120
    private let textChangeTime = 3
        
    private let timer: CancellableTimer
    
    var info: String?
    var shake = false
    var success = false
    var unlock = false
    var totalDigits: Int = 0
    var enteredDigitCount: Int = 0
    var isBlocked = false
    var isResetVisible = false

    private var isAuthenticating = false

    private var pin: [Int] = [] {
        didSet {
            enteredDigitCount = pin.count
        }
    }
        
    init(loginType: LoginType, flowController: LoginFlowControlling, interactor: LoginModuleInteracting) {
        self.loginType = loginType
        self.flowController = flowController
        self.interactor = interactor
        self.notificationCenter = .default
        
        timer = CancellableTimer()

        notificationCenter
            .addObserver(
                self,
                selector: #selector(didBecomeActive),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
        totalDigits = interactor.codeLength
    }

    func onAppear() {
        isVisible()
    }

    func onResetDismiss() {
        isResetVisible = false
        isVisible()
    }
    
    func onKeyPressed(_ digit: TFPinKey) {
        guard !isBlocked else { return }
        if let number = digit.number, pin.count < totalDigits {
            pin.append(number)
            if pin.count >= totalDigits {
                allEntered()
            }
        } else if digit.isDelete {
            _ = pin.popLast()
        }
    }
    
    func onClose() {
        flowController.toClose()
    }
}

private extension LoginPresenter {
    func biometry() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        interactor.verifyUsingBiometry(reason: reason) { [weak self] result in
            self?.isAuthenticating = false
            if result {
                self?.userLoggedIn()
            }
        }
    }
    
    func allEntered() {
        guard pin.count == totalDigits else { return }
        if interactor.verify(numbers: pin) {
            userLoggedIn()
        } else {
            userFailedToLogin()
        }
    }
    
    func userLoggedIn() {
        success.toggle()
        clearPIN()
        NotificationCenter.default.post(name: .userLoggedIn, object: nil)
        flowController.toLoggedIn()
    }
    
    func userFailedToLogin() {
        shake.toggle()
        clearPIN()
        if interactor.isLocked {
            lockedState()
        } else {
            info = T.Security.incorrectPIN
            timer.start(interval: .seconds(textChangeTime)) { [weak self] in
                self?.info = nil
                self?.timer.cancel()
            }
        }
    }
    
    func clearPIN() {
        pin = []
    }
    
    func lockedState() {
        isBlocked = true
        info = lockTimeMessage
        timer.start(interval: .seconds(1)) { [weak self] in
            if self?.interactor.isLocked == false {
                self?.info = nil
                self?.unlock.toggle()
                self?.timer.cancel()
                self?.isBlocked = false
            } else {
                self?.info = self?.lockTimeMessage ?? ""
            }
        }
    }
    
    var lockTimeMessage: String {
        if let lockTime = interactor.lockTime {
            if lockTime < twoMinutes {
                return T.Security.tooManyAttemptsError2
            }
            return T.Security.tooManyAttemptsTryAgainAfter("\(lockTime / minute)")
        }
        return T.Security.tooManyAttemptsError
    }
    
    @objc
    func didBecomeActive() {
        isVisible()
    }
    func isVisible() {
        guard !isResetVisible else { return }
        if interactor.isLocked {
            lockedState()
        } else {
            if interactor.isLoggedOut {
                biometry()
            }
        }
    }
}
