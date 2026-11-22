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
    
    /// Valid only for the current bytes of `encryptedContent`. Not a transient attribute, so filling it never marks
    /// the object as updated.
    let contentCache = SealedContentCache<ServiceSensitiveContent>()
    
    override func didTurnIntoFault() {
        super.didTurnIntoFault()
        contentCache.clear()
    }
    
    @nonobjc static func update(
        on context: NSManagedObjectContext,
        name: String,
        secret: String,
        additionalInfo: String?,
        modificationDate: Date,
        badgeColor: String?,
        iconType: String,
        iconTypeID: IconTypeID,
        labelColor: String,
        labelTitle: String,
        counter: Int?
    ) {
        guard let serviceForUpdating = listAllExisting(on: context, secret: secret).first else {
            Log("Can't find service for updating on local storage", module: .storage)
            return
        }
        
        do {
            try serviceForUpdating.updateContent { content in
                content.name = name
                content.additionalInfo = additionalInfo
                content.iconTypeID = iconTypeID
                content.labelTitle = labelTitle
            }
        } catch {
            Log(
                "\(entityName) - can't update content: \(SealedEntity.describe(error))",
                module: .storage,
                severity: .error
            )
            assertionFailure("\(entityName) - can't update content")
            return
        }
        
        serviceForUpdating.modificationDate = modificationDate

        if let badgeColor {
            serviceForUpdating.badgeColor = badgeColor
        }
        serviceForUpdating.iconType = iconType
        serviceForUpdating.labelColor = labelColor

        if let counter {
            serviceForUpdating.counter = NSNumber(value: counter)
        }
    }
    
    @nonobjc static func create(
        on context: NSManagedObjectContext,
        name: String,
        secret: String,
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
        let content = ServiceSensitiveContent(
            secret: secret.uppercased(),
            name: name,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            otpAuth: otpAuth,
            labelTitle: labelTitle,
            serviceTypeID: serviceTypeID,
            iconTypeID: iconTypeID
        )
        let secretHash: Data
        let sealed: Data
        do {
            guard let cipher = context.localStorageCipher else { throw SealedEntity.Failure.missingCipher }
            // The hash is part of the associated data, so the key has to exist before hashing
            try cipher.prepareForWriting()
            secretHash = try Self.secretHash(for: content.secret, cipher: cipher)
            sealed = try contentCodec.seal(content, hashes: [secretHash], cipher: cipher)
        } catch {
            Log(
                "\(entityName) - can't seal new entity: \(SealedEntity.describe(error))",
                module: .storage,
                severity: .error
            )
            assertionFailure("\(entityName) - can't seal new entity")
            return
        }
        
        // A service that exists isn't a deleted one
        DeletedServiceEntity.remove(on: context, secretHash: secretHash)
        
        let service = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! ServiceEntity
        
        service.secretHash = secretHash
        service.encryptedContent = sealed
        service.contentCache.store(content, sealed: sealed)
        service.modificationDate = modificationDate
        service.creationDate = creationDate
        if let tokenPeriod {
            service.tokenPeriod = NSNumber(value: tokenPeriod)
        }
        service.tokenLength = NSNumber(value: tokenLength)
        service.badgeColor = badgeColor
        service.iconType = iconType
        service.labelColor = labelColor
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
    
    @nonobjc static func delete(on context: NSManagedObjectContext, secret: String) {
        guard let serviceForDeletition = listAllExisting(on: context, secret: secret).first
        else { Log("Can't find service for deletition on local storage", module: .storage); return }
        var sectionList = listAll(on: context, sectionID: serviceForDeletition.sectionID)
        if let index = sectionList.firstIndex(of: serviceForDeletition) {
            sectionList.remove(at: index)
            updateOrder(of: sectionList)
        }
        delete(on: context, serviceEntity: serviceForDeletition)
    }
    
    /// - Parameter trashingDate: When the service was deleted – another moment than now when it was deleted
    ///   elsewhere.
    @nonobjc static func markAsTrashed(
        on context: NSManagedObjectContext,
        secret: String,
        trashingDate: Date = Date()
    ) {
        guard let serviceForTrashing = listAllExisting(on: context, secret: secret).first
        else { Log("Can't find service for trashing on local storage", module: .storage); return }
        serviceForTrashing.isTrashed = NSNumber(value: true)
        serviceForTrashing.trashingDate = trashingDate
        // Whatever puts a service in the trash – the service is a deleted one from now on
        DeletedServiceEntity.record(on: context, secret: secret, deletedAt: trashingDate)
    }
    
    @nonobjc static func markAsUntrashed(on context: NSManagedObjectContext, secret: String) {
        guard let serviceForUntrashing = listAllExisting(on: context, secret: secret)
            .first(where: { $0.isTrashed.boolValue })
        else { Log("Can't find service for untrashing on local storage", module: .storage); return }
        
        serviceForUntrashing.isTrashed = NSNumber(value: false)
        serviceForUntrashing.trashingDate = nil
        // Restored after it was deleted: newer than its deletion, wherever that one is still known
        serviceForUntrashing.modificationDate = Date()
        DeletedServiceEntity.remove(on: context, secretHash: serviceForUntrashing.secretHash)
    }
    
    @nonobjc static func getService(on context: NSManagedObjectContext, secret: String) -> ServiceEntity? {
        let list = listAllExisting(on: context, secret: secret)
        
        // If something went wrong (wrong migration, some bugs) -> remove duplicated entries instead of:
        if list.count > 1 {
            let itemsForDeletition = list[1...]
            for item in itemsForDeletition {
                delete(on: context, serviceEntity: item)
            }
        }
        
        return list.first
    }
    
    @nonobjc static func findService(on context: NSManagedObjectContext, secret: String) -> ServiceEntity? {
        guard let secretHash = Self.secretHash(for: secret, on: context) else { return nil }
        let list = listItemsWithOptions(on: context, options: .findNotTrashedBySecretHash(secretHash))
        
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
        // Put into another section by the user – a change of the service itself, unlike its position
        serviceToMove.modificationDate = Date()
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
    
    /// Not trashed, readable services filtered and sorted in memory (only the manual order comes from SQL)
    @nonobjc static func listItems(
        on context: NSManagedObjectContext,
        phrase: String?,
        sort: SortType,
        ids: [ServiceTypeID]
    ) -> [ServiceEntity] {
        let readable = listItemsWithOptions(on: context, options: .notTrashedSorted(sort))
            .compactMap(ListedService.init(entity:))
        return ServiceListing.sort(ServiceListing.filter(readable, phrase: phrase, ids: ids), by: sort)
            .map(\.entity)
    }
    
    @nonobjc static func listAllExisting(on context: NSManagedObjectContext) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .all)
    }
    
    @nonobjc static func findAllUnknownServices(on context: NSManagedObjectContext) -> [ServiceEntity] {
        listAllExisting(on: context).filter { service in
            guard let content = service.content else { return false }
            return content.serviceTypeID == nil && (content.rawIssuer != nil || content.otpAuth != nil)
        }
    }
    
    @nonobjc static func list(on context: NSManagedObjectContext, services: [ServiceID]) -> [ServiceEntity] {
        let secretHashes = services.compactMap { Self.secretHash(for: $0, on: context) }
        guard !secretHashes.isEmpty else { return [] }
        return listItemsWithOptions(on: context, options: .includeServices(secretHashes))
    }
    
    @nonobjc static func listAllNotTrashed(on context: NSManagedObjectContext) -> [ServiceEntity] {
        listItemsWithOptions(on: context, options: .allNotTrashed)
    }
    
    /// Counted in SQL, without decrypting
    @nonobjc static func countNotTrashed(on context: NSManagedObjectContext) -> Int {
        let fetchRequest = ServiceEntity.request()
        fetchRequest.predicate = ServiceOptions.allNotTrashed.predicate
        do {
            return try context.count(for: fetchRequest)
        } catch {
            Log("\(entityName) - can't count: \(SealedEntity.describe(error))", module: .storage, severity: .error)
            return 0
        }
    }
    
    @nonobjc static func listAll(on context: NSManagedObjectContext, sectionID: SectionID?) -> [ServiceEntity] {
        listItemsInSection(on: context, sectionID: sectionID)
    }
    
    // MARK: - Private
    /// Also trashed ones. Empty when the hash can't be computed.
    @nonobjc private static func listAllExisting(
        on context: NSManagedObjectContext,
        secret: String
    ) -> [ServiceEntity] {
        guard let secretHash = Self.secretHash(for: secret, on: context) else { return [] }
        return listItemsWithOptions(on: context, options: .findExistingBySecretHash(secretHash))
    }
    
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
    
    /// The modification date stays: a service that only moved (or was only pushed by another one moving)
    /// wasn't changed. A deletion made on another device in the meantime must still win – a new date would make
    /// the service look changed after it was deleted, and bring it back.
    @nonobjc private static func updateOrder(of services: [ServiceEntity]) {
        for (index, s) in services.enumerated() where s.sectionOrder != index {
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
        excludeServices: [ServiceID]
    ) -> [ServiceEntity] {
        let excludedHashes = excludeServices.compactMap { Self.secretHash(for: $0, on: context) }
        let readable = listItemsWithOptions(on: context, options: .widget(excludedHashes: excludedHashes))
            .compactMap(ListedService.init(entity:))
        return ServiceListing.filter(readable, phrase: filter, ids: [])
            .map(\.entity)
            .filter { $0.tokenType != TokenType.hotp.rawValue }
    }
}
