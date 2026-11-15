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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

enum DataKey: String {
    case token = "com.2fas.dataKey.token"
    case tokenValidationDate = "com.2fas.dataKey.tokenValidationDate"
    case gcmToken = "com.2fas.dataKey.gcmToken"
    case bioAuthEnabled = "com.2fas.dataKey.bioAuthEnabled"
    case pinKey = "com.2fas.dataKey.pinKey"
    case codeType = "com.2fas.dataKey.codeType"
    case migration = "com.2fas.dataKey.migration"
    case widgetsEnabled = "com.2fas.dataKey.widgetsEnabled"
    case deviceID = "com.2fas.dataKey.deviceID"
    case publicSigningKeyUploaded = "com.2fas.dataKey.publicSigningKeyUploaded"
}

/// Settings kept in `UserDefaults`.
///
final class LocalEncryptedStorage {
    /// What has to stay unreadable in a backup of the device: the PIN of the app and what identifies the device
    /// to the notification services
    static let sealedKeys: Set<DataKey> = [.pinKey, .gcmToken, .deviceID]

    // swiftlint:disable all
    private let encryption = KeyEncryption(
        key: Keys.LocalEncryptedStorage.key,
        alphabet: Keys.LocalEncryptedStorage.alphabet
    )
    // swiftlint:enable all
    private let defaults: UserDefaults
    private let cipher: LocalStorageCipher?
    
    /// - Parameter cipher: `nil` – nothing is sealed (the storage of values from before the app group).
    init(defaults: UserDefaults, cipher: LocalStorageCipher? = nil) {
        self.defaults = defaults
        self.cipher = cipher
    }
    
    func saveString(for key: DataKey, value: String) {
        if Self.sealedKeys.contains(key), let cipher {
            do {
                // In the main app the key is created with the first value that needs it
                try cipher.prepareForWriting()
                let sealed = try cipher.seal(Data(value.utf8), associatedData: Self.associatedData(for: key))
                defaults.set(sealed, forKey: key.rawValue)
                defaults.synchronize()
                return
            } catch {
                // Kept the old way rather than lost – it's sealed when it's read with the key available
                Log(
                    "LocalEncryptedStorage - can't seal a value: \(SealedEntity.describe(error))",
                    module: .protection,
                    severity: .error
                )
            }
        }
        let str = encryption.encipher(value)
        defaults.set(str, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    func saveBool(for key: DataKey, value: Bool) {
        defaults.set(value, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    func saveData(for key: DataKey, value: Data) {
        defaults.set(value, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    func saveInt(for key: DataKey, value: Int) {
        defaults.set(value, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    func remove(for key: DataKey) {
        defaults.removeObject(forKey: key.rawValue)
        defaults.synchronize()
    }
    
    func boolValue(for key: DataKey) -> Bool { defaults.bool(forKey: key.rawValue) }
    func intValue(for key: DataKey) -> Int { defaults.integer(forKey: key.rawValue) }
    
    func dataValue(for key: DataKey) -> Data? { defaults.data(forKey: key.rawValue) }
    
    func stringValue(for key: DataKey) -> String? {
        if Self.sealedKeys.contains(key), let cipher {
            if let sealed = defaults.data(forKey: key.rawValue) {
                do {
                    let plaintext = try cipher.open(sealed, associatedData: Self.associatedData(for: key))
                    return String(data: plaintext, encoding: .utf8)
                } catch {
                    Log(
                        "LocalEncryptedStorage - can't open a value: \(SealedEntity.describe(error))",
                        module: .protection,
                        severity: .error
                    )
                    return nil
                }
            }
            // Saved before the values were sealed (or while they couldn't be) – sealed now
            guard let str = defaults.string(forKey: key.rawValue) else { return nil }
            let value = encryption.decipher(str)
            if cipher.state == .available {
                saveString(for: key, value: value)
            }
            return value
        }
        guard let str = defaults.string(forKey: key.rawValue) else { return nil }
        return encryption.decipher(str)
    }
    
    /// Removes the sealed values – after the local storage key was replaced they can't be opened any more
    func removeSealedValues() {
        Self.sealedKeys.forEach { defaults.removeObject(forKey: $0.rawValue) }
        defaults.synchronize()
    }
    
    private static func associatedData(for key: DataKey) -> Data {
        Data("2fas.LocalEncryptedStorage.v1".utf8) + Data([0]) + Data(key.rawValue.utf8)
    }
}
