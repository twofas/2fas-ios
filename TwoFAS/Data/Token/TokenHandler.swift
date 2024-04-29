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
public typealias Algo = Common.Algorithm
#elseif os(watchOS)
import CommonWatch
public typealias Algo = CommonWatch.Algorithm
#endif

public struct TimedSecret {
    public let secret: Secret
    public let period: Period
    public let digits: Digits
    public let tokenType: TokenType
    public let algorithm: Algo
    
    public init(secret: Secret, period: Period, digits: Digits, algorithm: Algo, tokenType: TokenType) {
        self.secret = secret
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
        self.tokenType = tokenType
    }
}

public struct CounterSecret {
    public let secret: Secret
    public let counter: Int
    public let digits: Digits
    public let algorithm: Algo
    
    public init(secret: Secret, counter: Int, digits: Digits, algorithm: Algo) {
        self.secret = secret
        self.counter = counter
        self.digits = digits
        self.algorithm = algorithm
    }
}

public enum TokenHandler {
    public static func generateToken(
        secret: Secret,
        time: Date? = nil,
        digits: Digits,
        period: Period,
        algorithm: Algo,
        counter: Int,
        tokenType: TokenType
    ) -> TokenValue {
        if tokenType == .totp || tokenType == .steam {
            return TokenGenerator.generateTOTP(
                secret: secret,
                time: time,
                period: period,
                digits: digits,
                algoritm: algorithm,
                tokenType: tokenType
            )
        }
        return TokenGenerator.generateHOTP(secret: secret, counter: counter, digits: digits, algoritm: algorithm)
    }
    
#if os(iOS)
    public static let timer = TimerHandler()
    public static let counter = CounterHandler()
#endif
}

public extension TokenValue {
    func formattedValue(for type: TokenType) -> String {
        guard type == .hotp || type == .totp else {
            return self
        }
        
        let divider: Int
        if self.count.isMultiple(of: 2) {
            divider = Int(count / 2)
        } else {
            divider = Int(count / 2) + 1
        }
            
        let indexStartOfText = self.index(self.startIndex, offsetBy: 0)
        let indexMiddleOfText = self.index(self.startIndex, offsetBy: divider)
        
        let tokenStr = String(self[indexStartOfText..<indexMiddleOfText]) + " " + String(self[indexMiddleOfText...])
        return tokenStr        
    }
}
