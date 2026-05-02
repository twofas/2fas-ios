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

// MARK: - TFBorderWidth

/// Design system border-width scale.
///
/// Usage:
/// ```swift
/// view.overlay(RoundedRectangle(.large).stroke(AppColor.bordersPrimary, lineWidth: TFBorderWidth.hairline.value))
/// shape.stroke(AppColor.bordersPrimary, lineWidth: .hairline)
/// ```
@frozen
public enum TFBorderWidth: CGFloat, CaseIterable {
    /// 0.5 pt — hairline border used on cards and info frames.
    case hairline = 0.5

    /// Raw `CGFloat` value — use when a plain number is required.
    public var value: CGFloat { rawValue }
}

// MARK: - Shape extension

public extension Shape {
    /// Strokes the shape with a design-system border width.
    func stroke(_ style: some ShapeStyle, lineWidth: TFBorderWidth) -> some View {
        stroke(style, lineWidth: lineWidth.rawValue)
    }
}
