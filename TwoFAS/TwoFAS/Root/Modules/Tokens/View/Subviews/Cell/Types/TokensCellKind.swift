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

extension ListStyle {
    var cellKind: TokensCellKind {
        switch self {
        case .default: return .normal
        case .compact: return .compact
        case .large: return .large
        }
    }
}

enum TokensCellKind {
    case compact
    case normal
    case large
    case edit
    case pass
}

extension TokensCellKind {
    var iconDimension: CGFloat {
        switch self {
        case .normal, .large: return 52
        case .compact, .edit: return 40
        case .pass: return TokensPassCell.height
        }
    }

    var iconImageDimension: CGFloat {
        switch self {
        case .normal, .large: return 32
        case .compact, .edit: return 24
        case .pass: return TokensPassCell.height
        }
    }
}
