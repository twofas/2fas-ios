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

protocol AppearanceModuleInteracting: AnyObject {
    var isActiveSearchEnabled: Bool { get }
    var isNextTokenEnabled: Bool { get }
    var selectedListStyle: ListStyle { get }
    var areTokensHidden: Bool { get }
    
    func toogleIncomingToken()
    func toggleActiveSearch()
    func setSelectListStyle(_ listStyle: ListStyle)
    func toggleTokensHidden()
}

final class AppearanceModuleInteractor {
    private let appearanceInteractor: AppearanceInteracting
    
    init(appearanceInteractor: AppearanceInteracting) {
        self.appearanceInteractor = appearanceInteractor
    }
}

extension AppearanceModuleInteractor: AppearanceModuleInteracting {
    var isActiveSearchEnabled: Bool { appearanceInteractor.isActiveSearchEnabled }
    var isNextTokenEnabled: Bool { appearanceInteractor.isNextTokenEnabled }
    var selectedListStyle: ListStyle { appearanceInteractor.selectedListStyle }
    var areTokensHidden: Bool { appearanceInteractor.areTokensHidden }

    func toogleIncomingToken() {
        appearanceInteractor.toggleNextToken()
    }
    
    func toggleActiveSearch() {
        appearanceInteractor.toggleActiveSearch()
    }
    
    func setSelectListStyle(_ listStyle: ListStyle) {
        appearanceInteractor.setSelectListStyle(listStyle)
    }
    
    func toggleTokensHidden() {
        appearanceInteractor.toggleTokensHidden()
    }
}
