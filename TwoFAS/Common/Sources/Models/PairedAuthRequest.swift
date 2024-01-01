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

public struct PairedAuthRequest: Equatable, Hashable {
    public let extensionID: ExtensionID
    public let secret: String
    public let domain: String
    public let usedCount: Int
    public let createdAt: Date
    public let lastUsedAt: Date
    public let objectID: NSManagedObjectID
    
    public init(
        extensionID: ExtensionID,
        secret: String,
        domain: String,
        usedCount: Int,
        createdAt: Date,
        lastUsedAt: Date,
        objectID: NSManagedObjectID
    ) {
        self.extensionID = extensionID
        self.secret = secret
        self.domain = domain
        self.usedCount = usedCount
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.objectID = objectID
    }
}
