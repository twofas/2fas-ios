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

public protocol LogDataChange: AnyObject {
    func logNewServiceAdded(with secret: String)
    func logServicesModified(with secrets: [String])
    func logServiceDeleted(with secret: String)
    
    func logNewSectionAdded(with sectionID: String)
    func logSectionModified(with sectionID: String)
    func logSectionsModified(with sectionIDs: [String])
    func logSectionDeleted(with sectionID: String)
}

final class LogDataChangeImpl: LogDataChange {
    private let logHandler: LogHandler
    private let deletionLogger: DeletionLogger
    
    init(logHandler: LogHandler, deletionLogger: DeletionLogger) {
        self.logHandler = logHandler
        self.deletionLogger = deletionLogger
    }
    
    func logNewServiceAdded(with secret: String) {
        logHandler.log(entityID: secret, actionType: .created, kind: .service3)
        deletionLogger.serviceExists(secret: secret)
    }
    
    func logServicesModified(with secrets: [String]) {
        secrets.forEach {
            logHandler.log(entityID: $0, actionType: .modified, kind: .service3)
        }
    }
    
    func logServiceDeleted(with secret: String) {
        logHandler.log(entityID: secret, actionType: .deleted, kind: .service3)
        deletionLogger.serviceDeleted(secret: secret)
    }
    
    // MARK: Section
    func logNewSectionAdded(with sectionID: String) {
        logHandler.log(entityID: sectionID, actionType: .created, kind: .section)
        deletionLogger.sectionExists(sectionID: sectionID)
    }
    
    func logSectionModified(with sectionID: String) {
        logHandler.log(entityID: sectionID, actionType: .modified, kind: .section)
    }
    
    func logSectionsModified(with sectionIDs: [String]) {
        sectionIDs.forEach({
            logHandler.log(entityID: $0, actionType: .modified, kind: .section)
        })
    }
    
    func logSectionDeleted(with sectionID: String) {
        logHandler.log(entityID: sectionID, actionType: .deleted, kind: .section)
        deletionLogger.sectionDeleted(sectionID: sectionID)
    }
}

/// Logs what has to happen with the record of a deletion in the cloud whenever an item is deleted or exists
/// again – only in the format that has such records (`Config.vaultV3`), where deletions are decided by them.
///
/// A deletion is known in the log by the name of its record.
final class DeletionLogger {
    private let logHandler: LogHandler
    private let zoneManager: ZoneManaging
    private let syncEncryptionHandler: SyncEncryptionHandling
    
    init(logHandler: LogHandler, zoneManager: ZoneManaging, syncEncryptionHandler: SyncEncryptionHandling) {
        self.logHandler = logHandler
        self.zoneManager = zoneManager
        self.syncEncryptionHandler = syncEncryptionHandler
    }
    
    /// The service was deleted – the record of its deletion has to be in the cloud
    func serviceDeleted(secret: String) {
        log(.created, kind: .deletedService, value: secret.uppercased())
    }
    
    /// The service was added or restored – the record of its deletion (if any) has to go
    func serviceExists(secret: String) {
        log(.deleted, kind: .deletedService, value: secret.uppercased())
    }
    
    func sectionDeleted(sectionID: String) {
        log(.created, kind: .deletedSection, value: sectionID)
    }
    
    func sectionExists(sectionID: String) {
        log(.deleted, kind: .deletedSection, value: sectionID)
    }
    
    /// A record of a deletion that is older than what is remembered – it's removed from the cloud
    func deletionExpired(_ deletion: SyncDeletion, kind: RecordType) {
        guard zoneManager.usesSealedRecords else { return }
        logHandler.log(entityID: deletion.recordName, actionType: .deleted, kind: kind)
    }
    
    private func log(_ action: LogActionType, kind: RecordType, value: String) {
        guard zoneManager.usesSealedRecords, let identifierKey = syncEncryptionHandler.identifierKey else { return }
        let recordKind: SyncRecordKind = kind == .deletedService ? .deletedService : .deletedSection
        logHandler.log(
            entityID: identifierKey.recordName(of: value, kind: recordKind),
            actionType: action,
            kind: kind
        )
    }
}
