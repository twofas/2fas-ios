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

public enum ServiceRules {
    public static let labelMaxLength = 2
    public static let serviceNameMaxLength = 50
    public static let serviceNameMinLength = 1
    public static let privateKeyMaxLength = 512
    public static let privateKeyRegex = "^[a-zA-Z2-7]*$"
    public static let privateKeyAllowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz234567"
    public static let additionalInfoMaxLength = 50
    public static let minKeyLength: Int = 4
    public static let maxSectionNameLength: Int = 32
    public static let defaultTwoLetters = "MN"
    
    public static func isPrivateKeyTooShort(privateKey: String) -> Bool {
        privateKey.count < minKeyLength
    }
    
    public static func isPrivateKeyTooLong(privateKey: String) -> Bool {
        privateKey.count > privateKeyMaxLength
    }
    
    public static func isPrivateKeyValid(privateKey: String) -> Bool {
        guard privateKey.count >= minKeyLength && privateKey.count <= privateKeyMaxLength else { return false }
        
        let disallowedCharacterSet = CharacterSet(charactersIn: privateKeyAllowedCharacters).inverted
        let keyIsValid = privateKey.rangeOfCharacter(from: disallowedCharacterSet) == nil
        
        return keyIsValid
    }
    
    public static func isServiceNameValid(serviceName: String) -> Bool {
        !serviceName.isEmpty && serviceName.count <= serviceNameMaxLength
    }
    
    public static func isSectionNameValid(sectionName: String) -> Bool {
        !sectionName.isEmpty && sectionName.count <= maxSectionNameLength
    }
}
