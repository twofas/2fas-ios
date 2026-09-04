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
    /// Biometry key shown left of "0"; `nil` keeps that slot empty.
    let biometryKey: TFPinKey?
    /// Fades every key out (and back in) with a slight shrink, each key starting a beat after
    /// the previous one in reading order, and disables the keypad meanwhile. The slots stay,
    /// so the grid keeps its size either way.
    var isHidden = false
    let action: (TFPinKey) -> Void

    private let hiddenScale: CGFloat = 0.9
    private let toggleDuration: TimeInterval = 0.25
    /// Gap between consecutive keys' start times; 12 keys spread over about a third of a second.
    private let keyStagger: TimeInterval = 0.03

    var body: some View {
        // Note: the buttons are intentionally NOT wrapped in a `GlassEffectContainer`.
        // The keys are spaced far apart, so they never blend or morph — the container would
        // add no visual benefit. Worse, it merges all keys into a single rendered glass shape,
        // so the interactive press of one `.buttonStyle(.glass)` key (press-in + press-out)
        // forces the whole shape to re-render, making every button flash twice on each tap.
        PINKeypadLayout {
            staggered(TFPinButton(.digit(1), action: action), at: 0)
            staggered(TFPinButton(.digit(2), action: action), at: 1)
            staggered(TFPinButton(.digit(3), action: action), at: 2)
            staggered(TFPinButton(.digit(4), action: action), at: 3)
            staggered(TFPinButton(.digit(5), action: action), at: 4)
            staggered(TFPinButton(.digit(6), action: action), at: 5)
            staggered(TFPinButton(.digit(7), action: action), at: 6)
            staggered(TFPinButton(.digit(8), action: action), at: 7)
            staggered(TFPinButton(.digit(9), action: action), at: 8)
            // Hidden key keeps the slot so "0" stays centred.
            staggered(
                TFPinButton(biometryKey ?? .delete, action: action)
                    .isHidden(biometryKey == nil, remove: false),
                at: 9
            )
            staggered(TFPinButton(.digit(0), action: action), at: 10)
            staggered(
                TFPinButton(.delete, action: action)
                    .opacity(canDelete ? 1 : 0)
                    .disabled(!canDelete)
                    .animation(.easeInOut(duration: PINDotsAnimation.fillDuration), value: canDelete),
                at: 11
            )
        }
        .disabled(isHidden)
        .accessibilityHidden(isHidden)
    }

    /// Applies the hide/show effect to one key; `index` is its position in reading order and
    /// sets how long the key waits before its animation starts.
    private func staggered<Key: View>(_ key: Key, at index: Int) -> some View {
        key
            .opacity(isHidden ? 0 : 1)
            .scaleEffect(isHidden ? hiddenScale : 1)
            .animation(
                .easeInOut(duration: toggleDuration).delay(Double(index) * keyStagger),
                value: isHidden
            )
    }
}

#Preview {
    PINKeyboard(canDelete: true, biometryKey: nil, action: { _ in })
        .background(AppColor.backgroundsPrimary)
}

#Preview("Face ID") {
    PINKeyboard(canDelete: true, biometryKey: .biometry(.faceID), action: { _ in })
        .background(AppColor.backgroundsPrimary)
}

#Preview("Touch ID") {
    PINKeyboard(canDelete: false, biometryKey: .biometry(.touchID), action: { _ in })
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
