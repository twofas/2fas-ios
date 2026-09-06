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
    
    @Binding
    var info: String?
    /// Ties the brand's slot to the floating brand, see `LoginFloatingBrand`.
    let logoNamespace: Namespace.ID
    /// While the screen is on the splash the brand sits at the screen centre and the text
    /// under it is out; it fades in as the brand arrives.
    let showsSplash: Bool
    /// `false` while the brand is in the header, which can be before the splash is left: a
    /// biometry alert that covers the screen centre has it lifted out of the way early.
    let brandOnSplash: Bool
    
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
            let text = info ?? T.Security.enterPinShort
            Text(text)
                .textStyle(.body)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .foregroundStyle(.labelsSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .animation(.easeInOut, value: text)
                .padding(.top, .S)
                .opacity(showsSplash ? 0 : 1)
                .animation(showsSplash ? nil : SplashTransition.subtitleReveal, value: showsSplash)
        }
    }
}
