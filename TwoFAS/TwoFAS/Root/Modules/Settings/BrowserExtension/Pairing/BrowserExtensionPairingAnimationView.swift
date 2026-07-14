//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
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

struct BrowserExtensionPairingAnimationView: View {
    private let size: CGFloat = 500

    private let orbits: [Orbit] = [
        Orbit(image: Asset.pairingOval0.image, offset: .zero, rotationSpeed: 5),
        Orbit(image: Asset.pairingOval1.image, offset: CGPoint(x: 55, y: 55), rotationSpeed: 2),
        Orbit(image: Asset.pairingOval2.image, offset: CGPoint(x: 0, y: 140), rotationSpeed: 0.9),
        Orbit(image: Asset.pairingOval3.image, offset: CGPoint(x: 108, y: 75), rotationSpeed: 0.9),
        Orbit(image: Asset.pairingOval3.image, offset: CGPoint(x: -168, y: -168), rotationSpeed: 0.9)
    ]

    var body: some View {
        ZStack {
            Image(uiImage: Asset.pairingBackgroundOval1.image)
                .renderingMode(.template)
                .foregroundStyle(Color(Theme.Colors.Line.secondaryLine))

            Image(uiImage: Asset.pairingBackgroundOval2.image)
                .renderingMode(.template)
                .foregroundStyle(Color(Theme.Colors.Line.secondaryLine))

            ForEach(orbits.indices, id: \.self) { index in
                RotatingOrbit(orbit: orbits[index], containerSize: size)
            }
        }
        .frame(width: size, height: size)
        .background(Color(Theme.Colors.Fill.background))
    }
}

private struct Orbit {
    let image: UIImage
    let offset: CGPoint
    let rotationSpeed: CGFloat
}

private struct RotatingOrbit: View {
    let orbit: Orbit
    let containerSize: CGFloat

    @State private var rotation: Double = 0

    var body: some View {
        Image(uiImage: orbit.image)
            .renderingMode(.template)
            .foregroundStyle(Color(Theme.Colors.Fill.theme))
            .offset(x: orbit.offset.x, y: orbit.offset.y)
            .frame(width: containerSize, height: containerSize)
            .rotationEffect(.radians(rotation))
            .onAppear {
                let duration = (Double.pi * 2.0) / Double(orbit.rotationSpeed)
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    rotation = .pi * 2.0
                }
            }
    }
}

#Preview {
    BrowserExtensionPairingAnimationView()
}
