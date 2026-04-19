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

// MARK: - TFCornerRadius

/// Design system corner-radius scale.
///
/// Use directly wherever a corner radius value is required:
/// ```swift
/// view.cornerRadius(.medium)
/// RoundedRectangle(cornerRadius: .medium)
/// ```
@frozen
public enum TFCornerRadius: CGFloat, CaseIterable {
    /// 12 pt — default rounded button / card radius.
    case medium = 12
    /// 24 pt — info frame / card radius.
    case large = 24

    /// Raw `CGFloat` value — use when a plain number is required.
    public var value: CGFloat { rawValue }
}

// MARK: - View extension

public extension View {
    /// Clips the view to a rounded rectangle with the given design-system radius.
    ///
    /// Defaults to the `.continuous` corner style (squircle), matching
    /// iOS system controls.
    func cornerRadius(
        _ radius: TFCornerRadius,
        style: RoundedCornerStyle = .continuous
    ) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius.rawValue, style: style))
    }
}

// MARK: - RoundedRectangle extension

public extension RoundedRectangle {
    /// Creates a rounded rectangle using a design-system corner-radius token.
    init(_ radius: TFCornerRadius, style: RoundedCornerStyle = .continuous) {
        self.init(cornerRadius: radius.rawValue, style: style)
    }
}
