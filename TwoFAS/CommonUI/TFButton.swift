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

// MARK: - TFButtonSize

/// Size variants from the 2FAS button design system.
@frozen
public enum TFButtonSize {
    /// 28 pt hit target, 15 pt semibold label
    case small
    /// 36 pt hit target, 17 pt medium label
    case medium
    /// 48 pt hit target, 17 pt medium label
    case large
}

// MARK: - TFButtonVariant

/// Visual style of the button.
///
/// | Variant | Background (enabled) | Label (enabled) |
/// |---|---|---|
/// | `borderedProminent` | `accentsBrand` | `graysWhite` |
/// | `bordered` | `fillsTertiary` | `accentsBrand` |
/// | `borderedSecondary` | `fillsTertiary` | `labelsPrimary` |
/// | `borderless` | clear | `accentsBrand` |
/// | `borderlessNeutral` | clear | `labelsPrimary` |
///
/// Disabled state: label → `labelsTertiary`; filled-variant background → `fillsTertiary`.
@frozen
public enum TFButtonVariant {
    case borderedProminent
    case bordered
    case borderedSecondary
    case borderless
    case borderlessNeutral
}

// MARK: - TFButton

/// 2FAS Design System button.
///
/// Three content configurations:
/// - **Text** — label string only
/// - **Symbol** — SF Symbol icon in a circle
/// - **Symbol + Text** — icon followed by label in a capsule
///
/// The button adapts automatically to `@Environment(\.isEnabled)` for the
/// disabled state. A light haptic is fired on press-down via `SensoryFeedback`.
///
/// ```swift
/// // Text-only
/// TFButton("Play", variant: .borderedProminent, size: .large) { play() }
/// TFButton("Edit", variant: .bordered, size: .medium) { edit() }
/// TFButton("Info", variant: .borderless, size: .small)  { info() }
///
/// // Symbol-only (circular)
/// TFButton(systemImage: "play.fill", variant: .borderedProminent, size: .large) { }
///
/// // Symbol + text
/// TFButton(systemImage: "play.fill", "Play", variant: .bordered, size: .large) { }
///
/// // Disabled
/// TFButton("Save", variant: .borderedProminent, size: .large) { save() }
///     .disabled(true)
/// ```
public struct TFButton: View {

    private let label: String?
    private let systemImage: String?
    private let variant: TFButtonVariant
    private let size: TFButtonSize
    private let action: () -> Void

    // MARK: Init – text only

    public init(
        _ label: String,
        variant: TFButtonVariant,
        size: TFButtonSize,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.systemImage = nil
        self.variant = variant
        self.size = size
        self.action = action
    }

    // MARK: Init – symbol only

    public init(
        systemImage: String,
        variant: TFButtonVariant,
        size: TFButtonSize,
        action: @escaping () -> Void
    ) {
        self.label = nil
        self.systemImage = systemImage
        self.variant = variant
        self.size = size
        self.action = action
    }

    // MARK: Init – symbol + text

    public init(
        systemImage: String,
        _ label: String,
        variant: TFButtonVariant,
        size: TFButtonSize,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.systemImage = systemImage
        self.variant = variant
        self.size = size
        self.action = action
    }

    // MARK: Body

    public var body: some View {
        Button(action: action) {
            _TFButtonLabel(
                label: label,
                systemImage: systemImage,
                variant: variant,
                size: size
            )
        }
        .buttonStyle(_TFPressStyle())
    }
}

// MARK: - _TFButtonLabel

private struct _TFButtonLabel: View {
    let label: String?
    let systemImage: String?
    let variant: TFButtonVariant
    let size: TFButtonSize

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        switch (systemImage, label) {
        case (let img?, nil): symbolOnly(img)
        case (nil, let lbl?): textOnly(lbl)
        case (let img?, let lbl?): symbolAndText(img, lbl)
        default: EmptyView()
        }
    }

    // MARK: Symbol-only (circular)

    @ViewBuilder
    private func symbolOnly(_ imageName: String) -> some View {
        Image(systemName: imageName)
            .font(symbolFont)
            .foregroundStyle(labelColor)
            .frame(width: symbolDimension, height: symbolDimension)
            .background {
                Circle()
                    .fill(backgroundStyle)
            }
    }

    // MARK: Text-only

    @ViewBuilder
    private func textOnly(_ text: String) -> some View {
        Text(text)
            .textStyle(textStyleSize, textStyleWeight)
            .foregroundStyle(labelColor)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(textBackground)
    }

    // MARK: Symbol + text

    @ViewBuilder
    private func symbolAndText(_ imageName: String, _ text: String) -> some View {
        HStack(spacing: iconSpacing) {
            Image(systemName: imageName)
                .font(symbolFont)
            Text(text)
                .textStyle(textStyleSize, textStyleWeight)
        }
        .foregroundStyle(labelColor)
        .padding(.horizontal, hPad)
        .padding(.vertical, vPad)
        .background {
            Capsule()
                .fill(backgroundStyle)
        }
    }

    // MARK: Background helpers

    /// Borderless/Large uses a rounded rect; every other combination uses a capsule.
    @ViewBuilder
    private var textBackground: some View {
        if (variant == .borderless || variant == .borderlessNeutral) && size == .large {
            RoundedRectangle(.medium)
                .fill(backgroundStyle)
        } else {
            Capsule()
                .fill(backgroundStyle)
        }
    }

    // MARK: Colors

    private var labelColor: AppColor {
        guard isEnabled else { return .labelsTertiary }
        switch variant {
        case .borderedProminent: return .graysWhite
        case .bordered, .borderless: return .accentsBrand
        case .borderedSecondary, .borderlessNeutral: return .labelsPrimary
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        guard isEnabled else {
            switch variant {
            case .borderless, .borderlessNeutral: return AnyShapeStyle(Color.clear)
            default: return AnyShapeStyle(AppColor.fillsTertiary)
            }
        }
        switch variant {
        case .borderedProminent: return AnyShapeStyle(AppColor.accentsBrand)
        case .bordered, .borderedSecondary: return AnyShapeStyle(AppColor.fillsTertiary)
        case .borderless, .borderlessNeutral: return AnyShapeStyle(Color.clear)
        }
    }

    // MARK: Metrics

    private var symbolDimension: CGFloat {
        switch size {
        case .small: 28
        case .medium: 34
        case .large: 48
        }
    }

    /// Font used for the SF Symbol in standalone (icon-only) buttons.
    private var symbolFont: Font {
        switch size {
        case .small, .medium: return .system(size: 15, weight: .regular)
        case .large: return .system(size: 17, weight: .regular)
        }
    }

    private var textStyleSize: TextStyle {
        switch size {
        case .small: .subheadline
        case .medium, .large: .body
        }
    }

    private var textStyleWeight: TextStyleVariant {
        switch size {
        case .small: .emphasized // semibold
        case .medium, .large: .medium
        }
    }

    private var hPad: Spacing {
        switch size {
        case .small: .M // 8  (nearest to design 10)
        case .medium: .L // 12 (nearest to design 14)
        case .large: .XXL
        }
    }

    private var vPad: Spacing {
        switch size {
        case .small: .S
        case .medium: .M // 8  (nearest to design 7)
        case .large: .L // 12 (nearest to design 14)
        }
    }

    private var iconSpacing: Spacing {
        switch size {
        case .small: .XS  // 2 (nearest to design 3)
        case .medium, .large: .S
        }
    }
}
