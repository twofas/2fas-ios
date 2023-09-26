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

struct AddingServiceAdvancedRevealView: View {
    private let dimension: CGFloat = 45
    
    private let imageUp = Image(systemName: "chevron.up")
    private let imageDown = Image(systemName: "chevron.down")
        
    @Binding var isVisible: Bool
    var action: Callback
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack {
                HStack {
                    Text(T.Tokens.addManualOther)
                        .multilineTextAlignment(.leading)
                        .font(.body)
                        .foregroundColor(Color(Theme.Colors.Text.main))
                    Text(T.Tokens.addManualOtherOptional)
                        .multilineTextAlignment(.leading)
                        .font(.footnote)
                        .foregroundColor(Color(Theme.Colors.Text.inactive))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                image()
                    .foregroundColor(Color(Theme.Colors.inactiveInverted))
                    .frame(width: dimension, height: dimension)
            }
        })
    }
    
    func image() -> Image {
        if isVisible {
            return imageUp
        } else {
            return imageDown
        }
    }
}

struct AddingServiceAdvancedRevealView_Previews: PreviewProvider {
    static var previews: some View {
        AddingServiceAdvancedRevealView(isVisible: .constant(true), action: {})
    }
}
