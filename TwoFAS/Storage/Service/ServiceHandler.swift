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

// DEPRECATED - use Storage Repository
public final class ServiceHandler {
    public typealias ServicesWithinSections = [SectionID?: [ServiceData]]
    
    private let coreDataStack: CoreDataStack
    
    public typealias DidRefreshModifedDeleted = ([String], [String]) -> Void
    
    public var commonDidCreate: CommonDidCreate?
    public var commonDidModify: CommonDidModify?
    public var commonDidDelete: CommonDidDelete?
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Public/depracated
    
    public func count() -> Int {
        ServiceEntity.countNotTrashed(on: coreDataStack.context)
    }
    
    // MARK: - Internal
    
    func listAllForWidget(search: String?, exclude: [ServiceID]) -> ServiceEntity.ServicesWithinSections {
        ServiceEntity.listAllForWidget(on: coreDataStack.context, filter: search, excludeServices: exclude)
            .groupByCategory
    }
    
    func list(services: [ServiceID]) -> [ServiceEntity] {
        ServiceEntity.list(on: coreDataStack.context, services: services)
    }
    
    func move(from oldIndex: Int, currentSectionID: SectionID?, to newIndex: Int, newSectionID: SectionID?) {
        #if DEBUG
        Log("""
            ServiceHandler in Storage: move:
            oldIndex: \(oldIndex)
            currentSectionID: \(currentSectionID?.uuidString ?? "<nil>")
            newIndex: \(newIndex)
            newSectionID: \(newSectionID?.uuidString ?? "<nil>")
            """,
            module: .storage,
            save: false
        )
        #endif
        let updated = ServiceEntity.move(
            on: coreDataStack.context,
            from: oldIndex,
            currentSectionID: currentSectionID,
            to: newIndex,
            newSectionID: newSectionID
        )
        let secretsOfUpdated = updated.readableSecrets
        coreDataStack.save()
        guard !secretsOfUpdated.isEmpty else { return }
        commonDidModify?(secretsOfUpdated)
    }
    
    func clearCategory(for sectionID: SectionID) {
        #if DEBUG
        Log("ServiceHandler in Storage: clearCategory: \(sectionID)", module: .storage, save: false)
        #endif
        let countNilSection = ServiceEntity.listAll(on: coreDataStack.context, sectionID: nil).count
        let list = ServiceEntity.listAll(on: coreDataStack.context, sectionID: sectionID)
        var order = countNilSection
        list.forEach({
            $0.sectionID = nil
            $0.sectionOrder = order
            order += 1
        })
        let secretsOfUpdated = list.readableSecrets
        coreDataStack.save()
        guard !secretsOfUpdated.isEmpty else { return }
        commonDidModify?(secretsOfUpdated)
    }
    
    var hasServices: Bool {
        ServiceEntity.countNotTrashed(on: coreDataStack.context) > 0
    }
    
    func listAllServicesWithinSections(
        phrase: String?,
        sort: SortType,
        ids: [ServiceTypeID]
    ) -> ServicesWithinSections {
        ServiceEntity.listItems(on: coreDataStack.context, phrase: phrase, sort: sort, ids: ids)
            .groupByCategory.mapValues { $0.toServiceData() }
    }
    
    func removeAll() {
        Log("ServiceHandler in Storage: removeAll()", module: .storage)
        let all = ServiceEntity.listAllExisting(on: coreDataStack.context)
        all.forEach { coreDataStack.context.delete($0) }
        coreDataStack.save()
    }
    
    func removeAllNotTrashed() {
        Log("ServiceHandler in Storage: removeAllNotTrashed()", module: .storage)
        let all = ServiceEntity.listAllNotTrashed(on: coreDataStack.context)
        all.forEach { coreDataStack.context.delete($0) }
        coreDataStack.save()
    }
}

extension ServiceHandler: CommonServiceHandler {
    @discardableResult
    public func setServices(_ newServices: [ServiceData]) -> Bool {
        let currentServices = getAllServices()
        let currentServicesCount = currentServices.count
        // swiftlint:disable line_length
        Log("ServiceHandler in Storage: Current services count before merge: \(currentServicesCount)", module: .storage)
        Log("ServiceHandler in Storage: Current trashed services count before merge: \(getAllTrashedServices().count)", module: .storage)
        guard currentServices != newServices else {
            Log("ServiceHandler in Storage: Nothing new to import", module: .storage)
            return false
        }
        // Before anything is trashed or removed – the new services couldn't be added without a key for writing
        guard canWriteServices() else { return false }
        
        Log("ServiceHandler in Storage: There's a difference! Will try to merge\nNew services (\(newServices.count)), current services (\(currentServices.count))", module: .storage)
        #if DEBUG
        Log("ServiceHandler in Storage: New services: \(newServices)", module: .storage, save: false)
        Log("ServiceHandler in Storage: Current services: \(currentServices)", module: .storage, save: false)
        #endif
        let changes = modifiedDeleted(for: currentServices, newServices: newServices)
        Log("ServiceHandler in Storage: Modified: \(changes.modified.count), Deleted: \(changes.deleted.count)", module: .storage)
        #if DEBUG
        Log("ServiceHandler in Storage: Modified values: \(changes.modified), Deleted values: \(changes.deleted)", module: .storage, save: false)
        #endif
        
        let currentlyInTrash = getAllTrashedServices()
        Log("ServiceHandler in Storage: Currently in trash: \(currentlyInTrash.count)", module: .storage)
        
        let servicesWithUpdatedCounters = modifyCounters(newServices, current: currentServices)
        
        trashDeleted(with: currentServices, newServices: newServices)
        // TODO: Update items instead of whiping them out
        removeAllNotTrashed()
        
        let listForDeletition = prepareForTrashRemoval(currentlyInTrash: currentlyInTrash, newServices: newServices)
        cleanTrash(listForDeletition)
        
        let reorderedWhileAdded = addServices(servicesWithUpdatedCounters.sortedBySection)
        
        coreDataStack.save()
        NotificationCenter.default.post(
            name: .servicesWereUpdated,
            object: nil,
            userInfo: [
                Notification.UserInfoKey.modified: changes.modified,
                Notification.UserInfoKey.deleted: changes.deleted
            ]
        )
        if currentServicesCount == changes.deleted.count && currentServicesCount > 0 { // all services removed
            NotificationCenter.default.post(name: .allServicesRemoved, object: nil)
        }
        Log("ServiceHandler in Storage: Data imported. Current service count after merge: \(count())", module: .storage)
        Log("ServiceHandler in Storage: Current trashed services count after merge: \(getAllTrashedServices().count)", module: .storage)
        if !reorderedWhileAdded.isEmpty {
            Log(
                "ServiceHandler in Storage: \(reorderedWhileAdded.count) items reordered. Sending to sync",
                module: .storage
            )
            #if DEBUG
            Log("ServiceHandler in Storage: Values: \(reorderedWhileAdded)", module: .storage, save: false)
            #endif
            commonDidModify?(reorderedWhileAdded)
        }
        // swiftlint:enable line_length
        return true
    }
    
    public func getAllServices() -> [ServiceData] {
        ServiceEntity.listAllNotTrashed(on: coreDataStack.context)
            .toServiceData()
    }
    
    public func getAllServiceDeletions() -> [CommonServiceDeletion] {
        DeletedServiceEntity.listAll(on: coreDataStack.context).map {
            CommonServiceDeletion(secret: $0.secret, syncID: $0.syncID, deletedAt: $0.deletedAt)
        }
    }
    
    // swiftlint:disable:next function_body_length
    @discardableResult
    public func setServices(_ cloudServices: [ServiceData], deletions: SyncedDeletions) -> Bool {
        guard canWriteServices() else { return false }
        let context = coreDataStack.context
        let currentServices = getAllServices()
        let currentlyInTrash = getAllTrashedServices()
        let identifier: (String) -> Data = { deletions.serviceIdentifier($0.uppercased()) }
        
        /// When the service was deleted, as far as this device and the cloud know. A local record that the cloud
        /// knew and doesn't have any more was undone elsewhere (or expired) – it doesn't count.
        func deletionDate(of secret: String) -> Date? {
            let cloudDate = deletions.services[identifier(secret)]
            var localDate: Date?
            if let record = DeletedServiceEntity.find(on: context, secret: secret),
               record.syncID == nil || cloudDate != nil {
                localDate = record.deletedAt
            }
            return [cloudDate, localDate].compactMap { $0 }.max()
        }
        
        var servicesToSet: [ServiceData] = []
        var deletedHere: [(secret: String, deletedAt: Date)] = []
        // What the cloud has to hear about with the next sync
        var announceCreated: [String] = []
        var announceDeleted: [String] = []
        
        for service in cloudServices {
            if let deletedAt = deletionDate(of: service.secret) {
                if service.modifiedAt > deletedAt {
                    // Added or changed after it was deleted – the service wins and its deletion is removed
                    servicesToSet.append(service)
                    announceCreated.append(service.secret)
                } else {
                    deletedHere.append((service.secret, deletedAt))
                    announceDeleted.append(service.secret)
                }
            } else {
                servicesToSet.append(service)
            }
        }
        for service in currentServices where !cloudServices.contains(service.secret) {
            if let deletedAt = deletions.services[identifier(service.secret)], service.modifiedAt <= deletedAt {
                // The only way a service is deleted from elsewhere: the record of its deletion
                deletedHere.append((service.secret, deletedAt))
            } else if deletions.keepsLocalOnlyItems {
                // Not in the cloud and not deleted – it's kept and sent
                servicesToSet.append(service)
                announceCreated.append(service.secret)
            } else {
                deletedHere.append((service.secret, Date()))
            }
        }
        
        let hasChanges = currentServices != servicesToSet || !deletedHere.isEmpty
        if hasChanges {
            // swiftlint:disable:next line_length
            Log("ServiceHandler in Storage: Merging. In cloud: \(cloudServices.count), to set: \(servicesToSet.count), deleted: \(deletedHere.count)", module: .storage)
            let changes = modifiedDeleted(for: currentServices, newServices: servicesToSet)
            let servicesWithUpdatedCounters = modifyCounters(servicesToSet, current: currentServices)
            
            for deleted in deletedHere where currentServices.contains(deleted.secret) {
                ServiceEntity.markAsTrashed(on: context, secret: deleted.secret, trashingDate: deleted.deletedAt)
            }
            removeAllNotTrashed()
            // A service that is in the trash here and won with its deletion comes back
            cleanTrash(prepareForTrashRemoval(currentlyInTrash: currentlyInTrash, newServices: servicesToSet))
            let reorderedWhileAdded = addServices(servicesWithUpdatedCounters.sortedBySection)
            coreDataStack.save()
            
            NotificationCenter.default.post(
                name: .servicesWereUpdated,
                object: nil,
                userInfo: [
                    Notification.UserInfoKey.modified: changes.modified,
                    Notification.UserInfoKey.deleted: changes.deleted
                ]
            )
            if currentServices.count == changes.deleted.count && !currentServices.isEmpty {
                NotificationCenter.default.post(name: .allServicesRemoved, object: nil)
            }
            if !reorderedWhileAdded.isEmpty {
                commonDidModify?(reorderedWhileAdded)
            }
        }
        
        announceDeleted += reconcileDeletionRecords(with: deletions, identifier: identifier, kept: servicesToSet)
        coreDataStack.save()
        
        if deletions.keepsLocalOnlyItems {
            announceCreated.forEach { commonDidCreate?($0) }
            Set(announceDeleted).forEach { commonDidDelete?($0) }
        }
        return hasChanges
    }
    
    /// Brings the records of the deletions made here in line with the cloud.
    /// - Returns: The secrets of the deleted services the cloud doesn't know about yet.
    private func reconcileDeletionRecords(
        with deletions: SyncedDeletions,
        identifier: (String) -> Data,
        kept: [ServiceData]
    ) -> [String] {
        let context = coreDataStack.context
        var unknownToCloud: [String] = []
        for record in DeletedServiceEntity.listAll(on: context) {
            let secret = record.secret
            guard let syncID = record.syncID ?? secret.map(identifier) else {
                // Nothing says which service it was
                context.delete(record)
                continue
            }
            if let cloudDate = deletions.services[syncID] {
                record.deletedAt = max(record.deletedAt, cloudDate)
                // The cloud knows the deletion by its identifier – the secret isn't needed any more
                record.syncID = syncID
                record.encryptedContent = nil
            } else if record.syncID != nil {
                // The cloud knew it and doesn't have it any more: undone elsewhere or expired
                context.delete(record)
            } else if let secret, !kept.contains(secret) {
                unknownToCloud.append(secret)
            }
        }
        return unknownToCloud
    }
    
    // --
    
    /// `false` (logged) when the content of new services can't be sealed (e.g. the key is unavailable)
    private func canWriteServices() -> Bool {
        do {
            guard let cipher = coreDataStack.context.localStorageCipher else {
                throw SealedEntity.Failure.missingCipher
            }
            try cipher.prepareForWriting()
            return true
        } catch {
            Log(
                "ServiceHandler in Storage: Can't merge, writing not possible: \(SealedEntity.describe(error))",
                module: .storage,
                severity: .error
            )
            return false
        }
    }
    
    private func getAllTrashedServices() -> [ServiceData] {
        ServiceEntity.listAllTrashed(on: coreDataStack.context)
            .toServiceData()
    }
    
    private func modifyCounters(_ services: [ServiceData], current: [ServiceData]) -> [ServiceData] {
        #if DEBUG
        Log("ServiceHandler in Storage: modifyCounters", module: .storage, save: false)
        #endif
        var modifyServices = services
        services.enumerated().forEach { index, s in
            if let currentService = current.first(where: { $0.secret == s.secret }), s.tokenType == .hotp {
                if currentService.counter != s.counter {
                    var modifiedServiceData = s
                    let counterValue = max(
                        s.counter ?? TokenType.hotpDefaultValue,
                        currentService.counter ?? TokenType.hotpDefaultValue
                    )
                    modifiedServiceData.updateCounter(counterValue)
                    #if DEBUG
                    Log("ServiceHandler in Storage: updating counter: \(counterValue)", module: .storage, save: false)
                    #endif
                    modifyServices[index] = modifiedServiceData
                }
            }
        }
        return modifyServices
    }
    
    private func addServices(_ newServices: [SectionID?: [ServiceData]]) -> [String] {
        Log("ServiceHandler in Storage: addServices", module: .storage)
        
        var reorderedWhileAdded: [String] = []
        
        for (_, services) in newServices {
            services.enumerated().forEach { index, s in
                if s.order != index {
                    reorderedWhileAdded.append(s.secret)
                }
                
                createEntity(from: s, sectionOrder: index, counter: nil)
            }
        }
        
        return reorderedWhileAdded
    }
    
    private func addServicesAtEndOfSections(_ services: [ServiceData], counters: [Secret: Int]) {
        Log("ServiceHandler in Storage: addServicesAtEndOfSections. Count: \(services.count)", module: .storage)
        
        var currentCountInSections = getAllServices()
            .sortedBySection
            .mapValues({ $0.count })
        
        let servicesInSections = services.sortedBySection
        
        for (sectionID, services) in servicesInSections {
            services.forEach { s in
                let currentServicesCount = currentCountInSections[sectionID] ?? 0
                createEntity(from: s, sectionOrder: currentServicesCount, counter: counters[s.secret])
                currentCountInSections[sectionID] = currentServicesCount + 1
            }
        }
    }
    
    private func createEntity(from s: ServiceData, sectionOrder: Int, counter: Int?) {
        ServiceEntity.create(
            on: coreDataStack.context,
            name: s.name,
            secret: s.secret,
            serviceTypeID: s.serviceTypeID,
            additionalInfo: s.additionalInfo,
            rawIssuer: s.rawIssuer,
            otpAuth: s.otpAuth,
            creationDate: s.createdAt,
            modificationDate: s.modifiedAt,
            tokenPeriod: s.tokenPeriod?.rawValue,
            tokenLength: s.tokenLength.rawValue,
            badgeColor: s.badgeColor?.rawValue,
            iconType: s.iconType.rawValue,
            iconTypeID: s.iconTypeID,
            labelColor: s.labelColor.rawValue,
            labelTitle: s.labelTitle,
            sectionID: s.sectionID,
            sectionOrder: sectionOrder,
            algorithm: s.algorithm.rawValue,
            counter: counter ?? s.counter,
            tokenType: s.tokenType.rawValue,
            source: s.source.rawValue
        )
    }
    
    private func trashDeleted(with currentServices: [ServiceData], newServices: [ServiceData]) {
        let deleted: [ServiceData] = currentServices.compactMap { current in
            if newServices.contains(current.secret) {
                return nil
            } else {
                return current
            }
        }
        Log("ServiceHandler in Storage: Marking as trashed: count: \(deleted.count)", module: .storage)
        #if DEBUG
        Log("ServiceHandler in Storage: Marking as trashed: items: \(deleted)", module: .storage, save: false)
        #endif
        deleted.forEach({
            if ServiceEntity.findService(on: coreDataStack.context, secret: $0.secret) != nil {
                ServiceEntity.markAsTrashed(on: coreDataStack.context, secret: $0.secret)
            }
        })
        coreDataStack.save()
    }
    
    private func prepareForTrashRemoval(
        currentlyInTrash: [ServiceData],
        newServices: [ServiceData]
    ) -> [ServiceEntity] {
        let inTrashNowAdded: [ServiceData] = currentlyInTrash.compactMap({ current in
            if newServices.contains(current.secret) {
                return current
            } else {
                return nil
            }
        })
        Log("ServiceHandler in Storage: Cleaning trash: count: \(inTrashNowAdded.count)", module: .storage)
        #if DEBUG
        Log("ServiceHandler in Storage: Cleaning trash: \(inTrashNowAdded)", module: .storage, save: false)
        #endif
        let forDeletition = inTrashNowAdded.compactMap {
            ServiceEntity.getService(on: coreDataStack.context, secret: $0.secret)
        }
        return forDeletition
    }
    
    private func cleanTrash(_ forDeletition: [ServiceEntity]) {
        forDeletition.forEach { ServiceEntity.delete(on: coreDataStack.context, serviceEntity: $0) }
        
        coreDataStack.save()
    }
    
    private func modifiedDeleted(
        for currentServices: [ServiceData],
        newServices: [ServiceData]
    ) -> (modified: [String], deleted: [String]) {
        // swiftlint:disable line_length
        Log("ServiceHandler in Storage: modifiedDeleted. currentServices: \(currentServices.count), newServices: \(newServices.count)", module: .storage)
        // swiftlint:enable line_length
        let modified: [ServiceData] = currentServices.compactMap({ current in
            guard let newService = newServices.first(where: { $0.secret == current.secret }) else { return nil }
            if newService != current {
                return newService
            } else {
                return nil
            }
        })
        
        let deleted: [ServiceData] = currentServices.compactMap({ current in
            if newServices.contains(current.secret) {
                return nil
            } else {
                return current
            }
        })
        
        return (modified: modified.map({ $0.secret }), deleted: deleted.map({ $0.secret }))
    }
}

public extension ServiceHandler {
    // MARK: - Import from file
    
    func addNonexistentServices(_ services: [ServiceData]) -> Int {
        let currentServices = getAllServices().map({ $0.secret })
        let trashedServices = getAllTrashedServices()
        let trashedServicesSecrets = trashedServices.map({ $0.secret })
        let newServices = services.filter {
            !currentServices.contains($0.secret) || trashedServicesSecrets.contains($0.secret)
        }
        
        let listForDeletition = prepareForTrashRemoval(currentlyInTrash: trashedServices, newServices: services)
        let counterState: [Secret: Int] = listForDeletition.reduce(into: [Secret: Int]()) { result, entity in
            if entity.tokenType == TokenType.hotp.rawValue, let counter = entity.counter {
                result[entity.secret] = counter.intValue
            }
        }
        cleanTrash(listForDeletition)
        addServicesAtEndOfSections(newServices, counters: counterState)
        coreDataStack.save()
        
        newServices.forEach { commonDidCreate?($0.secret) }
        Log("ServiceHandler in Storage: Data imported from file. Count: \(newServices.count)", module: .storage)
        #if DEBUG
        Log(
            "ServiceHandler in Storage: Data imported from file. Services: \(newServices)",
            module: .storage,
            save: false
        )
        #endif
        return newServices.count
    }
    
    func countNewServices(from services: [ServiceData]) -> Int {
        let currentServices = getAllServices().map({ $0.secret })
        let trashedServices = getAllTrashedServices().map({ $0.secret })
        let count = services
            .filter { !currentServices.contains($0.secret) || trashedServices.contains($0.secret) }
            .count
        Log("ServiceHandler in Storage: Data from new file counted. Count: \(count)", module: .storage)
        return count
    }
}
