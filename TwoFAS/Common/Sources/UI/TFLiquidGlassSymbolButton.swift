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

public struct TFLiquidGlassSymbolButton: View {
    public enum Symbol: String {
        case close = "xmark"
        case back = "chevron.left"
    }
    
    private let fontSize: CGFloat = 20
    
    @GestureState
    private var isPressed = false
    private let action: () -> Void
    private let symbol: Symbol
    
    public init(symbol: Symbol, action: @escaping () -> Void) {
        self.symbol = symbol
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: symbol.rawValue)
                .font(.system(size: fontSize, weight: .regular))
                .foregroundStyle(AppColor.labelsVibrantPrimary)
                .padding(.S)
        }
        .modify {
            if #available(iOS 26, *) {
                $0.tint(nil)
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .clipShape(Circle())
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
