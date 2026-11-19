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

struct Info: Hashable {
    static let id = "info"
    /// 4 – sealed records in `Config.vaultV3`, with the records of deletions
    static let version: Int = 4
    /// The version left in the Info record of a vault that was retired: no app version syncs with such a vault –
    /// the ones that still use it ask for an update
    static let retiredVersion: Int = 1000
    
    enum Encryption: String {
        case system
        case user
    }
    let version: Int = Self.version
    let encyption: Encryption = .system
}
