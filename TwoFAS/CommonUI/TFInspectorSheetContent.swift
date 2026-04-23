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

// MARK: - Private metrics

private enum SheetMetrics {
    static let detentHeight:     CGFloat = 491
    static let cornerRadius:     CGFloat = 34   // sheet top-corner radius
    static let iconFontSize:     CGFloat = 41   // SF Symbol icon size
    static let sectionGap:       CGFloat = 40   // gap between icon+text and footnote+button
    static let toolbarBottomPad: CGFloat = 10
    static let grabberWidth:     CGFloat = 36
    static let grabberHeight:    CGFloat = 5
    static let grabberTopPad:    CGFloat = 5
    static let grabberFrameH:    CGFloat = 16
}

// MARK: - TFInspectorSheetContent

/// A bottom-sheet content view for contextual info panels ("Inspector" sheets).
///
/// Present it via the `.inspectorSheet(...)` convenience modifier, which
/// sets the correct detent, background material, and corner radius:
///
/// ```swift
/// Button("Learn more") { showInfo = true }
///     .inspectorSheet(
///         isPresented: $showInfo,
///         systemImage: "arrow.triangle.2.circlepath",
///         title: "Secure sync and backup",
///         description: "2FAS uses iCloud to securely create backups…",
///         footnote: "It is enabled by default and can be turned off at any time.",
///         actionTitle: "Understood"
///     )
/// ```
///
/// Tapping the CTA button runs the optional `action` closure, then dismisses.
public struct TFInspectorSheetContent: View {

    @Environment(\.dismiss) private var dismiss

    public let systemImage:  String
    public let title:        String
    public let description:  String
    public let footnote:     String?
    public let actionTitle:  String
    public let action:       () -> Void

    public init(
        systemImage:  String,
        title:        String,
        description:  String,
        footnote:     String?  = nil,
        actionTitle:  String,
        action:       @escaping () -> Void = {}
    ) {
        self.systemImage  = systemImage
        self.title        = title
        self.description  = description
        self.footnote     = footnote
        self.actionTitle  = actionTitle
        self.action       = action
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: 0) {
            toolbar
            contentSlot
            Spacer(minLength: 0)
        }
    }

    // MARK: Toolbar

    private var toolbar: some View {
        VStack(spacing: 0) {
            // Grabber
            Capsule()
                .fill(AppColor.fillsVibrantPrimary)
                .frame(width: SheetMetrics.grabberWidth, height: SheetMetrics.grabberHeight)
                .padding(.top, SheetMetrics.grabberTopPad)
                .frame(height: SheetMetrics.grabberFrameH)

            // Controls row: close button left, placeholder right for visual balance
            HStack {
                TFLiquidGlassSymbolButton(symbol: .close) { dismiss() }
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, .XL)
        }
        .padding(.bottom, SheetMetrics.toolbarBottomPad)
    }

    // MARK: Content slot

    private var contentSlot: some View {
        VStack(spacing: SheetMetrics.sectionGap) {
            // Icon + title + description
            VStack(spacing: Spacing.XXXL) {
                Image(systemName: systemImage)
                    .font(.system(size: SheetMetrics.iconFontSize, weight: .semibold))
                    .foregroundStyle(AppColor.accentsBrand)

                VStack(spacing: Spacing.M) {
                    Text(title)
                        .textStyle(.title2, .emphasized)
                        .foregroundStyle(AppColor.labelsPrimary)
                        .multilineTextAlignment(.center)

                    Text(description)
                        .textStyle(.callout)
                        .foregroundStyle(AppColor.labelsPrimary)
                        .multilineTextAlignment(.center)
                }
            }

            // Footnote + CTA button
            VStack(spacing: Spacing.XL) {
                if let footnote {
                    Text(footnote)
                        .textStyle(.footnote)
                        .foregroundStyle(AppColor.labelsSecondary)
                        .multilineTextAlignment(.center)
                }

                TFLiquidGlassTextButton(actionTitle) {
                    action()
                    dismiss()
                }
            }
        }
        .padding(.horizontal, .XL)
        .padding(.top, .M)
        .padding(.bottom, .XXXXXL)
    }
}

// MARK: - View convenience modifier

public extension View {
    /// Presents a `TFInspectorSheetContent` sheet with the correct detent,
    /// material background, and corner radius from the 2FAS Design System.
    func inspectorSheet(
        isPresented: Binding<Bool>,
        systemImage:  String,
        title:        String,
        description:  String,
        footnote:     String?  = nil,
        actionTitle:  String,
        action:       @escaping () -> Void = {}
    ) -> some View {
        sheet(isPresented: isPresented) {
            TFInspectorSheetContent(
                systemImage:  systemImage,
                title:        title,
                description:  description,
                footnote:     footnote,
                actionTitle:  actionTitle,
                action:       action
            )
            .presentationDetents([.height(SheetMetrics.detentHeight)])
            .presentationBackground(.regularMaterial)
            .presentationCornerRadius(SheetMetrics.cornerRadius)
            .presentationDragIndicator(.hidden)
        }
    }
}
