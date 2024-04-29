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

extension ServiceData {
    var comparisionDate: Date {
        modifiedAt
    }
}

extension CommonSectionData {
    var comparisionDate: Date {
        if let modificationDate {
            return modificationDate
        }
        return creationDate
    }
}

extension Info {
    var comparisionDate: Date {
        Date(timeIntervalSince1970: 1665947380)
    }
}

struct CommonDataIndex: Equatable {
    static func == (lhs: CommonDataIndex, rhs: CommonDataIndex) -> Bool {
        guard lhs.index == rhs.index && lhs.type == rhs.type else { return false }
        switch lhs.type {
        case .section: return (lhs.item as? CommonSectionData) == (rhs.item as? CommonSectionData)
        case .service1: return (lhs.item as? ServiceData) == (rhs.item as? ServiceData)
        case .service2: return (lhs.item as? ServiceData) == (rhs.item as? ServiceData)
        case .info: return (lhs.item as? Info) == (rhs.item as? Info)
        }
    }
    
    let index: Int
    let item: Any
    let type: RecordType
    
    var comparisionDate: Date {
        let date: Date?
        switch type {
        case .section: date = (item as? CommonSectionData)?.comparisionDate
        case .service1: date = (item as? ServiceData)?.comparisionDate
        case .service2: date = (item as? ServiceData)?.comparisionDate
        case .info: date = (item as? Info)?.comparisionDate
        }
        return date ?? Date.distantPast
    }
    
    func isEqual(to other: Any) -> Bool {
        switch type {
        case .section: return (item as? CommonSectionData) == (other as? CommonSectionData)
        case .service1: return (item as? ServiceData) == (other as? ServiceData)
        case .service2: return (item as? ServiceData) == (other as? ServiceData)
        case .info:  return (item as? Info) == (other as? Info)
        }
    }
}
