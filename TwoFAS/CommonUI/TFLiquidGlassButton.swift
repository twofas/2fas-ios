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

// MARK: - TFLiquidGlassButton

/// Liquid Glass button — for use in transparent contexts such as navigation bars
/// and overlay toolbars.
///
/// Two content configurations:
/// - **Text** — label in a pill-shaped glass capsule (48 pt tall)
/// - **Symbol** — SF Symbol icon in a glass circle (medium: 48 pt, large: 64 pt)
///
/// Two tint modes:
/// - `tinted: false` — frosted glass background, adaptive label colour
/// - `tinted: true`  — brand-tinted glass background, white label
///
/// A rigid impact haptic fires on press-down.
///
/// ```swift
/// // Text variants
/// TFLiquidGlassButton("Share",   tinted: false) { share() }
/// TFLiquidGlassButton("Sign in", tinted: true)  { signIn() }
///
/// // Symbol variants
/// TFLiquidGlassButton(systemImage: "plus",      size: .medium, tinted: false) { add() }
/// TFLiquidGlassButton(systemImage: "checkmark", size: .large,  tinted: true)  { confirm() }
/// ```
public struct TFLiquidGlassButton: View {
    // MARK: SymbolSize

    /// Hit-target size for the icon-only variant.
    public enum SymbolSize: CGFloat {
        /// 48 × 48 pt circle
        case medium = 48
        /// 64 × 64 pt circle
        case large = 64
        
        var fontSize: CGFloat {
            switch self {
            case .medium: 24
            case .large: 20
            }
        }
    }

    // MARK: Internal content type

    private enum Content {
        case text(String)
        case symbol(String, SymbolSize)
    }

    // MARK: Stored properties

    private let content: Content
    private let tinted: Bool
    private let action: () -> Void

    // MARK: Init – text

    public init(
        _ label: String,
        tinted: Bool,
        action: @escaping () -> Void
    ) {
        self.content = .text(label)
        self.tinted = tinted
        self.action = action
    }

    // MARK: Init – symbol

    public init(
        systemImage: String,
        size: SymbolSize = .medium,
        tinted: Bool,
        action: @escaping () -> Void
    ) {
        self.content = .symbol(systemImage, size)
        self.tinted = tinted
        self.action = action
    }

    // MARK: Body

    public var body: some View {
        Button(action: action) {
            switch content {
            case .text(let label):
                textLabel(label)
            case .symbol(let imageName, let size):
                symbolLabel(imageName, size: size)
            }
        }
        .buttonStyle(_TFPressStyle())
    }

    // MARK: Text label

    @ViewBuilder
    private func textLabel(_ label: String) -> some View {
        Text(label)
            .textStyle(.body, .medium)
            .foregroundStyle(labelColor)
            .padding(.horizontal, .XXL)
            .padding(.vertical, .S) // 4  (nearest to design 6)
            .background(
                Capsule()
                    .fill(glassStyle)
                    .shadow(.glass)
            )
    }

    // MARK: Symbol label

    @ViewBuilder
    private func symbolLabel(_ imageName: String, size: SymbolSize) -> some View {
        let dimension: CGFloat = size.rawValue
        let fontSize: CGFloat  = size.fontSize
        Image(systemName: imageName)
            .font(.system(size: fontSize, weight: .regular))
            .foregroundStyle(labelColor)
            .frame(width: dimension, height: dimension)
            .background(
                Circle()
                    .fill(glassStyle)
                    .shadow(.glass)
            )
    }

    // MARK: Helpers

    /// Frosted glass fill for untinted, brand fill for tinted.
    private var glassStyle: AnyShapeStyle {
        tinted
            ? AnyShapeStyle(AppColor.accentsBrand)
            : AnyShapeStyle(.ultraThinMaterial)
    }

    /// White on brand background; adaptive vibrant label on glass background.
    private var labelColor: AppColor {
        tinted ? .graysWhite : .labelsVibrantControlsPrimary
    }
}
