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

protocol ServiceListable {
    var name: String { get }
    var additionalInfo: String? { get }
    var serviceTypeID: ServiceTypeID? { get }
}

extension ServiceData: ServiceListable {}

/// In-memory equivalent of the SQL predicate and sort descriptors used by `ServiceOptions.filterByPhrase`.
enum ServiceListing {
    static func filter<T: ServiceListable>(_ items: [T], phrase: String?, ids: [ServiceTypeID]) -> [T] {
        let hasPhrase = phrase.map { !$0.isEmpty } ?? false
        guard hasPhrase || !ids.isEmpty else { return items }
        let idSet = Set(ids)
        
        return items.filter { item in
            if let phrase, hasPhrase,
               item.name.range(of: phrase, options: .caseInsensitive) != nil ||
                item.additionalInfo?.range(of: phrase, options: .caseInsensitive) != nil {
                return true
            }
            if let typeID = item.serviceTypeID, idSet.contains(typeID) {
                return true
            }
            return false
        }
    }
    
    static func sort<T: ServiceListable>(_ items: [T], by sort: SortType) -> [T] {
        switch sort {
        case .manual:
            return items
        case .az:
            return items.sorted { compare($0, $1) == .orderedAscending }
        case .za:
            return items.sorted { compare($0, $1) == .orderedDescending }
        }
    }
    
    // nil additionalInfo sorts before any value in ascending order (and last in descending).
    private static func compare<T: ServiceListable>(_ lhs: T, _ rhs: T) -> ComparisonResult {
        let byName = lhs.name.localizedStandardCompare(rhs.name)
        if byName != .orderedSame { return byName }
        switch (lhs.additionalInfo, rhs.additionalInfo) {
        case (nil, nil): return .orderedSame
        case (nil, _): return .orderedAscending
        case (_, nil): return .orderedDescending
        case (let l?, let r?): return l.localizedStandardCompare(r)
        }
    }
}
