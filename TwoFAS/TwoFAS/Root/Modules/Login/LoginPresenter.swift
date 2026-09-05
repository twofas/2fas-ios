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
    /// Key shown left of "0" on the keypad; `nil` hides the slot when biometry can't be used.
    var biometryKey: TFPinKey?
    /// `true` from the moment biometry is requested until its result arrives.
    private(set) var isAuthenticating = false
    /// `true` while the next time the screen is seen is going to prompt for biometry on its
    /// own, so the keypad is absent from that first frame instead of showing up and hiding a
    /// moment later. Set on creation and again whenever the app goes to the background;
    /// spent the first time the screen is worked with in the foreground.
    private(set) var expectsAutomaticBiometry: Bool
    /// The keypad is out while a biometry prompt is up or about to come up; it comes back only
    /// when the attempt fails or is cancelled.
    var isKeyboardHidden: Bool {
        isAuthenticating || expectsAutomaticBiometry
    }
    /// `false` while a prompt the app started on its own (on appearing or on becoming active)
    /// is up: the keypad then vanishes in the same frame, with no fade, because nothing the
    /// user did caused it. A prompt started from the biometry key hides the keypad animated.
    private(set) var animatesKeyboardHiding = true

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
        expectsAutomaticBiometry = interactor.willPromptBiometryOnAppear
        
        timer = CancellableTimer()

        notificationCenter
            .addObserver(
                self,
                selector: #selector(didBecomeActive),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
        notificationCenter
            .addObserver(
                self,
                selector: #selector(didEnterBackground),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )
        totalDigits = interactor.codeLength
        refreshBiometryKey()
    }

    func onAppear() {
        isVisible()
    }

    func onResetDismiss() {
        isResetVisible = false
        isVisible()
    }
    
    func onKeyPressed(_ key: TFPinKey) {
        // Hardware keys must not fill the dots while the keypad is hidden behind biometry.
        guard !isBlocked, !isAuthenticating else { return }
        switch key {
        case .digit(let number):
            guard pin.count < totalDigits else { return }
            pin.append(number)
            if pin.count >= totalDigits {
                DispatchQueue.main.asyncAfter(deadline: .now() + PINDotsAnimation.fillDuration) { [weak self] in
                    self?.allEntered()
                }
            }
        case .delete:
            _ = pin.popLast()
        case .biometry:
            biometry(userInitiated: true)
        }
    }
    
    func onClose() {
        flowController.toClose()
    }
}

private extension LoginPresenter {
    func biometry(userInitiated: Bool = false) {
        guard !isAuthenticating else { return }
        animatesKeyboardHiding = userInitiated
        isAuthenticating = true
        interactor.verifyUsingBiometry(reason: reason, userInitiated: userInitiated) { [weak self] result in
            guard let self else { return }
            isAuthenticating = false
            animatesKeyboardHiding = true
            if result {
                // Same feedback as a typed PIN: every dot fills, and the screen goes once the
                // fill has been seen.
                enteredDigitCount = totalDigits
                DispatchQueue.main.asyncAfter(deadline: .now() + PINDotsAnimation.fillDuration) { [weak self] in
                    self?.userLoggedIn()
                }
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

    /// The screen usually stays alive across a trip to the background and is the first thing
    /// seen on return, right before `didBecomeActive` prompts for biometry. Taking the keypad
    /// down now, while nothing is on screen, means the return shows no keypad at all.
    @objc
    func didEnterBackground() {
        guard interactor.willPromptBiometryOnAppear else { return }
        animatesKeyboardHiding = false
        expectsAutomaticBiometry = true
    }

    func isVisible() {
        refreshBiometryKey()
        // `onAppear` also fires while the screen is being prepared in the background, where a
        // prompt is impossible; leave the prediction alone and wait for `didBecomeActive`.
        guard !interactor.isAppInBackground else { return }
        // Whatever happens next is decided in this same pass, so the prediction is spent:
        // either `biometry()` flips `isAuthenticating` before the next frame, or the keypad
        // comes in.
        expectsAutomaticBiometry = false
        defer {
            // If the keypad stays or comes in after all, the next hide is a user's doing again.
            if !isKeyboardHidden { animatesKeyboardHiding = true }
        }
        guard !isResetVisible else { return }
        if interactor.isLocked {
            lockedState()
        } else {
            if interactor.isLoggedOut {
                biometry()
            }
        }
    }

    func refreshBiometryKey() {
        // Biometry unlocks the app only; the `.verify` flow stays PIN-only, as it always was.
        let key: TFPinKey? = if loginType == .login {
            switch interactor.availableBiometryType {
            case .faceID: .biometry(.faceID)
            case .touchID: .biometry(.touchID)
            case .none: nil
            }
        } else {
            nil
        }
        // Assign only on change: every mutation re-evaluates the whole keypad.
        if key != biometryKey {
            biometryKey = key
        }
    }
}
