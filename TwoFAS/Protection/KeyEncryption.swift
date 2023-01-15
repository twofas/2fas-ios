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

final class KeyEncryption {
    private typealias CacheType = [Character: [Character: Character]]

    private let key: [Character]
    private let alphabet: [Character]
    
    private lazy var cacheEnchiper: CacheType = makeCache(encipher: true)
    private lazy var cacheDechiper: CacheType = makeCache(encipher: false)
    
    init(key: String, alphabet: [Character]) {
        self.key = Array(key)
        self.alphabet = alphabet
    }
    
    func encipher(_ text: String) -> String { String(apply(cacheEnchiper, to: text)) }
    func decipher(_ cipher: String) -> String { String(apply(cacheDechiper, to: cipher)) }
    
    private func makeCache(encipher: Bool) -> CacheType {
        var tmp = CacheType()
        for char in key {
            if let shift = alphabet.firstIndex(of: char) {
                let linear = LinearCipher(shift: shift, alphabet: alphabet)
                tmp[char] = encipher ? linear.cacheEncipher : linear.cacheDecipher
            }
        }
        return tmp
    }
    
    private func apply(_ cache: CacheType, to text: String) -> [Character] {
        text.enumerated().map { index, letter in
            let letterKey = key[index % key.count]
            return cache[letterKey]?[letter] ?? letter
        }
    }
}

private final class LinearCipher {
    private let alphabet: [Character]
    private let shift: Int
    
    private(set) lazy var cacheDecipher: [Character: Character] = makeCache(shiftedBy: -self.shift)
    private(set) lazy var cacheEncipher: [Character: Character] = makeCache(shiftedBy: self.shift)
    
    init(shift: Int, alphabet: [Character]) {
        self.shift = shift
        self.alphabet = alphabet
    }
    
    func encipher(_ text: String) -> String { mangle(text, by: cacheEncipher) }
    func decipher(_ cipher: String) -> String { mangle(cipher, by: cacheDecipher) }
    
    private func makeCache(shiftedBy shift: Int) -> [Character: Character] {
        var tmpCache = [Character: Character]()
        for (index, char) in alphabet.enumerated() {
            let newIndex = alphabet.index(index, shiftedBy: shift)
            let newChar = alphabet[newIndex]
            tmpCache[char] = newChar
        }
        
        return tmpCache
    }
    
    private func mangle(_ text: String, by cache: [Character: Character]) -> String {
        String(text.map({ cache[$0] ?? $0 }))
    }
}

private extension Array where Element: Comparable {
    func index(_ i: Int, shiftedBy shift: Int) -> Int {
        let positions = i + shift
        var new = positions < 0 ? (count - abs(positions) % count) : positions % count
        if new == count { new = 0 }

        return new
    }
}
