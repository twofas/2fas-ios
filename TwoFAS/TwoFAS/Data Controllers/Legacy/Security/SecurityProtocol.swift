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
import Protection

protocol SecurityDelegate: AnyObject {
    
    func securityBioAuthSuccess()
    func securityBioAuthFailure()
    func securityLockUI()
    func securityUnlockUI()
    func retryBioAuthIfNecessary()
}

protocol SecurityProtocol: AnyObject {
    
    var delegate: SecurityDelegate? { get set }
    
    var isAuthenticationRequired: Bool { get }
    
    // auth
    func authSuccessfully()
    func authFailed()
    var canAuthorize: Bool { get }
    
    // PIN
    var currentCodeType: Protection.CodeType { get }
    func verifyPIN(_ PIN: Protection.PIN) -> Bool
    func savePIN(PINValue: String, codeType: Protection.CodeType)
    
    var isPINAuthEnabled: Bool { get }
    
    func disablePINAuth()
    
    // Bio auth
    func enableBioAuth()
    func disableBioAuth()
    
    var isBioAuthAvailable: Bool { get }
    var isBioAuthEnabled: Bool { get }
    
    func authenticateUsingBioAuthIfPossible(reason: String)
    
    //
    func applicationWillEnterForeground()
    func applicationDidEnterBackground()
    func applicationDidBecomeActive()
    
    //
    func lockApplication()
    
    //
    var isAuthenticatingUsingBiometric: Bool { get }
    
    //
    var interactor: AppLockStateInteractor? { get set }
}
