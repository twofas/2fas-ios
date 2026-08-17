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

public struct TFInfoView<VButtons: View>: View {
    private let background: AppColor
    private let icon: TFInfoContent.Icon
    private let title: String
    private let subtitle: String?
    private let description: String?
    private let attributedDescription: AttributedString?
    private let buttons: VButtons

    public init(
        icon: TFInfoContent.Icon,
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        attributedDescription: AttributedString? = nil,
        background: AppColor = .backgroundsPrimaryElevated,
        @ViewBuilder buttons: () -> VButtons
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.attributedDescription = attributedDescription
        self.background = background
        self.buttons = buttons()
    }

    public var body: some View {
        AdaptiveReadableContainer(verticalMargin: .zero) {
            VStack(alignment: .center) {
                Spacer()

                TFInfoContent(
                    icon: icon,
                    title: title,
                    subtitle: subtitle,
                    description: description,
                    attributedDescription: attributedDescription
                )

                Spacer()

                VStack(spacing: .L) {
                    buttons
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
        }
        .background(background)
        .minimumBottomSpacing()
    }
}
