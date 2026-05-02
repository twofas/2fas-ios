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

// MARK: - Private metrics

private enum BadgeMetrics {
    static let logoSize: CGFloat = 52
    static let padding: CGFloat = Spacing.ML.value
    static let cornerRadius: CGFloat = TFCornerRadius.badge.value
    static let borderWidth: CGFloat = 0.667 // 2 px @3x, per Figma liquid-glass spec
    static let borderAlphaDark: CGFloat = 0.4
    static let borderAlphaLight: CGFloat = 0.08
    static let glassOpacity: CGFloat = 0.09
    static let glassMidWhite: CGFloat = 0.68 // neutral midpoint of gradient end stop
}

// Gradient angle -14.74° → top-right to bottom-left
private let glassGradientStart = UnitPoint(x: 0.63, y: 0)
private let glassGradientEnd = UnitPoint(x: 0.37, y: 1)

// MARK: - Public component

/// Glass-framed logo badge from the Intro / Welcome screen.
///
/// ```swift
/// IntroLogoBadgeView(image: Image("mark"))
/// ```
///
/// - 72 × 72 pt outer size (52 pt logo + 10 pt padding on each side).
/// - Dark mode: near-transparent white glass, `rgba(white, 0.4)` border.
/// - Light mode: frosted white material, `rgba(black, 0.08)` border.
public struct IntroLogoBadgeView: View {
    public let image: Image
    
    @Environment(\.colorScheme) private var colorScheme
    
    public init(image: Image) {
        self.image = image
    }
    
    public var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: BadgeMetrics.logoSize, height: BadgeMetrics.logoSize)
            .padding(BadgeMetrics.padding)
            .background(glassBackground)
    }
    
    // MARK: - Background
    
    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: BadgeMetrics.cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(gradientSheen)
            .overlay(borderRing)
            .shadow(.glass)
    }
    
    private var gradientSheen: some View {
        RoundedRectangle(cornerRadius: BadgeMetrics.cornerRadius, style: .continuous)
            .fill(LinearGradient(
                stops: [
                    .init(
                        color: .white.opacity(BadgeMetrics.glassOpacity),
                        location: 0
                    ),
                    .init(
                        color: Color(white: BadgeMetrics.glassMidWhite).opacity(BadgeMetrics.glassOpacity),
                        location: 1
                    )
                ],
                startPoint: glassGradientStart,
                endPoint: glassGradientEnd
            ))
    }
    
    private var borderRing: some View {
        RoundedRectangle(cornerRadius: BadgeMetrics.cornerRadius, style: .continuous)
            .strokeBorder(
                colorScheme == .dark
                ? Color.white.opacity(BadgeMetrics.borderAlphaDark)
                : Color.black.opacity(BadgeMetrics.borderAlphaLight),
                lineWidth: BadgeMetrics.borderWidth
            )
    }
}
