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
import CoreData

public enum LogActionType: String {
    case deleted
    case created
    case modified
}

final class LogHandler {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func logFirstImport(entityIDs: [String], kind: RecordType) {
        entityIDs.forEach {
            LogEntity.create(
                on: coreDataStack.context,
                entityID: $0,
                action: LogActionType.created.rawValue,
                date: Date.distantPast,
                kind: kind.rawValue
            )
        }
        coreDataStack.save()
    }
    
    func log(entityID: String, actionType: LogActionType, kind: RecordType) {
        Log("LogHandler - log. actionType: \(actionType), kind: \(kind)", module: .cloudSync)
        if let entity = LogEntity.findLog(on: coreDataStack.context, entityID: entityID),
           let currentLogAction = LogActionType(rawValue: entity.action) {
            if actionType == .deleted && currentLogAction == .created {
                delete(identifiedBy: entityID)
            } else if actionType == .created && currentLogAction == .deleted {
                delete(identifiedBy: entityID)
                createLogEntry(with: entityID, actionType: .modified, kind: kind)
            } else if currentLogAction == .modified || currentLogAction == .created {
                updateDate(for: entityID)
                coreDataStack.save()
            }
        } else {
            createLogEntry(with: entityID, actionType: actionType, kind: kind)
        }
    }
    
    func listAll() -> [LogEntity] { LogEntity.listAll(on: coreDataStack.context) }
    
    func countChanges() -> Int { LogEntity.listAll(on: coreDataStack.context).count }
    
    func listAllActions() -> [LogActionType: [LogEntity]] {
        let all = listAll()
        return .init(grouping: all) { LogActionType(rawValue: $0.action) ?? .modified }
    }
    
    func delete(identifiedBy entityID: String) {
        LogEntity.delete(on: coreDataStack.context, identifiedBy: entityID)
        coreDataStack.save()
    }
    
    func deleteAll() {
        LogEntity.deleteAll(on: coreDataStack.context)
        coreDataStack.save()
    }
    
    func deleteAllApplied() {
        LogEntity.deleteAllApplied(on: coreDataStack.context)
        coreDataStack.save()
    }
    
    func countNotApplied() -> Int {
        LogEntity.countNotApplied(on: coreDataStack.context)
    }
    
    func markAsApplied(for entityID: String) {
        LogEntity.markAsApplied(on: coreDataStack.context, entityID: entityID)
        coreDataStack.save()
    }
    
    func markAsApplied(for entities: [LogEntity]) {
        let entityIDs = entities.map { $0.entityID }
        markAsApplied(for: entityIDs)
    }
    
    func markAsApplied(for entityIDs: [String]) {
        entityIDs.forEach { LogEntity.markAsApplied(on: coreDataStack.context, entityID: $0) }
        coreDataStack.save()
    }
    
    func markAllAsApplied() {
        let all = listAll()
        all.forEach { $0.isApplied = true }
        coreDataStack.save()
    }
    
    func updateDate(for entityID: String) {
        LogEntity.updateDate(on: coreDataStack.context, entityID: entityID)
        coreDataStack.save()
    }

    private func createLogEntry(with entityID: String, actionType: LogActionType, kind: RecordType) {
        LogEntity.create(
            on: coreDataStack.context,
            entityID: entityID,
            action: actionType.rawValue,
            date: Date(),
            kind: kind.rawValue
        )
        coreDataStack.save()
    }
}
