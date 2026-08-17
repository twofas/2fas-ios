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

// MARK: - TFEmptyScreen

/// A centered empty-state placeholder from the 2FAS design system.
///
/// Shows a hero icon, a title and an optional description, vertically centered
/// within the readable content width. The icon can be an SF Symbol or a
/// `UIImage`. All texts are centered and may span multiple lines.
///
/// ```swift
/// // SF Symbol
/// TFEmptyScreen(systemImage: "trash.fill", title: T.Settings.trashIsEmpty)
///
/// // SF Symbol + description
/// TFEmptyScreen(
///     systemImage: "trash.fill",
///     title: T.Settings.trashIsEmpty,
///     description: T.Settings.trashIsEmptyDescription
/// )
///
/// // UIImage
/// TFEmptyScreen(image: myImage, title: "Nothing here")
/// ```
public struct TFEmptyScreen: View {
    private let icon: TFInfoContent.Icon
    private let title: String
    private let subtitle: String?
    private let description: String?
    
    public init(
        icon: TFInfoContent.Icon,
        title: String,
        subtitle: String? = nil,
        description: String? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.description = description
    }

    public var body: some View {
        AdaptiveReadableContainer {
            VStack(spacing: .zero) {
                Spacer()

                TFInfoContent(
                    icon: icon,
                    title: title,
                    subtitle: subtitle,
                    description: description
                )

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
