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

struct LabelComposeView: View {
    @ObservedObject
    var presenter: LabelComposePresenter
    
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    
    @FocusState
    private var isTitleFocused: Bool?
    
    private let circleSize: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ZStack {
                HStack(spacing: .zero) {
                    TFLiquidGlassSymbolButton(symbol: .back) {
                        presenter.handleBack()
                    }
                    Spacer()
                    TFLiquidGlassTextButton(T.Commons.save, color: .accentsBrand) {
                        presenter.handleSave()
                    }
                    .disabled(!presenter.isSaveEnabled)
                }
                TFTitleView(title: T.Tokens.changeLabel)
            }
            .padding(.horizontal, .XL)
            .padding(.top, .XL)

            ScrollView {
                AdaptiveReadableContainer {
                    VStack(spacing: .XXXXL) {
                        ServiceIconView(
                            icon: .label(title: presenter.title, TintColor: presenter.color)
                        )
                        .shadow(.glass)

                        VStack(alignment: .leading, spacing: .zero) {
                            TFFloatingTextField(
                                placeHolder: T.Tokens.labelCharactersTitle,
                                text: $presenter.title,
                                inputType: .other,
                                keyboardType: .asciiCapable,
                                autocapitalization: .characters,
                                focused: $isTitleFocused,
                                focusValue: true
                            )

                            Divider()
                                .foregroundStyle(.separatorsNonOpaque)

                            colorMenu
                        }
                        .groupedSectionBackground()
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(.backgroundsPrimaryElevated)
        .onChange(of: presenter.title) { _, newValue in
            if newValue.count > presenter.titleMaxLength {
                presenter.title = String(newValue.prefix(presenter.titleMaxLength))
            }
        }
        .onAppear {
            if !UIAccessibility.isVoiceOverRunning {
                DispatchQueue.main.async {
                    isTitleFocused = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var colorMenu: some View {
        Menu {
            ForEach(TintColor.labelList, id: \.self) { color in
                Button {
                    presenter.handleSetColor(color)
                } label: {
                    Label {
                        Text(color.localizedName)
                    } icon: {
                        Image(uiImage: UIImage(systemName: "circle.fill")!
                            .withTintColor(color.color, renderingMode: .alwaysOriginal))
                    }
                }
            }
        } label: {
            HStack(spacing: .ML) {
                Text(T.Tokens.pickBackgroundColor)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .minimumScaleFactor(0.9)
                    .allowsTightening(true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Circle()
                    .fill(presenter.color.color(for: colorScheme))
                    .frame(width: circleSize, height: circleSize)
                
                Text(presenter.color.localizedName)
                    .textStyle(.body)
                    .foregroundStyle(.labelsSecondary)
                
                Image(systemName: "chevron.up.chevron.down")
                    .textStyle(.body)
                    .foregroundStyle(.labelsSecondary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, .XL)
        }
    }
}
