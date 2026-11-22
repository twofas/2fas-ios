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

final class CommonItemHandler {
    private let commonSectionHandler: CommonSectionHandler
    private let commonServiceHandler: CommonServiceHandler
    private let infoHandler: InfoHandler
    private let logHandler: LogHandler
    private let zoneManager: ZoneManaging
    private let syncEncryptionHandler: SyncEncryptionHandling
    private let deletionLogger: DeletionLogger
    
    private var itemsToAppend: [ServiceData] = []
    
    var mirrorsTheVault = SyncAccess.onlyUpdatesServices
    
    init(
        commonSectionHandler: CommonSectionHandler,
        commonServiceHandler: CommonServiceHandler,
        infoHandler: InfoHandler,
        logHandler: LogHandler,
        zoneManager: ZoneManaging,
        syncEncryptionHandler: SyncEncryptionHandling,
        deletionLogger: DeletionLogger
    ) {
        self.syncEncryptionHandler = syncEncryptionHandler
        self.deletionLogger = deletionLogger
        self.commonSectionHandler = commonSectionHandler
        self.commonServiceHandler = commonServiceHandler
        self.infoHandler = infoHandler
        self.logHandler = logHandler
        self.zoneManager = zoneManager
        
        commonSectionHandler.commonDidCreate = { [weak self] sectionID in
            Log("CommonItemHandler - commonSectionHandler - commonDidCreate", module: .cloudSync)
            self?.logHandler.log(entityID: sectionID, actionType: .created, kind: .section)
            self?.deletionLogger.sectionExists(sectionID: sectionID)
        }
        commonSectionHandler.commonDidModify = { [weak self] sectionIDs in
            Log("CommonItemHandler - commonSectionHandler - commonDidModify", module: .cloudSync)
            sectionIDs.forEach {
                self?.logHandler.log(entityID: $0, actionType: .modified, kind: .section)
            }
        }
        commonSectionHandler.commonDidDelete = { [weak self] sectionID in
            Log("CommonItemHandler - commonSectionHandler - commonDidDelete", module: .cloudSync)
            self?.logHandler.log(entityID: sectionID, actionType: .deleted, kind: .section)
            self?.deletionLogger.sectionDeleted(sectionID: sectionID)
        }
        
        commonServiceHandler.commonDidCreate = { [weak self] secret in
            Log("CommonItemHandler - commonServiceHandler - commonDidCreate", module: .cloudSync)
            self?.logHandler.log(entityID: secret, actionType: .created, kind: .service3)
            self?.deletionLogger.serviceExists(secret: secret)
        }
        commonServiceHandler.commonDidModify = { [weak self] secrets in
            Log("CommonItemHandler - commonServiceHandler - commonDidModify", module: .cloudSync)
            secrets.forEach {
                self?.logHandler.log(entityID: $0, actionType: .modified, kind: .service3)
            }
        }
        commonServiceHandler.commonDidDelete = { [weak self] secret in
            Log("CommonItemHandler - commonServiceHandler - commonDidDelete", module: .cloudSync)
            self?.logHandler.log(entityID: secret, actionType: .deleted, kind: .service3)
            self?.deletionLogger.serviceDeleted(secret: secret)
        }
    }
    
    /// - Returns: Whether every item was logged (a failure also schedules a reset of the Sync cache).
    @discardableResult
    func logFirstImport() -> Bool {
        let recordType: RecordType = zoneManager.inOldVault ? .service2 : .service3
        let sections = logHandler.logFirstImport(
            entityIDs: commonSectionHandler.getAllSections().map { $0.sectionID },
            kind: .section
        )
        let services = logHandler.logFirstImport(
            entityIDs: commonServiceHandler.getAllServices().map { $0.secret },
            kind: recordType
        )
        let info = logHandler.logFirstImport(entityIDs: [Info.id], kind: .info)
        return sections && services && info
    }
    
    func setItems(_ items: [RecordType: [Any]]) -> Bool {
        var newDataWasSet = false
        // In the format with the records of deletions nothing is deleted here for being absent in the cloud
        let deletions = syncedDeletions(from: items)
        
        if let sections = items[.section] as? [CommonSectionData] {
            Log("CommonItemHandler: sections (\(sections.count))")
            let value = if let deletions {
                commonSectionHandler.setSections(sections, deletions: deletions)
            } else {
                commonSectionHandler.setSections(sections)
            }
            newDataWasSet = newDataWasSet || value
        }
        
        if let services = items[.service3] as? [ServiceData] {
            Log("CommonItemHandler: services (\(services.count))")
            let sortedServices = services.sortedBySection.reduce(into: [ServiceData]()) { result, element in
                result += element.value
            }
            let value = if let deletions {
                commonServiceHandler.setServices(sortedServices, deletions: deletions)
            } else {
                commonServiceHandler.setServices(sortedServices)
            }
            newDataWasSet = newDataWasSet || value
        }
        
        return newDataWasSet
    }
    
    /// What the cloud knows about deletions – `nil` in the formats without the records of deletions. The records
    /// that are older than what is remembered don't count any more and are removed from the cloud.
    /// A deletion that is older than what is remembered doesn't count any more. The phone also removes its
    /// record from the cloud; the watch only mirrors the cloud and removes nothing from it.
    private func expired(_ deletion: SyncDeletion, kind: RecordType) {
        #if os(iOS)
        deletionLogger.deletionExpired(deletion, kind: kind)
        #endif
    }
    
    private func syncedDeletions(from items: [RecordType: [Any]]) -> SyncedDeletions? {
        guard zoneManager.usesSealedRecords, let identifierKey = syncEncryptionHandler.identifierKey else {
            return nil
        }
        var services: [Data: Date] = [:]
        for deletion in (items[.deletedService] as? [SyncDeletion]) ?? [] {
            if deletion.isExpired() {
                expired(deletion, kind: .deletedService)
            } else {
                services[deletion.identifier] = deletion.deletedAt
            }
        }
        var sections: [String: Date] = [:]
        for deletion in (items[.deletedSection] as? [SyncDeletion]) ?? [] {
            guard let sectionID = deletion.sectionID else { continue }
            if deletion.isExpired() {
                expired(deletion, kind: .deletedSection)
            } else {
                sections[sectionID] = deletion.deletedAt
            }
        }
        let keepsLocalOnlyItems = !mirrorsTheVault
        return SyncedDeletions(
            services: services,
            serviceIdentifier: { identifierKey.identifier(of: $0.uppercased(), kind: .deletedService) },
            sections: sections,
            keepsLocalOnlyItems: keepsLocalOnlyItems
        )
    }
    
    /// The deletions made on this device, as the items the cloud should have. `nil` in the formats without the
    /// records of deletions.
    private func localDeletions() -> (services: [SyncDeletion], sections: [SyncDeletion])? {
        guard zoneManager.usesSealedRecords, let identifierKey = syncEncryptionHandler.identifierKey else {
            return nil
        }
        let services: [SyncDeletion] = commonServiceHandler.getAllServiceDeletions().compactMap { deletion in
            let identifier = deletion.syncID
                ?? deletion.secret.map { identifierKey.identifier(of: $0.uppercased(), kind: .deletedService) }
            guard let identifier else { return nil }
            return SyncDeletion(identifier: identifier, deletedAt: deletion.deletedAt)
        }
        let sections: [SyncDeletion] = commonSectionHandler.getAllSectionDeletions().map { deletion in
            SyncDeletion(
                identifier: identifierKey.identifier(of: deletion.sectionID, kind: .deletedSection),
                deletedAt: deletion.deletedAt,
                sectionID: deletion.sectionID
            )
        }
        return (
            services.filter { !$0.isExpired() }.sorted { $0.recordName < $1.recordName },
            sections.filter { !$0.isExpired() }.sorted { $0.recordName < $1.recordName }
        )
    }
    
    func setItemsFromMigration(_ serviceDataToAppend: [ServiceData]) {
        Log("CommonItemHandler: setting items from migration (\(serviceDataToAppend.count))")
        itemsToAppend = serviceDataToAppend
    }
    
    func getAllItems() -> [RecordType: [Any]] {
        let sections = commonSectionHandler.getAllSections()
        let services = commonServiceHandler.getAllServices() + itemsToAppend
        itemsToAppend = []
        var value = [RecordType: [Any]]()
        value[.section] = sections
        let recordType: RecordType = zoneManager.inOldVault ? .service2 : .service3
        value[recordType] = services
        value[.info] = infoHandler.prepareForSendoff()
        if let deletions = localDeletions() {
            value[.deletedService] = deletions.services
            value[.deletedSection] = deletions.sections
        }
        return value
    }
}
