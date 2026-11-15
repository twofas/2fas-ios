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

import XCTest
import CoreData
import CloudKit
@testable import Common
@testable import Protection
@testable import Sync

/// Sync5 (obfuscated secrets, plaintext fields) → Sync6 (hashes + sealed content, sealed metadata)
final class SyncMigrationTests: XCTestCase {
    private struct LegacyService {
        var secret: String
        var name: String
        var additionalInfo: String?
        var rawIssuer: String?
        var otpAuth: String?
        var labelTitle = "LT"
        var serviceTypeID: UUID?
        var iconTypeID = UUID()
        var metadata: Data
        var creationDate = Date(timeIntervalSinceReferenceDate: 700_000_000)
        var modificationDate = Date(timeIntervalSinceReferenceDate: 700_000_100)
        var sectionID: UUID?
        var sectionOrder = 0
        var tokenPeriod: Int? = 30
        var tokenLength = 6
        var algorithm = "SHA1"
        var tokenType = "TOTP"
        // The model's default – the cache doesn't normalize it
        var counter: Int? = 0
        var badgeColor: String?
        var iconType = "label"
        var labelColor = "default"
        var source = "manual"

        var plainAttributes: [String: Any?] {
            [
                "creationDate": creationDate,
                "modificationDate": modificationDate,
                "sectionID": sectionID,
                "sectionOrder": sectionOrder,
                "tokenPeriod": tokenPeriod,
                "tokenLength": tokenLength,
                "algorithm": algorithm,
                "tokenType": tokenType,
                "counter": counter,
                "badgeColor": badgeColor,
                "iconType": iconType,
                "labelColor": labelColor,
                "source": source
            ]
        }
    }

    private struct LegacyLog {
        var entityID: String
        var action: String
        var kind: String
        var isApplied: Bool
        var date: Date
    }

    private let zoneID = CKRecordZone.ID(zoneName: "TestZone", ownerName: CKCurrentUserDefaultName)
    private let sectionID = UUID()
    private let sectionTitle = "SectionTitleMarker"
    private let sectionMetadata = Data("SectionMetadataMarker".utf8)

    private lazy var alpha = LegacyService(
        secret: "ALPHASECRETMARKER",
        name: "NameMarkerAlpha",
        additionalInfo: "InfoMarkerAlpha",
        rawIssuer: "IssuerMarkerAlpha",
        otpAuth: "otpauth://totp/IssuerMarkerAlpha:InfoMarkerAlpha?secret=ALPHASECRETMARKER",
        labelTitle: "AL",
        serviceTypeID: UUID(),
        metadata: oldVaultMetadata(secret: "ALPHASECRETMARKER"),
        sectionID: sectionID,
        sectionOrder: 2,
        tokenPeriod: 60,
        tokenLength: 8,
        algorithm: "SHA256",
        badgeColor: "red",
        iconType: "brand",
        labelColor: "orange",
        source: "link"
    )
    private lazy var beta = LegacyService(
        secret: "BETASECRETMARKER",
        name: "NameMarkerBeta",
        metadata: oldVaultMetadata(secret: "BETASECRETMARKER"),
        sectionOrder: 1,
        tokenPeriod: nil,
        tokenType: "HOTP",
        counter: 5
    )
    private lazy var logs = [
        LegacyLog(
            entityID: alpha.secret,
            action: "created",
            kind: "service",
            isApplied: false,
            date: Date(timeIntervalSinceReferenceDate: 710_000_000)
        ),
        LegacyLog(
            entityID: sectionID.uuidString,
            action: "modified",
            kind: "section",
            isApplied: true,
            date: Date(timeIntervalSinceReferenceDate: 710_000_500)
        )
    ]

    private var migratedServices: [LegacyService] { [alpha, beta] }

    private var directory: URL!
    private var stack: CoreDataStack?

    private var storeURL: URL { CoreDataStack.storeURL(name: "Sync", directory: directory) }

    override func setUp() {
        super.setUp()
        EncryptionHolder.initialize(with: LocalKeyEncryption())
        directory = makeTemporaryDirectory()
    }

    override func tearDown() {
        if let stack {
            closeStores(of: stack)
        }
        stack = nil
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testMigrationPreservesServiceCache() throws {
        try makeSync5Store(at: storeURL)

        let stack = openMigratedStack()
        let handler = makeServiceHandler(stack: stack)

        let list = handler.listAllWithMetadata()
        XCTAssertEqual(list.count, 2)
        for legacy in migratedServices {
            let item = try XCTUnwrap(list.first { $0.0.secret == legacy.secret }, legacy.name)
            assertService(item.0, equals: legacy)
            XCTAssertEqual(item.1, legacy.metadata, legacy.name)
        }
        XCTAssertEqual(handler.findService(by: alpha.secret.lowercased())?.serviceData.name, alpha.name)

        let entities = try stack.context.fetch(NSFetchRequest<NSManagedObject>(entityName: "ServiceCacheEntity"))
        for legacy in migratedServices {
            let entity = try XCTUnwrap(
                entities.first { ($0 as? ServiceCacheEntity)?.serviceData.secret == legacy.secret }
            )
            for (key, value) in legacy.plainAttributes {
                XCTAssertEqual(entity.value(forKey: key) as? NSObject, value as? NSObject, "\(legacy.name).\(key)")
            }
        }
    }

    func testMigrationPreservesSectionCache() throws {
        try makeSync5Store(at: storeURL)

        let stack = openMigratedStack()

        let sections = try stack.context.fetch(NSFetchRequest<NSManagedObject>(entityName: "SectionCacheEntity"))
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections.first?.value(forKey: "sectionID") as? String, sectionID.uuidString)
        XCTAssertEqual((sections.first as? SectionCacheEntity)?.title, sectionTitle)
        XCTAssertEqual(sections.first?.value(forKey: "metadata") as? Data, sectionMetadata)
    }

    func testMigrationPreservesLogs() throws {
        try makeSync5Store(at: storeURL)

        let stack = openMigratedStack()
        let handler = Sync.LogHandler(coreDataStack: stack)

        let list = handler.listAll()
        XCTAssertEqual(list.count, logs.count)
        for legacy in logs {
            let entity = try XCTUnwrap(list.first { $0.entityID == legacy.entityID }, legacy.kind)
            XCTAssertEqual(entity.action, legacy.action)
            XCTAssertEqual(entity.kind, legacy.kind)
            XCTAssertEqual(entity.isApplied, legacy.isApplied)
            XCTAssertEqual(entity.date, legacy.date)
        }
        // Looked up through the hash
        XCTAssertNotNil(LogEntity.findLog(on: stack.context, entityID: alpha.secret))
    }

    /// Added ahead of the sync of deletions, so that it needs no migration of its own
    func testMigratedSyncStoreHasEmptyDeletedEntities() throws {
        try makeSync5Store(at: storeURL)

        let stack = openMigratedStack()

        let model = try XCTUnwrap(stack.context.persistentStoreCoordinator?.managedObjectModel)
        let expectedAttributes: [String: Set<String>] = [
            "DeletedServiceCacheEntity": ["secretHash", "deletedAt", "encryptedContent", "encryptedMetadata"],
            "DeletedSectionCacheEntity": ["sectionID", "deletedAt", "metadata"]
        ]
        for (entityName, attributes) in expectedAttributes {
            let entity = try XCTUnwrap(model.entitiesByName[entityName], entityName)
            XCTAssertEqual(Set(entity.attributesByName.keys), attributes, entityName)
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            XCTAssertEqual(try stack.context.count(for: request), 0, entityName)
        }
    }

    func testMigratedSyncStoreHasNoPlaintext() throws {
        try makeSync5Store(at: storeURL)
        let oldBytes = rawStoreBytes(name: "Sync", in: directory)
        XCTAssertNotNil(oldBytes.range(of: Data(alpha.name.utf8)))
        XCTAssertNotNil(oldBytes.range(of: Data(alpha.secret.encrypt().utf8)))
        XCTAssertNotNil(oldBytes.range(of: Data("\(alpha.secret)_V2".encrypt().utf8)))
        XCTAssertNotNil(oldBytes.range(of: Data(logs[0].entityID.utf8)))

        let stack = openMigratedStack()
        XCTAssertEqual(makeServiceHandler(stack: stack).count(), 2)
        stack.save()

        let bytes = rawStoreBytes(name: "Sync", in: directory)
        XCTAssertFalse(bytes.isEmpty)
        var markers = ["otpauth://", logs[0].entityID]
        for service in migratedServices {
            markers += [service.secret, service.secret.encrypt(), service.name]
            markers += [service.secret + "_V2", (service.secret + "_V2").encrypt()]
            markers += [service.additionalInfo, service.rawIssuer].compactMap { $0 }
        }
        for marker in markers {
            XCTAssertNil(bytes.range(of: Data(marker.utf8)), "\(marker) found in the migrated store files")
        }
        // The title of a section is sealed too; its record metadata stays as it was
        XCTAssertNil(bytes.range(of: Data(sectionTitle.utf8)))
        XCTAssertNotNil(bytes.range(of: sectionMetadata))
    }

    func testMigrationDropsDuplicateAndEmptySecrets() throws {
        try makeSync5Store(at: storeURL, extraServices: true)

        let stack = openMigratedStack()
        let list = makeServiceHandler(stack: stack).listAll()

        XCTAssertEqual(list.map(\.secret).sorted(), migratedServices.map(\.secret).sorted())
        XCTAssertEqual(list.first { $0.secret == alpha.secret }?.name, alpha.name)
        XCTAssertEqual(
            try stack.context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "ServiceCacheEntity")),
            2
        )
    }

    func testStateResetIsRequiredOnlyForStoresOlderThanSync5() {
        for version in ["Sync", "Sync2", "Sync3", "Sync4"] {
            XCTAssertTrue(
                SyncInstance.requiresStateResetAfterMigration(from: CoreDataMigrationVersion(rawValue: version)),
                version
            )
        }
        for version in ["Sync5", "Sync6"] {
            XCTAssertFalse(
                SyncInstance.requiresStateResetAfterMigration(from: CoreDataMigrationVersion(rawValue: version)),
                version
            )
        }
    }

    func testMigrationNotAllowedLeavesOldStoreUntouched() throws {
        try makeSync5Store(at: storeURL)
        let oldBytes = rawStoreBytes(name: "Sync", in: directory)
        XCTAssertFalse(oldBytes.isEmpty)

        let stack = SyncInstance.makeCoreDataStack(
            cipher: makeTestCipher(),
            storeDirectory: directory,
            allowsMigration: false
        )
        self.stack = stack
        _ = stack.context

        let sync5 = try model(named: "Sync5")
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL,
            options: nil
        )
        XCTAssertTrue(sync5.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata))
        XCTAssertEqual(rawStoreBytes(name: "Sync", in: directory), oldBytes)
        let premigration = try FileManager.default.contentsOfDirectory(atPath: directory.path)
            .filter { $0.contains("premigration") }
        XCTAssertEqual(premigration, [])
        XCTAssertEqual(stack.context.persistentStoreCoordinator?.persistentStores.first?.type, NSInMemoryStoreType)
    }

    func testMigrationNotAllowedDefersSync() throws {
        try makeSync5Store(at: storeURL)

        let stack = SyncInstance.makeCoreDataStack(
            cipher: makeTestCipher(),
            storeDirectory: directory,
            allowsMigration: false
        )
        self.stack = stack

        XCTAssertEqual(stack.storeKind, .inMemory)
        XCTAssertTrue(SyncInstance.isSyncDeferred(storageMigrationDeferred: false, syncStack: stack))
    }

    func testCurrentStoreDefersSyncOnlyWithDeferredStorage() {
        let current = SyncInstance.makeCoreDataStack(cipher: makeTestCipher(), storeDirectory: directory)
        self.stack = current
        _ = current.context
        closeStores(of: current)

        let stack = SyncInstance.makeCoreDataStack(
            cipher: makeTestCipher(),
            storeDirectory: directory,
            allowsMigration: false
        )
        self.stack = stack

        XCTAssertEqual(stack.storeKind, .file)
        XCTAssertFalse(SyncInstance.isSyncDeferred(storageMigrationDeferred: false, syncStack: stack))
        XCTAssertTrue(SyncInstance.isSyncDeferred(storageMigrationDeferred: true, syncStack: stack))
    }

    func testPoliciesThrowWithoutCipher() throws {
        let sourceModel = try model(named: "Sync5")
        let manager = NSMigrationManager(sourceModel: sourceModel, destinationModel: try model(named: "Sync6"))
        XCTAssertNil(manager.localStorageCipher)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: sourceModel)
        try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        let service = insert(alpha, into: context)
        let log = insert(logs[0], into: context)

        XCTAssertThrowsError(
            try EncryptServiceCacheContentMigrationPolicy()
                .createDestinationInstances(forSource: service, in: NSEntityMapping(), manager: manager)
        ) { XCTAssertEqual($0 as? EncryptServiceCacheContentMigrationPolicy.Failure, .missingCipher) }
        XCTAssertThrowsError(
            try EncryptLogEntityMigrationPolicy()
                .createDestinationInstances(forSource: log, in: NSEntityMapping(), manager: manager)
        ) { XCTAssertEqual($0 as? EncryptLogEntityMigrationPolicy.Failure, .missingCipher) }
    }

    // MARK: - Helpers

    private func openMigratedStack() -> CoreDataStack {
        let stack = SyncInstance.makeCoreDataStack(cipher: makeTestCipher(), storeDirectory: directory)
        self.stack = stack
        // The stack loads (and migrates) the store on first use
        _ = stack.context
        return stack
    }

    private func makeServiceHandler(stack: CoreDataStack) -> Sync.ServiceHandler {
        Sync.ServiceHandler(
            coreDataStack: stack,
            serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler(
                zoneManager: ZoneManager(),
                encryptionHandler: SyncEncryptionHandler(reference: Data(), localEncryptionKeyData: Data(count: 32))
            )
        )
    }

    private func oldVaultMetadata(secret: String) -> Data {
        let recordID = ServiceRecord2.recordID(with: secret, zoneID: zoneID)
        return CKRecord(recordType: RecordType.service2.rawValue, recordID: recordID).encodeSystemFields()
    }

    private func assertService(_ service: ServiceData, equals legacy: LegacyService) {
        let name = legacy.name
        XCTAssertEqual(service.name, legacy.name, name)
        XCTAssertEqual(service.secret, legacy.secret, name)
        XCTAssertEqual(service.additionalInfo, legacy.additionalInfo, name)
        XCTAssertEqual(service.rawIssuer, legacy.rawIssuer, name)
        XCTAssertEqual(service.otpAuth, legacy.otpAuth, name)
        XCTAssertEqual(service.labelTitle, legacy.labelTitle, name)
        XCTAssertEqual(service.serviceTypeID, legacy.serviceTypeID, name)
        XCTAssertEqual(service.iconTypeID, legacy.iconTypeID, name)
        XCTAssertEqual(service.createdAt, legacy.creationDate, name)
        XCTAssertEqual(service.modifiedAt, legacy.modificationDate, name)
        XCTAssertEqual(service.sectionID, legacy.sectionID, name)
        XCTAssertEqual(service.order, legacy.sectionOrder, name)
        XCTAssertEqual(service.tokenPeriod?.rawValue, legacy.tokenPeriod, name)
        XCTAssertEqual(service.tokenLength.rawValue, legacy.tokenLength, name)
        XCTAssertEqual(service.algorithm.rawValue, legacy.algorithm, name)
        XCTAssertEqual(service.tokenType.rawValue, legacy.tokenType, name)
        XCTAssertEqual(service.counter, legacy.counter, name)
        XCTAssertEqual(service.badgeColor?.rawValue, legacy.badgeColor, name)
        XCTAssertEqual(service.iconType.rawValue, legacy.iconType, name)
        XCTAssertEqual(service.labelColor.rawValue, legacy.labelColor, name)
        XCTAssertEqual(service.source.rawValue, legacy.source, name)
    }

    /// A Sync5 store as the app wrote it
    private func makeSync5Store(at url: URL, extraServices: Bool = false) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try model(named: "Sync5"))
        let store = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: url,
            options: nil
        )
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        let services = migratedServices
        let extras = [
            LegacyService(secret: alpha.secret, name: "NameMarkerDuplicate", metadata: Data()),
            LegacyService(secret: "", name: "NameMarkerEmpty", metadata: Data())
        ]
        let logs = logs
        try context.performAndWait {
            insertSection(into: context)
            services.forEach { insert($0, into: context) }
            logs.forEach { insert($0, into: context) }
            try context.save()
            if extraServices {
                extras.forEach { insert($0, into: context) }
                try context.save()
            }
        }
        try coordinator.remove(store)
    }

    @discardableResult
    private func insert(_ service: LegacyService, into context: NSManagedObjectContext) -> NSManagedObject {
        let object = NSEntityDescription.insertNewObject(forEntityName: "ServiceCacheEntity", into: context)
        object.setValue(service.secret.encrypt(), forKey: "secret")
        object.setValue(service.name, forKey: "name")
        object.setValue(service.additionalInfo, forKey: "additionalInfo")
        object.setValue(service.rawIssuer, forKey: "rawIssuer")
        object.setValue(service.otpAuth, forKey: "otpAuth")
        object.setValue(service.labelTitle, forKey: "labelTitle")
        object.setValue(service.serviceTypeID, forKey: "serviceTypeID")
        object.setValue(service.iconTypeID, forKey: "iconTypeID")
        object.setValue(service.metadata, forKey: "metadata")
        for (key, value) in service.plainAttributes {
            object.setValue(value, forKey: key)
        }
        return object
    }

    @discardableResult
    private func insert(_ log: LegacyLog, into context: NSManagedObjectContext) -> NSManagedObject {
        let object = NSEntityDescription.insertNewObject(forEntityName: "LogEntity", into: context)
        object.setValue(log.entityID, forKey: "entityID")
        object.setValue(log.action, forKey: "action")
        object.setValue(log.kind, forKey: "kind")
        object.setValue(log.isApplied, forKey: "isApplied")
        object.setValue(log.date, forKey: "date")
        return object
    }

    private func insertSection(into context: NSManagedObjectContext) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "SectionCacheEntity", into: context)
        object.setValue(sectionID.uuidString, forKey: "sectionID")
        object.setValue(sectionTitle, forKey: "title")
        object.setValue(sectionMetadata, forKey: "metadata")
        object.setValue(Date(timeIntervalSinceReferenceDate: 690_000_000), forKey: "creationDate")
        object.setValue(Date(timeIntervalSinceReferenceDate: 690_000_500), forKey: "modificationDate")
        object.setValue(0, forKey: "order")
    }

    private func model(named version: String) throws -> NSManagedObjectModel {
        let bundle = Bundle(for: SyncHandler.self)
        let modelURL = try XCTUnwrap(bundle.url(forResource: version, withExtension: "mom", subdirectory: "Sync.momd"))
        return try XCTUnwrap(NSManagedObjectModel(contentsOf: modelURL))
    }
}
