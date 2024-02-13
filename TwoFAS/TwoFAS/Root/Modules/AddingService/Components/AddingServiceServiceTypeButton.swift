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

struct AddingServiceServiceTypeButton: View {
    private let size: CGSize = .init(width: 20, height: 20)
    
    let tokenType: TokenType
    let action: (TokenType) -> Void
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            action(tokenType)
        } label: {
            VStack(alignment: .center, spacing: 8) {
                AddingServiceTextContentView(text: text)
                image
                    .frame(width: size.width, height: size.height)
            }
        }
    }
    
    var text: String {
        switch tokenType {
        case .totp: return T.Tokens.totp
        case .steam: return T.Tokens.steam
        case .hotp: return T.Tokens.hotp
        }
    }
    
    var image: some View {
        if isSelected {
            return Asset.radioSelectionSelected.swiftUIImage
                .tint(Color(Theme.Colors.Controls.active))
        }
        return Asset.radioSelectionDeselected.swiftUIImage
            .tint(Color(Theme.Colors.Controls.inactive))
    }
}

struct AddingServiceServiceTypeButton_Previews: PreviewProvider {
    static var previews: some View {
        AddingServiceServiceTypeButton(tokenType: .totp, action: { _ in }, isSelected: .constant(false))
    }
}
