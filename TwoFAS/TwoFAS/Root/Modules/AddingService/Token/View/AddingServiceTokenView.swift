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
    @Environment(\.colorScheme) private var colorScheme
    @State private var rotationAngle = 0.0
    @State private var animationProgress: CGFloat = 0
    
    @ObservedObject var presenter: AddingServiceTokenPresenter
    let changeHeight: (CGFloat) -> Void
    let dismiss: () -> Void
    
    private let animation = Animation
        .linear(duration: 1)
        .repeatCount(1)
    
    var body: some View {
        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
            VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                VStack(spacing: 0) {
                    AddingServiceCloseButtonView {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    HStack {
                        Spacer()
                            .frame(maxWidth: .infinity)
                        VStack(alignment: .center, spacing: Theme.Metrics.standardSpacing) {
                            AddingServiceTitleView(text: T.Tokens.addSuccessTitle)
                            AddingServiceTextContentView(text: T.Tokens.addSuccessDescription)
                            AddingServiceLargeSpacing()
                            tokenView()
                        }
                        .frame(minWidth: 310, alignment: .center)
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, Theme.Metrics.doubleMargin)
            
            AddingServiceLargeSpacing()
            
            AddingServiceFullWidthButtonWithImage(
                text: T.Tokens.copyToken,
                icon: Asset.copyIcon.swiftUIImage
            ) {
                presenter.handleCopyCode()
            }
        }
        .padding(.horizontal, Theme.Metrics.doubleMargin)
        .observeHeight(onChange: { height in
            changeHeight(height)
        })
        .onChange(of: presenter.part) { newValue in
            withAnimation(animation) {
                animationProgress = newValue
            }
        }
        .background(Color(colorScheme == .dark ? ThemeColor.buttonCloseBackground : Theme.Colors.Fill.System.third))
    }
    
    @ViewBuilder
    private func tokenView() -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 12) {
                Image(uiImage: presenter.serviceIcon)
                    .accessibilityHidden(true)
                
                VStack(spacing: 4) {
                    AddingServiceTitleView(text: presenter.serviceName, alignToLeading: true)
                        .lineLimit(1)
                    if let serviceAdditionalInfo = presenter.serviceAdditionalInfo {
                        AddingServiceAdditionalInfoView(text: serviceAdditionalInfo)
                    }
                }
            }
            HStack(alignment: .center, spacing: 2 * ThemeMetrics.spacing) {
                AddingServiceTokenValueView(text: $presenter.token, willChangeSoon: $presenter.willChangeSoon)
                
                switch presenter.serviceTokenType {
                case .steam:
                    totpTokenView()
                case .totp:
                    totpTokenView()
                case .hotp:
                    Button {
                            withAnimation(
                                .linear(duration: 1)
                                .speed(5)
                                .repeatCount(1, autoreverses: false)
                            ) {
                                rotationAngle = 360.0
                            }
                    } label: {
                        Asset.refreshTokenCounter.swiftUIImage
                            .tint(Color(presenter.refreshTokenLocked ? ThemeColor.inactive : ThemeColor.theme))
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .disabled(presenter.refreshTokenLocked)
                    .onAnimationCompleted(for: rotationAngle) {
                        rotationAngle = 0
                        presenter.handleRefresh()
                    }
                }
            }
        }
        .padding(.init(top: 16, leading: 20, bottom: 12, trailing: 20))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Metrics.modalCornerRadius)
                .stroke(Color(Theme.Colors.Line.selectionBorder), lineWidth: 1)
        )
    }
    
    private func totpTokenView() -> some View {
        ZStack(alignment: .center) {
            AddingServiceTOTPTimerView(
                text: $presenter.time,
                willChangeSoon: $presenter.willChangeSoon
            )
            
            Circle()
                .trim(from: 0, to: $animationProgress.animation(animation).wrappedValue)
                .stroke(Color(presenter.willChangeSoon ? ThemeColor.theme : ThemeColor.primary),
                        style: StrokeStyle(
                            lineWidth: 1,
                            lineCap: .round
                        ))
                .rotationEffect(.degrees(-90))
                .padding(0.5)
                .frame(width: 30, height: 30)
        }
    }
}
