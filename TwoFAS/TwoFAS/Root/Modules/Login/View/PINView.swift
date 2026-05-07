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

struct PINView: View {
    var body: some View {
        PINKeypadLayout {
            TFPinButton(.digit(1)) { print("digit 1") }
            TFPinButton(.digit(2)) { print("digit 2") }
            TFPinButton(.digit(3)) { print("digit 3") }
            TFPinButton(.digit(4)) { print("digit 4") }
            TFPinButton(.digit(5)) { print("digit 5") }
            TFPinButton(.digit(6)) { print("digit 6") }
            TFPinButton(.digit(7)) { print("digit 7") }
            TFPinButton(.digit(8)) { print("digit 8") }
            TFPinButton(.digit(9)) { print("digit 9") }
            TFPinButton(.delete){}.isHidden(true, remove: false)
            TFPinButton(.digit(0)) { print("digit 0") }
            TFPinButton(.delete) { print("delete") }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.XL)
        .background(AppColor.backgroundsPrimary)
    }
}
