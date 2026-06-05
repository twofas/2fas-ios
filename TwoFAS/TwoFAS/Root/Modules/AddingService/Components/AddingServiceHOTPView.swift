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
import Common

struct AddingServiceHOTPView: View {
    @Environment(\.colorScheme)
    private var colorScheme
    
    @State
    private var rotationAngle = 0.0
    
    @Binding
    var refreshTokenLocked: Bool
    
    var handleRefresh: () -> Void
    
    var body: some View {
        Button {
            withAnimation(
                .linear(duration: 1)
                .speed(5)
                .repeatCount(1, autoreverses: false)
            ) {
                rotationAngle = 360.0
            }
        } label: {
            Asset.refreshTokenCounter.swiftUIImage
                .tint(
                    Color(
                        refreshTokenLocked ? AppColor.graysGray2.color(for: colorScheme) :
                        AppColor.accentsBrand.color(for: colorScheme)
                    )
                )
                .rotationEffect(.degrees(rotationAngle))
        }
        .disabled(refreshTokenLocked)
        .onAnimationCompleted(for: rotationAngle) {
            rotationAngle = 0
            handleRefresh()
        }
    }
}
