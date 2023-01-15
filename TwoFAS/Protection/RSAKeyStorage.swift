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
import KeychainAccess

public enum RSAKeyStorage {
    private static let keychainTokens = Keychain(service: "TWOFAS")
        .synchronizable(false)
        .accessibility(.afterFirstUnlockThisDeviceOnly)
    
    private static let privateKeyStorageKey = "io.magicpassword.privateRSAKey"
    private static let publicKeyStorageKey = "io.magicpassword.publicRSAKey"
        
    public static func save(privateKey: Data, publicKey: Data) {
        keychainTokens[data: privateKeyStorageKey] = privateKey
        keychainTokens[data: publicKeyStorageKey] = publicKey
    }
    
    public static var privateKey: Data? {
        keychainTokens[data: privateKeyStorageKey]
    }
    
    public static var publicKey: Data? {
        keychainTokens[data: publicKeyStorageKey]
    }
}
