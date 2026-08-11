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

// MARK: - TFRowContent

/// A standard row inside a `TFListSection`: a leading `body`-styled title that
/// fills the available width, followed by an optional trailing accessory.
///
/// Renders as:
/// `[title (labelsPrimary) ──────────────── accessory]`
///
/// The `accessory` builder supplies the trailing control — e.g. a `Toggle`,
/// a value `Text`, or an icon.
///
/// ```swift
/// TFRowContent(title: cell.title) {
///     Toggle("", isOn: $isOn)
///         .labelsHidden()
///         .tint(AppColor.accentsBrand)
/// }
/// ```
public struct TFRowContent<Accessory: View, Icon: View>: View {
    private let title: String
    private let isActive: Bool
    private let icon: Icon?
    private let accessory: Accessory
    
    public init(
        title: String,
        isActive: Bool = false,
        @ViewBuilder accessory: () -> Accessory
    ) where Icon == EmptyView {
        self.title = title
        self.isActive = isActive
        self.icon = nil
        self.accessory = accessory()
    }

    public init(title: String, isActive: Bool = false) where Accessory == EmptyView, Icon == EmptyView {
        self.title = title
        self.isActive = isActive
        self.icon = nil
        self.accessory = EmptyView()
    }
    
    public init(
        title: String,
        isActive: Bool = false,
        @ViewBuilder icon: (() -> Icon),
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.isActive = isActive
        self.icon = icon()
        self.accessory = accessory()
    }

    public var body: some View {
        HStack(spacing: .ML) {
            if let icon {
                icon
            }
            
            Text(title)
                .textStyle(.body)
                .foregroundStyle(isActive ? AppColor.accentsBrand : AppColor.labelsPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            accessory
        }
        .padding(.vertical, .L)
        .contentShape(Rectangle())
        .frame(minHeight: .normal)
    }
}

public struct CheveronIcon: View {
    public init() {}
    public var body: some View {
        Image(systemName: "chevron.right")
            .textStyle(.subheadline, .emphasized)
            .foregroundStyle(.labelsTertiary)
            .accessibilityHidden(true)
    }
}
