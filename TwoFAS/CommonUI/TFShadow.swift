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

// MARK: - TFShadow

/// Design system shadow styles.
///
/// Usage:
/// ```swift
/// view.shadow(.glass)
/// ```
public struct TFShadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
}

// MARK: - Named styles

public extension TFShadow {
    /// Subtle depth shadow used on glass (liquid-glass) elements.
    static let glass = TFShadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
}

// MARK: - View extension

public extension View {
    /// Applies a design-system shadow style.
    func shadow(_ style: TFShadow) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
