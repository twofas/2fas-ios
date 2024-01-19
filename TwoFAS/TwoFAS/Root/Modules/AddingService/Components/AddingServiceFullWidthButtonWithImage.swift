//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
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

struct AddingServiceFullWidthButtonWithImage: View {
    private let minHeight: CGFloat = 57
    
    let text: String
    let icon: Image
    let action: Callback
    
    var body: some View {
        Divider()
            .frame(height: 1)
            .overlay(Color(Theme.Colors.Line.secondarySeparator))
            .padding(.horizontal, -Theme.Metrics.doubleMargin)
            .accessibilityHidden(true)
        
        Button {
            action()
        } label: {
            HStack(spacing: Theme.Metrics.doubleMargin) {
                icon
                    .tint(Color(Theme.Colors.Fill.theme))
                AddingServiceTextContentView(text: text, alignToLeading: true)
            }
            .frame(minHeight: minHeight)
        }
    }
}

struct AddingServiceFullWidthButtonWithImage_Previews: PreviewProvider {
    static var previews: some View {
        AddingServiceFullWidthButtonWithImage(
            text: "Enter secret key manually",
            icon: Asset.keybordIcon.swiftUIImage,
            action: {}
        )
    }
}
