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

struct PINWelcomeHeader: View {
    /// Logo and greeting; drawn by the floating brand, only their place is reserved here.
    let brand: LoginBrand
    /// Ties the brand's slot to the floating brand, see `LoginFloatingBrand`.
    let logoNamespace: Namespace.ID
    /// While the screen is on the splash the brand sits at the screen centre and the text
    /// under it is out; it fades in as the brand arrives.
    let showsSplash: Bool
    /// `false` while the brand is in the header, which can be before the splash is left: a
    /// biometry alert that covers the screen centre has it lifted out of the way early.
    let brandOnSplash: Bool
    /// The subtitle's fade in as the splash is left.
    let subtitleReveal: Animation
    /// `true` takes the prompt out, through a lock-out, when there is no keypad to prompt for.
    var hidesSubtitle = false
    
    var body: some View {
        VStack(spacing: .zero) {
            LoginBrandHeaderSlot(brand: brand, isCurrent: !brandOnSplash, namespace: logoNamespace)
                // A greeting the brand leaves to the header sits where the brand's own
                // would, at the slot's bottom, and only fades.
                .overlay(alignment: .bottom) {
                    if !brand.drawsGreeting {
                        brand.greetingView
                    }
                }
            // The prompt stays up through an info message (see `PINInfoMessage`), which has
            // its own place lower down.
            PINSubtitle(T.Security.enterPinShort, color: .labelsSecondary)
                .padding(.top, .S)
                .opacity(hidesSubtitle ? 0 : 1)
                .animation(hidesSubtitle ? PINInfoMessage.fadeOut : PINInfoMessage.fadeIn, value: hidesSubtitle)
                .opacity(showsSplash ? 0 : 1)
                .animation(showsSplash ? nil : subtitleReveal, value: showsSplash)
        }
    }
}

/// A line of the header's small text.
struct PINSubtitle: View {
    let text: String
    let color: AppColor
    var style: TextStyle = .body

    init(_ text: String, color: AppColor, style: TextStyle = .body) {
        self.text = text
        self.color = color
        self.style = style
    }

    var body: some View {
        Text(text)
            .textStyle(style)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// An info message of the lock screen: the wrong-PIN note between the header and the dots,
/// or the lock-out notice in the keypad's place. Fades in and out, and takes no layout space
/// of its own, so nothing moves around it.
struct PINInfoMessage: View {
    /// The message's appearance.
    static let fadeIn: Animation = .easeInOut(duration: 0.2)
    /// The message's disappearance, quicker: it is on its way out because of something the
    /// user did.
    static let fadeOut: Animation = .easeInOut(duration: 0.1)

    let info: String?
    var color: AppColor = .accentsBrand
    var style: TextStyle = .body
    /// Keeps the message out even when there is one, e.g. while the screen is on the splash.
    var isHidden = false
    /// Animation of the message's appearance; `fadeIn` unless the caller has a beat of its
    /// own, `nil` for an instant switch.
    var reveal: Animation? = PINInfoMessage.fadeIn

    private var isShown: Bool {
        info != nil && !isHidden
    }

    var body: some View {
        // A removed view keeps its wording for the length of its transition, so the message
        // fades out reading as it did; a wording change while shown stays in place.
        ZStack {
            if let info, isShown {
                PINSubtitle(info, color: color, style: style)
                    .transition(.opacity)
            }
        }
        .animation(isShown ? reveal : Self.fadeOut, value: isShown)
    }
}
