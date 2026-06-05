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

private enum GlowMetrics {
    static let fontSize: CGFloat = 50
    static let tracking: CGFloat = 0.4
    static let blurOuter: CGFloat = 18     // two stacked layers → double intensity
    static let blurInner: CGFloat = 6     // tight edge
    static let phaseStart: CGFloat = -0.4
    static let phaseEnd: CGFloat = 0.4
    static let animDuration: Double = 4
}

// MARK: - Private HDR colors

private enum GlowColors {
    private static let cs = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)!

    private static func make(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> Color {
        Color(CGColor(colorSpace: cs, components: [r, g, b, 1.0])!)
    }

    static let red = make(1.25, 0.00, 0.06) // #ED1C24 boosted
    static let magenta = make(0.72, 0.00, 0.58) // #9A3075 boosted
    static let violet = make(0.22, 0.00, 1.15) // #5535C4 boosted
    static let blue = make(0.00, 0.22, 1.35) // #224DE9 boosted
    static let white = make(3.00, 3.00, 3.00) // HDR white (200 % above SDR)
}

private let hdrGradientStops: [Gradient.Stop] = [
    .init(color: GlowColors.red, location: 0),
    .init(color: GlowColors.magenta, location: 0.274),
    .init(color: GlowColors.violet, location: 0.662),
    .init(color: GlowColors.blue, location: 1)
]

// MARK: - GradientPhaseModifier

// LinearGradient doesn't conform to Animatable; driving it through this
// modifier lets SwiftUI interpolate `phase` on every display-link frame.
private struct GradientPhaseModifier: ViewModifier, Animatable {
    var phase: CGFloat
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func body(content: Content) -> some View {
        content.foregroundStyle(
            LinearGradient(
                stops: hdrGradientStops,
                startPoint: UnitPoint(x: phase, y: 0.5),
                endPoint: UnitPoint(x: phase + 1.0, y: 0.5)
            )
        )
    }
}

// MARK: - Public component

/// Animated HDR glow headline for the Intro / Welcome screen.
///
/// ```swift
/// IntroWelcomeView(text: "Incredible!")
/// ```
///
public struct IntroWelcomeView: View {
    public let text: String

    @Environment(\.colorScheme) private var colorScheme
    @State private var phase: CGFloat = GlowMetrics.phaseStart

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        ZStack(alignment: .center) {
            // Layers 1 & 2 — wide outer glow (stacked for double intensity)
            baseLabel.modifier(GradientPhaseModifier(phase: phase)).blur(radius: GlowMetrics.blurOuter)
            baseLabel.modifier(GradientPhaseModifier(phase: phase)).blur(radius: GlowMetrics.blurOuter)
            // Layer 3 — tight inner edge
            baseLabel.modifier(GradientPhaseModifier(phase: phase)).blur(radius: GlowMetrics.blurInner)
            // Layer 4 — HDR white (dark) / black (light)
            baseLabel.foregroundStyle(labelColor)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: GlowMetrics.animDuration)
                .repeatForever(autoreverses: true)
            ) {
                phase = GlowMetrics.phaseEnd
            }
        }
    }

    private var baseLabel: some View {
        Text(text)
            .font(.system(size: GlowMetrics.fontSize, weight: .bold))
            .tracking(GlowMetrics.tracking)
    }

    private var labelColor: Color {
        colorScheme == .dark ? GlowColors.white : .black
    }
}
