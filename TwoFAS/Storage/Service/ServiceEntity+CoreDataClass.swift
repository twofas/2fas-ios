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

@objc(ServiceEntity)
final class ServiceEntity: NSManagedObject {
    typealias ServicesWithinSections = [SectionID?: [ServiceEntity]]
    
    @nonobjc private static let entityName = "ServiceEntity"
    
    @nonobjc static func update(
        on context: NSManagedObjectContext,
        name: String,
        encryptedSecret: String,
        additionalInfo: String?,
        modificationDate: Date,
        badgeColor: String?,
        iconType: String,
        iconTypeID: IconTypeID,
        labelColor: String,
        labelTitle: String,
        counter: Int?
    ) {
        
        let services = listAllExisting(on: context)
        guard let serviceForUpdating = services.first(where: { service in service.secret == encryptedSecret }) else {
            Log("Can't find service for updating on local storage", module: .storage)
            return
        }
        
        serviceForUpdating.name = name
        serviceForUpdating.additionalInfo = additionalInfo
        serviceForUpdating.modificationDate = modificationDate

        if let badgeColor {
            serviceForUpdating.badgeColor = badgeColor
        }
        serviceForUpdating.iconType = iconType
        serviceForUpdating.iconTypeID = iconTypeID
        serviceForUpdating.labelColor = labelColor
        serviceForUpdating.labelTitle = labelTitle

        if let counter {
            serviceForUpdating.counter = NSNumber(value: counter)
        }
    }
    
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        name: String,
        encryptedSecret: String,
        serviceTypeID: ServiceTypeID?,
        additionalInfo: String?,
        rawIssuer: String?,
        otpAuth: String?,
        creationDate: Date,
        modificationDate: Date,
        tokenPeriod: Int?,
        tokenLength: Int,
        badgeColor: String?,
        iconType: String,
        iconTypeID: IconTypeID,
        labelColor: String,
        labelTitle: String,
        sectionID: SectionID?,
        sectionOrder: Int?,
        algorithm: String,
        counter: Int?,
        tokenType: String,
        source: String
    ) {
        let service = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! ServiceEntity
        
        service.name = name
        service.secret = encryptedSecret
        service.serviceTypeID = serviceTypeID
        service.additionalInfo = additionalInfo
        service.rawIssuer = rawIssuer
        service.otpAuth = otpAuth
        service.modificationDate = modificationDate
        service.creationDate = creationDate
        if let tokenPeriod {
            service.tokenPeriod = NSNumber(value: tokenPeriod)
        }
        service.tokenLength = NSNumber(value: tokenLength)
        service.badgeColor = badgeColor
        service.iconType = iconType
        service.iconTypeID = iconTypeID
        service.labelColor = labelColor
        service.labelTitle = labelTitle
        service.sectionID = sectionID
        service.algorithm = algorithm
        service.isTrashed = NSNumber(value: false)
        service.trashingDate = nil
        service.tokenType = tokenType
        service.source = source
        if let counter {
            service.counter = NSNumber(value: counter)
        }
        let order: Int = {
            if let sectionOrder {
                return sectionOrder
            }
            return lastItemOrder(on: context, in: sectionID)
        }()
        service.sectionOrder = order
    }
    
    @nonobjc static func delete(on context: NSManagedObjectContext, encryptedSecret: String) {
        let services = listAllExisting(on: context)
        guard let serviceForDeletition = services.first(where: { $0.secret == encryptedSecret })
        else { Log("Can't find service for deletition on local storage", module: .storage); return }
        var sectionList = listAll(on: context, sectionID: serviceForDeletition.sectionID)
        if let index = sectionList.firstIndex(of: serviceForDeletition) {
            sectionList.remove(at: index)
            updateOrder(of: sectionList)
        }
        delete(on: context, serviceEntity: serviceForDeletition)
    }
    
    @nonobjc static func markAsTrashed(on context: NSManagedObjectContext, encryptedSecret: String) {
        let services = listAllExisting(on: context)
        guard let serviceForTrashing = services.first(where: { $0.secret == encryptedSecret })
        else { Log("Can't find service for trashing on local storage", module: .storage); return }
        serviceForTrashing.isTrashed = NSNumber(value: true)
        serviceForTrashing.trashingDate = Date()
    }
    
    @nonobjc static func markAsUntrashed(on context: NSManagedObjectContext, encryptedSecret: String) {
        let trashedServices = listAllTrashed(on: context)
        guard let serviceForUntrashing = trashedServices.first(where: { $0.secret == encryptedSecret })
        else { Log("Can't find service for untrashing on local storage", module: .storage); return }
        
        serviceForUntrashing.isTrashed = NSNumber(value: false)
        serviceForUntrashing.trashingDate = nil
    }
    
    @nonobjc static func getService(on context: NSManagedObjectContext, encryptedSecret: String) -> ServiceEntity? {
        let list = listItemsWithOptions(on: context, options: .findExistingBySecret(encryptedSecret))
        
        // If something went wrong (wrong migration, some bugs) -> remove duplicated entries instead of:
        if list.count > 1 {
            let itemsForDeletition = list[1...]
            for item in itemsForDeletition {
                delete(on: context, serviceEntity: item)
            }
        }
        
        return list.first
    }
    
    @nonobjc static func findService(on context: NSManagedObjectContext, encryptedSecret: String) -> ServiceEntity? {
        let list = listItemsWithOptions(on: context, options: .findNotTrashedBySecret(encryptedSecret))
        
        // If something went wrong (wrong migration, some bugs) -> remove duplicated entries instead of:
        if list.count > 1 {
            let itemsForDeletition = list[1...]
            for item in itemsForDeletition {
                delete(on: context, serviceEntity: item)
            }
        }
        
        return list.first
    }
    
    @nonobjc static func move(
        on context: NSManagedObjectContext,
        from currentIndex: Int,
        currentSectionID: SectionID?,
        to newIndex: Int,
        newSectionID: SectionID?
    ) -> [ServiceEntity] {
        guard currentSectionID != newSectionID else {
            let servicesFromCurrent = listItemsInSection(on: context, sectionID: currentSectionID)
            let serviceToMove = servicesFromCurrent[currentIndex]
            updateOrder(of: servicesFromCurrent)
            var sortedServicesFromCurrent = servicesFromCurrent.sorted { $0.sectionOrder < $1.sectionOrder }
            sortedServicesFromCurrent.move(serviceToMove, to: newIndex)
            updateOrder(of: sortedServicesFromCurrent)
            return listUpdated(on: context)
        }
        
        var servicesFromCurrent = listItemsInSection(on: context, sectionID: currentSectionID)
        guard servicesFromCurrent[safe: currentIndex] != nil else { return [] }
        let serviceToMove = servicesFromCurrent.remove(at: currentIndex)
        updateOrder(of: servicesFromCurrent)
        
        let servicesFromNew = listItemsInSection(on: context, sectionID: newSectionID)
        updateOrder(of: servicesFromNew)
        var sortedServicesFromNew = servicesFromNew.sorted { $0.sectionOrder < $1.sectionOrder }
        sortedServicesFromNew.insert(serviceToMove, at: newIndex)
        updateOrder(of: sortedServicesFromNew)
        serviceToMove.sectionID = newSectionID
        return listUpdated(on: context)
    }
    
    @nonobjc static func delete(on context: NSManagedObjectContext, serviceEntity: ServiceEntity) {
        Log("Deleting entity of type: \(serviceEntity.debugServiceType)", module: .storage)
        context.delete(serviceEntity)
    }

    // MARK: - Shortcuts
    
    @nonobjc static func listAllTrashed(on context: NSManagedObjectContext) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .allTrashed)
    }
    
    @nonobjc static func listItemsInSection(
        on context: NSManagedObjectContext,
        sectionID: SectionID?
    ) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .fromSection(sectionID))
    }
    
    @nonobjc static func listItems(
        on context: NSManagedObjectContext,
        phrase: String?,
        sort: SortType,
        ids: [ServiceTypeID]
    ) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .filterByPhrase(phrase, sortBy: sort, trashed: .no, ids: ids))
    }
    
    @nonobjc static func listAllExisting(on context: NSManagedObjectContext) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .all)
    }
    
    @nonobjc static func findAllUnknownServices(on context: NSManagedObjectContext) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .unknownServices)
    }
    
    @nonobjc static func list(on context: NSManagedObjectContext, services: [ServiceID]) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .includeServices(services))
    }
    
    @nonobjc static func listAllNotTrashed(on context: NSManagedObjectContext) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .allNotTrashed)
    }
    
    @nonobjc static func listAll(on context: NSManagedObjectContext, sectionID: SectionID?) -> [ServiceEntity] {
        listItemsInSection(on: context, sectionID: sectionID)
    }
    
    // MARK: - Private
    @nonobjc private static func listItemsWithOptions(
        on context: NSManagedObjectContext,
        options: ServiceOptions
    ) -> [ServiceEntity] {
        listItems(on: context, predicate: options.predicate, sortDescriptors: options.sortDescriptors)
    }
    
    @nonobjc private static func listItems(
        on context: NSManagedObjectContext,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]
    ) -> [ServiceEntity] {
        let fetchRequest = ServiceEntity.request()
        if let predicate {
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = sortDescriptors
        
        var list: [ServiceEntity] = []
        
        do {
            list = try context.fetch(fetchRequest)
        } catch {
            let err = error as NSError
            // swiftlint:disable line_length
            Log("ServiceEntity in Storage listItems(filter:\(String(describing: predicate)): \(err.localizedDescription)", module: .storage)
            // swiftlint:enable line_length
            return []
        }
        
        return list
    }
    
    @nonobjc private static func listUpdated(on context: NSManagedObjectContext) -> [ServiceEntity] {
        listAllExisting(on: context)
            .filter { $0.isUpdated }
    }
    
    @nonobjc private static func updateOrder(of services: [ServiceEntity]) {
        for (index, s) in services.enumerated() {
            s.sectionOrder = index
        }
    }
    
    @nonobjc private static func lastItemOrder(on context: NSManagedObjectContext, in sectionID: SectionID?) -> Int {
        listItemsInSection(on: context, sectionID: sectionID).count - 1
    }
    
    // MARK: - Widgets
    
    @nonobjc static func listAllForWidget(
        on context: NSManagedObjectContext,
        filter: String?,
        excludeServices: [String]
    ) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .widget(filter: filter, excludedServices: excludeServices))
            .filter { $0.tokenType != TokenType.hotp.rawValue }
    }
}
