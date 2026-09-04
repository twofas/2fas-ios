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
                biometryKey: presenter.biometryKey
            ) {
                PINWelcomeHeader(loginType: presenter.loginType, info: $presenter.info)
            }
            
            Spacer(minLength: 0)
            
            if presenter.loginType == .login {
                PINWelcomeFooter {
                    presenter.isResetVisible = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .minimumBottomSpacing(.M)
        .sensoryFeedback(.success, trigger: presenter.success) { _, new in new }
        .sensoryFeedback(.start, trigger: presenter.unlock)
        .background(AppColor.backgroundsPrimary)
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

// MARK: - Preview

private final class PreviewLoginFlowController: LoginFlowControlling {
    func toClose() {}
    func toLoggedIn() {}
}

private final class PreviewLoginInteractor: LoginModuleInteracting {
    let isLocked = false
    let isLoggedOut = true
    let lockTime: Int? = nil
    let codeLength = 4
    let availableBiometryType: BiometryType = .faceID

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
