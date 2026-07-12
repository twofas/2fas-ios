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

// MARK: - TFListScreen

/// A scrollable list container matching the 2FAS Settings design system.
///
/// Stacks `TFListSection`s (or arbitrary content) with 24 pt vertical spacing
/// and the standard horizontal / bottom insets. Sits on
/// `.backgroundsPrimaryElevated` and is meant to be composed underneath a
/// `TFScreenTitleBar`.
public struct TFListScreen<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: .XXXL) {
                content
            }
            .padding(.horizontal, .XL)
            .padding(.top, .M)
            .padding(.bottom, .XXXL)
        }
        .background(AppColor.backgroundsPrimaryElevated)
    }
}

// MARK: - TFListSection

/// A grouped section with optional header/footer and the standard
/// `.groupedSectionBackground()` card around its rows.
///
/// Rows are provided via `@ViewBuilder`. To render separators between
/// rows, use `TFListSeparator` between them.
public struct TFListSection<Content: View>: View {
    private let title: String?
    private let footer: String?
    private let content: Content

    public init(
        title: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if let title {
                TFListSectionHeader(title)
            }

            VStack(alignment: .leading, spacing: .zero) {
                content
            }
            .groupedSectionBackground()

            if let footer {
                TFListSectionFooter(footer)
            }
        }
    }
}

// MARK: - TFListSectionHeader

/// Section header text — headline weight, secondary label color.
public struct TFListSectionHeader: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .textStyle(.headline)
            .foregroundStyle(AppColor.labelsSecondary)
            .accessibilityAddTraits(.isHeader)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, .ML)
            .padding(.horizontal, .XL)
    }
}

// MARK: - TFListSectionFooter

/// Section footer text — tight footnote, secondary label color.
public struct TFListSectionFooter: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .textStyle(.footnote, .regular, .tight)
            .foregroundStyle(AppColor.labelsSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, .M)
            .padding(.horizontal, .XL)
    }
}

// MARK: - TFListSeparator

/// A row separator inside a `TFListSection`. Set `hasLeadingIcon` to inset
/// the divider past the standard 28 pt icon + `.ML` spacing when the
/// preceding row uses a leading icon (`BrandIconTile` / `GradientIconTile`).
public struct TFListSeparator: View {
    private let hasLeadingIcon: Bool

    public init(hasLeadingIcon: Bool = false) {
        self.hasLeadingIcon = hasLeadingIcon
    }

    /// Standard 28 pt icon tile + 10 pt HStack spacing.
    public static let iconLeadingInset: CGFloat = 28 + Spacing.ML.value

    public var body: some View {
        Divider()
            .foregroundStyle(AppColor.separatorsNonOpaque)
            .padding(.leading, hasLeadingIcon ? Self.iconLeadingInset : 0)
    }
}

// MARK: - TFListMenuRow

#if os(iOS)
/// Standard row for opening a pop-up menu picker inside a `TFListSection`.
///
/// Renders as:
/// `[title (labelsPrimary) ────────── currentValue (labelsSecondary) ⇅]`
///
/// The `content` builder supplies the menu's items — typically a `Picker`
/// bound to a selection.
///
/// ```swift
/// TFListMenuRow(title: "Algorithm", value: selectedAlgorithm.rawValue) {
///     Picker(selection: $algorithm) {
///         ForEach(Algorithm.allCases, id: \.self) {
///             Text($0.rawValue).tag($0)
///         }
///     } label: { EmptyView() }
/// }
/// ```
public struct TFListMenuRow<MenuContent: View>: View {
    private let title: String
    private let value: String
    private let content: MenuContent

    public init(
        title: String,
        value: String,
        @ViewBuilder content: () -> MenuContent
    ) {
        self.title = title
        self.value = value
        self.content = content()
    }

    public var body: some View {
        Menu {
            content
        } label: {
            HStack(spacing: .ML) {
                Text(title)
                    .textStyle(.body)
                    .foregroundStyle(AppColor.labelsPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(value)
                    .textStyle(.body)
                    .foregroundStyle(AppColor.labelsSecondary)

                Image(systemName: "chevron.up.chevron.down")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.labelsSecondary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, .L)
            .contentShape(Rectangle())
        }
    }
}
#endif

// MARK: - TFScreenTitleBar

/// Internal SwiftUI navigation bar for screens that use
/// `NavigationBarHiddenHostingController`. Provides:
/// - Optional leading back button (`.back` symbol) via `onBack`
/// - Centered `TFTitleView`
/// - Optional trailing accessory
public struct TFScreenTitleBar<Trailing: View>: View {
    private let title: String
    private let leadingSymbol: TFLiquidGlassSymbolButton.Symbol?
    private let onLeadingTap: (() -> Void)?
    private let trailing: Trailing

    public init(
        title: String,
        leadingSymbol: TFLiquidGlassSymbolButton.Symbol? = .back,
        onLeadingTap: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.leadingSymbol = leadingSymbol
        self.onLeadingTap = onLeadingTap
        self.trailing = trailing()
    }

    public init(
        title: String,
        leadingSymbol: TFLiquidGlassSymbolButton.Symbol? = .back,
        onLeadingTap: (() -> Void)? = nil
    ) where Trailing == EmptyView {
        self.title = title
        self.leadingSymbol = leadingSymbol
        self.onLeadingTap = onLeadingTap
        self.trailing = EmptyView()
    }

    /// Convenience initializer preserving the older `showsBackButton` API.
    public init(
        title: String,
        showsBackButton: Bool,
        onBack: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.leadingSymbol = showsBackButton ? .back : nil
        self.onLeadingTap = onBack
        self.trailing = trailing()
    }

    public init(
        title: String,
        showsBackButton: Bool,
        onBack: (() -> Void)? = nil
    ) where Trailing == EmptyView {
        self.title = title
        self.leadingSymbol = showsBackButton ? .back : nil
        self.onLeadingTap = onBack
        self.trailing = EmptyView()
    }

    public var body: some View {
        ZStack {
            HStack(spacing: .zero) {
                if let leadingSymbol, let onLeadingTap {
                    TFLiquidGlassSymbolButton(symbol: leadingSymbol, action: onLeadingTap)
                }
                Spacer()
                trailing
            }
            TFTitleView(title: title)
        }
        .padding(.horizontal, .XXXL)
        .padding(.top, .XL)
        .padding(.bottom, .XL)
        .frame(alignment: .top)
    }
}
