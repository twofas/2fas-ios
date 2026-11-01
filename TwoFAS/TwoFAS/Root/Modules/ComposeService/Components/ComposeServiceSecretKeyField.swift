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

enum ComposeServiceSecretKeyMode: Hashable {
    case empty
    case hidden
    case hiddenNonCopyable
    case revealed(String)
}

struct ComposeServiceSecretKeyField<FocusValue: Hashable, MenuContent: View>: View {
    let mode: ComposeServiceSecretKeyMode
    @Binding var secret: String
    let errorMessage: Binding<String?>
    let focused: FocusState<FocusValue?>.Binding
    let focusValue: FocusValue
    let onReveal: () -> Void
    @ViewBuilder let menuContent: () -> MenuContent

    private let maskedPlaceholder = "••••••••••••••••••"

    var body: some View {
        switch mode {
        case .empty:
            TFInlineTextField(
                label: T.Tokens.serviceKey,
                placeholder: T.Tokens.addManualServiceKeyPlaceholder,
                text: $secret,
                inputType: .secret,
                keyboardType: .alphabet,
                autocapitalization: .characters,
                focused: focused,
                focusValue: focusValue,
                isInvalid: errorMessage.wrappedValue != nil
            )
        case .hidden:
            row(value: maskedPlaceholder, isMasked: true) {
                Button(action: onReveal) {
                    Image(icon: .eyeSlashFill)
                        .textStyle(.body)
                        .foregroundStyle(.labelsPrimary)
                        .accessibilityLabel(T.Voiceover.showServiceKey)
                }
                .buttonStyle(.plain)
            }
        case .hiddenNonCopyable:
            row(value: maskedPlaceholder, isMasked: true) {
                EmptyView()
            }
        case .revealed(let value):
            row(value: value, isMasked: false) {
                TFMenuButton(accessibilityLabel: T.Commons.optionsTitle, moveRight: true) {
                    menuContent()
                }
            }
        }
    }

    @ViewBuilder
    private func row<Accessory: View>(
        value: String,
        isMasked: Bool,
        @ViewBuilder accessory: () -> Accessory
    ) -> some View {
        TFInlineRow(label: T.Tokens.serviceKey) {
            HStack(spacing: .M) {
                Text(value)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel(T.Tokens.serviceKey)
                    .accessibilityValue(isMasked ? T.Voiceover.revealHiddenSecretKeyButtonTitle : value)

                accessory()
            }
        }
    }
}
