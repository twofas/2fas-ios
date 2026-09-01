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

    @Environment(\.presentedFromRegularWidth)
    private var isRegularWidth

    /// Pre-measurement fallback, replaced by the measured height after the first layout.
    @State private var sheetHeight: CGFloat = Theme.Metrics.modalLargePreferredHeight
    @State private var minContentHeight: CGFloat = 0
    @State private var topContentInset: CGFloat = 0
    @State private var naturalContentHeight: CGFloat = 0
    /// Pre-iOS-26 the bar sits below the scroll view instead of inside its insets, so its
    /// height is measured separately and added to the reported sheet height. Stays 0 on iOS 26.
    @State private var legacyBarHeight: CGFloat = 0

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

    @ViewBuilder
    var body: some View {
        let core = NavigationStack {
            scrollContent
                .closeToolbar(action: onClose)
        }

        switch sizing {
        case .fitContent:
            if isRegularWidth {
                core
                    .frame(idealHeight: totalSheetHeight)
                    .presentationSizing(.form.fitted(horizontal: false, vertical: true))
            } else {
                core
                    .presentationDetents([.height(totalSheetHeight)])
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

    // `.fillViewport` centers the content optically within the whole sheet — the navigation
    // bar area counts too, so the content sits higher than the bare viewport center — but
    // it must never start under the bar: the upward bias is clamped at the viewport edge
    // and disappears entirely once the content outgrows the viewport and scrolls.
    private var fillViewportTopPadding: CGFloat {
        guard sizing == .fillViewport else { return .zero }
        return max(0, (minContentHeight - topContentInset - naturalContentHeight) / 2)
    }

    /// The full sheet height for `.fitContent`: the scroll measurement plus, pre-iOS-26,
    /// the bar laid out below the scroll view.
    private var totalSheetHeight: CGFloat {
        sheetHeight + legacyBarHeight
    }

    @ViewBuilder
    private var scrollContent: some View {
        // On iOS 26 the bar lives in the scroll view's safe area: `safeAreaBar` registers it
        // with the scroll container, which draws the scroll edge effect (progressive blur)
        // beneath it — the SwiftUI counterpart of `UIScrollEdgeElementContainerInteraction`.
        // Older systems have no edge effect, so scrolled content would collide with the
        // buttons — there the scroll view ends above the bar instead.
        if #available(iOS 26.0, *) {
            scrollView
                .safeAreaBar(edge: .bottom, spacing: .zero) {
                    bottomBar
                        .minimumBottomSpacing()
                }
        } else {
            VStack(spacing: .zero) {
                scrollView

                bottomBar
                    .minimumBottomSpacing()
                    .onGeometryChange(for: CGFloat.self) { geometry in
                        geometry.size.height
                    } action: { height in
                        legacyBarHeight = height
                        if sizing == .fitContent {
                            onHeightChange?(totalSheetHeight)
                        }
                    }
            }
        }
    }

    private var scrollView: some View {
        ScrollView {
            content
                .onGeometryChange(for: CGFloat.self) { geometry in
                    geometry.size.height
                } action: { height in
                    guard sizing == .fillViewport else { return }
                    naturalContentHeight = height
                }
                .padding(.top, fillViewportTopPadding)
                .frame(
                    maxWidth: .infinity,
                    minHeight: sizing == .fillViewport ? minContentHeight : nil,
                    alignment: .top
                )
        }
        .scrollContentBackground(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        // For `.fitContent` the sheet height is the scroll content plus its insets (the
        // navigation bar and, on iOS 26, the pinned bottom bar report themselves as content
        // insets); rounding up keeps the content from overflowing the viewport by a fraction
        // of a point, which would enable scrolling. For `.fillViewport` the visible viewport
        // is measured instead, so the content can stretch to it. Rounding inside the
        // transform also keeps sub-point layout jitter from re-firing the action.
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            switch sizing {
            case .fitContent:
                ceil(geometry.contentSize.height + geometry.contentInsets.top + geometry.contentInsets.bottom)
            case .fillViewport:
                // containerSize is already the inset-adjusted viewport — do not subtract
                // the insets again.
                floor(geometry.containerSize.height)
            }
        } action: { _, height in
            guard height > 0 else { return }
            switch sizing {
            case .fitContent:
                sheetHeight = height
                onHeightChange?(totalSheetHeight)
            case .fillViewport:
                minContentHeight = height
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentInsets.top
        } action: { _, inset in
            guard sizing == .fillViewport else { return }
            topContentInset = inset
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
