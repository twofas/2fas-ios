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

// MARK: - TFRowHeight

/// Design system minimum row-height scale for list cells.
///
/// Usage:
/// ```swift
/// view.frame(minHeight: TFRowHeight.list.value)
/// view.frame(minHeight: .list)
/// ```
@frozen
public enum TFRowHeight: CGFloat, CaseIterable {
    /// 68 pt — swipeable list row (leading icon + text).
    case list = 68
    /// 55 pt — input
    case input = 55
    /// 52 pt - normal list posiition
    case normal = 52

    /// Raw `CGFloat` value — use when a plain number is required.
    public var value: CGFloat { rawValue }
}

// MARK: - View extension

public extension View {
    /// Sets a minimum row height using a design-system token.
    func frame(minHeight: TFRowHeight) -> some View {
        frame(minHeight: minHeight.value)
    }
}
