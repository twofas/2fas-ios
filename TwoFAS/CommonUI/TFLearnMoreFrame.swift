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

// MARK: - TFLearnMoreFrame

/// A pill-shaped "Learn more" tappable label from the Intro / Welcome screen.
///
/// ```swift
/// TFLearnMoreFrame("Learn more about backup") { showSheet = true }
/// ```
///
public struct TFLearnMoreFrame: View {
    private let label: String
    private let action: () -> Void

    public init(_ label: String, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(label)
                .textStyle(.subheadline, .emphasized)
                .foregroundStyle(AppColor.labelsPrimary)
                .padding(.horizontal, .ML)
                .padding(.vertical, Spacing.S)
                .background(
                    Capsule()
                        .fill(AppColor.fillsTertiary)
                )
        }
        .buttonStyle(_TFPressStyle())
    }
}
