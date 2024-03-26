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

protocol AppLockModuleInteracting: AnyObject {
    var isLockoutAttemptsChangeBlocked: Bool { get }
    var isLockoutBlockTimeChangeBlocked: Bool { get }
    
    var selectedAttempts: AppLockAttempts { get }
    var selectedBlockTime: AppLockBlockTime { get }
    
    func setAttempts(_ value: AppLockAttempts)
    func setBlockTime(_ value: AppLockBlockTime)
}

final class AppLockModuleInteractor {
    private let appLockInteractor: AppLockStateInteracting
    private let mdmInteractor: MDMInteracting
    
    init(appLockInteractor: AppLockStateInteracting, mdmInteractor: MDMInteracting) {
        self.appLockInteractor = appLockInteractor
        self.mdmInteractor = mdmInteractor
    }
}

extension AppLockModuleInteractor: AppLockModuleInteracting {
    var selectedAttempts: AppLockAttempts { appLockInteractor.appLockAttempts }
    var selectedBlockTime: AppLockBlockTime { appLockInteractor.appLockBlockTime }
    var isLockoutAttemptsChangeBlocked: Bool { mdmInteractor.isLockoutAttemptsChangeBlocked }
    var isLockoutBlockTimeChangeBlocked: Bool { mdmInteractor.isLockoutBlockTimeChangeBlocked }
    
    func setAttempts(_ value: AppLockAttempts) {
        appLockInteractor.setAppLockAttempts(value)
    }
    
    func setBlockTime(_ value: AppLockBlockTime) {
        appLockInteractor.setAppLockBlockTime(value)
    }
}
