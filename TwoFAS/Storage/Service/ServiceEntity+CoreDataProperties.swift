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

extension ServiceEntity {
    @nonobjc static func request() -> NSFetchRequest<ServiceEntity> {
        NSFetchRequest<ServiceEntity>(entityName: "ServiceEntity")
    }

    @NSManaged var name: String
    @NSManaged var secret: String
    @NSManaged var serviceTypeID: UUID?
    @NSManaged var additionalInfo: String?
    @NSManaged var rawIssuer: String?
    @NSManaged var creationDate: Date
    @NSManaged var modificationDate: Date
    @NSManaged var tokenPeriod: NSNumber?
    @NSManaged var tokenLength: NSNumber
    @NSManaged var badgeColor: String?
    @NSManaged var iconTypeID: UUID
    @NSManaged var iconType: String
    @NSManaged var labelColor: String
    @NSManaged var labelTitle: String
    @NSManaged var sectionID: UUID?
    @NSManaged var sectionOrder: Int
    @NSManaged var algorithm: String
    @NSManaged var isTrashed: NSNumber
    @NSManaged var trashingDate: Date?
    @NSManaged var tokenType: String
    @NSManaged var counter: NSNumber?
    @NSManaged var otpAuth: String?
    @NSManaged var source: String
}
