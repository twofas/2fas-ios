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
import CloudKit

enum ConstStorage {
    private static let KeyDatabaseChangeToken = "KeyDatabaseChangeToken"
    private static let KeyZoneChangeToken = "KeyZoneChangeToken"
    private static let KeyZoneInitiated = "KeyZoneInitiated"
    private static let KeyNotificationsInitiated = "KeyNotificationsInitiated"
    private static let KeyUsername = "KeyCloudUsername"
    private static let KeyCloudEnabled = "KeyCloudEnabled"
    
    private static let userDefaults = UserDefaults.standard
    
    static var databaseChangeToken: CKServerChangeToken? {
        get {
            guard let tokenData = userDefaults.object(forKey: KeyDatabaseChangeToken) as? Data else { return nil }
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: tokenData)
        }
        
        set {
            guard
                let newValue,
                let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
            else {
                userDefaults.setValue(nil, forKey: KeyDatabaseChangeToken)
                userDefaults.synchronize()
                return
            }
            
            userDefaults.set(data, forKey: KeyDatabaseChangeToken)
            userDefaults.synchronize()
        }
    }
    
    static var zoneChangeToken: CKServerChangeToken? {
        get {
            guard let tokenData = userDefaults.object(forKey: KeyZoneChangeToken) as? Data else { return nil }
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: tokenData)
        }
        
        set {
            guard
                let newValue,
                let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
            else {
                userDefaults.setValue(nil, forKey: KeyZoneChangeToken)
                userDefaults.synchronize()
                return
            }
            
            userDefaults.set(data, forKey: KeyZoneChangeToken)
            userDefaults.synchronize()
        }
    }
    
    static var notificationsInitiated: Bool {
        get { userDefaults.bool(forKey: KeyNotificationsInitiated) }
        
        set {
            userDefaults.set(newValue, forKey: KeyNotificationsInitiated)
            userDefaults.synchronize()
        }
    }
    
    static var zoneInitiated: Bool {
        get { userDefaults.bool(forKey: KeyZoneInitiated) }
        
        set {
            userDefaults.set(newValue, forKey: KeyZoneInitiated)
            userDefaults.synchronize()
        }
    }
    
    static var cloudEnabled: Bool {
        get { userDefaults.bool(forKey: KeyCloudEnabled) }
        
        set {
            userDefaults.set(newValue, forKey: KeyCloudEnabled)
            userDefaults.synchronize()
        }
    }
    
    static func clearZone() {
        notificationsInitiated = false
        zoneInitiated = false
        zoneChangeToken = nil
        databaseChangeToken = nil
    }
    
    static var username: String? {
        get { userDefaults.string(forKey: KeyUsername) }
        
        set {
            userDefaults.set(newValue, forKey: KeyUsername)
            userDefaults.synchronize()
        }
    }
}
