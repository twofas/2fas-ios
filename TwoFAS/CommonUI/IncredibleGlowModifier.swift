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

// MARK: - Shader accessor

private extension ShaderLibrary {
    static var incredibleGlow: ShaderFunction { ShaderLibrary.default.incredibleGlow }
}

// MARK: - ViewModifier

/// Adds an animated, multicolour aurora glow behind any view.
///
/// Usage:
/// ```swift
/// Text("Incredible!")
///     .font(.largeTitle.bold())
///     .incredibleGlow()
/// ```
///
/// - Parameters:
///   - glowSize:  Size of the glow layer relative to the wrapped view.
///                Increase to make the halo larger. Default: `CGSize(width: 1.4, height: 3.0)`
///   - blurRadius: Softness of the glow edges (points). Default: `28`.
///   - opacity:   Overall opacity of the glow. Default: `1`.
struct IncredibleGlowModifier: ViewModifier {
    var glowSize: CGSize
    var blurRadius: CGFloat
    var opacity: Double
    
    private let startDate = Date()
    
    init(
        glowSize: CGSize = CGSize(width: 1.4, height: 3.0),
        blurRadius: CGFloat = 28,
        opacity: Double  = 1
    ) {
        self.glowSize   = glowSize
        self.blurRadius = blurRadius
        self.opacity    = opacity
    }
    
    func body(content: Content) -> some View {
        content.background(alignment: .center) {
            TimelineView(.animation) { timeline in
                let elapsed = Float(timeline.date.timeIntervalSince(startDate))
                
                GeometryReader { proxy in
                    let w = proxy.size.width * glowSize.width
                    let h = proxy.size.height * glowSize.height
                    
                    Rectangle()
                        .fill(Color.white)           // source color (overridden by shader)
                        .frame(width: w, height: h)
                        .position(
                            x: proxy.size.width / 2,
                            y: proxy.size.height / 2
                        )
                        .colorEffect(
                            ShaderLibrary.incredibleGlow(
                                .float2(CGSize(width: w, height: h)),
                                .float(elapsed)
                            )
                        )
                        .blur(radius: blurRadius)
                        .blendMode(.screen)
                }
            }
            .opacity(opacity)
        }
    }
}

// MARK: - Convenience modifier

public extension View {
    /// Adds the animated multicolour aurora glow.
    func incredibleGlow(
        glowSize: CGSize = CGSize(width: 1.4, height: 3.0),
        blurRadius: CGFloat = 28,
        opacity: Double  = 1
    ) -> some View {
        modifier(IncredibleGlowModifier(
            glowSize: glowSize,
            blurRadius: blurRadius,
            opacity: opacity
        ))
    }
}
