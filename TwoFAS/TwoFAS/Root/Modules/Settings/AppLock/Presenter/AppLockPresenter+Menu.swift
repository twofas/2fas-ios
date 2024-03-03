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

extension AppLockPresenter {
    func buildMenu() -> [AppLockMenuSection] {
        let selectedAttempt = interactor.selectedAttempts
        let attempts = AppLockMenuSection(
            title: T.Settings.tooManyAttemptsHeader,
            cells:
                AppLockAttempts.allCases.map {
                    AppLockMenuCell(
                        title: $0.localized,
                        checkmark: selectedAttempt == $0,
                        disabled: interactor.isLockoutAttemptsChangeBlocked
                    )
                },
            footer: T.Settings.howManyAttemptsFooter
        )
        
        let selectedBlockTime = interactor.selectedBlockTime
        let blockTime = AppLockMenuSection(
            title: T.Settings.blockFor,
            cells:
                AppLockBlockTime.allCases.map {
                    AppLockMenuCell(
                        title: $0.localized,
                        checkmark: selectedBlockTime == $0,
                        disabled: interactor.isLockoutBlockTimeChangeBlocked
                    )
                }
        )
        var menu: [AppLockMenuSection] = [
            attempts
        ]
        
        if selectedAttempt != .noLimit {
            menu.append(blockTime)
        }
        
        return menu
    }
}
