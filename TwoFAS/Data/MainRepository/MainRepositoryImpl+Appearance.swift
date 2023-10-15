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
import Token
import Common

extension MainRepositoryImpl {
    // MARK: - Next Token
    
    var isNextTokenEnabled: Bool {
        userDefaultsRepository.isNextTokenEnabled
    }
    
    func enableNextToken() {
        userDefaultsRepository.setNextTokenEnabled(true)
    }
    
    func disableNextToken() {
        userDefaultsRepository.setNextTokenEnabled(false)
    }
    
    // MARK: - Active Search
    
    var isActiveSearchEnabled: Bool {
        userDefaultsRepository.isActiveSearchEnabled
    }
    
    func enableActiveSearch() {
        userDefaultsRepository.setActiveSearchEnabled(true)
    }
    
    func disableActiveSearch() {
        userDefaultsRepository.setActiveSearchEnabled(false)
    }
    
    // MARK: - List style
    var selectedListStyle: ListStyle {
        userDefaultsRepository.selectedListStyle
    }
    
    func setSelectListStyle(_ listStyle: ListStyle) {
        userDefaultsRepository.setSelectListStyle(listStyle)
    }
    
    // MARK: - Hide tokens
    var areTokensHidden: Bool {
        userDefaultsRepository.areTokensHidden
    }
    
    func setTokensHidden(_ hidden: Bool) {
        userDefaultsRepository.setTokensHidden(hidden)
    }
    
    // MARK: - Animation
    var shouldAnimate: Bool {
        !ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    // MARK: - Main menu
    var isMainMenuPortraitCollapsed: Bool {
        userDefaultsRepository.isMainMenuPortraitCollapsed
    }
    
    func setIsMainMenuPortraitCollapsed(_ isCollapsed: Bool) {
        userDefaultsRepository.setIsMainMenuPortraitCollapsed(isCollapsed)
    }
    
    var isMainMenuLandscapeCollapsed: Bool {
        userDefaultsRepository.isMainMenuLandscapeCollapsed
    }
    
    func setIsMainMenuLandscapeCollapsed(_ isCollapsed: Bool) {
        userDefaultsRepository.setIsMainMenuLandscapeCollapsed(isCollapsed)
    }
}
