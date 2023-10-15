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
import Storage
import Common
import Data

protocol SelectServiceModuleInteracting: AnyObject {
    func listServices(filter: String?, for domain: String) -> [SelectServiceSection]
    func browserName(for extensionID: ExtensionID) -> String
}

final class SelectServiceModuleInteractor {
    private let listingInteractor: ServiceListingInteracting
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting
    private let sortInteractor: SortInteracting
    private let pairedBrowsers: PairingWebExtensionInteracting
    
    private var bestServiceTypes: [ServiceTypeID]?
    
    init(
        listingInteractor: ServiceListingInteracting,
        serviceDefinitionInteractor: ServiceDefinitionInteracting,
        sortInteractor: SortInteracting,
        pairedBrowsers: PairingWebExtensionInteracting
    ) {
        self.listingInteractor = listingInteractor
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
        self.sortInteractor = sortInteractor
        self.pairedBrowsers = pairedBrowsers
    }
}

extension SelectServiceModuleInteractor: SelectServiceModuleInteracting {
    func listServices(filter: String?, for domain: String) -> [SelectServiceSection] {
        let currentSort = sortInteractor.currentSort
        let ids: [ServiceTypeID] = {
            guard let filter else { return [] }
            return serviceDefinitionInteractor.findServices(byTag: filter)
                .map({ $0.serviceTypeID })
        }()
        let list = listingInteractor
            .listAllWithingCategories(for: filter, sorting: currentSort, ids: ids)
            .filter({ !$0.services.isEmpty })
        
        var bestMatch: [ServiceData] = []
        
        if filter == nil {
            if bestServiceTypes == nil {
                bestServiceTypes = serviceDefinitionInteractor.findServices(domain: domain)
                    .map({ $0.serviceTypeID })
            }
            
            if let bestServiceTypes {
                list.forEach { category in
                    category.services.forEach { service in
                        if domain.uppercased().contains(service.name.uppercased()) {
                            bestMatch.append(service)
                        } else if let typeID = service.serviceTypeID, bestServiceTypes.contains(typeID) {
                            bestMatch.append(service)
                        }
                    }
                }
            }
        }
        
        var categories = list.map({ category -> SelectServiceSection in
            let cells = category.services.map({ serviceData in SelectServiceCell(serviceData: serviceData) })
            let title: SelectServiceSection.TitleType = {
                if let title = category.section?.title {
                    return .title(title)
                }
                return .noTitle
            }()
            return SelectServiceSection(title: title, cells: cells)
        })
        
        if !bestMatch.isEmpty {
            let cells = bestMatch.map({ serviceData in SelectServiceCell(serviceData: serviceData) })
            let bestMatchCategory = SelectServiceSection(title: .bestMatch, cells: cells)
            if categories.isEmpty {
                categories = [bestMatchCategory]
            } else {
                categories.insert(bestMatchCategory, at: 0)
            }
        }
        
        return categories
    }
    
    func browserName(for extensionID: ExtensionID) -> String {
        pairedBrowsers.listAll().first(where: { $0.extensionID == extensionID })?.name ?? T.Browser.unkownName
    }
}
