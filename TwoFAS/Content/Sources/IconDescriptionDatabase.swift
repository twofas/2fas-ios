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

import UIKit
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public protocol IconDescriptionDatabase: AnyObject {
    func name(for iconTypeID: IconTypeID) -> String?
    func iconDescription(for iconTypeID: IconTypeID) -> IconDescription?
    func listAll() -> [IconDescription]
    func grouppedList() -> [IconDescriptionGroup]
}

public final class IconDescriptionDatabaseImpl {
    public static var bundle: Bundle {
        Bundle(for: IconDescriptionDatabaseImpl.self)
    }
    private let database = IconDescriptionDatabaseGenerated()
    public init() {}
}

extension IconDescriptionDatabaseImpl: IconDescriptionDatabase {
    public func name(for iconTypeID: IconTypeID) -> String? {
        iconDescription(for: iconTypeID)?.name
    }
    
    public func iconDescription(for iconTypeID: IconTypeID) -> IconDescription? {
        database.icons.first(where: { $0.iconTypeID == iconTypeID })
    }
    
    public func listAll() -> [IconDescription] {
        database.icons
    }
    
    public func grouppedList() -> [IconDescriptionGroup] {
        let all = listAll()
        
        let grouped: [IconDescriptionGroup] = Dictionary(grouping: all, by: { def -> String in
            let first = def.name.first!
            if first.isNumber {
                return "0-9"
            } else {
                return String(first.uppercased())
            }
        })
            .sorted(by: { $0.key < $1.key })
            .map { key, icons in
                let sortedIcons = icons.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                return IconDescriptionGroup(title: key, icons: sortedIcons)
            }
        
        return grouped
    }
}
