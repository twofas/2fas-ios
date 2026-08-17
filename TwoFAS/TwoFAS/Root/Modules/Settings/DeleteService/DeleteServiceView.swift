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

struct DeleteServiceView: View {
    let action: Callback
    let cancel: Callback
    
    @State
    private var confirmed: Bool = false
        
    var body: some View {
        NavigationStack {
            TFInfoView(
                icon: .image(Asset.deleteForeverIcon.image, .original),
                title: T.Commons.warning.uppercased(),
                description: T.Tokens.tokenNotPossibleToRestore,
                buttons: {
                    TFToggleRow(T.Tokens.iWantToDeleteThisToken, isOn: $confirmed, isElevated: true)
                        .padding(.bottom, .S)
                    
                    TFButton(
                        T.Tokens.removeItForever,
                        variant: .borderedProminent,
                        size: .large,
                        action: action
                    )
                    .disabled(!confirmed)
                    
                    TFCancelButton(T.Commons.cancel, action: cancel)
                })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        cancel()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    DeleteServiceView(action: {}, cancel: {})
}
