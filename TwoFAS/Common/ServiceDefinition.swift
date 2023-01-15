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

import UIKit

public struct ServiceMatchRules: Hashable {
    public enum Field: String {
        case issuer
        case label
        case account
    }
    
    public enum Matcher: Hashable {
        case contains
        case startsWith
        case endsWith
        case equals
        case regex
    }
    
    public let field: Field
    public let text: String
    public let matcher: Matcher
    public let ignoreCase: Bool
}

public struct ServiceDefinition: Hashable {
    public let serviceTypeID: ServiceTypeID
    public let name: String
    public let issuer: [String]?
    public let tags: [String]?
    public let matchingRules: [ServiceMatchRules]?
    public let iconTypeID: IconTypeID
}

extension ServiceDefinition {
    var searchQuery: String {
        var value = name.lowercased()
        tags?.forEach({ tag in
            value += tag.lowercased()
        })
        return value
    }
}

public extension ServiceDefinition {
    var icon: UIImage {
        ServiceIcon.for(iconTypeID: iconTypeID)
    }
}
