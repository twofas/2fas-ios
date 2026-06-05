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

// MARK: - TFInfoFrame

/// An informational card with an optional SF Symbol icon, an optional title,
/// and a required body text.
///
/// Background uses `backgroundsSecondaryElevated`, border uses `bordersPrimary`
/// at hairline width. All text is `labelsPrimary` and centre-aligned.
///
/// Typography:
/// - Icon  — Title2 / Regular (22 pt)
/// - Title — Headline / Regular (17 pt Semibold)
/// - Body  — Footnote / Regular (13 pt)
///
/// ```swift
/// // Full variant
/// TFInfoFrame(
///     icon: "exclamationmark.triangle",
///     title: "Warning",
///     body: "If you reset the app without a backup you will lose all your codes."
/// )
///
/// // No icon
/// TFInfoFrame(title: "Note", body: "You can re-enable this in Settings.")
///
/// // Body only
/// TFInfoFrame(body: "iCloud Sync is currently unavailable.")
/// ```
public struct TFInfoFrame: View {
    private let icon: String?
    private let title: String?
    private let message: String

    public init(
        icon: String? = nil,
        title: String? = nil,
        body message: String
    ) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: .M) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(AppColor.labelsPrimary)
            }
            if let title {
                Text(title)
                    .textStyle(.headline)
                    .foregroundStyle(AppColor.labelsPrimary)
            }
            Text(message)
                .textStyle(.footnote)
                .foregroundStyle(AppColor.labelsPrimary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.XL)
        .background(AppColor.backgroundsSecondaryElevated)
        .cornerRadius(.large)
        .overlay(
            RoundedRectangle(.large)
                .stroke(AppColor.bordersPrimary, lineWidth: .hairline)
        )
    }
}
