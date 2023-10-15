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

struct AddingServiceAddServiceButton: View {
    let action: Callback
    @Binding var isEnabled: Bool
    
    var body: some View {
        Button {
            guard isEnabled else { return }
            action()
        } label: {
            Text(T.Tokens.addManualDoneCta)
                .font(.headline)
                .foregroundColor(Color(isEnabled ? Theme.Colors.Text.light : Theme.Colors.Text.inactive))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .background {
                    let size = CGSize(width: Theme.Metrics.modalCornerRadius, height: Theme.Metrics.modalCornerRadius)
                    RoundedRectangle(cornerSize: size)
                        .fill(Color(isEnabled ? Theme.Colors.Fill.theme : Theme.Colors.inactiveMoreContrast))
                        .frame(minHeight: 50)
                }
        }
    }
}

struct AddingServiceAddServiceButton_Previews: PreviewProvider {
    static var previews: some View {
        AddingServiceAddServiceButton(
            action: {},
            isEnabled: .constant(false)
        )
    }
}
