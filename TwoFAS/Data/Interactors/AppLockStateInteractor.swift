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
import CoreLocation
import Common

public protocol AppLockStateInteracting: AnyObject {
    var isAppLocked: Bool { get }
    
    var appLockAttempts: AppLockAttempts { get }
    func setAppLockAttempts(_ value: AppLockAttempts)
    var appLockBlockTime: AppLockBlockTime { get }
    func setAppLockBlockTime(_ value: AppLockBlockTime)
    
    var appLockRemainingSeconds: Int? { get }
    
    func lockApp()
}

final class AppLockStateInteractor {
    private let defaultAppLockAttempts: AppLockAttempts = .try3
    private let defaultAppLockBlockTime: AppLockBlockTime = .min10
    
    private let minute = 60
    
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension AppLockStateInteractor: AppLockStateInteracting {
    var isAppLocked: Bool {
        guard let lockTimestamp = mainRepository.lockAppUntil else { return false }
        
        let isBlocked = currentTimestamp < lockTimestamp
        if !isBlocked {
            clear()
        }
        
        return isBlocked
    }
    
    var appLockAttempts: AppLockAttempts {
        mainRepository.appLockAttempts ?? defaultAppLockAttempts
    }
    
    func setAppLockAttempts(_ value: AppLockAttempts) {
        Log("AppLockStateInteractor - setAppLockAttempts: \(value)", module: .interactor)
        mainRepository.setAppLockAttempts(value)
    }
    
    var appLockBlockTime: AppLockBlockTime {
        mainRepository.appLockBlockTime ?? defaultAppLockBlockTime
    }
    
    func setAppLockBlockTime(_ value: AppLockBlockTime) {
        Log("AppLockStateInteractor - setAppLockBlockTime: \(value)", module: .interactor)
        mainRepository.setAppLockBlockTime(value)
    }
    
    var appLockRemainingSeconds: Int? {
        guard let lockTimestamp = mainRepository.lockAppUntil, currentTimestamp < lockTimestamp else { return nil }
        return Int(lockTimestamp.timeIntervalSince1970 - currentTimestamp.timeIntervalSince1970)
    }
    
    func lockApp() {
        Log("AppLockStateInteractor - lockApp", module: .interactor)
        let lockForSeconds = TimeInterval(appLockBlockTime.value * minute)
        mainRepository.setLockAppUntil(date: Date(timeInterval: lockForSeconds, since: currentTimestamp))
    }
}

private extension AppLockStateInteractor {
    var currentTimestamp: Date {
        let location = CLLocation(latitude: 0, longitude: 0)
        let timestamp = location.timestamp
        return timestamp
    }
    
    func clear() {
        mainRepository.clearLockAppUntil()
    }
}
