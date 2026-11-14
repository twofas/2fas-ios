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
@testable import Common
@testable import Protection
@testable import Storage

/// TwoFAS7 (obfuscated secrets, plaintext fields) → TwoFAS8 (hashes + sealed content)
final class StorageMigrationTests: XCTestCase {
    /// A `ServiceEntity` row of the TwoFAS7 model
    private struct LegacyService {
        var secret: String
        var name: String
        var additionalInfo: String?
        var rawIssuer: String?
        var otpAuth: String?
        var labelTitle = "LT"
        var serviceTypeID: UUID?
        var iconTypeID = UUID()
        var creationDate = Date(timeIntervalSinceReferenceDate: 700_000_000)
        var modificationDate = Date(timeIntervalSinceReferenceDate: 700_000_100)
        var sectionID: UUID?
        var sectionOrder = 0
        var isTrashed = false
        var trashingDate: Date?
        var tokenPeriod: Int? = 30
        var tokenLength = 6
        var algorithm = "SHA1"
        var tokenType = "TOTP"
        var counter: Int?
        var badgeColor: String?
        var iconType = "label"
        var labelColor = "default"
        var source = "manual"

        /// Attributes TwoFAS8 keeps in plaintext, under the same names
        var plainAttributes: [String: Any?] {
            [
                "creationDate": creationDate,
                "modificationDate": modificationDate,
                "sectionID": sectionID,
                "sectionOrder": sectionOrder,
                "isTrashed": isTrashed,
                "trashingDate": trashingDate,
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

    private let sectionID = UUID()
    private let sectionTitle = "Work"
    private let sectionCreationDate = Date(timeIntervalSinceReferenceDate: 690_000_000)
    private let sectionModificationDate = Date(timeIntervalSinceReferenceDate: 690_000_500)
    private let extensionID = "extension-id"
    private let domain = "domainmarker.example"
    private let otherDomain = "otherdomain.example"
    private let authCreationDate = Date(timeIntervalSinceReferenceDate: 710_000_000)
    private let authLastUsed = Date(timeIntervalSinceReferenceDate: 710_000_900)
    private let authUsedCount: Int32 = 3
    private let pairingName = "Browser"
    private let pairingPublicKey = "public-key"
    private let pairingCreationDate = Date(timeIntervalSinceReferenceDate: 705_000_000)
    private let pairingModificationDate = Date(timeIntervalSinceReferenceDate: 705_000_700)
    private let newsID = "news-id"

    private lazy var regular = LegacyService(
        secret: "ALPHASECRETMARKER",
        name: "NameMarkerAlpha",
        additionalInfo: "InfoMarkerAlpha",
        rawIssuer: "IssuerMarkerAlpha",
        otpAuth: "otpauth://totp/IssuerMarkerAlpha:InfoMarkerAlpha?secret=ALPHASECRETMARKER",
        labelTitle: "AL",
        serviceTypeID: UUID(),
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
    private let trashed = LegacyService(
        secret: "BETASECRETMARKER",
        name: "NameMarkerBeta",
        additionalInfo: nil,
        sectionOrder: 1,
        isTrashed: true,
        trashingDate: Date(timeIntervalSinceReferenceDate: 720_000_000),
        tokenPeriod: 90
    )
    private let hotp = LegacyService(
        secret: "GAMMASECRETMARKER",
        name: "NameMarkerGamma",
        additionalInfo: "InfoMarkerGamma",
        sectionOrder: 0,
        tokenPeriod: nil,
        tokenType: "HOTP",
        counter: 5
    )
    private lazy var duplicate = LegacyService(
        secret: regular.secret,
        name: "NameMarkerDuplicate",
        additionalInfo: "InfoMarkerDuplicate"
    )
    private let emptySecret = LegacyService(secret: "", name: "NameMarkerEmpty")

    private var migratedServices: [LegacyService] { [regular, trashed, hotp] }

    private var directory: URL!
    private var cipher: LocalStorageCipherCore!
    private var storage: Storage?

    private var storeURL: URL { CoreDataStack.storeURL(name: Storage.storeName, directory: directory) }

    override func setUp() {
        super.setUp()
        EncryptionHolder.initialize(with: LocalKeyEncryption())
        directory = makeTemporaryDirectory()
        cipher = makeTestCipher()
    }

    override func tearDown() {
        if let storage {
            closeStores(of: storage.coreDataStack)
        }
        storage = nil
        cipher = nil
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testMigrationPreservesServices() throws {
        try makeTwoFAS7Store(at: storeURL)

        let repo = openMigratedStorage().storageRepository

        let services = repo.listAllExistingServices()
        XCTAssertEqual(services.count, 3)
        for legacy in migratedServices {
            let service = try XCTUnwrap(services.first { $0.secret == legacy.secret }, legacy.name)
            assertService(service, equals: legacy)
        }
        XCTAssertEqual(repo.listTrashedServices().map(\.secret), [trashed.secret])
        XCTAssertEqual(Set(repo.listAllNotTrashed().map(\.secret)), [regular.secret, hotp.secret])
        XCTAssertEqual(repo.findService(for: hotp.secret)?.counter, 5)
        XCTAssertEqual(repo.findService(for: regular.secret.lowercased())?.name, regular.name)
        XCTAssertEqual(repo.serviceExists(for: trashed.secret), .trashed)
        XCTAssertEqual(repo.section(for: regular.secret)?.sectionID, sectionID)

        // Plain attributes are copied 1:1 (also those `ServiceData` normalizes, e.g. a missing period)
        let context = try XCTUnwrap(storage?.coreDataStack.context)
        let entities = try context.fetch(NSFetchRequest<ServiceEntity>(entityName: "ServiceEntity"))
        for legacy in migratedServices {
            let entity = try XCTUnwrap(entities.first { $0.secret == legacy.secret }, legacy.name)
            for (key, value) in legacy.plainAttributes {
                XCTAssertEqual(entity.value(forKey: key) as? NSObject, value as? NSObject, "\(legacy.name).\(key)")
            }
        }
    }

    /// Reports the duration of migrating 500 services; no threshold
    func testMigrationOf500ServicesDuration() throws {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
        let secrets = (0..<500).map { _ in String((0..<32).map { _ in alphabet.randomElement()! }) }
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let benchDirectory = makeTemporaryDirectory()
            defer { try? FileManager.default.removeItem(at: benchDirectory) }
            let url = CoreDataStack.storeURL(name: Storage.storeName, directory: benchDirectory)
            do {
                try makeTwoFAS7Store(at: url, services: secrets.enumerated().map { index, secret in
                    LegacyService(
                        secret: secret,
                        name: "Service \(index)",
                        additionalInfo: index.isMultiple(of: 5) ? nil : "user\(index)@example.com",
                        sectionOrder: index
                    )
                })
            } catch {
                XCTFail("\(error)")
                return
            }
            let benchStorage = Storage(
                storeDirectory: benchDirectory,
                initializeLogStorage: false,
                cipher: cipher,
                allowsMigration: true,
                logError: nil
            )
            startMeasuring()
            _ = benchStorage.coreDataStack.context
            stopMeasuring()
            XCTAssertEqual(benchStorage.storageRepository.listAllExistingServices().count, 500)
            closeStores(of: benchStorage.coreDataStack)
        }
    }

    func testMigrationDropsDuplicateAndEmptySecrets() throws {
        try makeTwoFAS7Store(at: storeURL)

        let repo = openMigratedStorage().storageRepository

        let services = repo.listAllExistingServices()
        XCTAssertEqual(services.map(\.secret).sorted(), migratedServices.map(\.secret).sorted())
        // The first row with a secret wins
        XCTAssertEqual(services.first { $0.secret == regular.secret }?.name, regular.name)
        XCTAssertFalse(services.contains { $0.name == duplicate.name || $0.name == emptySecret.name })
        // No row left behind that can't be read
        XCTAssertEqual(try countRows(of: "ServiceEntity"), 3)
        XCTAssertEqual(repo.countServicesNotTrashed(), 2)
        // The auth request with an empty secret is dropped
        XCTAssertEqual(try countRows(of: "AuthRequestEntity"), 2)
    }

    func testMigrationPreservesAuthRequestsPairingsSections() throws {
        try makeTwoFAS7Store(at: storeURL)

        let repo = openMigratedStorage().storageRepository

        // A secret isn't unique among auth requests – both domains of the service are kept
        let requests = repo.listAllAuthRequestsForExtensionID(extensionID)
        XCTAssertEqual(requests.map(\.domain), [domain, otherDomain])
        for request in requests {
            XCTAssertEqual(request.secret, regular.secret)
            XCTAssertEqual(request.extensionID, extensionID)
            XCTAssertEqual(request.usedCount, Int(authUsedCount))
            XCTAssertEqual(request.createdAt, authCreationDate)
            XCTAssertEqual(request.lastUsedAt, authLastUsed)
        }
        XCTAssertEqual(repo.listAllAuthRequests(for: regular.secret).map(\.domain), [domain, otherDomain])
        XCTAssertEqual(repo.listAllAuthRequests(for: domain, extensionID: extensionID).map(\.secret), [regular.secret])

        let pairings = repo.listAllPairings()
        XCTAssertEqual(pairings.count, 1)
        XCTAssertEqual(pairings.first?.name, pairingName)
        XCTAssertEqual(pairings.first?.extensionID, extensionID)
        XCTAssertEqual(pairings.first?.publicKey, pairingPublicKey)
        XCTAssertEqual(pairings.first?.createdAt, pairingCreationDate)
        XCTAssertEqual(pairings.first?.modifiedAt, pairingModificationDate)

        let sections = repo.listAllSections()
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections.first?.sectionID, sectionID)
        XCTAssertEqual(sections.first?.title, sectionTitle)
        XCTAssertEqual(sections.first?.isCollapsed, true)
        XCTAssertEqual(sections.first?.createdAt, sectionCreationDate)
        XCTAssertEqual(sections.first?.modifiedAt, sectionModificationDate)

        XCTAssertEqual(repo.listAllNews().map(\.newsID), [newsID])
    }

    func testMigratedStoreContainsNoPlaintext() throws {
        try makeTwoFAS7Store(at: storeURL)
        let oldBytes = rawStoreBytes(name: Storage.storeName, in: directory)
        let obfuscated = regular.secret.encrypt()
        XCTAssertNotEqual(obfuscated, regular.secret)
        // The markers are there before the migration
        XCTAssertNotNil(oldBytes.range(of: Data(regular.name.utf8)))
        XCTAssertNotNil(oldBytes.range(of: Data(obfuscated.utf8)))

        let storage = openMigratedStorage()
        XCTAssertEqual(storage.storageRepository.listAllExistingServices().count, 3)
        storage.save()

        let bytes = rawStoreBytes(name: Storage.storeName, in: directory)
        XCTAssertFalse(bytes.isEmpty)
        var markers = [domain, otherDomain, "emptydomain.example", obfuscated, "otpauth://"]
        for service in [regular, trashed, hotp, duplicate, emptySecret] {
            markers += [service.secret, service.secret.encrypt(), service.name]
            markers += [service.additionalInfo, service.rawIssuer].compactMap { $0 }
        }
        for marker in markers where !marker.isEmpty {
            XCTAssertNil(bytes.range(of: Data(marker.utf8)), "\(marker) found in the migrated store files")
        }
    }

    func testNoPremigrationFilesAfterMigration() throws {
        try makeTwoFAS7Store(at: storeURL)

        _ = openMigratedStorage()

        XCTAssertEqual(try premigrationFiles(), [])
        XCTAssertTrue(
            CoreDataStack.isStoreCompatible(name: Storage.storeName, bundle: twoFASModelBundle, directory: directory)
        )
        XCTAssertFalse(try isStore(compatibleWith: "TwoFAS7"))
    }

    func testExtensionDoesNotTouchOldStore() throws {
        try makeTwoFAS7Store(at: storeURL)
        let oldBytes = rawStoreBytes(name: Storage.storeName, in: directory)
        XCTAssertFalse(oldBytes.isEmpty)

        let storage = Storage(
            storeDirectory: directory,
            initializeLogStorage: false,
            cipher: cipher,
            allowsMigration: false,
            logError: nil
        )
        self.storage = storage

        XCTAssertTrue(storage.isMigrationDeferred)
        XCTAssertTrue(storage.storageRepository.listAllNotTrashed().isEmpty)
        XCTAssertTrue(storage.storageRepository.listAllAuthRequestsForExtensionID(extensionID).isEmpty)
        XCTAssertTrue(try isStore(compatibleWith: "TwoFAS7"))
        XCTAssertEqual(rawStoreBytes(name: Storage.storeName, in: directory), oldBytes)
        XCTAssertEqual(try premigrationFiles(), [])
    }

    func testMigratedOrCurrentStoreIsNotDeferred() throws {
        try makeTwoFAS7Store(at: storeURL)
        let migrated = openMigratedStorage()
        XCTAssertFalse(migrated.isMigrationDeferred)
        closeStores(of: migrated.coreDataStack)

        let storage = Storage(
            storeDirectory: directory,
            initializeLogStorage: false,
            cipher: cipher,
            allowsMigration: false,
            logError: nil
        )
        self.storage = storage

        XCTAssertFalse(storage.isMigrationDeferred)
    }

    func testPoliciesThrowWithoutCipher() throws {
        let sourceModel = try model(named: "TwoFAS7")
        let manager = NSMigrationManager(sourceModel: sourceModel, destinationModel: try model(named: "TwoFAS8"))
        XCTAssertNil(manager.localStorageCipher)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: sourceModel)
        try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        let service = insert(regular, into: context)
        let request = insertAuthRequest(secret: regular.secret, domain: domain, into: context)
        
        XCTAssertThrowsError(
            try EncryptServiceContentMigrationPolicy()
                .createDestinationInstances(forSource: service, in: NSEntityMapping(), manager: manager)
        ) { XCTAssertEqual($0 as? EncryptServiceContentMigrationPolicy.Failure, .missingCipher) }
        XCTAssertThrowsError(
            try EncryptAuthRequestContentMigrationPolicy()
                .createDestinationInstances(forSource: request, in: NSEntityMapping(), manager: manager)
        ) { XCTAssertEqual($0 as? EncryptAuthRequestContentMigrationPolicy.Failure, .missingCipher) }
    }
    
    // MARK: - Helpers

    private func openMigratedStorage() -> Storage {
        let storage = Storage(
            storeDirectory: directory,
            initializeLogStorage: false,
            cipher: cipher,
            allowsMigration: true,
            logError: nil
        )
        self.storage = storage
        // The stack loads (and migrates) the store on first use
        _ = storage.coreDataStack.context
        return storage
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
        XCTAssertEqual(service.isTrashed, legacy.isTrashed, name)
        XCTAssertEqual(service.trashingDate, legacy.trashingDate, name)
        XCTAssertEqual(service.tokenPeriod, Period.create(legacy.tokenPeriod), name)
        XCTAssertEqual(service.tokenLength.rawValue, legacy.tokenLength, name)
        XCTAssertEqual(service.algorithm.rawValue, legacy.algorithm, name)
        XCTAssertEqual(service.tokenType.rawValue, legacy.tokenType, name)
        XCTAssertEqual(service.counter, legacy.counter, name)
        XCTAssertEqual(service.badgeColor?.rawValue, legacy.badgeColor, name)
        XCTAssertEqual(service.iconType.rawValue, legacy.iconType, name)
        XCTAssertEqual(service.labelColor.rawValue, legacy.labelColor, name)
        XCTAssertEqual(service.source.rawValue, legacy.source, name)
    }

    /// A TwoFAS7 store as the app wrote it: secrets obfuscated with `encrypt()`, everything else in plaintext.
    /// The duplicate is saved last, so it comes after the row it duplicates.
    private func makeTwoFAS7Store(at url: URL, services customServices: [LegacyService]? = nil) throws {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: try model(named: "TwoFAS7"))
        let store = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: url,
            options: nil
        )
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        let services = customServices ?? [regular, trashed, hotp, emptySecret]
        let duplicate = duplicate
        try context.performAndWait {
            insertSection(into: context)
            services.forEach { insert($0, into: context) }
            insertAuthRequest(secret: regular.secret, domain: domain, into: context)
            insertAuthRequest(secret: regular.secret, domain: otherDomain, into: context)
            insertAuthRequest(secret: "", domain: "emptydomain.example", into: context)
            insertPairing(into: context)
            insertNews(into: context)
            try context.save()
            if customServices == nil {
                insert(duplicate, into: context)
                try context.save()
            }
        }
        try coordinator.remove(store)
    }

    @discardableResult
    private func insert(_ service: LegacyService, into context: NSManagedObjectContext) -> NSManagedObject {
        let object = NSEntityDescription.insertNewObject(forEntityName: "ServiceEntity", into: context)
        object.setValue(service.secret.encrypt(), forKey: "secret")
        object.setValue(service.name, forKey: "name")
        object.setValue(service.additionalInfo, forKey: "additionalInfo")
        object.setValue(service.rawIssuer, forKey: "rawIssuer")
        object.setValue(service.otpAuth, forKey: "otpAuth")
        object.setValue(service.labelTitle, forKey: "labelTitle")
        object.setValue(service.serviceTypeID, forKey: "serviceTypeID")
        object.setValue(service.iconTypeID, forKey: "iconTypeID")
        for (key, value) in service.plainAttributes {
            object.setValue(value, forKey: key)
        }
        return object
    }

    private func insertSection(into context: NSManagedObjectContext) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "SectionEntity", into: context)
        object.setValue(sectionID, forKey: "sectionID")
        object.setValue(sectionTitle, forKey: "title")
        object.setValue(sectionCreationDate, forKey: "creationDate")
        object.setValue(sectionModificationDate, forKey: "modificationDate")
        object.setValue(0, forKey: "order")
        object.setValue(true, forKey: "isCollapsed")
    }

    @discardableResult
    private func insertAuthRequest(
        secret: String,
        domain: String,
        into context: NSManagedObjectContext
    ) -> NSManagedObject {
        let object = NSEntityDescription.insertNewObject(forEntityName: "AuthRequestEntity", into: context)
        object.setValue(secret.encrypt(), forKey: "secret")
        object.setValue(domain, forKey: "domain")
        object.setValue(extensionID, forKey: "extensionID")
        object.setValue(authCreationDate, forKey: "creationDate")
        object.setValue(authLastUsed, forKey: "lastUsed")
        object.setValue(authUsedCount, forKey: "usedCount")
        return object
    }

    private func insertPairing(into context: NSManagedObjectContext) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "PairingEntity", into: context)
        object.setValue(pairingName, forKey: "name")
        object.setValue(extensionID, forKey: "extensionID")
        object.setValue(pairingPublicKey, forKey: "publicKey")
        object.setValue(pairingCreationDate, forKey: "creationDate")
        object.setValue(pairingModificationDate, forKey: "modifcationDate")
    }

    private func insertNews(into context: NSManagedObjectContext) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "NewsEntity", into: context)
        object.setValue(newsID, forKey: "newsID")
        object.setValue("news", forKey: "icon")
        object.setValue(Date(timeIntervalSinceReferenceDate: 715_000_000), forKey: "publishedAt")
        object.setValue(false, forKey: "wasRead")
    }

    private func countRows(of entityName: String) throws -> Int {
        let context = try XCTUnwrap(storage?.coreDataStack.context)
        return try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
    }

    private func model(named version: String) throws -> NSManagedObjectModel {
        let modelURL = try XCTUnwrap(
            twoFASModelBundle.url(forResource: version, withExtension: "mom", subdirectory: "TwoFAS.momd")
        )
        return try XCTUnwrap(NSManagedObjectModel(contentsOf: modelURL))
    }
    
    private func isStore(compatibleWith version: String) throws -> Bool {
        let model = try model(named: version)
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeURL,
            options: nil
        )
        return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
    }

    private func premigrationFiles() throws -> [String] {
        try storeDirectoryContents(directory).filter { $0.hasSuffix(".premigration") }
    }
}
