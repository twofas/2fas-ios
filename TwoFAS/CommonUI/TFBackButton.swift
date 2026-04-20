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

// MARK: - TFBackButton

/// A 44 × 44 pt liquid-glass back button displaying the `chevron.left` SF Symbol.
///
/// ```swift
/// TFBackButton { navigationPath.removeLast() }
/// ```
public struct TFBackButton: View {
    private let size: CGFloat = 44
    private let fontSize: CGFloat = 20

    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: fontSize, weight: .regular))
                .foregroundStyle(AppColor.labelsVibrantPrimary)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(AnyShapeStyle(.ultraThinMaterial))
                        .shadow(.glass)
                )
        }
        .buttonStyle(_TFPressStyle())
    }
}
