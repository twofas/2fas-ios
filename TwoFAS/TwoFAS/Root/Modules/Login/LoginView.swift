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
            
            VStack(spacing: .XXXL) {
                Spacer()
                AdaptiveReadableContainer {
                    PINWelcomeHeader(loginType: presenter.loginType, info: $presenter.info)
                }
                Spacer()
            }
            .containerRelativeFrame(.vertical) { length, _ in
                length * (presenter.loginType == .verify ? 0.20 : 0.25)
            }
            
            PINDots(count: presenter.totalDigits, enteredCount: $presenter.enteredDigitCount)
                .disabled(presenter.isBlocked)
                .shake(on: presenter.shake)
                .sensoryFeedback(.error, trigger: presenter.shake) { _, new in new }
            
            PINKeyboard(action: presenter.onKeyPressed)
                .disabled(presenter.isBlocked)
            
            if presenter.loginType == .login {
                PINWelcomeFooter {
                    presenter.isResetVisible = true
                }
                .sheetContentPopover(
                    isPresented: $presenter.isResetVisible,
                    onDismiss: { presenter.onResetDismiss() }
                ) {
                    AppReset()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    }
}
