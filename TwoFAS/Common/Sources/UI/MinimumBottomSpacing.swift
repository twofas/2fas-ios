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

// MARK: - Minimum bottom spacing (safe-area aware)

/// Guarantees the content keeps at least `spacing` of clearance at the bottom,
/// counting the system safe area (e.g. the home indicator) towards it:
///
/// - if the bottom safe area is already `>= spacing`, nothing is added and the
///   native safe area is used as-is,
/// - if it is smaller (e.g. `0` on devices with a Home button), the difference
///   is added as bottom padding, so the effective bottom gap always equals
///   `spacing`.
public struct MinimumBottomSpacing: ViewModifier {
    private let spacing: Spacing

    @State private var bottomSafeArea: CGFloat = 0

    public init(spacing: Spacing) {
        self.spacing = spacing
    }

    public func body(content: Content) -> some View {
        content
            .padding(.bottom, max(0, spacing.value - bottomSafeArea))
            .background {
                // A safe-area-ignoring GeometryReader reports the true device
                // bottom inset regardless of how the content itself is laid out.
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { bottomSafeArea = proxy.safeAreaInsets.bottom }
                        .onChange(of: proxy.safeAreaInsets.bottom) { _, newValue in
                            bottomSafeArea = newValue
                        }
                }
                .ignoresSafeArea()
            }
    }
}

public extension View {
    /// Guarantees a minimum bottom clearance, counting the system safe area.
    ///
    /// See ``MinimumBottomSpacing``.
    func minimumBottomSpacing(_ spacing: Spacing = .XXXXXL) -> some View {
        modifier(MinimumBottomSpacing(spacing: spacing))
    }
}
