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
import CoreData
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

final class StorageRepositoryImpl: StorageRepository {
    private let coreDataStack: CoreDataStack
    
    var context: NSManagedObjectContext {
        coreDataStack.context
    }
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
        
    func save() {
        coreDataStack.save()
    }
    
    // MARK: - StorageRepository Protocol implementation
    
    var hasServices: Bool {
        ServiceEntity.countNotTrashed(on: context) > 0
    }
    
    func trashService(_ serviceData: ServiceData) -> (deleted: String, modified: [String]) {
        ServiceEntity.markAsTrashed(on: context, secret: serviceData.secret)
        guard let serviceAfterTrashing = ServiceEntity.getService(on: context, secret: serviceData.secret) else {
            Log("Can't find item to trash for service: \(serviceData.debugServiceType)", module: .storage)
            save()
            return (deleted: serviceData.secret, modified: [])
        }
        
        save()
        
        let sectionList = ServiceEntity.listAll(on: context, sectionID: serviceAfterTrashing.sectionID)
        sectionList.updateOrder()
        
        let modified = listUpdatedServices()
            .readableSecrets
        
        save()
        
        return (deleted: serviceData.secret, modified: modified)
    }
    
    func untrashService(_ serviceData: ServiceData) -> (added: String?, modified: [String]) {
        guard let serviceForUntrasing = ServiceEntity.getService(on: context, secret: serviceData.secret) else {
            Log("Can't find item to untrash for service: \(serviceData.debugServiceType)", module: .storage)
            return (added: nil, modified: [])
        }
        
        var sectionList: [ServiceEntity]
        if let sectionID = serviceForUntrasing.sectionID {
            if SectionEntity.section(on: context, for: sectionID) != nil {
                sectionList = ServiceEntity.listAll(on: context, sectionID: sectionID)
            } else {
                sectionList = ServiceEntity.listAll(on: context, sectionID: nil)
                serviceForUntrasing.sectionID = nil
            }
        } else {
            sectionList = ServiceEntity.listAll(on: context, sectionID: nil)
        }
        
        sectionList.append(serviceForUntrasing)
        sectionList.updateOrder()
        
        ServiceEntity.markAsUntrashed(on: context, secret: serviceData.secret)
        
        let untrashedSecret = serviceForUntrasing.content?.secret
        
        let modified = listUpdatedServices()
            .readableSecrets
            .filter({ $0 != untrashedSecret })
        
        save()
        
        return (added: untrashedSecret, modified: modified)
    }
    
    func listTrashedServices() -> [ServiceData] {
        ServiceEntity
            .listAllTrashed(on: context)
            .toServiceData()
    }
    
    func serviceExists(for secret: String) -> ServiceExistenceStatus {
        guard let service = ServiceEntity.getService(on: context, secret: secret) else {
            return .no
        }
        if service.isTrashed.boolValue == true {
            return .trashed
        }
        return .yes
    }
    
    func trashedService(for secret: String) -> ServiceData? {
        ServiceEntity.getService(on: context, secret: secret)?
            .toServiceData()
    }
    
    func listAllNotTrashed() -> [ServiceData] {
        ServiceEntity
            .listAllNotTrashed(on: context)
            .toServiceData()
    }
    
    func addService(
        name: String,
        secret: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        tokenPeriod: Period?,
        tokenLength: Digits,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        algorithm: Algorithm,
        counter: Int?,
        tokenType: TokenType,
        source: ServiceSource
    ) -> String {
        let date = Date()
        ServiceEntity.create(
            on: coreDataStack.context,
            name: name,
            secret: secret,
            serviceTypeID: serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            otpAuth: otpAuth,
            creationDate: date,
            modificationDate: date,
            tokenPeriod: tokenPeriod?.rawValue,
            tokenLength: tokenLength.rawValue,
            badgeColor: badgeColor?.rawValue,
            iconType: iconType.rawValue,
            iconTypeID: iconTypeID,
            labelColor: labelColor.rawValue,
            labelTitle: labelTitle,
            sectionID: nil,
            sectionOrder: nil,
            algorithm: algorithm.rawValue,
            counter: counter,
            tokenType: tokenType.rawValue,
            source: source.rawValue
        )
        
        save()
        
        return secret
    }
    
    func addService(
        name: String,
        secret: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        tokenPeriod: Period?,
        tokenLength: Digits,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        algorithm: Algorithm,
        counter: Int?,
        tokenType: TokenType,
        sectionID: SectionID?,
        source: ServiceSource
    ) -> String {
        let date = Date()
        let targetSectionServicesCount = ServiceEntity.listAll(on: context, sectionID: sectionID).count
        
        ServiceEntity.create(
            on: coreDataStack.context,
            name: name,
            secret: secret,
            serviceTypeID: serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            otpAuth: otpAuth,
            creationDate: date,
            modificationDate: date,
            tokenPeriod: tokenPeriod?.rawValue,
            tokenLength: tokenLength.rawValue,
            badgeColor: badgeColor?.rawValue,
            iconType: iconType.rawValue,
            iconTypeID: iconTypeID,
            labelColor: labelColor.rawValue,
            labelTitle: labelTitle,
            sectionID: sectionID,
            sectionOrder: targetSectionServicesCount,
            algorithm: algorithm.rawValue,
            counter: counter,
            tokenType: tokenType.rawValue,
            source: source.rawValue
        )
        
        save()
        
        return secret
    }
    
    @discardableResult
    func updateService(
        _ serviceData: ServiceData,
        name: String,
        additionalInfo: String?,
        badgeColor: TintColor?,
        iconType: IconType,
        iconTypeID: IconTypeID,
        labelColor: TintColor,
        labelTitle: String,
        counter: Int?
    ) -> String {
        ServiceEntity.update(
            on: coreDataStack.context,
            name: name,
            secret: serviceData.secret,
            additionalInfo: additionalInfo,
            modificationDate: Date(),
            badgeColor: badgeColor?.rawValue,
            iconType: iconType.rawValue,
            iconTypeID: iconTypeID,
            labelColor: labelColor.rawValue,
            labelTitle: labelTitle,
            counter: counter
        )
        
        save()
        
        return serviceData.secret
    }
    
    func deleteServices(_ services: [ServiceData]) {
        services.forEach {
            Log("Deleting Service: \($0.debugServiceType)", module: .storage)
            ServiceEntity.delete(on: context, secret: $0.secret)
        }
        save()
    }
    
    func deleteService(_ serviceData: ServiceData) {
        Log("Deleting Service: \(serviceData.debugServiceType)", module: .storage)
        ServiceEntity.delete(on: context, secret: serviceData.secret)
        save()
    }
    
    func listAllExistingServices() -> [ServiceData] {
        ServiceEntity.listAllExisting(on: context)
            .toServiceData()
    }
    
    func listAllWithingCategories(
        for phrase: String?,
        sorting: SortType = .az,
        ids: [ServiceTypeID] = []
    ) -> [CategoryData] {
        let allSections = SectionEntity
            .listAll(on: coreDataStack.context)
            .transformToSectionData()
        let allServices = ServiceEntity
            .listItems(on: coreDataStack.context, phrase: phrase, sort: sorting, ids: ids)
            .groupByCategory
            .mapValues { $0.toServiceData() }
        
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
    
    func findService(for secret: String) -> ServiceData? {
        ServiceEntity.findService(on: context, secret: secret)?
            .toServiceData()
    }
    
    func findAllUnknownServices() -> [ServiceData] {
        ServiceEntity.findAllUnknownServices(on: coreDataStack.context)
            .toServiceData()
    }
    
    func countServicesNotTrashed() -> Int {
        ServiceEntity.countNotTrashed(on: coreDataStack.context)
    }
    
    func incrementCounter(for secret: String) -> String? {
        guard let serviceData = findService(for: secret) else { return nil }
        let currentCounter = serviceData.counter ?? TokenType.hotpDefaultValue
        return updateService(
            serviceData,
            name: serviceData.name,
            additionalInfo: serviceData.additionalInfo,
            badgeColor: serviceData.badgeColor,
            iconType: serviceData.iconType,
            iconTypeID: serviceData.iconTypeID,
            labelColor: serviceData.labelColor,
            labelTitle: serviceData.labelTitle,
            counter: currentCounter + 1
        )
    }
}

private extension StorageRepositoryImpl {
    func listUpdatedServices() -> [ServiceEntity] {
       ServiceEntity.listAllExisting(on: context)
            .filter { $0.isUpdated }
    }
}
