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
import CryptoKit

#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

final class SyncEncryptionHandler {
    private let keychain = Keychain(service: "TWOFASSync")
        .synchronizable(true)
        .accessibility(.afterFirstUnlockThisDeviceOnly)
    private let userDefaults = UserDefaults.standard
    
    private let systemKeyKey = "io.twofas.systemKeyKey"
    private let userKeyKey = "io.twofas.userKeyKey"
    private let usedKeyKey = "io.twofas.usedKeyKey"
    private let saltKey = "io.twofas.saltKey"
    
    private let reference: Data
    
    private var cachedSalt: Data?
    private var cachedSystemKey: SymmetricKey?
    private var cachedUsedKey: Info.Encryption = .system
    private var cachedUserKey: SymmetricKey?
    private var cachedEncryptionReference: Data?
    
    init(reference: Data) {
        self.reference = reference
    }
    
    func initialize() {
        if let savedSalt = keychain[data: saltKey] {
            cachedSalt = savedSalt
        } else {
            guard let createdSalt = createSalt() else {
                Log("SyncEncryptionHandler: Can't create salt!", module: .cloudSync, severity: .error)
                return
            }
            keychain[data: saltKey] = createdSalt
            cachedSalt = createdSalt
        }
        
        if let savedSystemKey = keychain[data: systemKeyKey] {
            cachedSystemKey = SymmetricKey(data: savedSystemKey)
        } else {
            let randomStr = String.random(length: 128)
            guard let createdSystemKey = generateKey(for: randomStr) else {
                Log("SyncEncryptionHandler: Can't create system key!", module: .cloudSync, severity: .error)
                return
            }
            keychain[data: systemKeyKey] = createdSystemKey
            cachedSystemKey = SymmetricKey(data: createdSystemKey)
        }
        
        if var usedKeyValue = usedKey() {
            if usedKeyValue == .user {
                if let userKeyValue = userKey() {
                    cachedUserKey = SymmetricKey(data: userKeyValue)
                } else { // the key is missing - trying to recover
                    usedKeyValue = .system
                }
            }
            cachedUsedKey = usedKeyValue
        } else {
            cachedUsedKey = .system
            setUsedKey(.system)
        }
        
        cachedEncryptionReference = encrypt(reference)
    }
}

extension SyncEncryptionHandler {
    func setUserPassword(_ password: String) {
        guard let key = generateKey(for: password) else {
            Log("SyncEncryptionHandler: Can't create user key!", module: .cloudSync, severity: .error)
            return
        }
        saveUserKey(key)
        cachedUserKey = SymmetricKey(data: key)
        
        setUsedKey(.user)
        cachedUsedKey = .user
    }
    
    func setSystemKey() {
        saveUserKey(nil)
        cachedUserKey = nil
        
        setUsedKey(.system)
        cachedUsedKey = .system
    }
    
    func encrypt(_ data: Data) -> Data? {
        guard let currentKey else {
            Log("Error while encrypting: no current key!", module: .cloudSync, severity: .error)
            return nil
        }
        
        return encrypt(data, using: currentKey)
    }
    
    func decrypt(_ data: Data) -> Data? {
        guard let currentKey else {
            Log("Error while decrypting: no current key!", module: .cloudSync, severity: .error)
            return nil
        }
        
        return decrypt(data, using: currentKey)
    }
    
    var encryptionReference: Data? {
        cachedEncryptionReference
    }
}

private extension SyncEncryptionHandler {
    func encrypt(_ data: Data, using key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            Log("Error while encrypting: \(error)", module: .cloudSync, severity: .error)
            return nil
        }
    }
    
    func decrypt(_ data: Data, using key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let result = try AES.GCM.open(sealedBox, using: key)
            return result
        } catch {
            Log("Error while decrypting: \(error)", module: .cloudSync, severity: .error)
            return nil
        }
    }
    
    var currentKey: SymmetricKey? {
        if cachedUsedKey == .system {
            return cachedSystemKey
        } else {
            return cachedUserKey
        }
    }
    
    func generateKey(for password: String) -> Data? {
        guard let hexPassword = normalizeStringIntoHEXData(password) else {
            Log("SyncEncryptionHandler: Can't create HEX from Password", module: .cloudSync, severity: .error)
            return nil
        }
        
        guard let passwordData = Data(hexString: hexPassword) else {
            Log("SyncEncryptionHandler: Can't create HEX from Key", module: .cloudSync, severity: .error)
            return nil
        }
        guard let partOfSalt = cachedSalt?[0...15] else {
            Log("SyncEncryptionHandler: Cant' get salt!", module: .cloudSync, severity: .error)
            return nil
        }
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
            Log("SyncEncryptionHandler: Can't create key, error: \(error)", module: .cloudSync, severity: .error)
        }
        return nil
    }
    
    private func normalizeStringIntoHEXData(_ string: String) -> String? {
        let normalized = string.decomposedStringWithCompatibilityMapping
        return normalized.data(using: .utf8)?
            .hexEncodedString()
    }
    
    private func createSalt() -> Data? {
        let str = String.random(length: 64)
        guard let data = str.data(using: .utf8) else {
            Log("Can't create data for salt", module: .cloudSync, severity: .error)
            return nil
        }
        return Data(SHA256.hash(data: data))
    }
    
    private func saveUserKey(_ userKey: Data?) {
        guard let userKey else {
            userDefaults.set(nil, forKey: userKeyKey)
            userDefaults.synchronize()
            return
        }
        guard let cachedSystemKey, let encrypted = encrypt(userKey, using: cachedSystemKey) else {
            Log("Can't encrypt user key for saving", module: .cloudSync, severity: .error)
            return
        }
        userDefaults.set(encrypted, forKey: userKeyKey)
        userDefaults.synchronize()
    }
    
    private func userKey() -> Data? {
        guard let encrypted = userDefaults.data(forKey: userKeyKey) else {
            return nil
        }
        guard let cachedSystemKey, let decrypted = decrypt(encrypted, using: cachedSystemKey) else {
            Log("Can't decrypt user key for retrieval", module: .cloudSync, severity: .error)
            return nil
        }
        return decrypted
    }
    
    private func setUsedKey(_ usedKey: Info.Encryption) {
        guard let cachedSystemKey,
              let data = usedKey.rawValue.data(using: .utf8),
              let encrypted = encrypt(data, using: cachedSystemKey) else {
            Log("Can't encrypt used key for saving", module: .cloudSync, severity: .error)
            return
        }
        userDefaults.set(encrypted, forKey: usedKeyKey)
        userDefaults.synchronize()
    }
    
    private func usedKey() -> Info.Encryption? {
        guard let encrypted = userDefaults.data(forKey: usedKeyKey) else {
            return nil
        }
        guard let cachedSystemKey,
              let decryptedData = decrypt(encrypted, using: cachedSystemKey),
              let decryptedRaw = String(data: decryptedData, encoding: .utf8),
              let decrypted = Info.Encryption(rawValue: decryptedRaw)
        else {
            Log("Can't decrypt used key for retrieval", module: .cloudSync, severity: .error)
            return nil
        }
        return decrypted
    }
}
