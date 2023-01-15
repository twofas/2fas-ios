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
import NetworkStack
import Protection
import Token
import Storage

protocol MainRepository: AnyObject {
    // MARK: - DeviceID
    var isDeviceIDSet: Bool { get }
    var deviceID: String? { get }
    var isPINSet: Bool { get }
    
    // MARK: - Network
    func send2FAToken(
        for deviceID: DeviceID,
        extensionID: ExtensionID,
        tokenRequestID: String,
        token: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    )
    
    // MARK: - Storage
    func hasAnyServices() -> Bool
    func listAllPairedExtensions() -> [PairedWebExtension]
    func listAllAuthRequests(for domain: String, extensionID: ExtensionID) -> [PairedAuthRequest]
    func service(for secret: String) -> ServiceData?
    func incrementCounter(for secret: Secret)
    func updateAuthRequestUsage(for authRequest: PairedAuthRequest)
    
    // MARK: - RSA Encryption
    func encryptRSA(data: Data, using publicKeyInBase64String: String) -> Data?
    
    // MARK: - Generating Token
    func token(
        secret: Secret,
        time: Date?,
        digits: Digits,
        period: Period,
        algorithm: Common.Algorithm,
        counter: Int,
        tokenType: TokenType
    ) -> TokenValue
    
    // MARK: Time Offset
    var currentDate: Date { get }
}
