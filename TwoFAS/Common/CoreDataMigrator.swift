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

public protocol CoreDataMigratorProtocol: AnyObject {
    typealias Migrating = ((CoreDataMigrationVersion, CoreDataMigrationVersion) -> Void)
    
    func requiresMigrationToCurrentVersion(at storeURL: URL) -> Bool
    func migrateStoreToCurrentVersion(at storeURL: URL)
    var bundle: Bundle? { get set }
    var migrating: Migrating? { get set }
}

public final class CoreDataMigrator: CoreDataMigratorProtocol {
    public var bundle: Bundle?
    public var migrating: Migrating?
    private let momdSubdirectory: String
    private let versions: CoreDataMigrationVersionList
    
    // MARK: - Init
    
    public init(momdSubdirectory: String, versions: [CoreDataMigrationVersion], migrating: Migrating? = nil) {
        self.momdSubdirectory = "\(momdSubdirectory).momd"
        self.versions = CoreDataMigrationVersionList(versions: versions)
        self.migrating = migrating
    }
    
    // MARK: - Check
    
    public func requiresMigrationToCurrentVersion(at storeURL: URL) -> Bool {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return false
        }
        guard let bundle else {
            fatalError("Cant migrate without passed bundle")
        }
        
        let storedVersion = CoreDataMigrationVersion.compatibleVersionForStoreMetadata(
            metadata,
            versions: versions,
            momdSubdirectory: momdSubdirectory,
            bundle: bundle
        )
        let needsToMigrate = (storedVersion != versions.current)
        if needsToMigrate {
            // swiftlint:disable line_length
            Log("Need to migrate Core Data to current version: \(versions.current.rawValue) from \(String(describing: storedVersion?.rawValue))", module: .storage)
            // swiftlint:enable line_length
        }
        
        return needsToMigrate
    }
    
    // MARK: - Migration
    
    public func migrateStoreToCurrentVersion(at storeURL: URL) {
        forceWALCheckpointingForStore(at: storeURL)
        
        var currentURL = storeURL
        let migrationSteps = self.migrationStepsForStore(at: storeURL, toVersion: versions.current)
        
        for migrationStep in migrationSteps {
            Log("Migrating from \(migrationStep.sourceModel) to \(migrationStep.destinationModel)", module: .storage)
            let manager = NSMigrationManager(
                sourceModel: migrationStep.sourceModel,
                destinationModel: migrationStep.destinationModel
            )
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(UUID().uuidString)
            
            do {
                try manager.migrateStore(
                    from: currentURL,
                    sourceType: NSSQLiteStoreType,
                    options: nil,
                    with: migrationStep.mappingModel,
                    toDestinationURL: destinationURL,
                    destinationType: NSSQLiteStoreType,
                    destinationOptions: nil
                )
            } catch let error {
                // swiftlint:disable line_length
                fatalError("failed attempting to migrate from \(migrationStep.sourceModel) to \(migrationStep.destinationModel), error: \(error)")
                // swiftlint:enable line_length
            }
            
            if currentURL != storeURL {
                // Destroy intermediate step's store
                NSPersistentStoreCoordinator.destroyStore(at: currentURL)
            }
            
            currentURL = destinationURL
        }
        
        NSPersistentStoreCoordinator.replaceStore(at: storeURL, withStoreAt: currentURL)
        
        if currentURL != storeURL {
            NSPersistentStoreCoordinator.destroyStore(at: currentURL)
        }
    }
    
    private func migrationStepsForStore(
        at storeURL: URL,
        toVersion destinationVersion: CoreDataMigrationVersion
    ) -> [CoreDataMigrationStep] {
        guard let bundle else {
            fatalError("Cant migrate without passed bundle")
        }
        guard
            let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL),
            let sourceVersion = CoreDataMigrationVersion.compatibleVersionForStoreMetadata(
                metadata,
                versions: versions,
                momdSubdirectory: momdSubdirectory,
                bundle: bundle
            )
        else { fatalError("unknown store version at URL \(storeURL)") }
        
        migrating?(sourceVersion, destinationVersion)
        
        return migrationSteps(fromSourceVersion: sourceVersion, toDestinationVersion: destinationVersion)
    }

    private func migrationSteps(
        fromSourceVersion sourceVersion: CoreDataMigrationVersion,
        toDestinationVersion destinationVersion: CoreDataMigrationVersion
    ) -> [CoreDataMigrationStep] {
        guard let bundle else {
            fatalError("Cant migrate without passed bundle")
        }
        var sourceVersion = sourceVersion
        var migrationSteps = [CoreDataMigrationStep]()

        while sourceVersion != destinationVersion, let nextVersion = versions.nextVersion(for: sourceVersion) {
            let migrationStep = CoreDataMigrationStep(
                sourceVersion: sourceVersion,
                destinationVersion: nextVersion,
                momdSubdirectory: momdSubdirectory,
                bundle: bundle
            )
            migrationSteps.append(migrationStep)

            sourceVersion = nextVersion
        }

        return migrationSteps
    }
    
    // MARK: - WAL

    private func forceWALCheckpointingForStore(at storeURL: URL) {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL),
              let currentModel = NSManagedObjectModel.compatibleModelForStoreMetadata(metadata) else {
            return
        }
        
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: currentModel)
            
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = persistentStoreCoordinator.addPersistentStore(at: storeURL, options: options)
            try persistentStoreCoordinator.remove(store)
        } catch let error {
            fatalError("failed to force WAL checkpointing, error: \(error)")
        }
    }
}

private extension CoreDataMigrationVersion {
    static func compatibleVersionForStoreMetadata(
        _ metadata: [String: Any],
        versions: CoreDataMigrationVersionList,
        momdSubdirectory: String,
        bundle: Bundle
    ) -> CoreDataMigrationVersion? {
        let compatibleVersion = versions.first {
            let model = NSManagedObjectModel.managedObjectModel(
                forResource: $0.rawValue,
                momdSubdirectory: momdSubdirectory,
                bundle: bundle
            )
            
            return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        return compatibleVersion
    }
}

private extension NSManagedObjectModel {
    static func compatibleModelForStoreMetadata(_ metadata: [String: Any]) -> NSManagedObjectModel? {
        let mainBundle = Bundle.main
        return NSManagedObjectModel.mergedModel(from: [mainBundle], forStoreMetadata: metadata)
    }
}

private extension NSPersistentStoreCoordinator {
    static func destroyStore(at storeURL: URL) {
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        } catch let error {
            fatalError("failed to destroy persistent store at \(storeURL), error: \(error)")
        }
    }
    
    static func replaceStore(at targetURL: URL, withStoreAt sourceURL: URL) {
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.replacePersistentStore(
                at: targetURL,
                destinationOptions: nil,
                withPersistentStoreFrom: sourceURL,
                sourceOptions: nil,
                ofType: NSSQLiteStoreType
            )
        } catch let error {
            fatalError("failed to replace persistent store at \(targetURL) with \(sourceURL), error: \(error)")
        }
    }
    
    static func metadata(at storeURL: URL) -> [String: Any]? {
        try? NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL,
            options: nil
        )
    }
    
    func addPersistentStore(at storeURL: URL, options: [AnyHashable: Any]) -> NSPersistentStore {
        do {
            return try addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: options
            )
        } catch let error {
            fatalError("failed to add persistent store to coordinator, error: \(error)")
        }
    }
}
