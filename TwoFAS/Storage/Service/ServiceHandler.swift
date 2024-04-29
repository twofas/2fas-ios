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
        ServiceEntity.listAllNotTrashed(on: coreDataStack.context).count
    }
    
    // MARK: - Internal
    
    func listAllForWidget(search: String?, exclude: [ServiceID]) -> ServiceEntity.ServicesWithinSections {
        ServiceEntity.listAllForWidget(on: coreDataStack.context, filter: search, excludeServices: exclude.encrypt())
            .groupByCategory
    }
    
    func list(services: [ServiceID]) -> [ServiceEntity] {
        ServiceEntity.list(on: coreDataStack.context, services: services.encrypt())
    }
    
    func move(from oldIndex: Int, currentSectionID: SectionID?, to newIndex: Int, newSectionID: SectionID?) {
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
        let updated = ServiceEntity.move(
            on: coreDataStack.context,
            from: oldIndex,
            currentSectionID: currentSectionID,
            to: newIndex,
            newSectionID: newSectionID
        )
        let secretsOfUpdated = updated.map { $0.secret.decrypt() }
        coreDataStack.save()
        guard !secretsOfUpdated.isEmpty else { return }
        commonDidModify?(secretsOfUpdated)
    }
    
    func clearCategory(for sectionID: SectionID) {
        Log("ServiceHandler in Storage: clearCategory: \(sectionID)", module: .storage, save: false)
        let countNilSection = ServiceEntity.listAll(on: coreDataStack.context, sectionID: nil).count
        let list = ServiceEntity.listAll(on: coreDataStack.context, sectionID: sectionID)
        var order = countNilSection
        list.forEach({
            $0.sectionID = nil
            $0.sectionOrder = order
            order += 1
        })
        let secretsOfUpdated = list.map { $0.secret.decrypt() }
        coreDataStack.save()
        guard !secretsOfUpdated.isEmpty else { return }
        commonDidModify?(secretsOfUpdated)
    }
    
    var hasServices: Bool {
        !ServiceEntity.listAllNotTrashed(on: coreDataStack.context).isEmpty
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
        // swiftlint:disable line_length
        Log("ServiceHandler in Storage: Current services count before merge: \(currentServices.count)", module: .storage)
        Log("ServiceHandler in Storage: Current trashed services count before merge: \(getAllTrashedServices().count)", module: .storage)
        guard currentServices != newServices else {
            Log("ServiceHandler in Storage: Nothing new to import", module: .storage)
            return false
        }
        
        Log("ServiceHandler in Storage: There's a difference! Will try to merge\nNew services (\(newServices.count)), current services (\(currentServices.count))", module: .storage)
        Log("ServiceHandler in Storage: New services: \(newServices)", module: .storage, save: false)
        Log("ServiceHandler in Storage: Current services: \(currentServices)", module: .storage, save: false)
        let changes = modifiedDeleted(for: currentServices, newServices: newServices)
        Log("ServiceHandler in Storage: Modified: \(changes.modified.count), Deleted: \(changes.deleted.count)", module: .storage)
        Log("ServiceHandler in Storage: Modified values: \(changes.modified), Deleted values: \(changes.deleted)", module: .storage, save: false)
        
        let currentlyInTrash = getAllTrashedServices()
        Log("ServiceHandler in Storage: Currently in trash: \(currentlyInTrash.count)", module: .storage)
        
        let servicesWithUpdatedCounters = modifyCounters(newServices, current: currentServices)
        
        trashDeleted(with: currentServices, newServices: newServices)
        // TODO: Update items instead of whiping them out
        removeAllNotTrashed()
        
        cleanTrash(currentlyInTrash: currentlyInTrash, newServices: newServices)
        
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
        Log("ServiceHandler in Storage: Data imported. Current service count after merge: \(count())", module: .storage)
        Log("ServiceHandler in Storage: Current trashed services count after merge: \(getAllTrashedServices().count)", module: .storage)
        if !reorderedWhileAdded.isEmpty {
            Log(
                "ServiceHandler in Storage: \(reorderedWhileAdded.count) items reordered. Sending to sync",
                module: .storage
            )
            Log("ServiceHandler in Storage: Values: \(reorderedWhileAdded)", module: .storage, save: false)
            commonDidModify?(reorderedWhileAdded)
        }
        // swiftlint:enable line_length
        return true
    }
    
    public func getAllServices() -> [ServiceData] {
        ServiceEntity.listAllNotTrashed(on: coreDataStack.context)
            .map { ServiceData.createFromManagedObject(entity: $0) }
    }
    
    // --
    
    private func getAllTrashedServices() -> [ServiceData] {
        ServiceEntity.listAllTrashed(on: coreDataStack.context)
            .map { ServiceData.createFromManagedObject(entity: $0) }
    }
    
    private func modifyCounters(_ services: [ServiceData], current: [ServiceData]) -> [ServiceData] {
        Log("ServiceHandler in Storage: modifyCounters", module: .storage, save: false)
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
                    Log("ServiceHandler in Storage: updating counter: \(counterValue)", module: .storage, save: false)
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
                
                createEntity(from: s, sectionOrder: index)
            }
        }
        
        return reorderedWhileAdded
    }
    
    private func addServicesAtEndOfSections(_ services: [ServiceData]) {
        Log("ServiceHandler in Storage: addServicesAtEndOfSections. Count: \(services.count)", module: .storage)
        
        var currentCountInSections = getAllServices()
            .sortedBySection
            .mapValues({ $0.count })
        
        let servicesInSections = services.sortedBySection
        
        for (sectionID, services) in servicesInSections {
            services.forEach { s in
                let currentServicesCount = currentCountInSections[sectionID] ?? 0
                
                createEntity(from: s, sectionOrder: currentServicesCount)
                
                currentCountInSections[sectionID] = currentServicesCount + 1
            }
        }
    }
    
    private func createEntity(from s: ServiceData, sectionOrder: Int) {
        ServiceEntity.create(
            on: coreDataStack.context,
            name: s.name,
            encryptedSecret: s.secret.encrypt(),
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
            counter: s.counter,
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
        Log("ServiceHandler in Storage: Marking as trashed: items: \(deleted)", module: .storage, save: false)
        deleted.forEach({
            if let service = ServiceEntity.findService(
                on: coreDataStack.context,
                encryptedSecret: $0.secret.encrypt()
            ) {
                ServiceEntity.markAsTrashed(on: coreDataStack.context, encryptedSecret: service.secret)
            }
        })
        coreDataStack.save()
    }
    
    private func cleanTrash(currentlyInTrash: [ServiceData], newServices: [ServiceData]) {
        let inTrashNowAdded: [ServiceData] = currentlyInTrash.compactMap({ current in
            if newServices.contains(current.secret) {
                return current
            } else {
                return nil
            }
        })
        Log("ServiceHandler in Storage: Cleaning trash: count: \(inTrashNowAdded.count)", module: .storage)
        Log("ServiceHandler in Storage: Cleaning trash: \(inTrashNowAdded)", module: .storage, save: false)
        let forDeletition = inTrashNowAdded.compactMap {
            ServiceEntity.getService(on: coreDataStack.context, encryptedSecret: $0.secret.encrypt())
        }
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
        cleanTrash(currentlyInTrash: trashedServices, newServices: services)
        addServicesAtEndOfSections(newServices)
        coreDataStack.save()
        
        newServices.forEach { commonDidCreate?($0.secret) }
        Log("ServiceHandler in Storage: Data imported from file. Count: \(newServices.count)", module: .storage)
        Log(
            "ServiceHandler in Storage: Data imported from file. Services: \(newServices)",
            module: .storage,
            save: false
        )
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
