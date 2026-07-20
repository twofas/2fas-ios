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

        let attemptsSelected = interactor.selectedAttempts
        let attemptsOptions: [AppSecurityMenuCell.PickerOption] = AppLockAttempts.allCases.map { value in
            AppSecurityMenuCell.PickerOption(
                title: value.localized,
                kind: .attempts(value),
                isSelected: value == attemptsSelected
            )
        }
        let attemptsSection = AppSecurityMenuSection(
            title: T.Settings.appBlocking,
            cells: [
                AppSecurityMenuCell(
                    title: T.Settings.tooManyAttemptsHeader,
                    accessory: .picker(value: attemptsSelected.localized, options: attemptsOptions)
                )
            ],
            footer: T.Settings.howManyAttemptsFooter
        )

        let blockTimeSelected = interactor.selectedBlockTime
        let blockTimeOptions: [AppSecurityMenuCell.PickerOption] = AppLockBlockTime.allCases.map { value in
            AppSecurityMenuCell.PickerOption(
                title: value.localized,
                kind: .blockTime(value),
                isSelected: value == blockTimeSelected
            )
        }
        let blockTimeSection = AppSecurityMenuSection(
            cells: [
                AppSecurityMenuCell(
                    title: T.Settings.blockFor,
                    accessory: .picker(value: blockTimeSelected.localized, options: blockTimeOptions)
                )
            ]
        )

        let biometryType = interactor.biometryType
        let isBiometryEnabled = interactor.isBiometryEnabled

        let biometry: AppSecurityMenuSection? = {
            guard interactor.isBiometryAllowed else { return nil }
            let section = AppSecurityMenuSection(title: T.Settings.biometricAuthentication, cells: [
                AppSecurityMenuCell(
                    title: biometryType.localized,
                    accessory: .toggle(toggle: .init(
                        kind: .biometry,
                        isOn: isBiometryEnabled,
                        isBlocked: isBiometryAuthenticationInProgress
                    ))
                )
            ])
            switch biometryType {
            case .none: return nil
            case .touchID, .faceID: return section
            }
        }()

        var menu: [AppSecurityMenuSection] = [settings, attemptsSection]
        if attemptsSelected != .noLimit {
            menu.append(blockTimeSection)
        }
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
