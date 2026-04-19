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

// MARK: - Spacing

/// Design system spacing scale.
///
/// Use directly wherever SwiftUI accepts a spacing value:
/// ```swift
/// view.padding(.M)
/// view.padding(.horizontal, .XL)
/// view.margin(.top, .S)
///
/// VStack(spacing: Spacing.M.value) { ... }
/// EdgeInsets(vertical: .L, horizontal: .M)
/// ```
@frozen
public enum Spacing: CGFloat, CaseIterable {
    /// 2
    case XS = 2
    /// 4
    case S = 4
    /// 8
    case M = 8
    /// 12
    case L = 12
    /// 16
    case XL = 16
    /// 20
    case XXL = 20
    /// 24
    case XXXL = 24
    /// 28
    case XXXXL = 28
    /// 32
    case XXXXXL = 32
    
    /// Raw `CGFloat` value — use when a plain number is required,
    /// e.g. `VStack(spacing: Spacing.M.value)`.
    public var value: CGFloat { rawValue }
}

// MARK: - View + padding

public extension View {
    /// Applies equal padding on all edges.
    func padding(_ spacing: Spacing) -> some View {
        padding(spacing.value)
    }
    
    /// Applies padding to the specified edges.
    func padding(_ edges: Edge.Set, _ spacing: Spacing) -> some View {
        padding(edges, spacing.value)
    }
    
    /// Applies equal margin (padding) on all edges.
    func margin(_ spacing: Spacing) -> some View {
        padding(spacing.value)
    }
    
    /// Applies margin (padding) to the specified edges.
    func margin(_ edges: Edge.Set, _ spacing: Spacing) -> some View {
        padding(edges, spacing.value)
    }
}

// MARK: - Stack initializers

public extension VStack {
    init(alignment: HorizontalAlignment = .center, spacing: Spacing, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.value, content: content)
    }
}

public extension HStack {
    init(alignment: VerticalAlignment = .center, spacing: Spacing, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.value, content: content)
    }
}

public extension LazyVStack {
    init(alignment: HorizontalAlignment = .center, spacing: Spacing, pinnedViews: PinnedScrollableViews = .init(), @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.value, pinnedViews: pinnedViews, content: content)
    }
}

public extension LazyHStack {
    init(alignment: VerticalAlignment = .center, spacing: Spacing, pinnedViews: PinnedScrollableViews = .init(), @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.value, pinnedViews: pinnedViews, content: content)
    }
}

// MARK: - EdgeInsets

public extension EdgeInsets {
    /// Uniform insets on all sides.
    init(_ spacing: Spacing) {
        let v = spacing.value
        self.init(top: v, leading: v, bottom: v, trailing: v)
    }
    
    /// Separate vertical and horizontal insets.
    init(vertical: Spacing, horizontal: Spacing) {
        self.init(
            top: vertical.value,
            leading: horizontal.value,
            bottom: vertical.value,
            trailing: horizontal.value
        )
    }
    
    /// Independent insets per axis.
    init(top: Spacing, leading: Spacing, bottom: Spacing, trailing: Spacing) {
        self.init(
            top: top.value,
            leading: leading.value,
            bottom: bottom.value,
            trailing: trailing.value
        )
    }
}
