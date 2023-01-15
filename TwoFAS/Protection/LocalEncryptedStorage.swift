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
}

final class LocalEncryptedStorage {
    // swiftlint:disable all
    private let encryption = KeyEncryption(
        key: Keys.LocalEncryptedStorage.key,
        alphabet: Keys.LocalEncryptedStorage.alphabet
    )
    // swiftlint:enable all
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    func saveString(for key: DataKey, value: String) {
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
        guard let str = defaults.string(forKey: key.rawValue) else { return nil }
        return encryption.decipher(str)
    }
}
