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

struct ComposeServiceSecretKeyField<FocusValue: Hashable>: View {
    let mode: ComposeServiceSecretKeyMode
    @Binding var secret: String
    let errorMessage: Binding<String?>
    let focused: FocusState<FocusValue?>.Binding
    let focusValue: FocusValue
    let onReveal: () -> Void
    let onShare: () -> Void

    private let maskedPlaceholder = "•••••••••••••••"

    var body: some View {
        switch mode {
        case .empty:
            TFFloatingTextField(
                placeHolder: T.Tokens.serviceKey,
                text: $secret,
                inputType: .secret,
                keyboardType: .alphabet,
                autocapitalization: .characters,
                focused: focused,
                focusValue: focusValue,
                errorMessage: errorMessage
            )
        case .hidden:
            row(value: maskedPlaceholder, isMasked: true) {
                Button(action: onReveal) {
                    Image(systemName: "eye")
                        .textStyle(.body)
                        .foregroundStyle(.accentsBrand)
                        .accessibilityLabel(T.Voiceover.showServiceKey)
                }
                .buttonStyle(.plain)
            }
            .frame(minHeight: .input)
        case .hiddenNonCopyable:
            row(value: maskedPlaceholder, isMasked: true) {
                EmptyView()
            }
        case .revealed(let value):
            row(value: value, isMasked: false) {
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .textStyle(.body)
                        .foregroundStyle(.accentsBrand)
                        .accessibilityLabel(T.Voiceover.copyServiceKey)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func row<Accessory: View>(
        value: String,
        isMasked: Bool,
        @ViewBuilder accessory: () -> Accessory
    ) -> some View {
        HStack(spacing: .ML) {
            VStack(alignment: .leading, spacing: .S) {
                Text(T.Tokens.serviceKey)
                    .textStyle(.footnote)
                    .foregroundStyle(.labelsSecondary)
                Text(value)
                    .textStyle(.body)
                    .foregroundStyle(isMasked ? .labelsTertiary : .labelsPrimary)
                    .lineLimit(1)
                    .accessibilityLabel(isMasked ? T.Voiceover.revealHiddenSecretKeyButtonTitle : value)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            accessory()
        }
        .padding(.vertical, .L)
        .frame(minHeight: .input)
    }
}
