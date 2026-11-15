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

enum ServiceOptions {
    case findExistingBySecretHash(Data)
    case findNotTrashedBySecretHash(Data)
    case includeServices([Data])
    case fromSection(SectionID?)
    case allTrashed
    case allNotTrashed
    /// Name and additional info are encrypted, so only the manual order is applied in SQL
    case notTrashedSorted(SortType)
    case all
    case widget(excludedHashes: [Data])
}

extension ServiceOptions {
    var predicate: NSPredicate? {
        var andPredicates: [NSPredicate] = []
        
        switch self {
        case .findExistingBySecretHash(let secretHash):
            andPredicates.append(Predicate.findBySecretHash(secretHash))
        case .findNotTrashedBySecretHash(let secretHash):
            andPredicates.append(contentsOf: [Predicate.findBySecretHash(secretHash), Predicate.notTrashedItems])
        case .includeServices(let secretHashes):
            andPredicates.append(contentsOf: [Predicate.services(secretHashes), Predicate.notTrashedItems])
        case .fromSection(let section):
            andPredicates.append(contentsOf: [Predicate.findBySection(section), Predicate.notTrashedItems])
        case .allTrashed:
            andPredicates.append(Predicate.trashedItems)
        case .allNotTrashed, .notTrashedSorted:
            andPredicates.append(Predicate.notTrashedItems)
        case .all:
            andPredicates.append(contentsOf: [])
        case .widget(let excludedHashes):
            if !excludedHashes.isEmpty {
                andPredicates.append(Predicate.excludeServices(excludedHashes))
            }
            andPredicates.append(Predicate.notTrashedItems)
        }
        
        if andPredicates.isEmpty {
            return nil
        }
        if andPredicates.count == 1 {
            return andPredicates.first
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: andPredicates)
    }
    
    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .notTrashedSorted(let sortBy):
            switch sortBy {
            case .az, .za:
                return []
            case .manual:
                return [ServiceSortDescriptor.sectionID, ServiceSortDescriptor.sectionOrder]
            }
        case .allTrashed:
            return [ServiceSortDescriptor.trashingDate]
        default:
            return [ServiceSortDescriptor.sectionID, ServiceSortDescriptor.sectionOrder]
        }
    }
}

enum ServiceSortDescriptor {
    static let sectionID = NSSortDescriptor(key: #keyPath(ServiceEntity.sectionID), ascending: true)
    static let sectionOrder = NSSortDescriptor(key: #keyPath(ServiceEntity.sectionOrder), ascending: true)
    static let trashingDate = NSSortDescriptor(key: #keyPath(ServiceEntity.trashingDate), ascending: false)
}

enum Predicate {
    static let trashedItems = NSPredicate(format: "isTrashed == TRUE")
    static let notTrashedItems = NSPredicate(format: "isTrashed == FALSE")
    
    static func findBySecretHash(_ secretHash: Data) -> NSPredicate {
        NSPredicate(format: "secretHash == %@", secretHash as NSData)
    }
    
    static func services(_ secretHashes: [Data]) -> NSPredicate {
        NSPredicate(format: "secretHash IN %@", secretHashes)
    }
    
    static func excludeServices(_ secretHashes: [Data]) -> NSPredicate {
        NSPredicate(format: "NOT (secretHash IN %@)", secretHashes)
    }
    
    static func findBySection(_ section: SectionID?) -> NSPredicate {
        if let section {
            return NSPredicate(format: "sectionID == %@", section.uuidString)
        }
        return NSPredicate(format: "sectionID == NULL")
    }
}
