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

// swiftlint:disable no_magic_numbers
enum AppLockAttempts: String, CaseIterable, Equatable {
    case try3 = "3 tries"
    case try5 = "5 tries"
    case try10 = "10 tries"
    case noLimit = "no limit"
    
    var value: Int {
        switch self {
        case .try3: return 3
        case .try5: return 5
        case .try10: return 10
        case .noLimit: return Int.max
        }
    }
}

enum AppLockBlockTime: String, CaseIterable, Equatable {
    case min3 = "3 minutes"
    case min5 = "5 minutes"
    case min10 = "10 minutes"
    
    var value: Int {
        switch self {
        case .min3: return 3
        case .min5: return 5
        case .min10: return 10
        }
    }
}
