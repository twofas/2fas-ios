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
import CommonUI

struct PINKeyboard: View {
    let action: (TFPinKey) -> Void
    
    var body: some View {
        PINKeypadLayout {
            TFPinButton(.digit(1), action: action)
            TFPinButton(.digit(2), action: action)
            TFPinButton(.digit(3), action: action)
            TFPinButton(.digit(4), action: action)
            TFPinButton(.digit(5), action: action)
            TFPinButton(.digit(6), action: action)
            TFPinButton(.digit(7), action: action)
            TFPinButton(.digit(8), action: action)
            TFPinButton(.digit(9), action: action)
            TFPinButton(.delete, action: action)
                .isHidden(true, remove: false)
            TFPinButton(.digit(0), action: action)
            TFPinButton(.delete, action: action)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.XL)
    }
}
