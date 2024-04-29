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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public struct CategoryData: Equatable, Hashable {
    public let section: SectionData?
    public let services: [ServiceData]
    
    public static var empty: Self {
        .init(section: nil, services: [])
    }
}

public extension Array where Element == CategoryData {
    var allServices: [ServiceData] {
        reduce(into: [ServiceData]()) { result, category in
            result += category.services
        }
    }
    
    func indexPath(of serviceData: ServiceData) -> IndexPath? {
        for (section, category) in self.enumerated() {
            if let row = category.services.firstIndex(where: { $0.secret == serviceData.secret }) {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }
}
