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

extension TintColor {
    var localizedName: String {
        switch self {
        case .`default`: return T.Color.neutral
        case .lightBlue: return T.Color.lightBlue
        case .indigo: return T.Color.indigo
        case .purple: return T.Color.purple
        case .turquoise: return T.Color.turquoise
        case .green: return T.Color.green
        case .red: return T.Color.red
        case .orange: return T.Color.orange
        case .yellow: return T.Color.yellow
        case .pink: return T.Color.pink
        case .brown: return T.Color.brown
        }
    }
}
