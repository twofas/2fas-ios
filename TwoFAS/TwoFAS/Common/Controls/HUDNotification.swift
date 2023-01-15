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
import PKHUD

enum HUDNotification {
    static func presentSuccess(title: String, completion: Callback? = nil) {
        HUD.dimsBackground = false
        HUD.allowsInteraction = false
        PKHUD.sharedHUD.effect = UIBlurEffect(style: .dark)
        let notification = NotificationIcon(title: title, iconKind: .success)
        HUD.flash(HUDContentType.customView(view: notification), delay: 1) { _ in
            completion?()
        }
    }
    
    static func presentFailure(title: String, completion: Callback? = nil) {
        HUD.dimsBackground = false
        HUD.allowsInteraction = false
        PKHUD.sharedHUD.effect = UIBlurEffect(style: .dark)
        let notification = NotificationIcon(title: title, iconKind: .failure)
        HUD.flash(HUDContentType.customView(view: notification), delay: 1) { _ in
            completion?()
        }
    }
}
