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

// MARK: - TFPinKey

/// A key on the PIN entry pad.
///
/// ```swift
/// TFPinButton(.digit(1)) { handle(.digit(1)) }
/// TFPinButton(.digit(0)) { handle(.digit(0)) }
/// TFPinButton(.delete)   { deleteLast() }
/// ```
public enum TFPinKey: Equatable, Hashable {
    /// A numeric digit — expected range 0 … 9.
    case digit(Int)
    /// The backspace / delete key.
    case delete
    
    public var isNumber: Bool {
        switch self {
        case .digit: true
        case .delete: false
        }
    }
    
    public var isDelete: Bool {
        switch self {
        case .digit: false
        case .delete: true
        }
    }
    
    public var number: Int? {
        switch self {
        case .digit(let int): int
        case .delete: nil
        }
    }
}

// MARK: - TFPinButton

/// PIN pad button — a 64 × 64 pt liquid-glass circle that displays a digit
/// or the delete symbol.
///
/// Visual appearance is identical to
/// `TFLiquidGlassButton(systemImage:size:.large, tinted:false)`.
/// Digit labels use `Title1/Medium` (28 pt); the delete key uses the
/// `delete.backward` SF Symbol at `Title2/Regular` size (22 pt).
/// A rigid impact haptic fires on press-down.
///
/// ```swift
/// TFPinButton(.digit(7)) { handleDigit(7) }
/// TFPinButton(.delete)   { handleDelete() }
/// ```
public struct TFPinButton: View {
    public static let size: CGFloat = 64
    public static let tapInset: CGFloat = 6

    @State
    private var tapCount = 0

    private let key: TFPinKey
    private let action: (TFPinKey) -> Void

    public init(
        _ key: TFPinKey,
        action: @escaping (TFPinKey) -> Void
    ) {
        self.key = key
        self.action = action
    }

    public var body: some View {
        Button(action: {
            tapCount += 1
            action(key)
        }) {
            keyLabel
                .foregroundStyle(AppColor.labelsPrimary)
        }
        .modify {
            if #available(iOS 26, *) {
                $0.buttonStyle(GlassPinPressStyle())
                    .sensoryFeedback(.impact(weight: .light), trigger: tapCount)
            } else {
                $0.buttonStyle(PinPressStyle())
            }
        }
    }

    @available(iOS 26, *)
    private struct GlassPinPressStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: TFPinButton.size, maxHeight: TFPinButton.size)
                .aspectRatio(1, contentMode: .fit)
                .glassEffect(.regular, in: .circle)
                .shadow(.glass)
                .scaleEffect(configuration.isPressed ? 0.82 : 1)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
                .frame(
                    width: TFPinButton.size + TFPinButton.tapInset * 2,
                    height: TFPinButton.size + TFPinButton.tapInset * 2
                )
                .contentShape(Rectangle())
        }
    }

    private struct PinPressStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: TFPinButton.size, maxHeight: TFPinButton.size)
                .aspectRatio(1, contentMode: .fit)
                .background {
                    Circle()
                        .fill(AppColor.backgroundsSecondary)
                        .overlay {
                            if configuration.isPressed {
                                Circle().fill(AppColor.fillsPrimary)
                            }
                        }
                        .animation(.easeInOut, value: configuration.isPressed)
                }
                .sensoryFeedback(
                    .impact(flexibility: .rigid, intensity: 0.6),
                    trigger: configuration.isPressed
                ) { _, new in new }
                .frame(
                    width: TFPinButton.size + TFPinButton.tapInset * 2,
                    height: TFPinButton.size + TFPinButton.tapInset * 2
                )
                .contentShape(Rectangle())
        }
    }

    // MARK: Content

    @ViewBuilder
    private var keyLabel: some View {
        switch key {
        case .digit(let n):
            // Title1/Medium — 28 pt, weight 510, tracking +0.38
            Text(verbatim: "\(n)")
                .textStyle(.title1, .medium)
        case .delete:
            // Title2/Regular — 22 pt, weight 400
            Image(systemName: "delete.backward")
                .font(.system(size: 22, weight: .regular))
        }
    }
}
