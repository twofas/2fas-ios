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

import SwiftUI
import Common

struct AddingServiceTokenView: View {
    @ObservedObject var presenter: AddingServiceTokenPresenter
    let dismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            MainScreenModalView(
                onClose: dismiss,
                title: T.Tokens.addSuccessTitle,
                subtitle: T.Tokens.addSuccessDescription
            ) {
                tokenView()
            } footer: {
                TFButton(T.Tokens.copyToken, variant: .borderedSecondary, size: .largeWide, applyGlass: false) {
                    presenter.handleCopyCode()
                }
            }
        }
    }
    
    @ViewBuilder
    private func tokenView() -> some View {
        HStack(spacing: .L) {
            AddingServiceIcon(icon: presenter.serviceIcon)
            VStack(alignment: .leading, spacing: .SM) {
                AddingServiceTitleView(text: presenter.serviceName)
                AddingServiceTokenValueView(text: $presenter.token, willChangeSoon: $presenter.willChangeSoon)
            }
            
            switch presenter.serviceTokenType {
            case .steam, .totp:
                AddingServiceTOTPTimerView(
                    text: $presenter.time,
                    willChangeSoon: $presenter.willChangeSoon,
                    animationProgress: $presenter.part
                )
            case .hotp:
                AddingServiceHOTPView(
                    refreshTokenLocked: $presenter.refreshTokenLocked,
                    handleRefresh: presenter.handleRefresh
                )
            }
        }
        .padding(EdgeInsets(top: .XXL, leading: .XL, bottom: .XXL, trailing: .XL))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Metrics.modalCornerRadius)
                .inset(by: 0.5)
                .stroke(.bordersVibrant, lineWidth: 1)
        )
        .padding(.vertical, .XL)
    }
}
