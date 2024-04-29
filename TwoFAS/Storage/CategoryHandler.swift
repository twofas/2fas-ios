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

public final class CategoryHandler {
    private let sectionHandler: SectionHandler
    private let serviceHandler: ServiceHandler
    
    init(sectionHandler: SectionHandler, serviceHandler: ServiceHandler) {
        self.sectionHandler = sectionHandler
        self.serviceHandler = serviceHandler
    }
    
    public func listAll(sort: SortType) -> [CategoryData] {
        services(for: nil, sort: sort, ids: [])
    }
    
    public func findServices(for phrase: String, sort: SortType, ids: [ServiceTypeID]) -> [CategoryData] {
        services(for: phrase, sort: sort, ids: ids)
    }
    
    public func move(service: ServiceData, from oldIndex: Int, to newIndex: Int, newSection: SectionData?) {
        serviceHandler.move(
            from: oldIndex,
            currentSectionID: service.sectionID,
            to: newIndex,
            newSectionID: newSection?.sectionID
        )
    }
    
    public func create(with title: String) {
        sectionHandler.create(with: title)
    }
    
    public func collapseAction(for section: SectionData, shouldCollapse: Bool) {
        if shouldCollapse {
            sectionHandler.collapse(section)
        } else {
            sectionHandler.expand(section)
        }
    }
    
    public func moveDown(_ section: SectionData) {
        sectionHandler.moveDown(section: section)
    }
    
    public func moveUp(_ section: SectionData) {
        sectionHandler.moveUp(section: section)
    }
    
    public func rename(_ section: SectionData, with title: String) {
        sectionHandler.update(section, with: title)
    }
    
    public func delete(_ section: SectionData) {
        serviceHandler.clearCategory(for: section.sectionID)
        sectionHandler.delete(section)
    }
    
    private func services(for phrase: String?, sort: SortType, ids: [ServiceTypeID]) -> [CategoryData] {
        let allSections = sectionHandler.listAll()
        let allServices = serviceHandler.listAllServicesWithinSections(phrase: phrase, sort: sort, ids: ids)
        
        var result: [CategoryData] = []
        
        if let servicesWithoutCategory = allServices[nil] {
            result.append(CategoryData(section: nil, services: servicesWithoutCategory))
        }
        
        result.append(contentsOf: allSections.map { section -> CategoryData in
            let services: [ServiceData] = allServices[section.sectionID] ?? []
            return CategoryData(section: section, services: services)
        })
        
        return result
    }
}

extension CategoryHandler: WidgetServiceHandlerType {
    public func listAll(search: String?, exclude: [ServiceID]) -> [WidgetCategory] {
        let allSections = sectionHandler.listAll()
        let allServices = serviceHandler.listAllForWidget(search: search, exclude: exclude)
            .mapValues { $0.transformToWidgetService() }
        
        var result: [WidgetCategory] = []
        
        if let servicesWithoutCategory = allServices[nil], !servicesWithoutCategory.isEmpty {
            let services: [WidgetService] = servicesWithoutCategory
            result.append(WidgetCategory(categoryName: nil, services: services))
        }
        
        result.append(contentsOf: allSections.map { section -> WidgetCategory in
            let services: [WidgetService] = allServices[section.sectionID] ?? []
            return WidgetCategory(categoryName: section.title, services: services)
        })
        
        return result
    }
    
    public func listServices(with ids: [ServiceID]) -> [WidgetService] {
        serviceHandler.list(services: ids).transformToWidgetService()
    }
    
    public func hasServices() -> Bool {
        serviceHandler.hasServices
    }
}

private extension Collection where Element == ServiceEntity {
    func transformToWidgetService() -> [WidgetService] {
        map { service in
            WidgetService(
                serviceID: service.secret.decrypt(),
                serviceName: service.name,
                serviceTypeID: service.serviceTypeID,
                iconType: IconType(optionalWithDefaultRawValue: service.iconType),
                iconTypeID: service.iconTypeID,
                labelTitle: service.labelTitle,
                labelColor: TintColor(optionalWithDefaultRawValue: service.labelColor),
                serviceInfo: service.additionalInfo,
                period: Period.create(service.tokenPeriod?.intValue),
                digits: Digits.create(service.tokenLength.intValue),
                algorithm: Algorithm.create(service.algorithm),
                tokenType: TokenType.create(service.tokenType)
            )
        }
    }
}
