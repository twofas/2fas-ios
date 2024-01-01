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

enum QueryItemsType: Equatable {
    static func == (lhs: QueryItemsType, rhs: QueryItemsType) -> Bool {
        switch (lhs, rhs) {
        case (
            .issuer(_), .issuer(_)),
            (.secret(_), .secret(_)),
            (.period(_), .period(_)),
            (.digits(_), .digits(_)),
            (.algorithm(_), .algorithm(_)),
            (.counter(_), .counter(_)):
            return true
        default:
            return false
        }
    }
    
    case issuer(String)
    case secret(String)
    case digits(String)
    case period(String)
    case algorithm(String)
    case counter(String)
    case other(String, String)
    
    init(key: String, value: String) {
        let secretKey = "secret"
        let issuerKey = "issuer"
        let periodKey = "period"
        let digitsKey = "digits"
        let algorithmKey = "algorithm"
        let counterKey = "counter"
        
        if key == secretKey {
            self = .secret(value)
        } else if key == issuerKey {
            self = .issuer(value)
        } else if key == periodKey {
            self = .period(value)
        } else if key == digitsKey {
            self = .digits(value)
        } else if key == algorithmKey {
            self = .algorithm(value)
        } else if key == counterKey {
            self = .counter(value)
        } else {
            self = .other(key, value)
        }
    }
    
    var value: String {
        switch self {
        case .issuer(let item):
            return item
        case .secret(let item):
            return item
        case .other(_, let item):
            return item
        case .period(let item):
            return item
        case .digits(let item):
            return item
        case .algorithm(let item):
            return item
        case .counter(let item):
            return item
        }
    }
    
    var key: String {
        let secretKey = "secret"
        let issuerKey = "issuer"
        let periodKey = "period"
        let digitsKey = "digits"
        let algorithmKey = "algorithm"
        let counterKey = "counter"
        
        switch self {
        case .other(let k, _):
            return k
        case .issuer:
            return issuerKey
        case .secret:
            return secretKey
        case .period:
            return periodKey
        case .digits:
            return digitsKey
        case .algorithm:
            return algorithmKey
        case .counter:
            return counterKey
        }
    }
}
