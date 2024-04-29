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
import StorageWatch

struct Category: Identifiable, Hashable {
    let id: UUID
    let name: String
    let services: [Service]
}

extension CategoryData {
    func toCategory() -> Category {
        let id: UUID = {
            if let section {
                return section.sectionID
            }
            return UUID()
        }()
        let name: String = {
            if let section {
                return section.title
            }
            return T.Tokens.myTokens
        }()
        return Category(id: id, name: name, services: services.toServices())
    }
}

extension Array where Element == CategoryData {
    func toCategories() -> [Category] {
        map { $0.toCategory() }
    }
}
