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

final class CodeParser {
    func parse(codeStr: String) -> Code? {
        // Replace all spaces with proper URL Encoding
        let codeStr = codeStr.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "%20")
            .replacingOccurrences(of: "&amp;", with: "%26")
            .replacingOccurrences(of: "&lt;", with: "%3C")
            .replacingOccurrences(of: "&gt;", with: "%3E")
            .replacingOccurrences(of: "&quot;", with: "%22")
            .replacingOccurrences(of: "&apos;", with: "%27")
            .replacingOccurrences(of: "[", with: "%5B")
            .replacingOccurrences(of: "]", with: "%5D")
        
        // Verify if code is of TOTP type
        guard let components = NSURLComponents(string: codeStr) else { return nil }
        guard let scheme = components.scheme, scheme == "otpauth", let tokenType = components.host else { return nil }
                
        guard let query = components.queryItems else { return nil }
        
        let label = components.path?.trimmingCharacters(in: .init(charactersIn: "/"))
        let items = queryItems(query: query)
        
        guard let secret = items.find(forType: .secret(""))?
            .value
            .sanitazeSecret(),
              secret.isValidSecret()
        else { return nil }
        
        let issuer = items.find(forType: .issuer(""))
        let period: String? = items.find(forType: .period(""))?.value
        let digits: String? = items.find(forType: .digits(""))?.value
        let algorithm: String? = items.find(forType: .algorithm(""))?.value
        let counter: Int? = {
            guard let value = items.find(forType: .counter(""))?.value else { return nil }
            return Int(value)
        }()
        let otpAuth: String = {
            let itemsList: String = {
                var list: String = ""
                for i in items {
                    let key = i.key
                    var value = i.value
                    
                    if case QueryItemsType.secret = i {
                        value = "[hidden]"
                    }
                    list += "\(key)=\(value)&"
                }
                
                return list
            }()
            var path: String = {
                if let label {
                    return "\(scheme)://\(tokenType)/\(label)?\(itemsList)"
                }
                return "\(scheme)://\(tokenType)/?\(itemsList)"
            }()
            if path.last == "?" || path.last == "&" {
                path.removeLast()
            }
            return path
        }()
        
        guard Digits.verifyIfPresent(digits),
              Period.verifyIfPresent(period),
              Algorithm.verifyIfPresent(algorithm) else { return nil }
        
        return Code(
            issuer: issuer?.value,
            label: label,
            secret: secret,
            period: Period.create(period),
            digits: Digits.create(digits),
            algorithm: Algorithm.create(algorithm),
            tokenType: TokenType.create(tokenType),
            counter: counter,
            otpAuth: otpAuth
        )
    }
        
    private func queryItems(query: [URLQueryItem]) -> [QueryItemsType] {
        var values: [QueryItemsType] = []
        
        for item in query {
            guard let value = item.value?.removingPercentEncoding else { continue }
            let parsedItem = QueryItemsType(key: item.name, value: value)
            values.append(parsedItem)
        }
        
        return values
    }
 }
