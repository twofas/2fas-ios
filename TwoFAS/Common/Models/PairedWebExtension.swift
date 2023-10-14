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

public struct PairedWebExtension {
    public let extensionID: ExtensionID
    public let name: String
    public let createdAt: Date
    public let modifiedAt: Date
    public let publicKey: String
    public let objectID: NSManagedObjectID
    
    public init(
        extensionID: ExtensionID,
        name: String,
        createdAt: Date,
        modifiedAt: Date,
        publicKey: String,
        objectID: NSManagedObjectID
    ) {
        self.extensionID = extensionID
        self.name = name
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.publicKey = publicKey
        self.objectID = objectID
    }
}
