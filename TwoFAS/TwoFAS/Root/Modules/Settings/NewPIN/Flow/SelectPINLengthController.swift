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
import Common

enum SelectPINLengthController {
    static func make(in view: UIView, completion: @escaping (PINType) -> Void) -> AlertController {
        let preferredStyle: UIAlertController.Style = {
            if UIDevice.isiPad {
                return .alert
            }
            return .actionSheet
        }()
        let alertController = AlertController(
            title: T.Settings.selectPinLength,
            message: nil,
            preferredStyle: preferredStyle
        )
        PINType.allCases.forEach { pinType in
            let action = UIAlertAction(title: pinType.localized, style: .default) { _ in
                completion(pinType)
            }
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: T.Commons.cancel, style: .cancel, handler: { _ in }))
        
        return alertController
    }
}
