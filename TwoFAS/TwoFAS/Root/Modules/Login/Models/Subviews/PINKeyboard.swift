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

struct PINKeyboard: View {
    /// Whether there is anything to delete. When `false` the delete key is hidden
    /// (but still occupies its slot so the grid does not reflow).
    let canDelete: Bool
    let action: (TFPinKey) -> Void

    var body: some View {
        // Note: the buttons are intentionally NOT wrapped in a `GlassEffectContainer`.
        // The keys are spaced far apart, so they never blend or morph — the container would
        // add no visual benefit. Worse, it merges all keys into a single rendered glass shape,
        // so the interactive press of one `.buttonStyle(.glass)` key (press-in + press-out)
        // forces the whole shape to re-render, making every button flash twice on each tap.
        PINKeypadLayout {
            TFPinButton(.digit(1), action: action)
            TFPinButton(.digit(2), action: action)
            TFPinButton(.digit(3), action: action)
            TFPinButton(.digit(4), action: action)
            TFPinButton(.digit(5), action: action)
            TFPinButton(.digit(6), action: action)
            TFPinButton(.digit(7), action: action)
            TFPinButton(.digit(8), action: action)
            TFPinButton(.digit(9), action: action)
            TFPinButton(.delete, action: action)
                .isHidden(true, remove: false)
            TFPinButton(.digit(0), action: action)
            TFPinButton(.delete, action: action)
                .opacity(canDelete ? 1 : 0)
                .disabled(!canDelete)
                .accessibilityHidden(!canDelete)
                .animation(.easeInOut(duration: PINDotsAnimation.fillDuration), value: canDelete)
        }
    }
}

#Preview {
    PINKeyboard(canDelete: true, action: { _ in })
        .background(AppColor.backgroundsPrimary)
}

private struct KeypadDeviceGridPreview: View {
    private let widths: [(String, CGFloat)] = [
        ("min 228", 228),
        ("SE 320", 320),
        ("iPhone 393", 393),
        ("Pro Max 430", 430),
        ("iPad split 540", 540)
    ]

    var body: some View {
        VStack(spacing: 16) {
                ForEach(widths, id: \.0) { label, width in
                    HStack(spacing: 12) {
                        Text(verbatim: label)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .frame(width: 90, alignment: .trailing)
                        PINKeypadLayout {
                            TFPinButton(.digit(1), action: { _ in })
                            TFPinButton(.digit(2), action: { _ in })
                            TFPinButton(.digit(3), action: { _ in })
                            TFPinButton(.digit(4), action: { _ in })
                            TFPinButton(.digit(5), action: { _ in })
                            TFPinButton(.digit(6), action: { _ in })
                            TFPinButton(.digit(7), action: { _ in })
                            TFPinButton(.digit(8), action: { _ in })
                            TFPinButton(.digit(9), action: { _ in })
                            TFPinButton(.delete, action: { _ in }).isHidden(true, remove: false)
                            TFPinButton(.digit(0), action: { _ in })
                            TFPinButton(.delete, action: { _ in })
                        }
                        .frame(width: width, height: 380)
                        .border(.red.opacity(0.4))
                    }
                }
        }
        .scaleEffect(0.36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.backgroundsPrimary)
    }
}

#Preview("Device grid") {
    KeypadDeviceGridPreview()
}
