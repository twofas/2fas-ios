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

public protocol ServiceDefinitionDatabase: AnyObject {
    func listAll() -> [ServiceDefinition]
    func service(using serviceTypeID: ServiceTypeID) -> ServiceDefinition?
    func serviceName(for serviceTypeID: ServiceTypeID?) -> String?
    
    func findService(using issuer: String) -> ServiceDefinition?
    func findServices(byTag searchText: String) -> [ServiceDefinition]
    func findServicesByTagOrIssuer(
        _ searchText: String,
        exactMatch: Bool,
        useTags: Bool
    ) -> [ServiceDefinition]
    func findServices(domain searchText: String) -> [ServiceDefinition]
    
    func findLegacyService(using string: String) -> ServiceTypeID?
    func findLegacyIcon(using string: String) -> IconTypeID?
}

public final class ServiceDefinitionDatabaseImpl {
    private let db = ServiceDefinitionDatabaseGenerated()
    private let legacyExchangeDb = LegacyExchangeDatabase()
    private let legacyServiceDB: LegacyServiceDatabase = LegacyServiceDatabaseImpl()
    
    public init() {}
}

extension ServiceDefinitionDatabaseImpl: ServiceDefinitionDatabase {
    public func listAll() -> [ServiceDefinition] {
        db.services
    }
    
    public func service(using serviceTypeID: ServiceTypeID) -> ServiceDefinition? {
        db.services.first(where: { $0.serviceTypeID == serviceTypeID })
    }
    
    public func serviceName(for serviceTypeID: ServiceTypeID?) -> String? {
        guard let serviceTypeID else { return nil }
        return service(using: serviceTypeID)?.name
    }
    
    public func findLegacyService(using string: String) -> ServiceTypeID? {
        guard let serviceType = legacyExchangeDb.looselyCheckImportType(for: string) else { return nil }
        return legacyServiceDB.serviceTypeID(for: serviceType)
    }
    
    public func findLegacyIcon(using string: String) -> IconTypeID? {
        guard let serviceTypeID = findLegacyService(using: string),
              let iconTypeID = service(using: serviceTypeID)?.iconTypeID
        else { return nil }
        
        return iconTypeID
    }
    
    public func findService(using issuer: String) -> ServiceDefinition? {
        // TODO: Duplicated from New Code interactor - remove when migration is properly set up
        let definitions = listAll()
        for def in definitions {
            if let issuerList = def.issuer {
                for iss in issuerList {
                    if iss.lowercased() == issuer.lowercased() {
                        return def
                    }
                }
            }
            
            if let issuerRules = def.matchingRules?.filter({ $0.field == .issuer }), !issuerRules.isEmpty {
                for rule in issuerRules {
                    if rule.isMatching(for: issuer) {
                        return def
                    }
                }
            }
        }
        return nil
    }
    
    public func findServices(byTag searchText: String) -> [ServiceDefinition] {
        let query = searchText.uppercased()
        let definitions = listAll()
        return definitions.filter({ service in
            guard let tags = service.tags else { return false }
            return tags.contains(where: { $0.contains(query) })
        })
    }
    
    public func findServicesByTagOrIssuer(
        _ searchText: String,
        exactMatch: Bool,
        useTags: Bool
    ) -> [ServiceDefinition] {
        let query = searchText.uppercased()
        let definitions = listAll()
        return definitions.filter({ service in
            let name = service.name.uppercased()
            if exactMatch {
                if name == query {
                    return true
                }
            } else {
                if name.contains(query) {
                    return true
                }
            }
            
            if let issuerList = service.issuer {
                for issuer in issuerList {
                    if exactMatch {
                        if issuer.uppercased() == query {
                            return true
                        }
                    } else {
                        if issuer.uppercased().contains(query) {
                            return true
                        }
                    }
                }
            }
            
            if let issuerRules = service.matchingRules?.filter({ $0.field == .issuer }), !issuerRules.isEmpty {
                for rule in issuerRules {
                    if rule.isMatching(for: query) {
                        return true
                    }
                }
            }
            
            if useTags {
                return service.tags?.contains(where: {
                    if exactMatch {
                        return $0.uppercased() == query
                    } else {
                        return $0.uppercased().contains(query)
                    }
                }) ?? false
            }
            return false
        })
    }
    
    public func findServices(domain searchText: String) -> [ServiceDefinition] {
        let query = searchText.uppercased()
        let definitions = listAll()
        return definitions.filter({ service in
            query.contains(service.name.uppercased()) ||
            service.issuer?.first(where: { query.contains($0.uppercased()) }) != nil
        })
    }
}
