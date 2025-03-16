//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
import SignalArgon2
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

final class SyncEncryptionHandler {
    private let keychain = Keychain(service: "TWOFASSync")
        .synchronizable(true)
        .accessibility(.afterFirstUnlockThisDeviceOnly)
    
    private let encryptionReferenceKey = "io.twofas.encryptionReferenceKey"
    private let systemKeyKey = "io.twofas.systemKeyKey"
    private let userKeyKey = "io.twofas.userKeyKey"
    private let saltKey = "io.twofas.saltKey"
    
    init {
        if keychain[data: encryptionReferenceKey] == nil {
            
        }
    }
    
    public func setUserPassword(_ password: String) {
        
    }
    
    public func disableUserPassword() {
        
    }
    
//    public static func save(privateKey: Data, publicKey: Data) {
//        keychainTokens[data: privateKeyStorageKey] = privateKey
//        keychainTokens[data: publicKeyStorageKey] = publicKey
//    }
//    
//    public static var privateKey: Data? {
//        keychainTokens[data: privateKeyStorageKey]
//    }
//    
//    public static var publicKey: Data? {
//        keychainTokens[data: publicKeyStorageKey]
//    }
    
    private func generateKey(for password: String) -> Data? {
        guard let hexPassword = normalizeStringIntoHEXData(password) else {
            Log("Can't create HEX from Password", module: .cloudSync, severity: .error)
            return nil
        }
       
        guard let passwordData = Data(hexString: hexPassword) else {
            Log("Can't create HEX from Key", module: .cloudSync, severity: .error)
            return nil
        }
        let partOfSalt = salt[0...15]
        do  {
            let (rawHash, _) = try Argon2.hash(
                iterations: UInt32(3),
                memoryInKiB: UInt32(64 * 1024),
                threads: UInt32(4),
                password: passwordData,
                salt: partOfSalt,
                desiredLength: 32,
                variant: .id,
                version: .v13
            )
            return rawHash
        } catch {
            Log("Can't create key, error: \(error)", module: .cloudSync, severity: .error)
        }
        return nil
    }
    
    private func normalizeStringIntoHEXData(_ string: String) -> String? {
        let normalized = string.decomposedStringWithCompatibilityMapping
        return normalized.data(using: .utf8)?
            .hexEncodedString()
    }
    
    private func createSalt() -> Data? {
        let lastCount = 4
        guard words.count >= lastCount else {
            Log("Can't get 4 words. Words count: \(words.count)", module: .cloudSync, severity: .error)
            return nil
        }
        let words = words.map({ $0.lowercased() })
        let elements = words.suffix(lastCount).joined()
        guard let data = elements.data(using: .utf8) else {
            Log("Can't greate data from words", module: .cloudSync, severity: .error)
            return nil
        }
        return Data(SHA256.hash(data: data))
    }
}
