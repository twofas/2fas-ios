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
enum HTTPMethod: Equatable {
    internal enum HasBody {
        case yes
        case no
        case unlikely
    }
    
    case GET
    case PUT
    case HEAD
    case POST
    case PATCH
    case TRACE
    case DELETE
    
    internal var hasRequestBody: HasBody {
        switch self {
        case .TRACE:
            return .no
        case .POST, .PUT, .PATCH:
            return .yes
        case .GET, .HEAD, .DELETE:
            fallthrough
        default:
            return .unlikely
        }
    }
}

extension HTTPMethod: RawRepresentable {
    public var rawValue: String {
        switch self {
        case .GET:
            return "GET"
        case .PUT:
            return "PUT"
        case .HEAD:
            return "HEAD"
        case .POST:
            return "POST"
        case .PATCH:
            return "PATCH"
        case .TRACE:
            return "TRACE"
        case .DELETE:
            return "DELETE"
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
        case "GET":
            self = .GET
        case "PUT":
            self = .PUT
        case "HEAD":
            self = .HEAD
        case "POST":
            self = .POST
        case "PATCH":
            self = .PATCH
        case "TRACE":
            self = .TRACE
        case "DELETE":
            self = .DELETE
        default:
            self = .GET
        }
    }
}
// swiftlint:enable all
