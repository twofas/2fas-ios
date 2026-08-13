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
import Protection

public protocol LoginInteracting: AnyObject {
    var codeLength: Int { get }
    var isLocked: Bool { get }
    var isLoggedOut: Bool { get }
    
    func authSuccessfully()
    func authFailed()
    
    func verifyPIN(_ code: PIN) -> Bool
    func authenticateUsingBiometry(reason: String, completion: @escaping (Bool) -> Void)
}

final class LoginInteractor {
    private let security: SecurityProtocol
    
    init(security: SecurityProtocol) {
        self.security = security
    }
}

extension LoginInteractor: LoginInteracting {
    var codeLength: Int {
        security.currentCodeType.intValue
    }
    
    var isLocked: Bool {
        !security.canAuthorize
    }
    
    var isLoggedOut: Bool {
        security.isAuthenticationRequired
    }
    
    func authenticateUsingBiometry(reason: String, completion: @escaping (Bool) -> Void) {
        security.authenticateUsingBiometry(reason: reason) { result in
            switch result {
            case .autenticated: completion(true)
            default: completion(false)
            }
        }
    }
    
    func verifyPIN(_ code: PIN) -> Bool {
        security.verifyPIN(code)
    }
    
    func authSuccessfully() {
        security.authSuccessfully()
    }
    
    func authFailed() {
        security.authFailed()
    }
}
