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
    @Environment(\.colorScheme)
    private var colorScheme
    @Environment(\.isEnabled)
    private var isEnabled

    private let label: String
    private let color: AppColor?
    private let action: () -> Void

    @GestureState
    private var isPressed = false

    public init(
        _ label: String,
        color: AppColor? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.color = color
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            if #available(iOS 26, *) {
                textLabel
                    .padding(.S)
            } else {
                textLabel
                    .padding(.horizontal, .L)
                    .padding(.vertical, .S)
                    .background {
                        Capsule()
                            .fill(fallbackBackground)
                    }
            }
        }
        .modify {
            if #available(iOS 26, *) {
                if color != nil {
                    if isEnabled {
                        $0.tint(color)
                            .buttonStyle(.glassProminent)
                            .buttonBorderShape(.capsule)
                            .shadow(.glass)
                    } else {
                        $0.tint(nil)
                            .buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                            .shadow(.glass)
                    }
                } else {
                    $0.buttonStyle(.glass)
                        .buttonBorderShape(.capsule)
                        .shadow(.glass)
                }
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

    private var textLabel: some View {
        Text(label)
            .textStyle(.body, .medium)
            .foregroundStyle(labelColor)
    }

    private var labelColor: AppColor {
        if !isEnabled { return .labelsVibrantTertiary }
        if color != nil { return .graysWhite }
        return .labelsVibrantPrimary
    }

    /// Non-glass fallback: solid fill on `.glassProminent` case, subtle
    /// `fillsTertiary` on the neutral case; disabled reads as `.fillsTertiary`.
    private var fallbackBackground: AppColor {
        guard isEnabled else { return .fillsTertiary }
        if let color { return color }
        return .fillsTertiary
    }
}

extension View {
    @inlinable
    func modify<T: View>(@ViewBuilder modifier: (Self) -> T) -> T {
        modifier(self)
    }
}
