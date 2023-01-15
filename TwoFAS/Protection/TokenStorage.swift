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

final public class TokenStorage: TokenStorageType {
    private let storage: LocalEncryptedStorage
    
    init(storage: LocalEncryptedStorage) {
        self.storage = storage
    }
    
    public func save(GCMToken: String) {
        storage.saveString(for: .gcmToken, value: GCMToken)
    }
    
    public func save(deviceID: String) {
        storage.saveString(for: .deviceID, value: deviceID)
    }
 
    public func update(newGCMToken GCMToken: GCMToken) {
        storage.saveString(for: .gcmToken, value: GCMToken)
    }
    
    public func update(newDeviceID deviceID: String) {
        storage.saveString(for: .deviceID, value: deviceID)
    }
    
    public func removeAll() {
        storage.remove(for: .gcmToken)
        storage.remove(for: .deviceID)
    }
    
    public func removeDeviceID() {
        storage.remove(for: .deviceID)
    }
    
    public func removeGCMToken() {
        storage.remove(for: .gcmToken)
    }
    
    public var deviceID: String? { storage.stringValue(for: .deviceID) }
    public var GCMToken: String? { storage.stringValue(for: .gcmToken) }
}
