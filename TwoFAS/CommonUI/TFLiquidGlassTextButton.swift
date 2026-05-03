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

public struct TFLiquidGlassTextButton: View {
    private let label: String
    private let action: () -> Void

    @GestureState
    private var isPressed = false
    
    public init(
        _ label: String,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(label)
                .textStyle(.body, .medium)
                .foregroundStyle(AppColor.labelsVibrantPrimary)
                .padding(.S)
        }
        .modify {
            if #available(iOS 26, *) {
                $0.tint(nil)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                    .clipShape(Capsule())
                    .shadow(.glass)
            } else {
                $0.buttonStyle(ButtonFeedbackStyle())
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in state = true }
        )
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: isPressed) { _, new in new }
    }
}

extension View {
    @inlinable
    func modify<T: View>(@ViewBuilder modifier: (Self) -> T) -> T {
        modifier(self)
    }
}
