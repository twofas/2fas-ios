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
    /// Hiding fades the keys out in place; showing brings them back from the "5" slot, each
    /// on its own spring: a longer way means a later start, a longer flight and a bigger
    /// bounce on landing. The keypad is disabled while hidden. Every slot keeps a placeholder
    /// while its key is out, so the grid keeps its size either way.
    var isHidden = false
    /// `false` removes the keys in the same frame `isHidden` turns on, with no fade, for hides
    /// the user did not cause. Showing is animated regardless.
    var animatesHiding = true
    let action: (TFPinKey) -> Void

    /// Coordinate space of the whole keypad; each key measures its slot in it and asks the
    /// layout where the "5" slot is in the same space.
    private let keypadSpace = "PINKeyboard"
    /// Reading-order index of the slot the keys gather on.
    private let gatherSlot = 4

    /// Size of the laid-out keypad, needed to know each key's travel before it animates.
    @State private var keypadSize: CGSize = .zero

    /// Drives the removal transition of every key.
    private let fadeOut: Animation = .easeInOut(duration: 0.2)
    /// Opacity part of the entrance, shared by all keys; the flight is what differs.
    private let fadeIn: Animation = .easeIn(duration: 0.2)
    /// Pause before the entrance starts. The keys are already in place, invisible on "5", so
    /// the screen stays calm while whatever hid them (the biometry alert) is still going away.
    private let entranceDelay: TimeInterval = 0.2

    // Spring tuning for the entrance, interpolated between the nearest key ("5" itself,
    // travel 0) and the farthest corner.
    private let nearFlight: TimeInterval = 0.15
    private let farFlight: TimeInterval = 0.5
    private let nearBounce = 0.2
    private let farBounce = 0.45
    /// The two bottom-corner slots (biometry and delete) travel the farthest and would
    /// overshoot the most, so they get a fixed bounce and delay instead of the interpolated ones.
    private let outerKeys: Set<Int> = [9, 11]
    private let outerBounce = 0.3
    private let outerDelay: TimeInterval = 0.05
    /// Farthest key's head start; the nearest starts at once.
    private let farReleaseDelay: TimeInterval = 0.1
    /// Speed the keys already have when released, as a fraction of their own travel per
    /// second, so every key leaves "5" with the same kick regardless of distance. Zero would
    /// start them from rest, which reads as static.
    private let launchVelocity = 6.0

    var body: some View {
        // Note: the buttons are intentionally NOT wrapped in a `GlassEffectContainer`.
        // The keys are spaced far apart, so they never blend or morph — the container would
        // add no visual benefit. Worse, it merges all keys into a single rendered glass shape,
        // so the interactive press of one `.buttonStyle(.glass)` key (press-in + press-out)
        // forces the whole shape to re-render, making every button flash twice on each tap.
        PINKeypadLayout {
            slot(TFPinButton(.digit(1), action: action), at: 0)
            slot(TFPinButton(.digit(2), action: action), at: 1)
            slot(TFPinButton(.digit(3), action: action), at: 2)
            slot(TFPinButton(.digit(4), action: action), at: 3)
            slot(TFPinButton(.digit(5), action: action), at: 4)
            slot(TFPinButton(.digit(6), action: action), at: 5)
            slot(TFPinButton(.digit(7), action: action), at: 6)
            slot(TFPinButton(.digit(8), action: action), at: 7)
            slot(TFPinButton(.digit(9), action: action), at: 8)
            // Hidden key keeps the slot so "0" stays centred.
            slot(
                TFPinButton(biometryKey ?? .delete, action: action)
                    .isHidden(biometryKey == nil, remove: false),
                at: 9
            )
            slot(TFPinButton(.digit(0), action: action), at: 10)
            slot(
                TFPinButton(.delete, action: action)
                    .opacity(canDelete ? 1 : 0)
                    .disabled(!canDelete)
                    .animation(.easeInOut(duration: PINDotsAnimation.fillDuration), value: canDelete),
                at: 11
            )
        }
        .coordinateSpace(.named(keypadSpace))
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            keypadSize = size
        }
        // Sets the transaction the keys are inserted and removed in; the removal fade uses it
        // directly, the entrance overrides it per key inside the transition. Showing always
        // needs an animation here, or the insertion transition would not run at all.
        .animation(isHidden && !animatesHiding ? nil : fadeOut, value: isHidden)
        .disabled(isHidden)
        .accessibilityHidden(isHidden)
    }

    /// One slot of the grid: the key while shown, a same-sized blank while hidden, so the
    /// layout always sees twelve subviews. `index` is the slot's position in reading order.
    @ViewBuilder
    private func slot<Key: View>(_ key: Key, at index: Int) -> some View {
        if isHidden {
            Color.clear
        } else {
            key.transition(AsymmetricTransition(
                insertion: KeyEntrance(
                    flight: spring(for: index),
                    fade: fadeIn,
                    startDelay: entranceDelay,
                    keypadSpace: keypadSpace,
                    gatherSlot: gatherSlot
                ),
                removal: .blurReplace
            ))
        }
    }

    /// Entrance spring for the key at `index`, scaled by its travel relative to the farthest key.
    private func spring(for index: Int) -> Animation {
        let t = relativeTravel(of: index)
        let flight = nearFlight + (farFlight - nearFlight) * t
        let isOuter = outerKeys.contains(index)
        let bounce = isOuter ? outerBounce : nearBounce + (farBounce - nearBounce) * t
        let delay = isOuter ? outerDelay : farReleaseDelay * t
        return .interpolatingSpring(
            Spring(duration: flight, bounce: bounce),
            initialVelocity: launchVelocity
        )
        .delay(delay)
    }

    /// Travel of the key at `index` to the gather slot as a fraction of the longest travel.
    /// Uses the measured keypad size; before the first layout pass the layout's minimum
    /// geometry stands in, which ranks the keys the same way.
    private func relativeTravel(of index: Int) -> CGFloat {
        let bounds = CGRect(origin: .zero, size: keypadSize)
        let target = PINKeypadLayout.slotCentre(at: gatherSlot, in: bounds)
        func travel(_ i: Int) -> CGFloat {
            let centre = PINKeypadLayout.slotCentre(at: i, in: bounds)
            return hypot(centre.x - target.x, centre.y - target.y)
        }
        let longest = (0..<12).map(travel).max() ?? 0
        guard longest > 0 else { return 0 }
        return travel(index) / longest
    }
}

/// Insertion transition of one key: it starts on the gather slot, invisible, and springs out
/// to its own slot while fading in. The travel is a pure offset, so the slot itself never
/// moves and the grid does not reflow.
///
/// Slot and target are both taken in the keypad's space. `bounds(of:)` reports the keypad in
/// the key's own local space, so only its size is used; the target comes from the layout's
/// placement maths for that size.
private struct KeyEntrance: Transition {
    let flight: Animation
    let fade: Animation
    /// Pause before both animations start; the key waits it out invisible on the gather slot.
    /// Adds to whatever delay `flight` already carries for its place in the wave.
    let startDelay: TimeInterval
    let keypadSpace: String
    let gatherSlot: Int

    func body(content: Content, phase: TransitionPhase) -> some View {
        let isGathered = !phase.isIdentity
        let keypadSpace = keypadSpace
        let gatherSlot = gatherSlot
        content
            .visualEffect { content, proxy in
                let slot = proxy.frame(in: .named(keypadSpace))
                let keypadSize = proxy.bounds(of: .named(keypadSpace))?.size ?? slot.size
                let target = PINKeypadLayout.slotCentre(
                    at: gatherSlot,
                    in: CGRect(origin: .zero, size: keypadSize)
                )
                return content.offset(
                    x: isGathered ? target.x - slot.midX : 0,
                    y: isGathered ? target.y - slot.midY : 0
                )
            }
            .animation(flight.delay(startDelay), value: phase)
            .opacity(isGathered ? 0 : 1)
            .animation(fade.delay(startDelay), value: phase)
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
