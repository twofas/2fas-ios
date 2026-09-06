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

/// Timing and geometry of the login screen leaving its launch-screen look: the brand, logo
/// and greeting, shrinks from the screen centre into the header while the rest of the
/// screen comes in.
enum SplashTransition {
    /// `LogoGrid` at its natural size, as the launch storyboard draws it.
    static let splashLogoSize = CGSize(width: 80, height: 96)
    /// The logo in the header; 5:6 like the asset.
    static let headerLogoSize = CGSize(width: 47.5, height: 57)
    /// How much bigger the logo is on the splash: exactly enough to match the launch screen's.
    static let scale = splashLogoSize.height / headerLogoSize.height
    /// The greeting grows less than the logo on the splash.
    static let greetingScale: CGFloat = 1.1
    /// Gap between the logo and the greeting on the splash; the header has `LoginBrand.gap`.
    static let splashGap: CGFloat = Spacing.XXXL.rawValue
    /// Pause before anything moves, shared with the keypad: a cancelled biometry alert is
    /// still going away when the failure arrives, and the exit must not start under it.
    static let delay: TimeInterval = PINKeyboard.entranceDelay
    /// The brand's lift from the screen centre to the header: position and size in one go.
    static let flight: Animation = .smooth(duration: 0.35).delay(delay) //spring(duration: 0.6, bounce: 0.15).delay(delay)
    /// The text under the brand fades in once the brand is nearly in place, so the greeting
    /// does not fly over it.
    static let subtitleReveal: Animation = .easeIn(duration: 0.2).delay(delay + 0.2)
    /// The dots fade in on their own beat, after the subtitle.
    static let dotsReveal: Animation = .easeIn(duration: 0.2).delay(delay + 0.1)
    /// Pause before the keys come out of the "5" slot, counted from the splash exit: the same
    /// beat as the brand's lift. The keypad's own `entranceDelay` applies to every other
    /// entrance.
    static let keypadDelay: TimeInterval = delay + 0.1
    /// Reduce Motion: no travel, the brand crossfades between its two places.
    static let crossfade: Animation = .easeInOut(duration: 0.3)
    /// The greeting's fade in on the splash, once the screen has taken over from the launch
    /// screen; also its fade out and back when an info message stands in for it.
    static let greeting: Animation = .easeInOut(duration: 0.4)
    /// Matched geometry ids of the brand's two places. Both slots are permanent sources; the
    /// floating brand switches between the ids, which animates it from one to the other.
    static let splashSlotID = "LoginBrand.splash"
    static let headerSlotID = "LoginBrand.header"
}

/// The logo with the greeting under it, laid out the way the header shows it. One view that
/// has its logo big on the splash and small in the header: a `LoginBrandHeaderSlot` and a
/// `LoginBrandSplashSlot` reserve its two places, `LoginFloatingBrand` draws it.
struct LoginBrand: View {
    static let greetings: [String] = [
        T.Login.helloHeader,
        T.Login.helloHeader1,
        T.Login.helloHeader2,
        T.Login.helloHeader3,
        T.Login.helloHeader4
    ]

    /// Greeting under the logo; `nil` keeps the logo alone over the gap the greeting would
    /// take.
    let greeting: String?
    /// `false` keeps the greeting out, leaving its space, until its first appearance: on the
    /// splash, or with the header once the splash is gone. Fades in with `revealAnimation`.
    let isGreetingRevealed: Bool
    let revealAnimation: Animation
    /// `false` takes the greeting out, keeping its space, while an info message stands in
    /// for it.
    let showsGreeting: Bool
    /// `false` keeps the greeting's space but leaves drawing it to the header (see
    /// `PINWelcomeHeader`), for a splash that is left right away: the greeting then fades in
    /// where it belongs instead of arriving with the logo.
    var drawsGreeting = true
    /// `1` as the header shows it; `SplashTransition.scale` as the splash does. The logo is
    /// laid out at the scaled size, drawn natively so it matches the launch screen pixel for
    /// pixel; the gap under it and the greeting grow along, by their own smaller amounts.
    /// Changes animate with the surrounding transaction.
    var scale: CGFloat = 1
    /// Width the greeting wraps at, before its scale is applied. Set to what fits the screen
    /// at the splash scale, so the greeting wraps the same way in both places and never runs
    /// past the edges when grown; `nil` lets it take what the container offers.
    var greetingMaxWidth: CGFloat?

    /// Gap between the logo and the greeting, as the header has it.
    static let gap = Spacing.M.rawValue + Spacing.S.rawValue

    /// Where between the header (`0`) and the splash (`1`) the brand is.
    private var progress: CGFloat {
        (scale - 1) / (SplashTransition.scale - 1)
    }

    private var greetingScale: CGFloat {
        1 + (SplashTransition.greetingScale - 1) * progress
    }

    private var gap: CGFloat {
        Self.gap + (SplashTransition.splashGap - Self.gap) * progress
    }

    var body: some View {
        VStack(spacing: .zero) {
            Asset.logoGrid.swiftUIImage
                .resizable()
                .frame(
                    width: SplashTransition.headerLogoSize.width * scale,
                    height: SplashTransition.headerLogoSize.height * scale
                )
                .accessibilityHidden(true)
                .padding(.bottom, gap)
            if greeting != nil {
                greetingView
                    .opacity(drawsGreeting ? 1 : 0)
                    .scaleEffect(greetingScale, anchor: .top)
            } else {
                Spacer()
                    .frame(height: Spacing.XL.rawValue)
            }
        }
    }
}

private extension LoginBrand {
    func scaled(_ scale: CGFloat) -> LoginBrand {
        var brand = self
        brand.scale = scale
        return brand
    }
}

extension LoginBrand {
    /// The greeting as the brand lays it out, with its fades. Drawn by the brand itself, or
    /// by the header over the brand's slot when the brand is not drawing it.
    @ViewBuilder
    var greetingView: some View {
        if let greeting {
            Text(greeting)
                .textStyle(.title2, .emphasized)
                .foregroundStyle(.labelsPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(showsGreeting ? 1 : 0)
                .animation(SplashTransition.greeting, value: showsGreeting)
                .opacity(isGreetingRevealed ? 1 : 0)
                .animation(revealAnimation, value: isGreetingRevealed)
                .frame(maxWidth: greetingMaxWidth)
        }
    }
}

/// The brand's place in the header: takes the brand's size, so the texts below it line up
/// under the floating brand, and draws nothing. With Reduce Motion it draws the brand itself
/// and crossfades with the splash slot. `isCurrent` says whether the brand is here now.
struct LoginBrandHeaderSlot: View {
    let brand: LoginBrand
    let isCurrent: Bool
    let namespace: Namespace.ID

    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    var body: some View {
        brand
            .opacity(reducesMotion && isCurrent ? 1 : 0)
            .animation(SplashTransition.crossfade, value: isCurrent)
            .matchedGeometryEffect(
                id: SplashTransition.headerSlotID,
                in: namespace,
                properties: .position,
                anchor: .top
            )
            .accessibilityHidden(!reducesMotion)
    }
}

/// The brand's place on the splash: the launch screen's logo box at the screen centre, the
/// brand hanging from its top edge with its logo grown to fill the box. Draws nothing, except with
/// Reduce Motion, where it draws the scaled brand and crossfades with the header slot.
struct LoginBrandSplashSlot: View {
    let brand: LoginBrand
    let isCurrent: Bool
    let namespace: Namespace.ID

    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    var body: some View {
        Color.clear
            .frame(
                width: SplashTransition.splashLogoSize.width,
                height: SplashTransition.splashLogoSize.height
            )
            .overlay(alignment: .top) {
                if reducesMotion {
                    brand
                        .scaled(SplashTransition.scale)
                        .opacity(isCurrent ? 1 : 0)
                        .animation(SplashTransition.crossfade, value: isCurrent)
                }
            }
            .matchedGeometryEffect(
                id: SplashTransition.splashSlotID,
                in: namespace,
                properties: .position,
                anchor: .top
            )
            .accessibilityHidden(true)
    }
}

/// The visible brand. Hangs from the top edge of the slot it is matched to, its logo grown
/// on the splash: instantly into the splash (that happens out of sight, on the way to the
/// background) and on a spring out of it. Not drawn with Reduce Motion, where the slots
/// show the brand themselves.
struct LoginFloatingBrand: View {
    let brand: LoginBrand
    let isSplash: Bool
    let namespace: Namespace.ID

    @Environment(\.accessibilityReduceMotion) private var reducesMotion

    var body: some View {
        if !reducesMotion {
            brand
                .scaled(isSplash ? SplashTransition.scale : 1)
                .matchedGeometryEffect(
                    id: isSplash ? SplashTransition.splashSlotID : SplashTransition.headerSlotID,
                    in: namespace,
                    properties: .position,
                    anchor: .top,
                    isSource: false
                )
                .animation(isSplash ? nil : SplashTransition.flight, value: isSplash)
                .allowsHitTesting(false)
        }
    }
}
