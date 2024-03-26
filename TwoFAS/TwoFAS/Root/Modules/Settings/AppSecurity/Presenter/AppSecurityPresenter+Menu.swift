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

import Foundation
import Data

extension AppSecurityPresenter {
    func buildMenu() -> [AppSecurityMenuSection] {
        let isPINset = interactor.isPINSet
        
        let PINcell = AppSecurityMenuCell(
            title: T.Settings.pinCode,
            accessory: .toggle(toggle: .init(kind: .PIN, isOn: isPINset, isBlocked: interactor.isPasscodeRequried))
        )
        
        guard isPINset else {
            return [
                AppSecurityMenuSection(
                    title: T.Settings.settings,
                    cells: [PINcell],
                    footer: interactor.biometryType.localizedDescription
                )
            ]
        }
        
        let settings = AppSecurityMenuSection(title: T.Settings.settings, cells: [
            PINcell,
            AppSecurityMenuCell(title: T.Security.changePin, accessory: .none, action: .changePIN)
        ])
        
        let limitOfTrials = interactor.limitOfTrials.localized
        
        let appBlocking = AppSecurityMenuSection(title: T.Settings.appBlocking, cells: [
            AppSecurityMenuCell(title: T.Settings.limitOfTrials, accessory: .info(text: limitOfTrials), action: .limit)
        ])
        
        let biometryType = interactor.biometryType
        let isBiometryEnabled = interactor.isBiometryEnabled
        
        let biometry: AppSecurityMenuSection? = {
            guard interactor.isBiometryAllowed else { return nil }
            let section = AppSecurityMenuSection(title: T.Settings.biometricAuthentication, cells: [
                AppSecurityMenuCell(
                    title: biometryType.localized,
                    accessory: .toggle(toggle: .init(kind: .biometry, isOn: isBiometryEnabled, isBlocked: false))
                )
            ])
            switch biometryType {
            case .none: return nil
            case .touchID, .faceID: return section
            }
        }()
        
        var menu: [AppSecurityMenuSection] = [settings, appBlocking]
        if let biometry {
            menu.append(biometry)
        }
        
        return menu
    }
}

extension BiometryType {
    var localizedDescription: String? {
        switch self {
        case .none:
            return nil
        case .touchID:
            return T.Settings.turnPinCodeToEnableTouchid
        case .faceID:
            return T.Settings.turnPinCodeToEnableFaceid
        }
    }
}
