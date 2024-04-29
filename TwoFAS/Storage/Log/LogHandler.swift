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

public final class LogHandler: LogStorageHandling {
    private struct CachedEntry {
        let content: String
        let timestamp: Date
        let module: Int
        let severity: Int
    }
    
    private let maxEntries: Int = 10000
    private let checkEvery: Int = 300
    private let saveEvery: Int = 10
    private var checkCounter: Int = 0
    private var saveCounter: Int = 0
    private var zoneSaveCounter: Int = 0
        
    private var inZone = false
    
    private let context: NSManagedObjectContext
    private let queue = DispatchQueue(
        label: "com.2fas.logHandlerQueue",
        attributes: .concurrent
    )
    
    init(coreDataStack: CoreDataStack) {
        context = coreDataStack.createBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        #if os(iOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(save),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(save),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(save),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        #endif
    }
    
    public func markZoneStart() {
        inZone = true
    }
    
    public func markZoneEnd() {
        inZone = false
        saveCounter += zoneSaveCounter
        zoneSaveCounter = 0
        checkSave()
    }
    
    public func store(content: String, timestamp: Date, module: Int, severity: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            self.context.performAndWait {
                LogEntryEntity.create(
                    on: self.context,
                    content: content,
                    timestamp: timestamp,
                    module: module,
                    severity: severity
                )
            }
            
            self.checkCounter += 1
            
            if self.inZone {
                self.zoneSaveCounter += 1
            } else {
                self.saveCounter += 1
                self.checkSave()
                self.checkCleanup()
            }
        }
    }
    
    public func listAll() -> [LogEntry] {
        queue.sync {
            LogEntryEntity.listAll(on: context, ascending: true)
                .map { entity in
                    LogEntry(
                        content: entity.content,
                        timestamp: entity.timestamp,
                        module: LogModule(rawValue: Int(entity.module)) ?? .unknown,
                        severity: LogSeverity(rawValue: Int(entity.severity)) ?? .unknown
                    )
                }
        }
    }
    
    private func checkSave() {
        guard saveCounter >= saveEvery else { return }
        
        save()
    }
    
    @objc(save)
    private func save() {
        queue.async(flags: .barrier) { [weak self] in
            self?.saveCounter = 0
            self?.zoneSaveCounter = 0
            
            if self?.context.hasChanges == true {
                self?.context.performAndWait { [weak self] in
                    do {
                        try self?.context.save()
                    } catch {
                        Log("Error while saving context in LogStorage: \(error)")
                    }
                }
            }
        }
    }
    
    private func checkCleanup() {
        guard checkCounter >= checkEvery else { return }
        checkCounter = 0
        
        queue.async(flags: .barrier) { [weak self] in
            self?.context.performAndWait { [weak self] in
                guard let self else { return }
                let context = self.context
                
                guard LogEntryEntity.count(on: context) > self.maxEntries else { return }
                let all = LogEntryEntity.listAll(on: context, quickFetch: true, ascending: false)
                let forRemoval = Array(all[self.maxEntries...])
                LogEntryEntity.remove(on: context, objects: forRemoval)
            }
        }
    }
}
