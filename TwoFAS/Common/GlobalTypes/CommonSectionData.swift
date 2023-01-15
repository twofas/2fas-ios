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

public struct CommonSectionData: Hashable {
    public let name: String
    public let sectionID: String
    public let creationDate: Date
    public let modificationDate: Date?
    public let isCollapsed: Bool
    
    public init(name: String, sectionID: String, creationDate: Date, modificationDate: Date?, isCollapsed: Bool) {
        self.name = name
        self.sectionID = sectionID
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.isCollapsed = isCollapsed
    }
    
    public static func == (lhs: CommonSectionData, rhs: CommonSectionData) -> Bool {
        // DO NOT add isCollapsed!
        lhs.name == rhs.name
        && lhs.sectionID == rhs.sectionID
        && lhs.creationDate == rhs.creationDate
        && lhs.modificationDate == rhs.modificationDate
    }
}
