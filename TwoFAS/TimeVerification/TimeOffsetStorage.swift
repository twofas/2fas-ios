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

public enum TimeOffsetStorage {
    private static let keyExists = "com.2fas.TimeOffsetStorageExists"
    private static let keyOffset = "com.2fas.TimeOffsetStorageOffset"
    private static let userDefaults = UserDefaults(suiteName: Config.suiteName)!
    
    private static var offsetIsStored: Bool { userDefaults.bool(forKey: keyExists) }
    
    static func setOffset(offset: Int) {
        userDefaults.set(offset, forKey: keyOffset)
        userDefaults.set(true, forKey: keyExists)
        userDefaults.synchronize()
    }
    
    static func clearOffset() {
        userDefaults.removeObject(forKey: keyOffset)
        userDefaults.set(false, forKey: keyExists)
        userDefaults.synchronize()
    }
    
    public static var offset: Int? {
        guard offsetIsStored else { return nil}
        return userDefaults.integer(forKey: keyOffset)
    }
}

public extension TimeOffsetStorage {
    static var currentDate: Date {
        let currentOffset = offset ?? 0
        return Date() + TimeInterval(currentOffset)
    }
}
