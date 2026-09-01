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

/// How a `SheetContent` resolves the sheet height.
enum SheetSizing {
    /// The sheet height follows the content: in compact width the sheet gets a detent equal
    /// to the measured content height; in regular width it becomes a centered form sheet
    /// fitted vertically to the content.
    case fitContent
    /// The sheet keeps the system frame (the `.large` detent, or a centered form sheet in
    /// regular width); the content stretches to the visible viewport so it can center
    /// itself with `Spacer`s.
    case fillViewport
}

private struct PresentedFromRegularWidthKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Whether the sheet's presenting context is regular-width. Inside a sheet the system
    /// `horizontalSizeClass` reads compact even on a full-screen iPad, so the presenting
    /// view injects its own width class via `presentedFromRegularWidth(_:)`.
    var presentedFromRegularWidth: Bool {
        get { self[PresentedFromRegularWidthKey.self] }
        set { self[PresentedFromRegularWidthKey.self] = newValue }
    }
}

extension View {
    /// Marks SwiftUI-presented sheet content with the presenting view's width class — apply
    /// inside the `.sheet` closure, passing `horizontalSizeClass == .regular` read from the
    /// presenting view's environment. Sheets presented from UIKit manage regular width
    /// themselves and leave the default (compact).
    func presentedFromRegularWidth(_ isRegularWidth: Bool) -> some View {
        environment(\.presentedFromRegularWidth, isRegularWidth)
    }

    /// Marks `SheetContent` presented through SwiftUI's `.popover` — the popover takes the
    /// content's ideal size, so the component sizes itself to the given width and to the
    /// measured content height instead of applying sheet presentation sizing. The compact
    /// adaptation (iPhone) still becomes the content-height bottom sheet.
    func presentedInPopover(width: CGFloat = Theme.Metrics.popoverPreferredWidth) -> some View {
        environment(\.presentedInPopoverWidth, width)
    }
}

private struct PresentedInPopoverWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

extension EnvironmentValues {
    /// Width of the popover this sheet content is presented in; nil outside popovers.
    var presentedInPopoverWidth: CGFloat? {
        get { self[PresentedInPopoverWidthKey.self] }
        set { self[PresentedInPopoverWidthKey.self] = newValue }
    }
}

/// Shared content layout for modal sheets: a system toolbar with a close button, scrollable
/// content and a bottom bar pinned outside the scroll view. The bar stacks the injected
/// buttons and an optional accessory view above them. Scrolling stays inactive until the
/// content outgrows the viewport; the pinned bottom bar never leaves the screen.
///
/// For SwiftUI-presented sheets the component also applies the presentation sizing itself
/// (detents in compact width, a centered form sheet in regular width — the presenting view
/// injects its width class with `presentedFromRegularWidth(_:)`). A sheet presented from
/// UIKit manages its own detent or `preferredContentSize` instead — subscribe to the
/// measured height with `onHeightChange(_:)`.
struct SheetContent<Content: View, Buttons: View, BottomAccessory: View>: View {
    private let sizing: SheetSizing
    private let onClose: () -> Void
    private let content: Content
    private let buttons: Buttons
    private let bottomAccessory: BottomAccessory
    private var onHeightChange: ((CGFloat) -> Void)?
    private var addsBalancedBottomSpacing = true

    @Environment(\.presentedFromRegularWidth)
    private var isRegularWidth

    @Environment(\.presentedInPopoverWidth)
    private var popoverWidth

    /// Pre-measurement fallback, replaced by the measured height after the first layout.
    @State private var sheetHeight: CGFloat = Theme.Metrics.modalLargePreferredHeight
    @State private var headerHeight: CGFloat = 0

    /// In the popover incarnation the sheet is always content-fitted: `.fillViewport`
    /// stretching applies only inside a real sheet viewport (the compact adaptation).
    private var isPopoverIncarnation: Bool {
        popoverWidth != nil && isRegularWidth
    }

    private var balancedBottomSpacingHeight: CGFloat {
        addsBalancedBottomSpacing ? headerHeight : .zero
    }

    /// `buttons` fills the pinned bottom bar; `bottomAccessory` sits in the bar above them.
    init(
        sizing: SheetSizing,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content,
        @ViewBuilder buttons: () -> Buttons,
        @ViewBuilder bottomAccessory: () -> BottomAccessory
    ) {
        self.sizing = sizing
        self.onClose = onClose
        self.content = content()
        self.buttons = buttons()
        self.bottomAccessory = bottomAccessory()
    }

    /// Reports the measured sheet height — for sheets presented from UIKit, which apply
    /// it to their own detent or `preferredContentSize`.
    func onHeightChange(_ action: @escaping (CGFloat) -> Void) -> Self {
        var copy = self
        copy.onHeightChange = action
        return copy
    }

    /// A navigation-bar-high space below the content (before the buttons) mirrors the bar
    /// above in every incarnation — the popover grows by it, a fitted sheet's detent
    /// includes it, and in `.fillViewport` the centered content-plus-space block balances
    /// the bar optically. On by default; a content screen opts out with `false`.
    func balancedBottomSpacing(_ isEnabled: Bool) -> Self {
        var copy = self
        copy.addsBalancedBottomSpacing = isEnabled
        return copy
    }

    @ViewBuilder
    var body: some View {
        let core = column

        if let popoverWidth {
            // The popover takes the column's natural size — only the width is imposed, and
            // only in the popover incarnation; the compact-adapted sheet proposes its own
            // width and the detents take over, honouring the declared sizing.
            core
                .frame(width: isPopoverIncarnation ? popoverWidth : nil)
                .presentationCompactAdaptation(.sheet)
                .presentationDetents(sizing == .fitContent ? [.height(sheetHeight)] : [.large])
        } else {
        switch sizing {
        case .fitContent:
            if isRegularWidth {
                // The fitted form sheet reads the content's ideal height; the ideal of
                // multiline text is queried without a width and underestimates, so the
                // measured height overrides it.
                core
                    .frame(idealHeight: sheetHeight)
                    .presentationSizing(.form.fitted(horizontal: false, vertical: true))
            } else {
                core
                    .presentationDetents([.height(sheetHeight)])
            }
        case .fillViewport:
            if isRegularWidth {
                core
                    .presentationSizing(.form)
            } else {
                core
                    .presentationDetents([.large])
            }
        }
        }
    }

    // A plain, non-greedy column: header with the close button, the content, and the
    // pinned bottom bar. There is deliberately no ScrollView (and no NavigationStack —
    // it is greedy, which would break natural sizing): the measured height is then the
    // pure content height, independent of presentation-environment insets, which removes
    // the whole class of "measured in the window, presented with different insets"
    // sizing mismatches. Content taller than the container clips.
    private var column: some View {
        VStack(spacing: .zero) {
            header

            content
                // Take the height the text actually needs even when the container proposes
                // less — otherwise it truncates with an ellipsis and the measured height
                // (which drives the detent/ideal size) can never grow to fit it.
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, balancedBottomSpacingHeight)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: sizing == .fillViewport && !isPopoverIncarnation ? .infinity : nil)

            bottomBar
                .minimumBottomSpacing()
        }
        // For `.fitContent` the measured natural height drives the compact detent and the
        // UIKit host's preferredContentSize; rounding up avoids sub-point overflow.
        .onGeometryChange(for: CGFloat.self) { geometry in
            ceil(geometry.size.height)
        } action: { height in
            guard height > 0, sizing == .fitContent || isPopoverIncarnation else { return }
            sheetHeight = height
            onHeightChange?(height)
        }
    }

    private var header: some View {
        HStack {
            TFLiquidGlassSymbolButton(symbol: .close, action: onClose)

            Spacer()
        }
        .padding(.horizontal, .M)
        .padding(.vertical, .M)
        .onGeometryChange(for: CGFloat.self) { geometry in
            geometry.size.height
        } action: { height in
            headerHeight = height
        }
    }

    private var bottomBar: some View {
        AdaptiveReadableContainer(verticalMargin: .zero) {

            VStack(spacing: .XXXL) {
                bottomAccessory

                VStack(spacing: .M) {
                    buttons
                }
            }
        }
    }
}

extension SheetContent where BottomAccessory == EmptyView {
    init(
        sizing: SheetSizing,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content,
        @ViewBuilder buttons: () -> Buttons
    ) {
        self.init(
            sizing: sizing,
            onClose: onClose,
            content: content,
            buttons: buttons,
            bottomAccessory: { EmptyView() }
        )
    }
}

extension SheetContent where Buttons == EmptyView, BottomAccessory == EmptyView {
    init(
        sizing: SheetSizing,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            sizing: sizing,
            onClose: onClose,
            content: content,
            buttons: { EmptyView() },
            bottomAccessory: { EmptyView() }
        )
    }
}
