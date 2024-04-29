//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

extension Protection.CodeType: RawRepresentable {
    private enum Keys {
        static let PIN4 = "PIN4"
        static let PIN6 = "PIN6"
    }
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        if rawValue == Keys.PIN4 {
            self = .PIN4
        } else if rawValue == Keys.PIN6 {
            self = .PIN6
        } else {
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .PIN4: return Keys.PIN4
        case .PIN6: return Keys.PIN6
        }
    }
}

public extension Protection.CodeType {
    var intValue: Int {
        switch self {
        case .PIN4: return 4
        case .PIN6: return 6
        }
    }
}
