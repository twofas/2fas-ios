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

struct AddingServiceTitleView: View {
    let text: String
    let alignToLeading: Bool
    
    init(text: String, alignToLeading: Bool = false) {
        self.text = text
        self.alignToLeading = alignToLeading
    }
    
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(Color(Theme.Colors.Text.main))
            .ifElse(alignToLeading,
            contentIf: {
                $0.multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }, contentElse: {
                $0.multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            })
    }
}

struct AddingServiceTitleView_Previews: PreviewProvider {
    static var previews: some View {
        AddingServiceTitleView(text: "Test text", alignToLeading: true)
    }
}
