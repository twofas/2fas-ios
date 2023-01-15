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

// swiftlint:disable all
public enum Keys {
    enum LocalKeyEncryption {
        static let key: String = "PROVIDEYOUROWNTYPEOFNONTRIVIALKEY"
        static let alphabet: [Character] = ["2", "3", "4", "5", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
    
    enum LocalEncryptedStorage {
        static let key: String = "SOYOURENCRYPTIONWILLBESECURE"
        static let alphabet: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    }
    
    enum Reference {
        private static let value: [UInt8] = [116, 82, 105, 83, 115, 76, 75, 122, 56, 54, 72, 112, 114, 104, 52, 99, 101, 67, 50, 79, 80, 100, 55, 120, 97, 122, 110, 52, 114, 114, 86, 116, 52, 120, 104, 102, 69, 85, 98, 79, 106, 120, 76, 88, 56, 82, 99, 51, 109, 107, 73, 83, 88, 69, 48, 108, 87, 98, 109, 110, 87, 102, 103, 103, 108, 103, 98, 66, 74, 104, 116, 89, 103, 112, 75, 54, 102, 77, 108, 49, 68, 54, 109, 116, 115, 121, 57, 50, 82, 51, 72, 107, 100, 71, 102, 119, 117, 88, 98, 122, 76, 101, 98, 113, 86, 70, 74, 115, 82, 55, 74, 90, 50, 119, 53, 56, 116, 57, 51, 56, 105, 121, 109, 119, 71, 51, 56, 50, 52, 105, 103, 89, 121, 49, 119, 105, 54, 110, 50, 87, 68, 112, 79, 49, 81, 49, 80, 54, 57, 122, 119, 74, 71, 115, 50, 70, 53, 97, 49, 113, 80, 52, 77, 121, 73, 105, 68, 83, 68, 55, 78, 67, 86, 50, 79, 118, 105, 100, 88, 81, 67, 66, 110, 68, 108, 71, 102, 109, 122, 48, 102, 49, 66, 81, 121, 83, 82, 107, 107, 116, 52, 114, 121, 105, 74, 101, 67, 106, 68, 50, 111, 52, 81, 115, 118, 101, 74, 57, 117, 69, 66, 85, 110, 56, 69, 76, 121, 79, 114, 69, 83, 118, 53, 82, 53, 68, 77, 68, 107, 68, 52, 105, 65, 70, 56, 84, 88, 85, 55, 75, 120, 111, 74, 117, 106, 100]
        static var dataValue = Data(value)
    }
    
    public enum Sync {
        public static let key: String = "P$5U80SQZNT2^I"
    }
}
