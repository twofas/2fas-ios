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

extension Code {
    /// Chech if path is parsable: otpauth-migration://offline?data=...
    static func checkGoogleAuth(with data: String) -> [Code]? {
        guard let components = NSURLComponents(string: data),
              let scheme = components.scheme, scheme == "otpauth-migration",
              let host = components.host, host == "offline",
              let query = components.queryItems,
              let data = query.first(where: { $0.name == "data" }),
              let value = data.value?.removingPercentEncoding,
              let encodeData = Data(base64Encoded: value),
              let unpacked = try? MigrationPayload(serializedData: encodeData)
        else { return nil }
                
        return unpacked.otpParameters.compactMap { param -> Code? in
            guard let secret = param.secretValue else { return nil }
            let digits: Digits = {
                if let value = param.digitsValue {
                    return value
                }
                return .digits6
            }()

            let algo: Algorithm = {
                if let value = param.algorithmValue {
                    return value
                }
                return .SHA1
            }()
            
            let tokenType: TokenType = {
                if let value = param.typeValue {
                    return value
                }
                return .totp
            }()
            let counter = Int(param.counter)
            
            return Code(
                issuer: param.issuer,
                label: param.name,
                secret: secret,
                period: .period30,
                digits: digits,
                algorithm: algo,
                tokenType: tokenType,
                counter: counter,
                otpAuth: nil
            )
        }
    }
}
