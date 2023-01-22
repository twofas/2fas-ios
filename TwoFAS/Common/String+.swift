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

public extension String {
    // swiftlint:disable no_magic_numbers
    func splitVersion() -> VersionDecoded? {
        
        let arr = self.split(separator: ".").compactMap { Int(String($0)) }
        
        switch arr.count {
        case 0: return nil
        case 1: return VersionDecoded(major: arr[0], minor: 0, fix: 0)
        case 2: return VersionDecoded(major: arr[0], minor: arr[1], fix: 0)
        case 3: return VersionDecoded(major: arr[0], minor: arr[1], fix: arr[2])
        default:
            return nil
        }
    }
    // swiftlint:enable no_magic_numbers
    
    // swiftlint:disable no_magic_numbers
    func isASCII() -> Bool {
        guard count > 0 else { return false }
        let byteArray = Array(self).map { String($0).utf8 }
        for char in byteArray {
            if let firstByte = char.first, char.count == 1 && (firstByte >= 0 && firstByte < 128) {
                // valid
            } else {
                return false
            }
        }
        return true
    }
    // swiftlint:enable no_magic_numbers
    
    // swiftlint:disable no_magic_numbers
    func isBase32() -> Bool {
        guard count > 0 else { return false }
        let byteArray = Array(self.uppercased()).map { String($0).utf8 }
        for char in byteArray {
            if let firstByte = char.first,
               char.count == 1
                && ((firstByte >= 65 && firstByte <= 90) || (firstByte >= 50 && firstByte <= 55)) {
                // valid
            } else {
                return false
            }
        }
        return true
    }
    // swiftlint:enable no_magic_numbers
    
    func isValidSecret() -> Bool {
        let maxLength = ServiceRules.privateKeyMaxLength
        guard count >= ServiceRules.minKeyLength && count <= maxLength else { return false }
        let chars = Array(self)
        for char in chars {
            if char.isASCII && (char.isLetter || char.isNumber || char.isPadding) {
                // valid
            } else {
                return false
            }
        }
        return true
    }
    
    func sanitazeName() -> String {
        replacingOccurrences(of: "\\", with: "")
    }
    
    func sanitazeSecret() -> String {
        replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: "-", with: "")
            .uppercased()
    }
    
    func dataFromBase32String() -> Data? {
        MF_Base32Codec.data(fromBase32String: self)
    }
    
    subscript(_ i: Int) -> String {
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        
        return String(self[idx1..<idx2])
    }
    
    subscript(r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        
        return String(self[start ..< end])
    }
    
    subscript(r: CountableClosedRange<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        
        return String(self[startIndex...endIndex])
    }
    
    subscript(r: CountablePartialRangeFrom<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        
        return String(self[startIndex...])
    }
    
    var twoLetters: String {
        guard count > 1 else { return String(first ?? Character("")).uppercased()  }
        return self[0...1].uppercased()
    }
    
    func components(withMaxLength length: Int) -> [String] {
        stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}
