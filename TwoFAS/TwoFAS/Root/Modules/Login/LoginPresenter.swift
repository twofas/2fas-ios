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
    
    /// A wrong PIN's message, shown for a moment under the prompt.
    var info: String?
    /// The lock-out message, shown in the keypad's place for as long as the lock lasts.
    var lockMessage: String?
    var shake = false
    var success = false
    var unlock = false
    var totalDigits: Int = 0
    var enteredDigitCount: Int = 0
    var isBlocked = false
    var isResetVisible = false
    /// Key shown left of "0" on the keypad; `nil` hides the slot when biometry can't be used.
    var biometryKey: TFPinKey?
    /// `true` from the moment biometry is requested until it fails or is cancelled. After a
    /// success it stays `true`: the screen is on its way out and neither the keypad nor the
    /// splash must change under it.
    private(set) var isAuthenticating = false
    /// `true` while the screen looks like the launch screen: only the logo, centred, nothing
    /// else. The lock screen starts like this when it takes over from the system launch
    /// screen, or when an automatic biometry prompt is coming: the prompt runs over the
    /// splash and the splash goes only when the prompt fails. Otherwise it leaves the splash
    /// the first time it is worked with in the foreground. A lock screen prepared while the
    /// app is already running, with no prompt to come, skips the splash and starts complete.
    /// Re-entered, without animation, on a trip to the background that is going to be
    /// followed by an automatic prompt, so the return shows the splash again. Never `true`
    /// for `.verify`.
    private(set) var showsSplash: Bool
    /// `true` while the splash is going to be held by an automatic biometry prompt, so it is
    /// worth greeting on it; a splash that is left right away shows the logo alone and the
    /// greeting comes in with the rest of the header.
    private(set) var promptsOnSplash: Bool
    /// `true` while the splash is the continuation of the system launch screen, which is the
    /// only time its logo has to sit at the screen centre. A splash re-entered on the way to
    /// the background is free to start in whatever shape suits the next prompt.
    private(set) var splashFollowsLaunchScreen: Bool
    /// `true` from a trip to the background that put the screen back on the splash until it
    /// is next seen in the foreground: the greeting is out meanwhile, so the app switcher
    /// shows the launch screen's look, and comes back in the way it does on a cold start.
    /// Set in the same pass as `showsSplash`, so the snapshot cannot catch the greeting.
    private(set) var greetingIsAway = false
    /// The keypad is out on the splash and while a biometry prompt is up; it comes back only
    /// when the attempt fails or is cancelled.
    var isKeyboardHidden: Bool {
        isAuthenticating || showsSplash || isBlocked
    }
    /// `false` while a prompt the app started on its own (on appearing or on becoming active)
    /// is up, or while the screen is back on the splash for one: the keypad then vanishes in
    /// the same frame, with no fade, because nothing the user did caused it. A prompt started
    /// from the biometry key hides the keypad animated.
    private(set) var animatesKeyboardHiding = true
    /// Pause before the keypad's next entrance: the keypad's own after a biometry prompt,
    /// the splash exit's beat when the keypad comes in with the rest of the screen.
    private(set) var keypadEntranceDelay: TimeInterval = PINKeyboard.entranceDelay
    /// `true` once the user is in and the lock screen is on its way out over the app, see
    /// `UnlockTransition`; the view grows, blurs and fades while this is set.
    private(set) var isLeaving = false

    private var pin: [Int] = [] {
        didSet {
            enteredDigitCount = pin.count
        }
    }
        
    /// `followsLaunchScreen`: the screen is the first thing after the system launch screen.
    init(
        loginType: LoginType,
        flowController: LoginFlowControlling,
        interactor: LoginModuleInteracting,
        followsLaunchScreen: Bool = false
    ) {
        self.loginType = loginType
        self.flowController = flowController
        self.interactor = interactor
        self.notificationCenter = .default
        let willPrompt = interactor.willPromptBiometryOnAppear
        showsSplash = loginType == .login && (followsLaunchScreen || willPrompt)
        promptsOnSplash = loginType == .login && willPrompt
        splashFollowsLaunchScreen = followsLaunchScreen
        
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
        // Hardware keys must not fill the dots while the keypad is out: on the splash or
        // behind biometry.
        guard !isBlocked, !isKeyboardHidden else { return }
        // Any key means the wrong-PIN note has been seen; it need not wait out its time.
        dismissInfo()
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
    
    /// Takes the wrong-PIN note down, and the timer that would have.
    private func dismissInfo() {
        guard info != nil else { return }
        info = nil
        timer.cancel()
    }

    func onClose() {
        flowController.toClose()
    }
}

private extension LoginPresenter {
    func biometry(userInitiated: Bool = false) {
        guard !isAuthenticating else { return }
        animatesKeyboardHiding = userInitiated
        keypadEntranceDelay = PINKeyboard.entranceDelay
        isAuthenticating = true
        interactor.verifyUsingBiometry(reason: reason, userInitiated: userInitiated) { [weak self] result in
            guard let self else { return }
            guard result else {
                isAuthenticating = false
                animatesKeyboardHiding = true
                // An automatic prompt over the splash has failed: time for the keypad. In the
                // background nothing is seen; `isVisible()` decides again on return.
                if !interactor.isAppInBackground {
                    leaveSplash()
                }
                return
            }
            // `isAuthenticating` stays set so nothing starts coming back under the exit.
            if showsSplash {
                // Straight out of the splash: the logo stays centred, there are no dots to fill.
                userLoggedIn()
            } else {
                // Same feedback as a typed PIN: every dot fills, and the screen goes once the
                // fill has been seen.
                enteredDigitCount = totalDigits
                DispatchQueue.main.asyncAfter(deadline: .now() + PINDotsAnimation.fillDuration) { [weak self] in
                    self?.userLoggedIn()
                }
            }
        }
    }

    /// The view animates this direction on its own: the logo lifts into the header while the
    /// keypad, texts, dots and footer come in.
    func leaveSplash() {
        guard showsSplash else { return }
        keypadEntranceDelay = SplashTransition.keypadDelay
        showsSplash = false
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
        NotificationCenter.default.post(name: .userLoggedIn, object: nil)
        // The parent puts the app underneath first; the dots stay filled while this screen
        // flies away over it.
        flowController.toLoggedIn()
        guard loginType == .login else { return }
        withAnimation(UnlockTransition.Login.fade) {
            isLeaving = true
        } completion: { [weak self] in
            self?.flowController.toLoggedInTransitionFinished()
        }
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
        // A wrong-PIN note from the attempt before may still be up, and its timer is about
        // to be replaced by the countdown; the lock message says it all.
        info = nil
        lockMessage = lockTimeMessage
        timer.start(interval: .seconds(1)) { [weak self] in
            if self?.interactor.isLocked == false {
                self?.lockMessage = nil
                self?.unlock.toggle()
                self?.timer.cancel()
                self?.isBlocked = false
            } else {
                self?.lockMessage = self?.lockTimeMessage ?? ""
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
    /// seen on return, right before `didBecomeActive` prompts for biometry. Going back to the
    /// splash now, while nothing is on screen, means the return starts from the splash with
    /// the prompt over it, as a cold start does.
    @objc
    func didEnterBackground() {
        guard loginType == .login, interactor.willPromptBiometryOnAppear else { return }
        animatesKeyboardHiding = false
        showsSplash = true
        promptsOnSplash = true
        splashFollowsLaunchScreen = false
        greetingIsAway = true
    }

    func isVisible() {
        refreshBiometryKey()
        // `onAppear` also fires while the screen is being prepared in the background, where a
        // prompt is impossible; stay on the splash and wait for `didBecomeActive`.
        guard !interactor.isAppInBackground else { return }
        greetingIsAway = false
        // A prompt is up, or has just succeeded and the screen is on its way out: its
        // completion decides. This also absorbs the `didBecomeActive` the biometry alert's
        // dismissal fires.
        guard !isAuthenticating else { return }
        defer {
            // If the keypad stays or comes in after all, the next hide is a user's doing again.
            if !isKeyboardHidden { animatesKeyboardHiding = true }
        }
        guard !isResetVisible else { return }
        if interactor.isLocked {
            lockedState()
            leaveSplash()
        } else if interactor.isLoggedOut {
            // Runs over the splash; a failure leaves it.
            biometry()
        } else {
            leaveSplash()
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
