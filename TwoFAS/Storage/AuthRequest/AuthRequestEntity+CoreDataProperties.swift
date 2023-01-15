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
import CoreData

extension AuthRequestEntity {
    @nonobjc static func request() -> NSFetchRequest<AuthRequestEntity> {
        NSFetchRequest<AuthRequestEntity>(entityName: "AuthRequestEntity")
    }

    @NSManaged var secret: String
    @NSManaged var extensionID: String
    @NSManaged var domain: String
    @NSManaged var lastUsed: Date
    @NSManaged var usedCount: Int32
    @NSManaged var creationDate: Date
}

extension AuthRequestEntity: Identifiable {}
