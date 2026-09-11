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

private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - ViewModifier

private struct ShakeModifier: ViewModifier {
    let trigger: Bool
    
    @State private var attempts: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: attempts))
            .onChange(of: trigger) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    attempts += 1
                }
            }
    }
}

// MARK: - View Extension

extension View {
    func shake(on trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}
