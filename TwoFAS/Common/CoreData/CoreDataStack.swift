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

public final class CoreDataStack {
    private let migrator: CoreDataMigratorProtocol?
    
    public var logError: ((String) -> Void)?
    public var presentErrorToUser: ((String) -> Void)?
    
    private var readOnly = false
    private var name: String?
    private var bundle: Bundle?
    
    private lazy var storeDescription: NSPersistentStoreDescription = {
        guard let name else { fatalError("Trying to run persistentContainer without name!") }
        let storeUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.twofas.com")!
            .appendingPathComponent("\(name).sqlite")
        
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = false
        description.shouldMigrateStoreAutomatically = false
        description.url = storeUrl
        description.isReadOnly = readOnly
        description.type = NSSQLiteStoreType
        
        return description
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        guard let name, let bundle else { fatalError("Trying to run persistentContainer without name or bundle!") }
        let container = NSPersistentContainer(name: name, bundle: bundle)
        
        container.persistentStoreDescriptions = [storeDescription]

        migrateStoreIfNeeded {
            container.loadPersistentStores { [weak self] _, error in
                if let error = error as NSError? {
                    // swiftlint:disable line_length
                    let err = "Unresolved error while loadPersistentStores: \(error), \(error.userInfo), for stack: \(name)"
                    // swiftlint:enable line_length
                    self?.logError?(err)
                    self?.parseError(with: error.userInfo)
                    fatalError(err)
                }
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    public init(readOnly: Bool, name: String, bundle: Bundle, migrator: CoreDataMigratorProtocol? = nil) {
        self.name = name
        self.bundle = bundle
        self.readOnly = readOnly
        self.migrator = migrator
        migrator?.bundle = bundle
    }
    
    public var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    public func save() {
        let context = persistentContainer.viewContext
        save(onContext: context)
    }
    
    public func performInBackground(_ closure: @escaping (NSManagedObjectContext) -> Void) {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.perform { [weak self] in
            closure(context)
            self?.save(onContext: context)
        }
    }
    
    public func performAndWaitInBackground(_ closure: @escaping (NSManagedObjectContext) -> Void) {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.performAndWait { [weak self] in
            closure(context)
            self?.save(onContext: context)
        }
    }
    
    public func createBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    private func save(onContext context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            // swiftlint:disable line_length
            let err = "Unresolved error while saving data: \(nserror), \(nserror.userInfo), for stack: \(String(describing: name))"
            // swiftlint:enable line_length
            logError?(err)
            assertionFailure(err)
        }
    }
    
    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        guard let migrator else {
            completion()
            return
        }
        guard let storeURL = storeDescription.url else {
            fatalError("persistentContainer was not set up properly")
        }
        
        if migrator.requiresMigrationToCurrentVersion(at: storeURL) {
            migrator.migrateStoreToCurrentVersion(at: storeURL)
        }
        completion()
    }
    
    private func parseError(with dict: [String: Any]) {
        guard let value = dict["NSSQLiteErrorDomain"] as? Int, value == 13 else { return }
        // swiftlint:disable line_length
        presentErrorToUser?("It appears that either you've run out of disk space now or the database was damaged by such event in the past") // TODO: Add translation!
        // swiftlint:enable line_length
    }
}

public extension NSPersistentContainer {
    @nonobjc convenience init(name: String, bundle: Bundle) {
        
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                Log("Unable to located Core Data model", module: .storage)
                fatalError("Unable to located Core Data model")
            }
        
        self.init(name: name, managedObjectModel: mom)
    }
}

public extension NSManagedObject {
    @nonobjc func delete() {
        managedObjectContext?.delete(self)
    }
}
