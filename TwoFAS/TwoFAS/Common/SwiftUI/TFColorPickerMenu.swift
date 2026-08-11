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

struct TFColorPickerMenu: View {
    @Environment(\.colorScheme)
    private var colorScheme

    private let title: String
    @Binding private var selectedColor: TintColor
    private let colors: [TintColor]

    private let circleSize: CGFloat = 20

    init(
        title: String,
        selectedColor: Binding<TintColor>,
        colors: [TintColor] = TintColor.labelList
    ) {
        self.title = title
        self._selectedColor = selectedColor
        self.colors = colors
    }

    var body: some View {
        Menu {
            ForEach(colors, id: \.self) { color in
                Button {
                    selectedColor = color
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
                Text(title)
                    .textStyle(.body)
                    .foregroundStyle(.labelsPrimary)
                    .minimumScaleFactor(0.9)
                    .allowsTightening(true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Circle()
                    .fill(selectedColor.color(for: colorScheme))
                    .frame(width: circleSize, height: circleSize)

                Text(selectedColor.localizedName)
                    .textStyle(.body)
                    .foregroundStyle(.labelsSecondary)

                Image(systemName: "chevron.up.chevron.down")
                    .textStyle(.body)
                    .foregroundStyle(.labelsSecondary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: .normal)
        }
    }
}
