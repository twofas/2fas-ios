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
import Data

protocol VerifyPINModuleInteracting: AnyObject {
    var unlock: Callback? { get set }
    var updateState: Callback? { get set }
    
    var isLocked: Bool { get }
    var currentCodeLength: Int { get }
    var secondsTillUnlock: Int { get }

    func shouldLock(attempt: Int) -> Bool
    func verifyPIN(_ PIN: String) -> Bool
    func lock()
}

final class VerifyPINModuleInteractor {
    private let protectionInteractor: ProtectionInteracting
    private let timerInteractor: TimerInteracting
    private let appLockStateInteractor: AppLockStateInteracting
    
    var unlock: Callback?
    var updateState: Callback?
    
    init(
        protectionInteractor: ProtectionInteracting,
        timerInteractor: TimerInteracting,
        appLockStateInteractor: AppLockStateInteracting
    ) {
        self.protectionInteractor = protectionInteractor
        self.timerInteractor = timerInteractor
        self.appLockStateInteractor = appLockStateInteractor
        
        timerInteractor.timerTicked = { [weak self] in
            guard let self else { return }
            if !self.isLocked {
                timerInteractor.pause()
                self.unlock?()
            } else {
                self.updateState?()
            }
        }
    }
    
    deinit {
        timerInteractor.destroy()
    }
}

extension VerifyPINModuleInteractor: VerifyPINModuleInteracting {
    var currentCodeLength: Int {
        protectionInteractor.currentCodeLength
    }
    
    var secondsTillUnlock: Int {
        appLockStateInteractor.appLockRemainingSeconds ?? 0
    }

    var isLocked: Bool {
        appLockStateInteractor.isAppLocked
    }
    
    func verifyPIN(_ PIN: String) -> Bool {
        protectionInteractor.validatePIN(PIN)
    }
        
    func shouldLock(attempt: Int) -> Bool {
        attempt >= appLockStateInteractor.appLockAttempts.value
    }
    
    func lock() {
        appLockStateInteractor.lockApp()
        timerInteractor.start()
    }
}
