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

public protocol WidgetsInteracting: AnyObject {
    var areEnabled: Bool { get }
    var showWarning: Bool { get }
    
    func markWarningAsShown()
    func enable()
    func disable()
    
    func reload()
    
    // MARK: Exchange Token
    var exchangeToken: String? { get }
    func setExchangeToken(_ key: String)
    func clearExchangeToken()
}

final class WidgetsInteractor {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension WidgetsInteractor: WidgetsInteracting {
    var areEnabled: Bool {
        mainRepository.areWidgetsEnabled
    }
    
    var showWarning: Bool {
        mainRepository.shouldShowWidgetEnablingWarning
    }
    
    func markWarningAsShown() {
        Log("WidgetsInteractor - markWarningAsShown", module: .interactor)
        mainRepository.markWidgetEnablingWarningAsShown()
    }
    
    func enable() {
        Log("WidgetsInteractor - enable", module: .interactor)
        mainRepository.enableWidgets()
    }
    
    func disable() {
        Log("WidgetsInteractor - disable", module: .interactor)
        mainRepository.disableWidgets()
    }
    
    func reload() {
        mainRepository.reloadWidgets()
    }
    
    // MARK: Exchange Token
    var exchangeToken: String? {
        mainRepository.exchangeToken
    }
    
    func setExchangeToken(_ key: String) {
        mainRepository.setExchangeToken(key)
    }
    
    func clearExchangeToken() {
        mainRepository.clearExchangeToken()
    }
}
