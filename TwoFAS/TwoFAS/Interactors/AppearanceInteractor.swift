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

protocol AppearanceInteracting: AnyObject {
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
}
