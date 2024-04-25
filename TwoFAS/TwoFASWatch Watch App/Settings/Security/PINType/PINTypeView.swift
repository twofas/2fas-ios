//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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
import CommonWatch

struct PINTypeView: View {
    var didSelect: (PINType) -> Void
    let showClose: Bool
    var didClose: (() -> Void)?
    
    init(didSelect: @escaping (PINType) -> Void, showClose: Bool = false, didClose: (() -> Void)? = nil) {
        self.didSelect = didSelect
        self.showClose = showClose
        self.didClose = didClose
    }
    
    var body: some View {
        VStack {
            Button {
                didSelect(.digits4)
            } label: {
                Text(T.Settings.pin4Digits)
            }

            Button {
                didSelect(.digits6)
            } label: {
                Text(T.Settings.pin6Digits)
            }
        }
        .containerBackground(.red.gradient, for: .navigation)
        .navigationTitle(T.Settings.selectPinLength)
        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarBackButtonHidden(showClose)
        .toolbar(content: {
            if showClose {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        didClose?()
                    } label: {
                        Label(T.Commons.close, systemImage: "xmark")
                    }
                }
            }
        })
    }
}
