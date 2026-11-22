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

final class SyncCacheEncryptionTests: XCTestCase {
    private var directory: URL!
    private var stack: CoreDataStack!
    private var logHandler: Sync.LogHandler!
    private var serviceHandler: Sync.ServiceHandler!
    /// Failed decryption schedules a reset in `UserDefaults.standard` of the host app – restored after every test
    private var savedResetRequired = false

    private var context: NSManagedObjectContext { stack.context }

    override func setUp() {
        super.setUp()
        savedResetRequired = ConstStorage.syncResetRequired
        directory = makeTemporaryDirectory()
        openStack(cipher: makeTestCipher())
    }

    override func tearDown() {
        if let stack {
            closeStores(of: stack)
        }
        stack = nil
        logHandler = nil
        serviceHandler = nil
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        ConstStorage.syncResetRequired = savedResetRequired
        super.tearDown()
    }

    // MARK: - Change log

    func testLogIsFoundByEntityID() {
        logHandler.log(entityID: "SECRETA", actionType: .created, kind: .service3)
        logHandler.log(entityID: "SECRETA", actionType: .modified, kind: .service3)
        context.reset()

        let all = logHandler.listAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.entityID, "SECRETA")
        XCTAssertEqual(all.first?.action, LogActionType.created.rawValue)
        XCTAssertEqual(all.first?.kind, RecordType.service3.rawValue)
        XCTAssertNotNil(LogEntity.findLog(on: context, entityID: "SECRETA"))
        XCTAssertNil(LogEntity.findLog(on: context, entityID: "secreta"), "entityID is compared exactly")
    }

    func testLogDeletedAfterCreateIsRemoved() {
        logHandler.log(entityID: "SECRETA", actionType: .created, kind: .service3)
        logHandler.log(entityID: "SECRETA", actionType: .deleted, kind: .service3)

        XCTAssertTrue(logHandler.listAll().isEmpty)
    }

    func testMarkAsAppliedByEntityID() {
        logHandler.log(entityID: "SECRETA", actionType: .created, kind: .service3)
        logHandler.log(entityID: "SECTION-1", actionType: .modified, kind: .section)
        context.reset()

        logHandler.markAsApplied(for: "SECRETA")

        XCTAssertEqual(logHandler.countNotApplied(), 1)
        XCTAssertEqual(logHandler.listAll().first(where: { $0.entityID == "SECRETA" })?.isApplied, true)
        XCTAssertEqual(logHandler.listAll().first(where: { $0.entityID == "SECTION-1" })?.isApplied, false)

        logHandler.markAsApplied(for: logHandler.listAll())
        XCTAssertEqual(logHandler.countNotApplied(), 0)
    }

    func testModificationsLoggedTogetherMatchOneByOne() {
        func prepare() {
            logHandler.deleteAll()
            logHandler.log(entityID: "CREATED", actionType: .created, kind: .service3)
            logHandler.log(entityID: "MODIFIED", actionType: .modified, kind: .service3)
            logHandler.log(entityID: "DELETED", actionType: .deleted, kind: .service3)
            logHandler.markAsApplied(for: "MODIFIED")
        }
        func state() -> [String] {
            logHandler.listAll().map { "\($0.entityID) \($0.action) \($0.kind) \($0.isApplied)" }.sorted()
        }
        let modified = ["NEW1", "CREATED", "MODIFIED", "DELETED", "NEW2", "NEW1"]
        
        prepare()
        modified.forEach { logHandler.log(entityID: $0, actionType: .modified, kind: .service3) }
        let oneByOne = state()
        prepare()
        logHandler.logModified(entityIDs: modified, kind: .service3)
        
        XCTAssertEqual(state(), oneByOne)
        XCTAssertEqual(state(), [
            "CREATED created \(RecordType.service3.rawValue) false",
            "DELETED deleted \(RecordType.service3.rawValue) false",
            "MODIFIED modified \(RecordType.service3.rawValue) true",
            "NEW1 modified \(RecordType.service3.rawValue) false",
            "NEW2 modified \(RecordType.service3.rawValue) false"
        ])
    }
    
    func testModificationLoggedAgainIsNewer() {
        func dates() -> [String: Date] {
            Dictionary(uniqueKeysWithValues: logHandler.listAll().map { ($0.entityID, $0.date) })
        }
        logHandler.logModified(entityIDs: ["AAAA", "BBBB"], kind: .service3)
        let before = dates()
        Thread.sleep(forTimeInterval: 0.02)
        
        logHandler.logModified(entityIDs: ["BBBB", "CCCC"], kind: .service3)
        
        let after = dates()
        XCTAssertEqual(after.count, 3)
        XCTAssertEqual(after["AAAA"], before["AAAA"])
        XCTAssertGreaterThan(after["BBBB"] ?? .distantPast, before["BBBB"] ?? .distantFuture)
    }
    
    /// Deleting or moving an item on a long list modifies every item behind it
    func testLoggingManyModificationsIsFast() {
        let entityIDs = (0..<450).map { "SECRET\($0)" }
        logHandler.logModified(entityIDs: entityIDs, kind: .service3)
        
        let start = Date()
        logHandler.logModified(entityIDs: entityIDs, kind: .service3)
        
        XCTAssertLessThan(Date().timeIntervalSince(start), 0.1)
        XCTAssertEqual(logHandler.countChanges(), 450)
    }
    
    func testFirstImportLogsEveryEntity() {
        logHandler.logFirstImport(entityIDs: ["SECTION-1", "SECTION-2"], kind: .section)
        context.reset()

        XCTAssertEqual(Set(logHandler.listAll().map(\.entityID)), ["SECTION-1", "SECTION-2"])
        XCTAssertNotNil(LogEntity.findLog(on: context, entityID: "SECTION-2"))
    }

    // MARK: - Service cache

    func testServiceCacheFindAndDeleteBySecret() {
        addService(secret: "abcdefgh")

        XCTAssertNotNil(serviceHandler.findService(by: "ABCDEFGH"))
        XCTAssertEqual(serviceHandler.findServices(by: ["abcdefgh"]).map(\.secret), ["ABCDEFGH"])
        XCTAssertNil(serviceHandler.findService(by: "OTHERSECRET"))

        serviceHandler.delete(identifiedBy: ["ABCDEFGH"])

        XCTAssertEqual(serviceHandler.count(), 0)
    }

    func testServiceCacheRoundTripsAllFields() throws {
        let serviceTypeID = UUID()
        let iconTypeID = UUID()
        let sectionID = UUID()
        let metadata = Data("metadata".utf8)
        addService(
            metadata: metadata,
            name: "Account",
            secret: "jbswy3dpehpk3pxp",
            serviceTypeID: serviceTypeID,
            additionalInfo: "user@example.com",
            rawIssuer: "Issuer",
            otpAuth: "otpauth://totp/Issuer:user?secret=JBSWY3DPEHPK3PXP",
            iconTypeID: iconTypeID,
            labelTitle: "AC",
            sectionID: sectionID
        )
        context.reset()

        let (service, storedMetadata) = try XCTUnwrap(serviceHandler.listAllWithMetadata().first)
        XCTAssertEqual(storedMetadata, metadata)
        XCTAssertEqual(service.name, "Account")
        XCTAssertEqual(service.secret, "JBSWY3DPEHPK3PXP")
        XCTAssertEqual(service.serviceTypeID, serviceTypeID)
        XCTAssertEqual(service.additionalInfo, "user@example.com")
        XCTAssertEqual(service.rawIssuer, "Issuer")
        XCTAssertEqual(service.otpAuth, "otpauth://totp/Issuer:user?secret=JBSWY3DPEHPK3PXP")
        XCTAssertEqual(service.labelTitle, "AC")
        XCTAssertEqual(service.iconTypeID, iconTypeID)
        XCTAssertEqual(service.sectionID, sectionID)
        XCTAssertEqual(service.order, 3)
        XCTAssertEqual(service.tokenPeriod, .period30)
        XCTAssertEqual(service.tokenLength, .digits6)
        XCTAssertEqual(service.algorithm, .SHA1)
        XCTAssertEqual(service.tokenType, .totp)
    }

    func testUpdateFromRecordSealsContentAndMetadataOnce() throws {
        let cipher = CountingCipher()
        reopenStack(cipher: cipher)
        let iconTypeID = UUID()
        let recordMetadata = CKRecord(
            recordType: RecordType.service2.rawValue,
            recordID: CKRecord.ID(recordName: "record", zoneID: CKRecordZone.ID(zoneName: "Zone"))
        ).encodeSystemFields()
        addService(name: "Old", secret: "JBSWY3DPEHPK3PXP", labelTitle: "OL")
        let record = try makeServiceRecord2(
            metadata: recordMetadata,
            name: "New",
            secret: "JBSWY3DPEHPK3PXP",
            iconTypeID: iconTypeID
        )
        let contentSealsBefore = cipher.sealCount(associatedDataPrefix: "2fas.ServiceCacheEntity.v1")
        let metadataSealsBefore = cipher.sealCount(associatedDataPrefix: "2fas.ServiceCacheEntity.metadata.v1")

        serviceHandler.updateOrCreate(with: record, save: true)

        XCTAssertEqual(cipher.sealCount(associatedDataPrefix: "2fas.ServiceCacheEntity.v1") - contentSealsBefore, 1)
        XCTAssertEqual(
            cipher.sealCount(associatedDataPrefix: "2fas.ServiceCacheEntity.metadata.v1") - metadataSealsBefore,
            1
        )
        context.reset()
        let services = serviceHandler.listAllWithMetadata()
        XCTAssertEqual(services.count, 1)
        XCTAssertEqual(services.first?.0.name, "New")
        XCTAssertEqual(services.first?.0.secret, "JBSWY3DPEHPK3PXP")
        XCTAssertEqual(services.first?.0.additionalInfo, "info")
        XCTAssertEqual(services.first?.0.rawIssuer, "Issuer")
        XCTAssertEqual(services.first?.0.labelTitle, "NE")
        XCTAssertEqual(services.first?.0.iconTypeID, iconTypeID)
        XCTAssertEqual(services.first?.0.tokenLength, .digits8)
        XCTAssertEqual(services.first?.1, recordMetadata)
    }

    // MARK: - Failures

    func testNothingIsInsertedWhenWritingIsNotPossible() {
        let cipher = CountingCipher()
        cipher.failsWriting = true
        reopenStack(cipher: cipher)

        // Every write that can't be sealed schedules a reset – the cache would miss the change
        ConstStorage.syncResetRequired = false
        addService(secret: "AAAA")
        XCTAssertTrue(ConstStorage.syncResetRequired, "service insert")

        ConstStorage.syncResetRequired = false
        logHandler.log(entityID: "AAAA", actionType: .created, kind: .service3)
        XCTAssertTrue(ConstStorage.syncResetRequired, "log insert")

        ConstStorage.syncResetRequired = false
        XCTAssertFalse(logHandler.logFirstImport(entityIDs: ["SECTION-1", "SECTION-2"], kind: .section))
        XCTAssertTrue(ConstStorage.syncResetRequired, "first import")

        XCTAssertEqual(cipher.sealCount, 0)
        XCTAssertEqual(serviceHandler.count(), 0)
        XCTAssertTrue(logHandler.listAll().isEmpty)
    }

    func testFirstImportReportsSuccess() {
        ConstStorage.syncResetRequired = false

        XCTAssertTrue(logHandler.logFirstImport(entityIDs: ["SECTION-1"], kind: .section))
        XCTAssertTrue(logHandler.logFirstImport(entityIDs: [], kind: .section))
        XCTAssertFalse(ConstStorage.syncResetRequired)
    }

    func testUpdateThatCantBeSealedSchedulesResetAndChangesNothing() throws {
        let cipher = CountingCipher()
        reopenStack(cipher: cipher)
        let metadata = Data("metadata".utf8)
        addService(metadata: metadata, name: "Old", secret: "JBSWY3DPEHPK3PXP")
        let record = try makeServiceRecord2(
            metadata: CKRecord(
                recordType: RecordType.service2.rawValue,
                recordID: CKRecord.ID(recordName: "record", zoneID: CKRecordZone.ID(zoneName: "Zone"))
            ).encodeSystemFields(),
            name: "New",
            secret: "JBSWY3DPEHPK3PXP",
            iconTypeID: UUID()
        )
        ConstStorage.syncResetRequired = false
        cipher.failsWriting = true

        serviceHandler.updateOrCreate(with: record, save: true)

        XCTAssertTrue(ConstStorage.syncResetRequired)
        context.reset()
        let services = serviceHandler.listAllWithMetadata()
        XCTAssertEqual(services.map(\.0.name), ["Old"])
        XCTAssertEqual(services.first?.1, metadata)
    }

    func testRowsSealedWithOtherKeyThrowOnDecryption() throws {
        addService(name: "Alpha", secret: "AAAA")
        logHandler.log(entityID: "AAAA", actionType: .created, kind: .service3)

        reopenStack(cipher: makeTestCipher())

        let service = try XCTUnwrap(ServiceCacheEntity.listAll(on: context).first)
        XCTAssertThrowsError(try service.decryptedContent())
        XCTAssertNil(service.content)
        XCTAssertThrowsError(try service.decryptedMetadata())
        XCTAssertEqual(service.metadata, Data())
        let log = try XCTUnwrap(logHandler.listAll().first)
        XCTAssertThrowsError(try log.decryptedEntityID())
        XCTAssertEqual(log.entityID, "")
    }

    // MARK: - Files

    func testSyncStoreContainsNoPlaintext() {
        addService(
            name: "NameMarkerXYZ",
            secret: "PLAINTEXTSECRETMARKER",
            additionalInfo: "InfoMarkerXYZ",
            rawIssuer: "IssuerMarkerXYZ",
            otpAuth: "otpauth://totp/NameMarkerXYZ?secret=PLAINTEXTSECRETMARKER",
            labelTitle: "LabelMarkerXYZ"
        )
        logHandler.log(entityID: "PLAINTEXTSECRETMARKER", actionType: .created, kind: .service3)
        logHandler.log(entityID: "SECTIONIDMARKER", actionType: .modified, kind: .section)
        stack.save()

        let bytes = rawStoreBytes(name: SyncInstance.storeName, in: directory)
        XCTAssertFalse(bytes.isEmpty)
        let markers = [
            "PLAINTEXTSECRETMARKER",
            "NameMarkerXYZ",
            "InfoMarkerXYZ",
            "IssuerMarkerXYZ",
            "LabelMarkerXYZ",
            "SECTIONIDMARKER",
            "otpauth://"
        ]
        for marker in markers {
            XCTAssertNil(bytes.range(of: Data(marker.utf8)), "\(marker) found in store files")
        }
    }

    /// The record name of an old-vault record is the obfuscated `<SECRET>_V2`, and it's part of the system fields
    func testOldVaultRecordMetadataIsNotStoredInPlaintext() throws {
        EncryptionHolder.initialize(with: LocalKeyEncryption())
        let secret = "PLAINTEXTSECRETMARKER"
        let zoneID = CKRecordZone.ID(zoneName: "TestZone", ownerName: CKCurrentUserDefaultName)
        let recordID = ServiceRecord2.recordID(with: secret, zoneID: zoneID)
        let metadata = CKRecord(recordType: RecordType.service2.rawValue, recordID: recordID).encodeSystemFields()
        let obfuscatedRecordName = "\(secret)_V2".encrypt()
        XCTAssertEqual(recordID.recordName, obfuscatedRecordName)
        XCTAssertNotNil(metadata.range(of: Data(obfuscatedRecordName.utf8)), "the fixture has to contain the name")

        addService(metadata: metadata, secret: secret)

        let bytes = rawStoreBytes(name: "Sync", in: directory)
        XCTAssertFalse(bytes.isEmpty)
        for marker in [secret, "\(secret)_V2", obfuscatedRecordName] {
            XCTAssertNil(bytes.range(of: Data(marker.utf8)), "\(marker) found in store files")
        }
        context.reset()
        XCTAssertEqual(serviceHandler.listAllWithMetadata().first?.1, metadata)
    }

    // MARK: - Helpers

    private func openStack(cipher: LocalStorageCipher) {
        stack = SyncInstance.makeCoreDataStack(cipher: cipher, storeDirectory: directory)
        logHandler = Sync.LogHandler(coreDataStack: stack)
        serviceHandler = Sync.ServiceHandler(
            coreDataStack: stack,
            serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler(
                zoneManager: ZoneManager(),
                encryptionHandler: SyncEncryptionHandler(reference: Data(), localEncryptionKeyData: Data(count: 32))
            )
        )
    }

    private func reopenStack(cipher: LocalStorageCipher) {
        closeStores(of: stack)
        openStack(cipher: cipher)
    }

    /// An old-vault record of the service with `secret`; the service handler gets the encryption to read it
    private func makeServiceRecord2(
        metadata: Data,
        name: String,
        secret: String,
        iconTypeID: UUID
    ) throws -> ServiceRecord2 {
        let encryption = ExchangeFileEncryption()
        let encryptedSecret = try XCTUnwrap(encryption.encrypt(with: "password", data: Data(secret.utf8)))
        let record = try XCTUnwrap(ServiceRecord2.create(
            with: metadata,
            name: name,
            secret: encryptedSecret.data,
            serviceTypeID: nil,
            additionalInfo: "info",
            rawIssuer: "Issuer",
            otpAuth: nil,
            tokenPeriod: 60,
            tokenLength: 8,
            badgeColor: nil,
            iconType: IconType.label.rawValue,
            iconTypeID: iconTypeID.uuidString,
            labelColor: TintColor.default.rawValue,
            labelTitle: "NE",
            sectionID: nil,
            sectionOrder: 0,
            algorithm: Algorithm.SHA1.rawValue,
            counter: nil,
            tokenType: TokenType.totp.rawValue,
            source: ServiceSource.manual.rawValue,
            reference: encryptedSecret.reference
        ))
        serviceHandler.encryption = encryption
        serviceHandler.embedded = "password"
        return ServiceRecord2(record: record)
    }

    private func addService(
        metadata: Data = Data(),
        name: String = "Service",
        secret: String,
        serviceTypeID: ServiceTypeID? = nil,
        additionalInfo: String? = nil,
        rawIssuer: String? = nil,
        otpAuth: String? = nil,
        iconTypeID: IconTypeID = .default,
        labelTitle: String = "SE",
        sectionID: SectionID? = nil
    ) {
        ServiceCacheEntity.create(
            on: context,
            metadata: metadata,
            name: name,
            secret: secret,
            serviceTypeID: serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            otpAuth: otpAuth,
            creationDate: Date(),
            modificationDate: Date(),
            tokenPeriod: Period.period30.rawValue,
            tokenLength: Digits.digits6.rawValue,
            badgeColor: nil,
            iconType: IconType.label.rawValue,
            iconTypeID: iconTypeID,
            labelColor: TintColor.default.rawValue,
            labelTitle: labelTitle,
            sectionID: sectionID,
            sectionOrder: 3,
            algorithm: Algorithm.SHA1.rawValue,
            counter: nil,
            tokenType: TokenType.totp.rawValue,
            source: ServiceSource.manual.rawValue
        )
        stack.save()
    }
}

/// Counts seals; can refuse writing like a cipher whose key is unavailable
private final class CountingCipher: LocalStorageCipher {
    private let core = makeTestCipher()
    var failsWriting = false
    private var sealedAssociatedData: [Data] = []

    var sealCount: Int { sealedAssociatedData.count }

    func sealCount(associatedDataPrefix prefix: String) -> Int {
        sealedAssociatedData.filter { $0.starts(with: Data(prefix.utf8)) }.count
    }

    var state: LocalStorageCipherState { failsWriting ? .keyUnavailable : .available }

    func seal(_ plaintext: Data, associatedData: Data) throws -> Data {
        guard !failsWriting else { throw LocalStorageCipherError.keyUnavailable }
        sealedAssociatedData.append(associatedData)
        return try core.seal(plaintext, associatedData: associatedData)
    }

    func open(_ sealed: Data, associatedData: Data) throws -> Data {
        try core.open(sealed, associatedData: associatedData)
    }

    func lookupHash(for value: String, context: String) throws -> Data {
        try core.lookupHash(for: value, context: context)
    }

    func prepareForWriting() throws {
        guard !failsWriting else { throw LocalStorageCipherError.keyUnavailable }
    }
}
