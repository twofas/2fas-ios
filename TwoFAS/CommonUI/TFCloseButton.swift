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

// MARK: - TFCloseButton

/// A 44 × 44 pt liquid-glass dismiss button displaying the `xmark` SF Symbol.
///
/// Intended for sheet and modal toolbars — matches the close-button pattern
/// from the 2FAS Design System.
///
/// The label colour adapts automatically to light / dark mode via
/// `labelsVibrantPrimary`. A rigid impact haptic fires on press-down.
///
/// ```swift
/// TFCloseButton { dismiss() }
/// ```
public struct TFCloseButton: View {
    private let size: CGFloat = 44
    private let fontSize: CGFloat = 20
    
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
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
