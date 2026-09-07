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

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    /// Ties the floating brand to its splash slot and header slot, see `LoginFloatingBrand`.
    @Namespace private var logoNamespace
    /// Picked once per screen, so the greeting does not change while the screen is up.
    @State private var greeting = LoginBrand.greetings.randomElement() ?? T.Login.helloHeader

    /// `true` when the system draws the biometry prompt over the screen centre: Touch ID,
    /// Face ID behind a notch, iPad. Face ID on a Dynamic Island phone animates in the island
    /// instead.
    private static let biometryAlertCoversCentre = !UIDevice.hasDynamicIsland

    /// Where the brand sits. On the splash, except on a device whose biometry alert covers
    /// the screen centre: there the brand is in the header while a prompt is up, lifting
    /// ahead of the alert on a cold start, and from the first frame on a return from the
    /// background, where nothing ties the splash to the launch screen. The rest of the screen
    /// still waits for the prompt's outcome.
    private var brandOnSplash: Bool {
        guard presenter.showsSplash else { return false }
        guard Self.biometryAlertCoversCentre else { return true }
        return presenter.splashFollowsLaunchScreen && !presenter.isAuthenticating
    }

    /// The greeting sits on the splash only when a biometry prompt holds the splash with the
    /// brand at the centre. Where the alert takes the centre, the brand lifts alone, as it
    /// does with no biometry at all, and the greeting fades in up in the header.
    private var greetsOnSplash: Bool {
        presenter.promptsOnSplash && !Self.biometryAlertCoversCentre
    }

    /// `true` when the brand is already up in the header as the splash is left, having
    /// lifted ahead of a biometry alert: the subtitle then comes in on the header's beat,
    /// with no flight to wait for.
    private var brandRoseEarly: Bool {
        presenter.promptsOnSplash && Self.biometryAlertCoversCentre
    }

    /// Logo and greeting, big on the splash and small in the header. Only the lock screen
    /// greets. `greetsOnSplash` has the greeting join the brand at the centre and fade in
    /// there; otherwise it belongs to the header, fading in like the subtitle once the brand
    /// is up.
    private func brand(contentWidth: CGFloat) -> LoginBrand {
        LoginBrand(
            greeting: presenter.loginType == .login ? greeting : nil,
            isGreetingRevealed: !presenter.greetingIsAway,
            drawsGreeting: greetsOnSplash,
            greetingMaxWidth: greetingMaxWidth(contentWidth: contentWidth)
        )
    }

    /// The width the header offers its texts (the readable width of
    /// `AdaptiveReadableContainer`), shrunk so the greeting still fits it once grown to the
    /// splash scale. Taken from the layout pass itself, not from a measurement that lands a
    /// pass later: the floating brand's matched position is not refreshed when only its own
    /// width changes, so its width must be right from the first pass.
    private func greetingMaxWidth(contentWidth: CGFloat) -> CGFloat? {
        guard contentWidth > 0 else { return nil }
        let readableWidth = AdaptiveReadableContainer<EmptyView>.readableWidth(
            available: contentWidth,
            sizeClass: horizontalSizeClass
        )
        return readableWidth / SplashTransition.greetingScale
    }

    private var dotsAnimation: Animation? {
        if presenter.showsSplash {
            nil
        } else if presenter.isBlocked {
            PINInfoMessage.fadeOut
        } else {
            SplashTransition.dotsReveal
        }
    }

    /// The footer goes with the keypad, except through a lock-out: the way to restore the app
    /// is worth keeping in reach while the keypad is replaced by the lock message.
    private var isFooterHidden: Bool {
        presenter.isKeyboardHidden && !presenter.isBlocked
    }

    /// Mirrors the keypad: an automatic hide is instant, a user's hide fades, showing fades in
    /// after the keypad's entrance delay.
    private var footerAnimation: Animation? {
        if isFooterHidden {
            presenter.animatesKeyboardHiding ? PINKeyboard.fadeOut : nil
        } else {
            PINKeyboard.fadeIn.delay(presenter.keypadEntranceDelay)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            content(brand: brand(contentWidth: proxy.size.width))
        }
    }

    private func content(brand: LoginBrand) -> some View {
        VStack(spacing: .zero) {
            if presenter.loginType == .verify {
                HStack {
                    TFLiquidGlassSymbolButton(symbol: .close) {
                        presenter.onClose()
                    }
                    Spacer()
                }
                .padding(.XL)
            }
            
            // Keeps the logo off the top edge on a short screen; with room to spare the
            // spacers share it as before and this minimum never binds.
            Spacer(minLength: Spacing.XXXL.value)
            
            PINEntryBlock(
                totalDigits: presenter.totalDigits,
                enteredCount: $presenter.enteredDigitCount,
                shake: presenter.shake,
                isDisabled: presenter.isBlocked,
                onKeyPressed: presenter.onKeyPressed,
                biometryKey: presenter.biometryKey,
                isKeyboardHidden: presenter.isKeyboardHidden,
                keyboardAnimatesHiding: presenter.animatesKeyboardHiding,
                keyboardEntranceDelay: presenter.keypadEntranceDelay,
                // The dots are out on the splash and through a lock-out; a lock that starts
                // under the user's fingers fades them, the splash exit reveals them.
                hidesDots: presenter.showsSplash || presenter.isBlocked,
                dotsAnimation: dotsAnimation,
                betweenHeaderAndDots: PINInfoMessage(
                    info: presenter.info,
                    isHidden: presenter.isBlocked || presenter.showsSplash
                )
            ) {
                PINWelcomeHeader(
                    brand: brand,
                    logoNamespace: logoNamespace,
                    showsSplash: presenter.showsSplash,
                    brandOnSplash: brandOnSplash,
                    subtitleReveal: brandRoseEarly ? SplashTransition.headerReveal : SplashTransition.subtitleReveal,
                    hidesSubtitle: presenter.isBlocked
                )
            }
            
            Spacer(minLength: 0)
            
            if presenter.loginType == .login {
                // Goes away and comes back with the keypad, on the keypad's timing, but keeps
                // its slot so the block above does not move.
                PINWelcomeFooter {
                    presenter.isResetVisible = true
                }
                .opacity(isFooterHidden ? 0 : 1)
                .disabled(isFooterHidden)
                .animation(footerAnimation, value: isFooterHidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .minimumBottomSpacing(.M)
        // The launch screen's logo box: window centre, natural size, safe areas ignored. Goes
        // after the bottom spacing so the slot spans the whole screen, not just the content.
        .overlay {
            LoginBrandSplashSlot(brand: brand, isCurrent: brandOnSplash, namespace: logoNamespace)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
        .overlay {
            LoginFloatingBrand(brand: brand, isSplash: brandOnSplash, namespace: logoNamespace)
        }
        // The lock message at the screen centre, where the keypad and dots were. Comes in on
        // the keypad's beat: after the keys have faded out, or with the rest of the screen
        // out of the splash.
        .overlay {
            PINInfoMessage(
                info: presenter.lockMessage,
                color: .labelsPrimary,
                style: .title3,
                isHidden: presenter.showsSplash,
                reveal: PINKeyboard.fadeIn.delay(presenter.keypadEntranceDelay)
            )
            .padding(.horizontal, .XL)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
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
