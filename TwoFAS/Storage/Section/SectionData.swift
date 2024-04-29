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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public struct SectionData: Hashable {
    public let title: String
    public let sectionID: SectionID
    public let isCollapsed: Bool
    public let createdAt: Date
    public let modifiedAt: Date?
    
    let objectID: NSManagedObjectID?
    
    init(
        title: String,
        sectionID: SectionID,
        isCollapsed: Bool,
        createdAt: Date,
        modifiedAt: Date?,
        objectID: NSManagedObjectID
    ) {
        self.title = title
        self.sectionID = sectionID
        self.isCollapsed = isCollapsed
        self.objectID = objectID
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

extension SectionData {
    static func createFromManagedObject(_ entity: SectionEntity) -> SectionData {
        .init(
            title: entity.title,
            sectionID: entity.sectionID,
            isCollapsed: entity.isCollapsed,
            createdAt: entity.creationDate,
            modifiedAt: entity.modificationDate,
            objectID: entity.objectID
        )
    }
}
