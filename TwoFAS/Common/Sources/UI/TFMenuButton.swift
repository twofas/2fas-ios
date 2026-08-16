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

// MARK: - TFMenuButton

/// An overflow ("…") button that presents a contextual `Menu`.
///
/// The trigger is a standard `ellipsis` SF Symbol rendered in
/// `labelsSecondary` inside a 44 × 44 pt tappable area, giving every
/// menu entry point across the app an identical appearance.
///
/// ```swift
/// TFMenuButton {
///     Button(action: onRestore) {
///         Label(T.Settings.restore, systemImage: "arrow.clockwise")
///     }
///     Button(role: .destructive, action: onDelete) {
///         Label(T.Commons.delete, systemImage: "trash.fill")
///     }
/// }
/// ```
///
public struct TFMenuButton<Content: View>: View {
    private let accessibilityLabel: String?
    private let moveRight: Bool
    private let content: () -> Content

    public init(
        accessibilityLabel: String? = nil,
        moveRight: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.moveRight = moveRight
        self.content = content
    }

    public var body: some View {
        Menu {
            content()
        } label: {
            Image(systemName: "ellipsis")
                .textStyle(.body)
                .foregroundStyle(AppColor.labelsSecondary)
                .frame(width: 44, height: 44, alignment: moveRight ? .trailing : .center)
                .contentShape(Rectangle())
                .modify {
                    if let accessibilityLabel {
                        $0.accessibilityLabel(accessibilityLabel)
                    } else {
                        $0
                    }
                }
        }
    }
}
