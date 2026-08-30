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

struct ComposeServiceIconTypeSelector: View {
    @Binding var selectedType: IconType
    let iconTypeID: IconTypeID
    let labelTitle: String
    let labelColor: TintColor

    var body: some View {
        HStack(spacing: .zero) {
            IconTypeOption(
                type: .brand,
                title: T.Tokens.brandIcon,
                selectedType: $selectedType
            ) {
                ServiceIconView(icon: .brand(iconTypeID: iconTypeID))
            }
            IconTypeOption(
                type: .label,
                title: T.Tokens.label,
                selectedType: $selectedType
            ) {
                ServiceIconView(icon: .label(title: labelTitle, tintColor: labelColor))
            }
        }
        .padding(.vertical, .XL)
    }
}

private struct IconTypeOption<Preview: View>: View {
    let type: IconType
    let title: String
    @Binding var selectedType: IconType
    @ViewBuilder let preview: () -> Preview

    private let indicatorSize: CGFloat = 22

    var body: some View {
        Button {
            selectedType = type
        } label: {
            VStack(spacing: .ML) {
                preview()

                Text(title)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)

                if selectedType == type {
                    Image(icon: .checkmark)
                        .textStyle(.footnote, .emphasized)
                        .foregroundStyle(.graysWhite)
                        .frame(width: indicatorSize, height: indicatorSize, alignment: .center)
                        .background(.accentsBrand)
                        .cornerRadius(100)
                } else {
                    Circle()
                        .inset(by: 0.75)
                        .stroke(.graysGray3, lineWidth: 1.5)
                        .frame(width: indicatorSize, height: indicatorSize)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressFeedbackButtonStyle())
    }
}

private struct PressFeedbackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .sensoryFeedback(
                .impact(flexibility: .rigid, intensity: 0.6),
                trigger: configuration.isPressed
            ) { _, new in new }
    }
}
