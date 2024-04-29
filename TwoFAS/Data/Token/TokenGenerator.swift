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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public enum TokenGenerator {
    // swiftlint:disable function_default_parameter_at_end
    public static func generateTOTP(
        secret: String,
        time: Date? = nil,
        period: Period,
        digits: Digits,
        algoritm: Algorithm,
        tokenType: TokenType
    ) -> TokenValue {
        guard let secretData = secret.dataFromBase32String(),
            !secretData.isEmpty else {
                Log("Invalid secret")
                return ""
        }
        
        guard let generator = Generator(
            factor: .timer(period: TimeInterval(period.rawValue)),
            secret: secretData,
            algorithm: algoritm,
            tokenType: tokenType,
            digits: digits.rawValue) else {
                Log("Invalid generator parameters")
                return ""
        }
        
        let token = Token(name: "2FAS", issuer: "contact@2fas.com", generator: generator)
        
        guard let time,
              let value = try? token.generator.password(at: time)
        else { return token.currentPassword ?? "" }
        
        return value
    }
    
    public static func generateHOTP(secret: String, counter: Int, digits: Digits, algoritm: Algorithm) -> TokenValue {
        guard let secretData = secret.dataFromBase32String(),
            !secretData.isEmpty else {
                Log("Invalid secret")
                return ""
        }
        
        guard let generator = Generator(
            factor: .counter(Int64(counter)),
            secret: secretData,
            algorithm: algoritm,
            tokenType: TokenType.hotp,
            digits: digits.rawValue) else {
                Log("Invalid generator parameters")
                return ""
        }
        
        let token = Token(name: "2FAS", issuer: "contact@2fas.com", generator: generator)
        
        return token.currentPassword ?? ""
    }
    // swiftlint:enable function_default_parameter_at_end
}
