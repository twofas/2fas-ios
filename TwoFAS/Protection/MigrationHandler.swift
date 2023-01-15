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
import Common

final class MigrationHandler {
    private let currentVersion: Int = 2
    private let storage: LocalEncryptedStorage
    
    private let standarStorage = LocalEncryptedStorage(defaults: .standard)
    
    init(storage: LocalEncryptedStorage) {
        self.storage = storage
    }
    
    func migrateIfNeeded() {
        let currentValue = storage.intValue(for: .migration)
        guard currentValue != currentVersion else {
            Log("No need for migrating protection storage")
            return
        }
        
        Log("Migrating protection storage. Is: \(currentValue), should be: \(currentVersion)")
        if standarStorage.intValue(for: .migration) == 1 {
            migrateFromStandardStorage()
        } else {
            migrateFromKeychain()
        }

        Log("Saving protection storage version: \(currentVersion)")
        storage.saveInt(for: .migration, value: currentVersion)
    }
    
    private func migrateFromKeychain() {
        Log("Protection storage: migrateFromKeychain()")
        
        let tokenKey = "io.magicpassword.Token"
        let validTillKey = "io.magicpassword.ValidTill"
        let GCMTokenKey = "com.2fas.GCM_NEW"
        let bioAuthEnabledKey = "com.twofas.BioAuthEnabled"
        let PINKey = "com.twofas.PIN"
        let codeTypeKey = "com.twofas.CodeType"
        
        let keychainTokens = Keychain(service: "TWOFAS")
            .synchronizable(false)
            .accessibility(.afterFirstUnlockThisDeviceOnly)
        let keychainBio = Keychain()
        let keychainCode = Keychain(service: "TWOFAS")
        
        if let token = keychainTokens[tokenKey] {
            storage.saveString(for: .token, value: token)
        }
        
        if let validTill = keychainTokens[data: validTillKey] {
            storage.saveData(for: .tokenValidationDate, value: validTill)
        }
        
        if let gcmToken = keychainTokens[GCMTokenKey] {
            storage.saveString(for: .gcmToken, value: gcmToken)
        }
        
        if let value = keychainBio[data: bioAuthEnabledKey], let enabled = Bool(data: value) {
            storage.saveBool(for: .bioAuthEnabled, value: enabled)
        }
        
        if let pinValue = keychainCode[PINKey] {
            storage.saveString(for: .pinKey, value: pinValue)
        }
        
        if let codeType = keychainCode[codeTypeKey] {
            storage.saveString(for: .codeType, value: codeType)
        }
        
        keychainTokens[tokenKey] = nil
        keychainTokens[data: validTillKey] = nil
        keychainTokens[GCMTokenKey] = nil
        
        keychainBio[data: bioAuthEnabledKey] = nil
        
        keychainCode[PINKey] = nil
        keychainCode[codeTypeKey] = nil
    }
    
    private func migrateFromStandardStorage() {
        Log("Protection storage: migrateFromStandardStorage()")
        
        if let token = standarStorage.stringValue(for: .token) {
            storage.saveString(for: .token, value: token)
            standarStorage.remove(for: .token)
        }
        
        if let tokenValidationDate = standarStorage.dataValue(for: .tokenValidationDate) {
            storage.saveData(for: .tokenValidationDate, value: tokenValidationDate)
            standarStorage.remove(for: .tokenValidationDate)
        }
        
        if let gcmToken = standarStorage.stringValue(for: .gcmToken) {
            storage.saveString(for: .gcmToken, value: gcmToken)
            standarStorage.remove(for: .gcmToken)
        }

        if standarStorage.boolValue(for: .bioAuthEnabled) {
            storage.saveBool(for: .bioAuthEnabled, value: true)
            standarStorage.remove(for: .bioAuthEnabled)
        }
        
        if let pinKey = standarStorage.stringValue(for: .pinKey) {
            storage.saveString(for: .pinKey, value: pinKey)
            standarStorage.remove(for: .pinKey)
        }

        if let codeType = standarStorage.stringValue(for: .codeType) {
            storage.saveString(for: .codeType, value: codeType)
            standarStorage.remove(for: .codeType)
        }
    }
}
