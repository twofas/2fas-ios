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
import Data

struct LoginView: View {
    @Bindable
    var presenter: LoginPresenter

    @Environment(\.scenePhase)
    private var scenePhase

#if DEBUG
    /// Hides the keypad the way a running biometry prompt does, so the animation can be
    /// watched without Face ID. Toggled by the debug button in the top-right corner.
    @State private var debugHidesKeyboard = false
#endif

    private var isKeyboardHidden: Bool {
#if DEBUG
        presenter.isKeyboardHidden || debugHidesKeyboard
#else
        presenter.isKeyboardHidden
#endif
    }

    /// Mirrors the keypad: an automatic hide is instant, a user's hide fades, showing fades in
    /// after the keypad's entrance delay.
    private var footerAnimation: Animation? {
        if isKeyboardHidden {
            presenter.animatesKeyboardHiding ? PINKeyboard.fadeOut : nil
        } else {
            PINKeyboard.fadeIn.delay(PINKeyboard.entranceDelay)
        }
    }

    var body: some View {
        VStack(spacing: .S) {
            if presenter.loginType == .verify {
                HStack {
                    TFLiquidGlassSymbolButton(symbol: .close) {
                        presenter.onClose()
                    }
                    Spacer()
                }
                .padding(.XL)
            }
            
            Spacer(minLength: 0)
            
            PINEntryBlock(
                totalDigits: presenter.totalDigits,
                enteredCount: $presenter.enteredDigitCount,
                shake: presenter.shake,
                isDisabled: presenter.isBlocked,
                onKeyPressed: presenter.onKeyPressed,
                biometryKey: presenter.biometryKey,
                isKeyboardHidden: isKeyboardHidden,
                keyboardAnimatesHiding: presenter.animatesKeyboardHiding
            ) {
                PINWelcomeHeader(loginType: presenter.loginType, info: $presenter.info)
            }
            
            Spacer(minLength: 0)
            
            if presenter.loginType == .login {
                // Goes away and comes back with the keypad, on the keypad's timing, but keeps
                // its slot so the block above does not move.
                PINWelcomeFooter {
                    presenter.isResetVisible = true
                }
                .opacity(isKeyboardHidden ? 0 : 1)
                .disabled(isKeyboardHidden)
                .animation(footerAnimation, value: isKeyboardHidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#if DEBUG
        .overlay(alignment: .topTrailing) {
            Button(debugHidesKeyboard ? "Show keypad" : "Hide keypad") {
                debugHidesKeyboard.toggle()
            }
            .buttonStyle(.bordered)
            .padding(.XL)
        }
#endif
        .minimumBottomSpacing(.M)
        .sensoryFeedback(.success, trigger: presenter.success) { _, new in new }
        .sensoryFeedback(.start, trigger: presenter.unlock)
        .background(AppColor.backgroundsPrimary)
        .modifier(UnlockExit(isLeaving: presenter.isLeaving))
        .onAppear {
            presenter.onAppear()
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            guard oldValue != newValue else { return }
            if newValue == .active {
                presenter.onAppear()
            }
        }
        .sheet(isPresented: $presenter.isResetVisible, onDismiss: {
            presenter.onResetDismiss()
        }) {
            AppReset()
        }
    }
}

/// Exit of the login screen over the app, see `UnlockTransition.Login`. Goes after the
/// background so the whole screen, not just its content, grows and fades. The scale takes its
/// own curve; the opacity stays on the transaction's curve the presenter animates with, which
/// is also what its completion waits for.
private struct UnlockExit: ViewModifier {
    let isLeaving: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isLeaving ? UnlockTransition.Login.scale : 1)
            .animation(UnlockTransition.Login.zoom, value: isLeaving)
            .opacity(isLeaving ? 0 : 1)
            .allowsHitTesting(!isLeaving)
    }
}

// MARK: - Preview

private final class PreviewLoginFlowController: LoginFlowControlling {
    func toClose() {}
    func toLoggedIn() {}
    func toLoggedInTransitionFinished() {}
}

private final class PreviewLoginInteractor: LoginModuleInteracting {
    let isLocked = false
    let isLoggedOut = true
    let lockTime: Int? = nil
    let codeLength = 4
    let availableBiometryType: BiometryType = .faceID
    let willPromptBiometryOnAppear = false
    let isAppInBackground = false

    func verify(numbers: [Int]) -> Bool { false }
    func verifyUsingBiometry(reason: String, userInitiated: Bool, completion: @escaping (Bool) -> Void) {}
}

private func previewPresenter(loginType: LoginType) -> LoginPresenter {
    LoginPresenter(
        loginType: loginType,
        flowController: PreviewLoginFlowController(),
        interactor: PreviewLoginInteractor()
    )
}

#Preview("Login") {
    LoginView(presenter: previewPresenter(loginType: .login))
}

#Preview("Verify") {
    LoginView(presenter: previewPresenter(loginType: .verify))
}
