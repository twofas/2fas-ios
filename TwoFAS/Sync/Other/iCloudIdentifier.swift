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
import CryptoKit
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

enum iCloudIdentifier {
    private static let v2Identifier = "_V2"
    private static let longIdentifier = "_L00NG_"
    private static let v3Identifier = "_V3"
    
    case v3(id: String)
    case v2(id: String)
    case long(hash: String, beginsWith: String)
    case deprecated(id: String)
    
    static func generate(from str: String) -> String {
        "\(hash(from: str.uppercased()))\(v3Identifier)"
    }
    
    static func generateV2(from str: String) -> String {
        "\(str)\(v2Identifier)"
    }
    
    static func hash(from str: String) -> String {
        guard let data = str.data(using: .utf8) else { return str }
        return SHA256.hash(data: data)
            .compactMap { String(format: "%02x", $0) }
            .joined()
            .uppercased()
    }
    
    static func parse(_ str: String) -> Self {
        if let range = str.range(of: v3Identifier) {
            return .v3(id: str.replacingCharacters(in: range, with: ""))
        }
        if let range = str.range(of: v2Identifier) {
            let secret = str.replacingCharacters(in: range, with: "")
            return .v2(id: secret)
        }
        if let range = str.range(of: longIdentifier) {
            let lowRange = str.startIndex
            
            let hash = String(str[lowRange..<range.lowerBound])
            let beginsWith = String(str[range.upperBound...])
            return .long(hash: hash, beginsWith: beginsWith)
        }
        return .deprecated(id: str)
    }
}
