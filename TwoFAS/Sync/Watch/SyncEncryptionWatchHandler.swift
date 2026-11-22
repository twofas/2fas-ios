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
import CommonWatch

final class SyncEncryptionWatchHandler {
    private let keychain = Keychain(service: Config.keychainSync)
        .synchronizable(true)
        .accessibility(.afterFirstUnlock)
    private let userDefaults = UserDefaults.standard
    
    private let systemKeyKey = "io.twofas.systemKeyKey"
    private let userKeyKey = "io.twofas.userKeyKey"
    private let usedKeyKey = "io.twofas.usedKeyKey"
    private let deviceCodeKey = "io.twofas.deviceCodeKey"
    
    private let reference: Data
    
    private var cachedSystemKey: SymmetricKey?
    private var cachedUsedKey: Info.Encryption = .system
    private var cachedUserKey: SymmetricKey?
    private var cachedEncryptionReference: Data?
    private var cachedDeviceCode: String?
    
    private var localEncryptionKey: SymmetricKey
    
    private var encryptedUserKeyCached: Data?
    
    /// What the Info record carried when it was last fetched
    private var cloudInfo = SyncCloudEncryptionInfo.empty
    private var cachedIdentifierKey: SyncIdentifierKey?
    
    init(reference: Data, localEncryptionKeyData: Data) {
        self.reference = reference
        self.localEncryptionKey = SymmetricKey(data: localEncryptionKeyData)
    }
    
    func initialize() {
        if let savedSystemKey = keychain[data: systemKeyKey] {
            cachedSystemKey = SymmetricKey(data: savedSystemKey)
        } else {
            Log("No system key available!", module: .cloudSync, severity: .error)
        }
        
        if let usedKeyValue = usedKey() {
            // Without the user's key nothing is read or written until the ticket from the phone brings it again –
            // the system key isn't used in its place
            if usedKeyValue == .user, let userKeyValue = userKey() {
                cachedUserKey = SymmetricKey(data: userKeyValue)
            }
            cachedUsedKey = usedKeyValue
        } else {
            cachedUsedKey = .system
            setUsedKey(.system)
        }
        
        if let restored = restoreDeviceCode() {
            cachedDeviceCode = restored
        } else {
            let generated = DeviceCode.generate()
            saveDeviceCode(generated)
            cachedDeviceCode = generated
        }
        
        cachedEncryptionReference = encrypt(reference)
    }
    
    var deviceCode: DeviceCode {
        DeviceCode(code: cachedDeviceCode ?? "")
    }
}

extension SyncEncryptionWatchHandler: SyncEncryptionHandling {
    func verifyUserPassword(_ password: String) -> Bool {
        false // not used in this context
    }
    
    /// - Parameter isLegacyTicket: The ticket comes from a vault older than `Config.vaultV3`, where it was made
    ///   with the key built into the app. Accepted only there, until the phone migrates the cloud.
    func setEncryptedUserKey(_ encryptedKey: Data, isLegacyTicket: Bool) {
        if let cachedEncrypted = encryptedUserKeyCached, cachedEncrypted == encryptedKey {
            return
        }
        encryptedUserKeyCached = encryptedKey
        let opened: Data? = if isLegacyTicket {
            decrypt(encryptedKey, using: localEncryptionKey)
        } else if let cachedSystemKey {
            // The ticket is sealed with the system key (from the iCloud Keychain) for this watch
            try? SyncWatchTicket.open(encryptedKey, systemKey: cachedSystemKey, deviceCode: deviceCode.code)
        } else {
            nil
        }
        guard let key = opened else {
            Log("Error while opening the user key ticket!", module: .cloudSync, severity: .error)
            return
        }
        saveUserKey(key)
        cachedUserKey = SymmetricKey(data: key)
        
        setUsedKey(.user)
        cachedUsedKey = .user
        
        cachedEncryptionReference = encrypt(reference)
    }
    
    func setSystemKey() {
        saveUserKey(nil)
        cachedUserKey = nil
        
        setUsedKey(.system)
        cachedUsedKey = .system
        
        cachedEncryptionReference = encrypt(reference)
    }
    
    func encrypt(_ data: Data) -> Data? {
        guard let currentKey else {
            Log("Error while encrypting: no current key!", module: .cloudSync, severity: .error)
            return nil
        }
        guard let encrypted = encrypt(data, using: currentKey) else {
            return nil
        }
        return encrypted
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
    
    var recordKey: SymmetricKey? { currentKey }
    /// The watch never changes the key
    var previousRecordKey: SymmetricKey? { nil }
    
    var identifierKey: SyncIdentifierKey? {
        if let cachedIdentifierKey {
            return cachedIdentifierKey
        }
        guard let wrapped = cloudInfo.wrappedIdentifierKey, let currentKey,
              let key = try? SyncIdentifierKey.unwrap(wrapped, with: currentKey) else { return nil }
        cachedIdentifierKey = key
        return key
    }
    
    /// The watch never creates the key – it only uses the one the phone put in the Info record
    @discardableResult
    func createIdentifierKeyIfNeeded() -> Bool {
        identifierKey != nil
    }
    
    /// The watch never changes the encryption – it keeps what the Info record carried
    func cloudEncryptionInfo(cached: SyncCloudEncryptionInfo) -> SyncCloudEncryptionInfo {
        cached
    }
    
    func cloudEncryptionInfoFetched(_ info: SyncCloudEncryptionInfo) {
        if info.wrappedIdentifierKey != cloudInfo.wrappedIdentifierKey {
            cachedIdentifierKey = nil
        }
        cloudInfo = info
    }

    var hasCompleteEncryptionElements: Bool {
        if cachedUsedKey == .user {
            cachedSystemKey != nil && cachedUserKey != nil
        } else {
            cachedSystemKey != nil
        }
    }

    var hasSystemEncryptionElements: Bool {
        cachedSystemKey != nil
    }

    var encryptionType: Info.Encryption {
        cachedUsedKey
    }
    
    func purge() {
        saveUserKey(nil)
        if encryptionType == .user {
            setSystemKey()
        }
    }
}

private extension SyncEncryptionWatchHandler {
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
            cachedSystemKey
        } else {
            cachedUserKey
        }
    }
    
    private func saveUserKey(_ userKey: Data?) {
        guard let userKey else {
            userDefaults.set(nil, forKey: userKeyKey)
            userDefaults.synchronize()
            return
        }
        guard let encrypted = encrypt(userKey, using: localEncryptionKey) else {
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
        guard let decrypted = decrypt(encrypted, using: localEncryptionKey) else {
            Log("Can't decrypt user key for retrieval", module: .cloudSync, severity: .error)
            return nil
        }
        return decrypted
    }
    
    private func setUsedKey(_ usedKey: Info.Encryption) {
        guard let data = usedKey.rawValue.data(using: .utf8),
              let encrypted = encrypt(data, using: localEncryptionKey) else {
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
        guard let decryptedData = decrypt(encrypted, using: localEncryptionKey),
              let decryptedRaw = String(data: decryptedData, encoding: .utf8),
              let decrypted = Info.Encryption(rawValue: decryptedRaw)
        else {
            Log("Can't decrypt used key for retrieval", module: .cloudSync, severity: .error)
            return nil
        }
        return decrypted
    }
    
    private func restoreDeviceCode() -> String? {
        userDefaults.string(forKey: deviceCodeKey)
    }
    
    private func saveDeviceCode(_ code: String) {
        userDefaults.set(code, forKey: deviceCodeKey)
        userDefaults.synchronize()
    }
}
