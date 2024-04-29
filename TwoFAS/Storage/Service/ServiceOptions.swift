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

public enum ServiceOptions {
    public enum TrashOptions {
        case yes
        case no
        case all // default
    }
    
    case filterByPhrase(String?, sortBy: SortType, trashed: TrashOptions, ids: [ServiceTypeID])
    case findExistingBySecret(String)
    case findNotTrashedBySecret(String)
    case includeServices([String])
    case fromSection(SectionID?)
    case allTrashed
    case allNotTrashed
    case unknownServices
    case all
    case widget(filter: String?, excludedServices: [String])
}

extension ServiceOptions {
    var predicate: NSPredicate? {
        var andPredicates: [NSPredicate] = []
        
        switch self {
        case .filterByPhrase(let phrase, _, let trashed, let ids):
            if let phrase, !phrase.isEmpty {
                if ids.isEmpty {
                    andPredicates.append(Predicate.findByPhrase(phrase))
                } else {
                    andPredicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [
                        Predicate.findByPhrase(phrase),
                        Predicate.findByServiceTypes(ids)
                    ]))
                }
            } else {
                if !ids.isEmpty {
                    andPredicates.append(Predicate.findByServiceTypes(ids))
                }
            }
            if let trashPredicate = trashed.predicate {
                andPredicates.append(trashPredicate)
            }
        case .findExistingBySecret(let secret):
            andPredicates.append(Predicate.findBySecret(secret))
        case .findNotTrashedBySecret(let secret):
            andPredicates.append(contentsOf: [Predicate.findBySecret(secret), Predicate.notTrashedItems])
        case .includeServices(let services):
            andPredicates.append(contentsOf: [Predicate.services(services), Predicate.notTrashedItems])
        case .fromSection(let section):
            andPredicates.append(contentsOf: [Predicate.findBySection(section), Predicate.notTrashedItems])
        case .allTrashed:
            andPredicates.append(Predicate.trashedItems)
        case .allNotTrashed:
            andPredicates.append(Predicate.notTrashedItems)
        case .unknownServices:
            andPredicates.append(Predicate.unknownServices)
        case .all:
            andPredicates.append(contentsOf: [])
        case .widget(let phrase, let excludedServices):
            if let phrase, !phrase.isEmpty {
                andPredicates.append(Predicate.findByPhrase(phrase))
            }
            if !excludedServices.isEmpty {
                andPredicates.append(Predicate.excludeServices(excludedServices))
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
        case .filterByPhrase(_, let sortBy, _, _):
            switch sortBy {
            case .az:
                return [ServiceSortDescriptor.sortByNameAscending, ServiceSortDescriptor.sortByInfoAscending]
            case .za:
                return [ServiceSortDescriptor.sortByNameDescending, ServiceSortDescriptor.sortByInfoDescending]
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

extension ServiceOptions.TrashOptions {
    var predicate: NSPredicate? {
        switch self {
        case .yes:
            return Predicate.trashedItems
        case .no:
            return Predicate.notTrashedItems
        case .all:
            return nil
        }
    }
}

enum ServiceSortDescriptor {
    static let sectionID = NSSortDescriptor(key: #keyPath(ServiceEntity.sectionID), ascending: true)
    static let sectionOrder = NSSortDescriptor(key: #keyPath(ServiceEntity.sectionOrder), ascending: true)
    static let trashingDate = NSSortDescriptor(key: #keyPath(ServiceEntity.trashingDate), ascending: false)
    static let sortByNameAscending = NSSortDescriptor(
        key: #keyPath(ServiceEntity.name),
        ascending: true,
        selector: #selector(NSString.localizedStandardCompare)
    )
    static let sortByNameDescending = NSSortDescriptor(
        key: #keyPath(ServiceEntity.name),
        ascending: false,
        selector: #selector(NSString.localizedStandardCompare)
    )
    static let sortByInfoAscending = NSSortDescriptor(
        key: #keyPath(ServiceEntity.additionalInfo),
        ascending: true,
        selector: #selector(NSString.localizedStandardCompare)
    )
    static let sortByInfoDescending = NSSortDescriptor(
        key: #keyPath(ServiceEntity.additionalInfo),
        ascending: false,
        selector: #selector(NSString.localizedStandardCompare)
    )
}

enum Predicate {
    static let trashedItems = NSPredicate(format: "isTrashed == TRUE")
    static let notTrashedItems = NSPredicate(format: "isTrashed == FALSE")
    static let unknownServices = NSPredicate(
        format: "(serviceTypeID == NULL) AND ((rawIssuer != NULL) OR (otpAuth != NULL))"
    )
    
    static func findBySecret(_ secret: String) -> NSPredicate {
        NSPredicate(format: "secret == %@", secret)
    }
    
    static func services(_ services: [String]) -> NSPredicate {
        NSPredicate(format: "secret IN %@", services)
    }
    
    static func excludeServices(_ services: [String]) -> NSPredicate {
        NSPredicate(format: "NOT (secret IN %@)", services)
    }
    
    static func findByPhrase(_ phrase: String) -> NSPredicate {
        NSPredicate(format: "(name contains[c] %@) OR (additionalInfo contains[c] %@)", phrase, phrase)
    }
    
    static func findByServiceTypes(_ ids: [ServiceTypeID]) -> NSPredicate {
        NSPredicate(format: "serviceTypeID in %@", ids)
    }
    
    static func findBySection(_ section: SectionID?) -> NSPredicate {
        if let section {
            return NSPredicate(format: "sectionID == %@", section.uuidString)
        }
        return NSPredicate(format: "sectionID == NULL")
    }
}
