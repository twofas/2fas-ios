import SwiftUI

// MARK: - AppColor

/// All color tokens from the 2FAS Design System (Pass_colors.json).
///
/// `AppColor` conforms to `ShapeStyle`, so it can be used anywhere SwiftUI
/// accepts a style — and it automatically adapts to light / dark mode.
///
/// ```swift
/// Text("Hello")
///     .foregroundStyle(AppColor.labelsPrimary)
///
/// Rectangle()
///     .fill(AppColor.accentsBrand)
///
/// view.background(AppColor.backgroundsPrimary)
/// view.tint(AppColor.accentsBlue)
/// ```
///
/// When you need a plain `Color` (e.g. to pass to an API):
/// ```swift
/// @Environment(\.colorScheme) var colorScheme
/// let c: Color = AppColor.labelsPrimary.color(for: colorScheme)
/// ```
public enum AppColor: CaseIterable {

    // MARK: Labels
    case labelsPrimary
    case labelsSecondary
    case labelsTertiary
    case labelsQuaternary

    // MARK: Labels – Vibrant
    case labelsVibrantPrimary
    case labelsVibrantSecondary
    case labelsVibrantTertiary
    case labelsVibrantQuaternary

    // MARK: Labels – Vibrant Controls
    case labelsVibrantControlsPrimary
    case labelsVibrantControlsSecondary
    case labelsVibrantControlsTertiary

    // MARK: Accents
    case accentsBlue
    case accentsBrand
    case accentsOrange
    case accentsYellow
    case accentsGreen
    case accentsMint
    case accentsTeal
    case accentsCyan
    case accentsBrown
    case accentsIndigo
    case accentsPurple
    case accentsPink

    // MARK: Backgrounds
    case backgroundsPrimary
    case backgroundsSecondary
    case backgroundsTertiary
    case backgroundsPrimaryElevated
    case backgroundsSecondaryElevated
    case backgroundsTertiaryElevated

    // MARK: Backgrounds – Grouped
    case backgroundsGroupedPrimary
    case backgroundsGroupedSecondary
    case backgroundsGroupedTertiary
    case backgroundsGroupedPrimaryElevated
    case backgroundsGroupedSecondaryElevated
    case backgroundsGroupedTertiaryElevated

    // MARK: Fills
    case fillsPrimary
    case fillsSecondary
    case fillsTertiary
    case fillsQuaternary

    // MARK: Fills – Vibrant
    case fillsVibrantPrimary
    case fillsVibrantSecondary
    case fillsVibrantTertiary

    // MARK: Separators
    case separatorsOpaque
    case separatorsNonOpaque
    case separatorsVibrant

    // MARK: Grays
    case graysBlack
    case graysWhite
    case graysGray
    case graysGray2
    case graysGray3
    case graysGray4
    case graysGray5
    case graysGray6

    // MARK: Overlays
    case overlaysDefault
    case overlaysActivityViewController
    case overlaysLGFill

    // MARK: Borders
    case bordersPrimary
    case bordersVibrant
}

// MARK: - ShapeStyle

/// `AppColor` is a first-class SwiftUI `ShapeStyle`.
/// It reads the current `colorScheme` from the environment and resolves
/// to the correct light or dark value automatically.
extension AppColor: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        environment.colorScheme == .dark ? darkColor : lightColor
    }
}

// MARK: - Color accessors

public extension AppColor {
    /// Fixed light-mode `Color` (non-adaptive).
    var lightColor: Color { light }

    /// Fixed dark-mode `Color` (non-adaptive).
    var darkColor: Color { dark }

    /// Adaptive `Color` resolved for the given `ColorScheme`.
    ///
    /// Use when a plain `Color` is required and you have access
    /// to the current color scheme from the environment.
    func color(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkColor : lightColor
    }
}

// MARK: - View convenience
//
// Concrete `AppColor` overloads let Swift infer the type from the method
// signature, enabling the short dot syntax at call sites:
//
//   Text("Hello").foregroundStyle(.labelsPrimary)
//   view.background(.backgroundsSecondary)
//   view.tint(.accentsBlue)
//   Rectangle().fill(.accentsBrand)
//   Circle().stroke(.separatorsOpaque, lineWidth: 1)
//
// `AnyShapeStyle` erases the concrete type so the call inside each helper
// dispatches to SwiftUI's generic overload instead of looping back.

public extension View {
    func foregroundStyle(_ token: AppColor) -> some View {
        foregroundStyle(AnyShapeStyle(token))
    }

    func background(_ token: AppColor) -> some View {
        background(AnyShapeStyle(token))
    }

    func tint(_ token: AppColor) -> some View {
        tint(AnyShapeStyle(token))
    }

    func border(_ token: AppColor, width: CGFloat = 1) -> some View {
        overlay(Rectangle().stroke(AnyShapeStyle(token), lineWidth: width))
    }
}

public extension Shape {
    func fill(_ token: AppColor) -> some View {
        fill(AnyShapeStyle(token))
    }

    func stroke(_ token: AppColor, lineWidth: CGFloat = 1) -> some View {
        stroke(AnyShapeStyle(token), lineWidth: lineWidth)
    }
}

}

// MARK: - Raw values

private extension AppColor {

    var light: Color {
        switch self {
        // Labels
        case .labelsPrimary: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
        case .labelsSecondary: Color(.sRGB, red: 0.2353, green: 0.2353, blue: 0.2627, opacity: 0.7)
        case .labelsTertiary: Color(.sRGB, red: 0.2353, green: 0.2353, blue: 0.2627, opacity: 0.3)
        case .labelsQuaternary: Color(.sRGB, red: 0.2353, green: 0.2353, blue: 0.2627, opacity: 0.18)
        // Labels – Vibrant
        case .labelsVibrantPrimary: Color(.sRGB, red: 0.102, green: 0.102, blue: 0.102, opacity: 1)
        case .labelsVibrantSecondary: Color(.sRGB, red: 0.4471, green: 0.4471, blue: 0.4471, opacity: 1)
        case .labelsVibrantTertiary: Color(.sRGB, red: 0.749, green: 0.749, blue: 0.749, opacity: 1)
        case .labelsVibrantQuaternary: Color(.sRGB, red: 0.851, green: 0.851, blue: 0.851, opacity: 1)
        // Labels – Vibrant Controls
        case .labelsVibrantControlsPrimary: Color(.sRGB, red: 0.102, green: 0.102, blue: 0.102, opacity: 1)
        case .labelsVibrantControlsSecondary: Color(.sRGB, red: 0.4471, green: 0.4471, blue: 0.4471, opacity: 1)
        case .labelsVibrantControlsTertiary: Color(.sRGB, red: 0.749, green: 0.749, blue: 0.749, opacity: 1)
        // Accents
        case .accentsBlue: Color(.sRGB, red: 0, green: 0.5333, blue: 1, opacity: 1)
        case .accentsBrand: Color(.sRGB, red: 0.8941, green: 0.1098, blue: 0.1333, opacity: 1)
        case .accentsOrange: Color(.sRGB, red: 1, green: 0.5529, blue: 0.1569, opacity: 1)
        case .accentsYellow: Color(.sRGB, red: 1, green: 0.8, blue: 0, opacity: 1)
        case .accentsGreen: Color(.sRGB, red: 0.2039, green: 0.7804, blue: 0.349, opacity: 1)
        case .accentsMint: Color(.sRGB, red: 0, green: 0.7843, blue: 0.702, opacity: 1)
        case .accentsTeal: Color(.sRGB, red: 0, green: 0.7647, blue: 0.8157, opacity: 1)
        case .accentsCyan: Color(.sRGB, red: 0, green: 0.7529, blue: 0.9098, opacity: 1)
        case .accentsBrown: Color(.sRGB, red: 0.6745, green: 0.498, blue: 0.3686, opacity: 1)
        case .accentsIndigo: Color(.sRGB, red: 0.3804, green: 0.3333, blue: 0.9608, opacity: 1)
        case .accentsPurple: Color(.sRGB, red: 0.7961, green: 0.1882, blue: 0.8784, opacity: 1)
        case .accentsPink: Color(.sRGB, red: 1, green: 0.1765, blue: 0.3333, opacity: 1)
        // Backgrounds
        case .backgroundsPrimary: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        case .backgroundsSecondary: Color(.sRGB, red: 0.949, green: 0.949, blue: 0.9686, opacity: 1)
        case .backgroundsTertiary: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        case .backgroundsPrimaryElevated: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        case .backgroundsSecondaryElevated: Color(.sRGB, red: 0.949, green: 0.949, blue: 0.9686, opacity: 1)
        case .backgroundsTertiaryElevated: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        // Backgrounds – Grouped
        case .backgroundsGroupedPrimary: Color(.sRGB, red: 0.949, green: 0.949, blue: 0.9686, opacity: 1)
        case .backgroundsGroupedSecondary: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        case .backgroundsGroupedTertiary: Color(.sRGB, red: 0.949, green: 0.949, blue: 0.9686, opacity: 1)
        case .backgroundsGroupedPrimaryElevated: Color(.sRGB, red: 0.949, green: 0.949, blue: 0.9686, opacity: 1)
        case .backgroundsGroupedSecondaryElevated: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        case .backgroundsGroupedTertiaryElevated: Color(.sRGB, red: 0.949, green: 0.949, blue: 0.9686, opacity: 1)
        // Fills
        case .fillsPrimary: Color(.sRGB, red: 0.4706, green: 0.4706, blue: 0.4706, opacity: 0.2)
        case .fillsSecondary: Color(.sRGB, red: 0.4706, green: 0.4706, blue: 0.502, opacity: 0.16)
        case .fillsTertiary: Color(.sRGB, red: 0.4627, green: 0.4627, blue: 0.502, opacity: 0.12)
        case .fillsQuaternary: Color(.sRGB, red: 0.4549, green: 0.4549, blue: 0.502, opacity: 0.08)
        // Fills – Vibrant
        case .fillsVibrantPrimary: Color(.sRGB, red: 0.8, green: 0.8, blue: 0.8, opacity: 1)
        case .fillsVibrantSecondary: Color(.sRGB, red: 0.8784, green: 0.8784, blue: 0.8784, opacity: 1)
        case .fillsVibrantTertiary: Color(.sRGB, red: 0.9294, green: 0.9294, blue: 0.9294, opacity: 1)
        // Separators
        case .separatorsOpaque: Color(.sRGB, red: 0.7765, green: 0.7765, blue: 0.7843, opacity: 1)
        case .separatorsNonOpaque: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.12)
        case .separatorsVibrant: Color(.sRGB, red: 0.902, green: 0.902, blue: 0.902, opacity: 1)
        // Grays
        case .graysBlack: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
        case .graysWhite: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        case .graysGray: Color(.sRGB, red: 0.5569, green: 0.5569, blue: 0.5765, opacity: 1)
        case .graysGray2: Color(.sRGB, red: 0.6824, green: 0.6824, blue: 0.698, opacity: 1)
        case .graysGray3: Color(.sRGB, red: 0.7804, green: 0.7804, blue: 0.8, opacity: 1)
        case .graysGray4: Color(.sRGB, red: 0.8196, green: 0.8196, blue: 0.8392, opacity: 1)
        case .graysGray5: Color(.sRGB, red: 0.898, green: 0.898, blue: 0.9176, opacity: 1)
        case .graysGray6: Color(.sRGB, red: 0.949, green: 0.949, blue: 0.9686, opacity: 1)
        // Overlays
        case .overlaysDefault: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.4)
        case .overlaysActivityViewController: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.2)
        case .overlaysLGFill: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.02)
        // Borders
        case .bordersPrimary: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 0.16)
        case .bordersVibrant: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 0.2)
        }
    }

    var dark: Color {
        switch self {
        // Labels
        case .labelsPrimary: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        case .labelsSecondary: Color(.sRGB, red: 0.9216, green: 0.9216, blue: 0.9608, opacity: 0.8)
        case .labelsTertiary: Color(.sRGB, red: 0.9216, green: 0.9216, blue: 0.9608, opacity: 0.3)
        case .labelsQuaternary: Color(.sRGB, red: 0.9216, green: 0.9216, blue: 0.9608, opacity: 0.16)
        // Labels – Vibrant
        case .labelsVibrantPrimary: Color(.sRGB, red: 0.9608, green: 0.9608, blue: 0.9608, opacity: 1)
        case .labelsVibrantSecondary: Color(.sRGB, red: 0.5412, green: 0.5412, blue: 0.5412, opacity: 1)
        case .labelsVibrantTertiary: Color(.sRGB, red: 0.251, green: 0.251, blue: 0.251, opacity: 1)
        case .labelsVibrantQuaternary: Color(.sRGB, red: 0.149, green: 0.149, blue: 0.149, opacity: 1)
        // Labels – Vibrant Controls
        case .labelsVibrantControlsPrimary: Color(.sRGB, red: 0.9608, green: 0.9608, blue: 0.9608, opacity: 1)
        case .labelsVibrantControlsSecondary: Color(.sRGB, red: 0.5412, green: 0.5412, blue: 0.5412, opacity: 1)
        case .labelsVibrantControlsTertiary: Color(.sRGB, red: 0.251, green: 0.251, blue: 0.251, opacity: 1)
        // Accents
        case .accentsBlue: Color(.sRGB, red: 0, green: 0.5686, blue: 1, opacity: 1)
        case .accentsBrand: Color(.sRGB, red: 0.8941, green: 0.1098, blue: 0.1333, opacity: 1)
        case .accentsOrange: Color(.sRGB, red: 1, green: 0.5725, blue: 0.1882, opacity: 1)
        case .accentsYellow: Color(.sRGB, red: 1, green: 0.8392, blue: 0, opacity: 1)
        case .accentsGreen: Color(.sRGB, red: 0.1882, green: 0.8196, blue: 0.3451, opacity: 1)
        case .accentsMint: Color(.sRGB, red: 0, green: 0.8549, blue: 0.7647, opacity: 1)
        case .accentsTeal: Color(.sRGB, red: 0, green: 0.8235, blue: 0.8784, opacity: 1)
        case .accentsCyan: Color(.sRGB, red: 0.2353, green: 0.8275, blue: 0.9961, opacity: 1)
        case .accentsBrown: Color(.sRGB, red: 0.7176, green: 0.5412, blue: 0.4, opacity: 1)
        case .accentsIndigo: Color(.sRGB, red: 0.4275, green: 0.4863, blue: 1, opacity: 1)
        case .accentsPurple: Color(.sRGB, red: 0.8588, green: 0.2039, blue: 0.949, opacity: 1)
        case .accentsPink: Color(.sRGB, red: 1, green: 0.2157, blue: 0.3725, opacity: 1)
        // Backgrounds
        case .backgroundsPrimary: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
        case .backgroundsSecondary: Color(.sRGB, red: 0.1098, green: 0.1098, blue: 0.1176, opacity: 1)
        case .backgroundsTertiary: Color(.sRGB, red: 0.1725, green: 0.1725, blue: 0.1804, opacity: 1)
        case .backgroundsPrimaryElevated: Color(.sRGB, red: 0.1098, green: 0.1098, blue: 0.1176, opacity: 1)
        case .backgroundsSecondaryElevated: Color(.sRGB, red: 0.1725, green: 0.1725, blue: 0.1804, opacity: 1)
        case .backgroundsTertiaryElevated: Color(.sRGB, red: 0.2275, green: 0.2275, blue: 0.2353, opacity: 1)
        // Backgrounds – Grouped
        case .backgroundsGroupedPrimary: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
        case .backgroundsGroupedSecondary: Color(.sRGB, red: 0.1098, green: 0.1098, blue: 0.1176, opacity: 1)
        case .backgroundsGroupedTertiary: Color(.sRGB, red: 0.1725, green: 0.1725, blue: 0.1804, opacity: 1)
        case .backgroundsGroupedPrimaryElevated: Color(.sRGB, red: 0.1098, green: 0.1098, blue: 0.1176, opacity: 1)
        case .backgroundsGroupedSecondaryElevated: Color(.sRGB, red: 0.1725, green: 0.1725, blue: 0.1804, opacity: 1)
        case .backgroundsGroupedTertiaryElevated: Color(.sRGB, red: 0.2275, green: 0.2275, blue: 0.2353, opacity: 1)
        // Fills
        case .fillsPrimary: Color(.sRGB, red: 0.4706, green: 0.4706, blue: 0.502, opacity: 0.36)
        case .fillsSecondary: Color(.sRGB, red: 0.4706, green: 0.4706, blue: 0.502, opacity: 0.32)
        case .fillsTertiary: Color(.sRGB, red: 0.4627, green: 0.4627, blue: 0.502, opacity: 0.24)
        case .fillsQuaternary: Color(.sRGB, red: 0.4627, green: 0.4627, blue: 0.502, opacity: 0.18)
        // Fills – Vibrant
        case .fillsVibrantPrimary: Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2, opacity: 1)
        case .fillsVibrantSecondary: Color(.sRGB, red: 0.1216, green: 0.1216, blue: 0.1216, opacity: 1)
        case .fillsVibrantTertiary: Color(.sRGB, red: 0.0706, green: 0.0706, blue: 0.0706, opacity: 1)
        // Separators
        case .separatorsOpaque: Color(.sRGB, red: 0.2196, green: 0.2196, blue: 0.2275, opacity: 1)
        case .separatorsNonOpaque: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 0.08)
        case .separatorsVibrant: Color(.sRGB, red: 0.102, green: 0.102, blue: 0.102, opacity: 1)
        // Grays
        case .graysBlack: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
        case .graysWhite: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        case .graysGray: Color(.sRGB, red: 0.5569, green: 0.5569, blue: 0.5765, opacity: 1)
        case .graysGray2: Color(.sRGB, red: 0.3882, green: 0.3882, blue: 0.4, opacity: 1)
        case .graysGray3: Color(.sRGB, red: 0.2824, green: 0.2824, blue: 0.2902, opacity: 1)
        case .graysGray4: Color(.sRGB, red: 0.2275, green: 0.2275, blue: 0.2353, opacity: 1)
        case .graysGray5: Color(.sRGB, red: 0.1725, green: 0.1725, blue: 0.1804, opacity: 1)
        case .graysGray6: Color(.sRGB, red: 0.1098, green: 0.1098, blue: 0.1176, opacity: 1)
        // Overlays
        case .overlaysDefault: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.6)
        case .overlaysActivityViewController: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.29)
        case .overlaysLGFill: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.2)
        // Borders
        case .bordersPrimary: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 0.12)
        case .bordersVibrant: Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 0.2)
        }
    }
}
