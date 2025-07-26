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
    private static let allowedNumbers = ["2", "3", "4", "5", "6", "7"]
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
    
    func removeWhitespaces() -> String {
        components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
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
            if isValidSecretCharacter(char) {
                // valid
            } else {
                return false
            }
        }
        return true
    }
    
    func sanitazeName() -> String {
        replacingOccurrences(of: "\\", with: "")
            .trim()
    }
    
    func sanitazeSecret() -> String {
        let str = self.removeWhitespaces()
            .trimmingCharacters(in: .init(charactersIn: "="))
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: "-", with: "")
            .uppercased()
        return str.filter { char in
            isValidSecretCharacter(char)
        }
    }
    
    func prepareSecretForParsing() -> String {
        let list = [" ", "\\", "-", "0", "1", "8", "9"]
        return self.compactMap { char -> String? in
            let symbol = String(char)
            if list.contains(symbol) {
                return nil
            }
            return symbol
        }
        .joined()
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
        guard self.count > 1 else {
            if self.count == 1 {
                return String(self.first ?? Character("")).uppercased()
            }
            return ""
        }
        return self[0...1].uppercased()
    }
    
    func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func components(withMaxLength length: Int) -> [String] {
        stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
    
    func sanitizeInfo() -> String {
        let elipsis = "..."
        let str = self.trim()
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
        var append = false
        var strEnd = str.count
        if str.count > ServiceRules.additionalInfoMaxLength {
            strEnd = ServiceRules.additionalInfoMaxLength - elipsis.count
            append = true
        }
        var cutStr = String(str[0..<strEnd])
        if append {
            cutStr += elipsis
        }
        
        return cutStr
    }
    
    func isEmailValid() -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
        "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
        "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
        "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
        "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
        "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isASCIILetter: Bool {
        uppercased().rangeOfCharacter(from: CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")) != nil
    }
    var isNumber: Bool { self.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil }
    var isUUIDCharacter: Bool {
        let charset = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        return reduce(into: true) { partialResult, char in
            partialResult = partialResult && String(char).rangeOfCharacter(from: charset) != nil
        }
    }
    var isValidLabel: Bool {
        guard !self.isEmpty else { return false }
        let char = Character(self)
        return char.isASCII || char.isLetter || char.isNumber || char.isSymbol || char.isEmoji
    }
    
    var isBackspace: Bool { strcmp(self.cString(using: .utf8), "\\b") == -92 }
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        // swiftlint:disable legacy_random
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        // swiftlint:enable legacy_random
        return randomString
    }
    
    func matches(_ regex: String) -> Bool {
        let wholeRange = self.startIndex..<self.endIndex
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) == wholeRange
    }
    
    private func isValidSecretCharacter(_ char: Character) -> Bool {
        char.isASCII &&
        (char.isLetter || char.isPadding || (char.isNumber && Self.allowedNumbers.contains(String(char))))
    }
}
