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
import Common

public protocol AppearanceInteracting: AnyObject {
    // MARK: - Next Token
    
    var isNextTokenEnabled: Bool { get }
    func enableNextToken()
    func disableNextToken()
    func toggleNextToken()
    
    // MARK: - Active Search
    
    var isActiveSearchEnabled: Bool { get }
    func enableActiveSearch()
    func disableActiveSearch()
    func toggleActiveSearch()
    
    // MARK: - List style
    
    var selectedListStyle: ListStyle { get }
    func setSelectListStyle(_ listStyle: ListStyle)
    
    // MARK: - Hide tokens
    
    var areTokensHidden: Bool { get }
    func setTokensHidden(_ hidden: Bool)
    func toggleTokensHidden()
    
    // MARK: - Animation
    var shouldAnimate: Bool { get }
    
    // MARK: - Main menu
    var isPortraitMainMenuCollapsed: Bool { get }
    func setIsMenuPortraitCollapsed(_ isCollapsed: Bool)
    var isMenuLandscapeCollapsed: Bool { get }
    func setIsMenuLandscapeCollapsed(_ isCollapsed: Bool)
}

final class AppearanceInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension AppearanceInteractor: AppearanceInteracting {
    // MARK: - Next Token
    
    var isNextTokenEnabled: Bool {
        mainRepository.isNextTokenEnabled
    }
    
    func enableNextToken() {
        Log("AppearanceInteractor - enable Next Token", module: .interactor)
        mainRepository.enableNextToken()
    }
    
    func disableNextToken() {
        Log("AppearanceInteractor - disable Next Token", module: .interactor)
        mainRepository.disableNextToken()
    }
    
    func toggleNextToken() {
        if isNextTokenEnabled {
            disableNextToken()
        } else {
            enableNextToken()
        }
    }
    
    // MARK: - Active Search
    
    var isActiveSearchEnabled: Bool {
        mainRepository.isActiveSearchEnabled
    }
    
    func enableActiveSearch() {
        Log("AppearanceInteractor - enable Active Search", module: .interactor)
        mainRepository.enableActiveSearch()
    }
    
    func disableActiveSearch() {
        Log("AppearanceInteractor - disable Active Search", module: .interactor)
        mainRepository.disableActiveSearch()
    }
    
    func toggleActiveSearch() {
        if isActiveSearchEnabled {
            disableActiveSearch()
        } else {
            enableActiveSearch()
        }
    }
    
    // MARK: - List style
    var selectedListStyle: ListStyle {
        mainRepository.selectedListStyle
    }
    
    func setSelectListStyle(_ listStyle: ListStyle) {
        Log("AppearanceInteractor - set list style: \(listStyle)", module: .interactor)
        mainRepository.setSelectListStyle(listStyle)
    }
    
    // MARK: - Hide tokens
    var areTokensHidden: Bool {
        mainRepository.areTokensHidden
    }
    
    func setTokensHidden(_ hidden: Bool) {
        Log("AppearanceInteractor - set tokens hidden: \(hidden)", module: .interactor)
        mainRepository.setTokensHidden(hidden)
    }
    
    func toggleTokensHidden() {
        setTokensHidden(!areTokensHidden)
    }
    
    // MARK: - Animation
    var shouldAnimate: Bool {
        mainRepository.shouldAnimate
    }
    
    // MARK: - Main menu
    var isPortraitMainMenuCollapsed: Bool {
        mainRepository.isMainMenuPortraitCollapsed
    }
    
    func setIsMenuPortraitCollapsed(_ isCollapsed: Bool) {
        mainRepository.setIsMainMenuPortraitCollapsed(isCollapsed)
    }
    
    var isMenuLandscapeCollapsed: Bool {
        mainRepository.isMainMenuLandscapeCollapsed
    }
    
    func setIsMenuLandscapeCollapsed(_ isCollapsed: Bool) {
        mainRepository.setIsMainMenuLandscapeCollapsed(isCollapsed)
    }
}
