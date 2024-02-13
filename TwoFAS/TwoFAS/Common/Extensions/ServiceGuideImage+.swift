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

import UIKit
import Data

extension ServiceGuideImage {
    var icon: UIImage {
        switch self {
        case .webMenu: Asset.guideWebMenu.image
        case .gears: Asset.guideGears.image
        case .webUrl: Asset.guideWebUrl.image
        case .twoFasType: Asset.guide2fasType.image
        case .appButton: Asset.guideAppButton.image
        case .pushNotification: Asset.guidePushNotification.image
        case .account: Asset.guideAccount.image
        case .retype: Asset.guideRetype.image
        case .webAccount1: Asset.guideWebAccount1.image
        case .webAccount2: Asset.guideWebAccount2.image
        case .webPhone: Asset.guideWebPhone.image
        case .phoneQR: Asset.guidePhoneQr.image
        case .webButton: Asset.guideWebButton.image
        case .secretKey: Asset.guideSecretKey.image
        }
    }
}
