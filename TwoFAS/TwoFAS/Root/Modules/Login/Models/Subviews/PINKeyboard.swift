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
import Common

struct PINKeyboard: View {
    let action: (TFPinKey) -> Void

    @Namespace private var glassNamespace

    var body: some View {
        keypad
            .modify { view in
                if #available(iOS 26, *) {
                    GlassEffectContainer { view }
                } else {
                    view
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.XL)
    }

    private var keypad: some View {
        PINKeypadLayout {
            TFPinButton(.digit(1), glassID: "digit-1", glassNamespace: glassNamespace, action: action)
            TFPinButton(.digit(2), glassID: "digit-2", glassNamespace: glassNamespace, action: action)
            TFPinButton(.digit(3), glassID: "digit-3", glassNamespace: glassNamespace, action: action)
            TFPinButton(.digit(4), glassID: "digit-4", glassNamespace: glassNamespace, action: action)
            TFPinButton(.digit(5), glassID: "digit-5", glassNamespace: glassNamespace, action: action)
            TFPinButton(.digit(6), glassID: "digit-6", glassNamespace: glassNamespace, action: action)
            TFPinButton(.digit(7), glassID: "digit-7", glassNamespace: glassNamespace, action: action)
            TFPinButton(.digit(8), glassID: "digit-8", glassNamespace: glassNamespace, action: action)
            TFPinButton(.digit(9), glassID: "digit-9", glassNamespace: glassNamespace, action: action)
            TFPinButton(.delete, glassID: "delete-placeholder", glassNamespace: glassNamespace, action: action)
                .isHidden(true, remove: false)
            TFPinButton(.digit(0), glassID: "digit-0", glassNamespace: glassNamespace, action: action)
            TFPinButton(.delete, glassID: "delete", glassNamespace: glassNamespace, action: action)
        }
    }
}
