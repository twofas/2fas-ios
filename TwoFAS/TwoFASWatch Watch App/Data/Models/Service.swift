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

import SwiftUI
import CommonWatch

struct Service: Identifiable, Hashable {
    let id: String
    let name: String
    let additionalInfo: String?
    let iconType: IconType
    let iconTypeID: IconTypeID
    let labelColor: Color
    let labelTitle: String
    let badgeColor: Color
}

extension ServiceData {
    func toService() -> Service {
        Service(
            id: secret,
            name: name,
            additionalInfo: additionalInfo,
            iconType: iconType,
            iconTypeID: iconTypeID,
            labelColor: Color(labelColor.color),
            labelTitle: labelTitle,
            badgeColor: Color(badgeColor?.color ?? TintColor.default.color)
        )
    }
}

extension Array where Element == ServiceData {
    func toServices() -> [Service] {
        map { $0.toService() }
    }
}
