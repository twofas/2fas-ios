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

import Foundation
import CommonWatch

enum SecurityPath: Hashable {
    enum SetPIN: Hashable {
        case selectLength
        case enterPIN(PINType)
        case verifyPIN(AppPIN)
        case success
    }
    enum DisablePIN: Hashable {
        case verify
        case success
    }
    enum ChangePIN: Hashable {
        case verify
        case selectLength
        case enterPIN(PINType)
        case verifyPIN(AppPIN)
        case success
    }
    
    case setPIN(SetPIN)
    case disablePIN(DisablePIN)
    case changePIN(ChangePIN)
}
