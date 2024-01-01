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

public extension Code {
    // ex. twofas_c://2e7849e8-f58b-405a-988b-536567ac5c1b
    static func checkTwoFASWebExtension(with data: String) -> String? {
        let components = data.replacingOccurrences(of: "://", with: "|").split(separator: "|")
        guard components.count == 2,
              let first = components.first,
              let last = components.last,
                first == "twofas_c" else { return nil }
     
        return String(last)
    }
}
