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

public enum Digits: Int, CaseIterable, Equatable {
    case digits6 = 6
    case digits7 = 7
    case digits8 = 8
    
    public var string: String {
        String(self.rawValue)
    }
    
    public static var defaultValue: Self {
        .digits6
    }
    
    public static func create(_ value: Int?) -> Self {
        guard let value, let instance = Digits(rawValue: value) else {
            return defaultValue
        }
        return instance
    }
    
    public static func create(_ value: String?) -> Self {
        guard let value, let intValue = Int(value) else {
            return defaultValue
        }
        return create(intValue)
    }
    
    public static func verifyIfPresent(_ value: String?) -> Bool {
        guard let value else { return true }
        guard let intValue = Int(value), Digits(rawValue: intValue) != nil else { return false }
        return true
    }
}
