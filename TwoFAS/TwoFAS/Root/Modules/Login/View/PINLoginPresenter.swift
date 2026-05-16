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
import CommonUI

@Observable
final class PINLoginPresenter {
    private let flowController: LoginFlowControlling
    private let interactor: LoginModuleInteracting
    
    private let reason = T.Security.confirmYouAreDeviceOwner
    
    private let minute = 60
    private let twoMinutes = 120
    private let textChangeTime = 3
        
    private let timer: CancellableTimer
    
    var info: String?
    var shake = false
    var totalDigits: Int = 0
    var enteredDigitCount: Int = 0
    var isBlocked = false
    
    private var pin: [Int] = [] {
        didSet {
            enteredDigitCount = pin.count
        }
    }
        
    init(flowController: LoginFlowControlling, interactor: LoginModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        
        timer = CancellableTimer()
                
        totalDigits = interactor.codeLength
    }
    
    func onAppear() {
        if interactor.isLocked {
            lockedState()
        } 
        biometry()
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
}

private extension PINLoginPresenter {
    func biometry() {
        interactor.verifyUsingBiometry(reason: reason) { [weak self] result in
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
            shake.toggle()
            userFailedToLogin()
        }
    }
    
    func userLoggedIn() {
        clearPIN()
        NotificationCenter.default.post(name: .userLoggedIn, object: nil)
        flowController.toLoggedIn()
    }
    
    func userFailedToLogin() {
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
                self?.timer.cancel()
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
}
