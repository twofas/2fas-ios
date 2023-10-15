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
    // MARK: - DeviceID
    
    var isDeviceIDSet: Bool {
        protectionModule.tokenStorage.deviceID != nil
    }
    
    var deviceID: String? {
        protectionModule.tokenStorage.deviceID
    }
    
    func saveDeviceID(_ deviceID: String) {
        protectionModule.tokenStorage.save(deviceID: deviceID)
    }
    
    func clearDeviceID() {
        protectionModule.tokenStorage.removeDeviceID()
    }
    
    // MARK: - FCM Token
    
    var isGCMTokenSet: Bool {
        protectionModule.tokenStorage.GCMToken != nil
    }
    
    var gcmToken: String? {
        protectionModule.tokenStorage.GCMToken
    }
    
    func saveGCMToken(_ gcmToken: String) {
        protectionModule.tokenStorage.save(GCMToken: gcmToken)
    }
    
    func clearGCMToken() {
        protectionModule.tokenStorage.removeGCMToken()
    }
    
    // MARK: - 2FA Token
    
    func token(
        secret: Secret,
        time: Date?,
        digits: Digits,
        period: Period,
        algorithm: Common.Algorithm,
        counter: Int,
        tokenType: TokenType
    ) -> TokenValue {
        TokenHandler.generateToken(
            secret: secret,
            time: time,
            digits: digits,
            period: period,
            algorithm: algorithm,
            counter: counter,
            tokenType: tokenType
        )
    }
}
