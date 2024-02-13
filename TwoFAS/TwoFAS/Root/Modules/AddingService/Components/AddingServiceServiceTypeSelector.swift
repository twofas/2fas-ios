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

struct AddingServiceServiceTypeSelector: View {    
    @Binding var selectedTokenType: TokenType
    
    var body: some View {
        Group {
            HStack {
                createServiceTypeButton(type: .totp)
                createServiceTypeButton(type: .steam)
                createServiceTypeButton(type: .hotp)
            }
            .frame(alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }

    private func createServiceTypeButton(type: TokenType) -> some View {
        AddingServiceServiceTypeButton(
            tokenType: type,
            action: { tokenType in selectedTokenType = tokenType
            }, isSelected: Binding(get: {
                selectedTokenType == type
            }, set: { _ in selectedTokenType = type }))
    }
}

struct AddingServiceServiceTypeSelector_Previews: PreviewProvider {
    static var previews: some View {
        AddingServiceServiceTypeSelector(selectedTokenType: .constant(.totp))
    }
}
