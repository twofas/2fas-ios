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

extension String {
    var localized: String { NSLocalizedString(self, comment: "") }
    
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
    
    func removeWhitespaces() -> String {
        components(separatedBy: .whitespacesAndNewlines).joined()
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
    
    var twoLetters: String {
        guard self.count > 1 else {
            if self.count == 1 {
                return String(self.first ?? Character("")).uppercased()
            }
            return ""
        }
        return self[0...1].uppercased()
    }
    
    func matches(_ regex: String) -> Bool {
        let wholeRange = self.startIndex..<self.endIndex
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) == wholeRange
    }
}

extension Optional where Wrapped == String {
    var hasContent: Bool { self != nil && !self!.isEmpty }
    var value: String { self ?? "" }
    var nilIfEmpty: String? {
        guard let self, !self.isEmpty else { return nil }
        return self
    }
}

extension NSMutableAttributedString {
    @discardableResult
    func formatAsLink(textToFind: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        
        if foundRange.location != NSNotFound {
            self.addAttribute(.foregroundColor, value: Theme.Colors.Text.theme, range: foundRange)
            self.addAttribute(.underlineColor, value: Theme.Colors.Text.theme, range: foundRange)
            self.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: foundRange)
            return true
        }
        return false
    }
}
