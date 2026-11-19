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
import CryptoKit
import CloudKit
@testable import Common
@testable import Protection
@testable import Sync

final class SyncCryptoTests: XCTestCase {
    private struct Content: Codable, Equatable {
        var secret: String
        var name: String
    }

    private let syncKey = SymmetricKey(size: .bits256)
    private let content = Content(secret: "SECRETMARKER", name: "NameMarker")

    // MARK: - Key derivation parameters

    func testCurrentParametersMeetTheMinimum() {
        XCTAssertTrue(SyncKDFParameters.current.meetsMinimum)
        XCTAssertTrue(SyncKDFParameters.legacy.isSupported)
        XCTAssertEqual(SyncKDFParameters.minimum.iterations, 3)
        XCTAssertEqual(SyncKDFParameters.minimum.memoryKiB, 64 * 1024)
        XCTAssertEqual(SyncKDFParameters.minimum.parallelism, 4)
    }

    func testWeakerParametersDoNotMeetTheMinimum() {
        var fewerIterations = SyncKDFParameters.minimum
        fewerIterations.iterations = 2
        var lessMemory = SyncKDFParameters.minimum
        lessMemory.memoryKiB = 32 * 1024
        var fewerThreads = SyncKDFParameters.minimum
        fewerThreads.parallelism = 1

        for parameters in [fewerIterations, lessMemory, fewerThreads] {
            XCTAssertTrue(parameters.isSupported, "\(parameters)")
            XCTAssertFalse(parameters.meetsMinimum, "\(parameters)")
        }
    }

    func testStrongerParametersMeetTheMinimum() {
        var stronger = SyncKDFParameters.minimum
        stronger.iterations = 4
        stronger.memoryKiB = 128 * 1024

        XCTAssertTrue(stronger.meetsMinimum)
    }

    /// What comes from the cloud must not make the device allocate gigabytes or run for minutes
    func testParametersOutOfBoundsAreNotSupported() {
        var unknownAlgorithm = SyncKDFParameters.minimum
        unknownAlgorithm.algorithm = "scrypt"
        var hugeMemory = SyncKDFParameters.minimum
        hugeMemory.memoryKiB = 8 * 1024 * 1024
        var hugeIterations = SyncKDFParameters.minimum
        hugeIterations.iterations = 100_000
        var zeroIterations = SyncKDFParameters.minimum
        zeroIterations.iterations = 0
        var otherKeyLength = SyncKDFParameters.minimum
        otherKeyLength.keyLength = 16

        for parameters in [unknownAlgorithm, hugeMemory, hugeIterations, zeroIterations, otherKeyLength] {
            XCTAssertFalse(parameters.isSupported, "\(parameters)")
            XCTAssertFalse(parameters.meetsMinimum, "\(parameters)")
        }
    }

    func testParametersRoundTrip() throws {
        let encoded = try XCTUnwrap(SyncKDFParameters.current.encoded())

        XCTAssertEqual(SyncKDFParameters(encoded: encoded), .current)
        XCTAssertNil(SyncKDFParameters(encoded: Data("not json".utf8)))
    }

    /// A frozen sample of what is stored in the Info record – it has to stay readable
    func testFrozenParametersSampleDecodes() {
        let sample = #"""
        {"algorithm":"argon2id","iterations":3,"keyLength":32,"memoryKiB":65536,"parallelism":4,"version":19}
        """#

        XCTAssertEqual(SyncKDFParameters(encoded: Data(sample.utf8)), .minimum)
    }

    // MARK: - Identifiers

    func testIdentifierIsStableForTheKey() {
        let key = SyncIdentifierKey.generate()
        let sameKey = SyncIdentifierKey(data: key.data)

        XCTAssertEqual(
            key.recordName(of: "SECRET", kind: .service),
            sameKey?.recordName(of: "SECRET", kind: .service)
        )
        XCTAssertEqual(key.identifier(of: "SECRET", kind: .service).count, 32)
        XCTAssertEqual(key.recordName(of: "SECRET", kind: .service).count, 64)
    }

    func testIdentifiersOfKindsAndKeysDiffer() {
        let key = SyncIdentifierKey.generate()
        let names = SyncRecordKind.allCases.map { key.recordName(of: "SECRET", kind: $0) }

        XCTAssertEqual(Set(names).count, SyncRecordKind.allCases.count)
        XCTAssertNotEqual(
            key.recordName(of: "SECRET", kind: .service),
            SyncIdentifierKey.generate().recordName(of: "SECRET", kind: .service)
        )
        XCTAssertNotEqual(
            key.recordName(of: "SECRET", kind: .service),
            key.recordName(of: "SECRET2", kind: .service)
        )
    }

    func testRecordNameDoesNotContainTheValue() {
        let name = SyncIdentifierKey.generate().recordName(of: "SECRETMARKER", kind: .service)

        XCTAssertFalse(name.uppercased().contains("SECRETMARKER"))
        XCTAssertTrue(name.allSatisfy { $0.isHexDigit })
    }

    func testIdentifierKeyHasToBe32Bytes() {
        XCTAssertNil(SyncIdentifierKey(data: Data(repeating: 1, count: 31)))
        XCTAssertNotNil(SyncIdentifierKey(data: Data(repeating: 1, count: 32)))
    }

    /// The identifiers survive a change of the password: only the wrapping of the key is replaced
    func testIdentifierKeyWrappedWithAnotherSyncKeyGivesTheSameIdentifiers() throws {
        let key = SyncIdentifierKey.generate()
        let newSyncKey = SymmetricKey(size: .bits256)

        let wrapped = try key.wrapped(with: syncKey)
        let unwrapped = try SyncIdentifierKey.unwrap(wrapped, with: syncKey)
        let rewrapped = try unwrapped.wrapped(with: newSyncKey)

        XCTAssertEqual(try SyncIdentifierKey.unwrap(rewrapped, with: newSyncKey), key)
        XCTAssertNil(wrapped.range(of: key.data))
    }

    func testIdentifierKeyCanNotBeUnwrappedWithAnotherKey() throws {
        let wrapped = try SyncIdentifierKey.generate().wrapped(with: syncKey)

        XCTAssertThrowsError(try SyncIdentifierKey.unwrap(wrapped, with: SymmetricKey(size: .bits256)))
        XCTAssertThrowsError(try SyncIdentifierKey.unwrap(Data(wrapped.dropLast()), with: syncKey))
    }

    // MARK: - Record content

    func testRecordContentRoundTrip() throws {
        let codec = SyncRecordCodec<Content>(recordType: "ServiceRecord4", syncKey: syncKey)

        let sealed = try codec.seal(content, recordName: "record-a")

        XCTAssertEqual(try codec.open(sealed, recordName: "record-a"), content)
        XCTAssertNil(sealed.range(of: Data("SECRETMARKER".utf8)))
        XCTAssertNil(sealed.range(of: Data("NameMarker".utf8)))
    }

    /// The blob is bound to its record: it can't be moved to another record, record type or key
    func testRecordContentCanNotBeOpenedElsewhere() throws {
        let codec = SyncRecordCodec<Content>(recordType: "ServiceRecord4", syncKey: syncKey)
        let sealed = try codec.seal(content, recordName: "record-a")

        XCTAssertThrowsError(try codec.open(sealed, recordName: "record-b"))
        XCTAssertThrowsError(
            try SyncRecordCodec<Content>(recordType: "SectionRecord2", syncKey: syncKey)
                .open(sealed, recordName: "record-a")
        )
        XCTAssertThrowsError(
            try SyncRecordCodec<Content>(recordType: "ServiceRecord4", syncKey: SymmetricKey(size: .bits256))
                .open(sealed, recordName: "record-a")
        )
    }

    /// The sync key used for the records gives nothing that opens local storage content, and the other way round
    func testSyncAndLocalStorageDomainsAreSeparate() throws {
        let associatedData = Data("ad".utf8)
        let local = LocalStorageCipherCore(dataKey: syncKey)
        let sync = LocalStorageCipherCore(dataKey: syncKey, domain: "2fas.sync.record")

        let sealed = try local.seal(Data("payload".utf8), associatedData: associatedData)

        XCTAssertThrowsError(try sync.open(sealed, associatedData: associatedData))
        XCTAssertNotEqual(
            try local.lookupHash(for: "SECRET", context: "c"),
            try sync.lookupHash(for: "SECRET", context: "c")
        )
    }

    // MARK: - Watch ticket

    func testWatchTicketRoundTrip() throws {
        let userKey = Data(repeating: 7, count: 32)

        let ticket = try SyncWatchTicket.seal(userKey: userKey, systemKey: syncKey, deviceCode: "device-a")

        XCTAssertEqual(try SyncWatchTicket.open(ticket, systemKey: syncKey, deviceCode: "device-a"), userKey)
        XCTAssertNil(ticket.range(of: userKey))
    }

    func testWatchTicketIsBoundToTheDeviceAndTheSystemKey() throws {
        let ticket = try SyncWatchTicket.seal(
            userKey: Data(repeating: 7, count: 32),
            systemKey: syncKey,
            deviceCode: "device-a"
        )

        XCTAssertThrowsError(try SyncWatchTicket.open(ticket, systemKey: syncKey, deviceCode: "device-b"))
        XCTAssertThrowsError(
            try SyncWatchTicket.open(ticket, systemKey: SymmetricKey(size: .bits256), deviceCode: "device-a")
        )
    }

    // MARK: - Info record

    private let zoneID = CKRecordZone.ID(zoneName: "TestZone", ownerName: CKCurrentUserDefaultName)

    private func makeInfoRecord(encryptionInfo: SyncCloudEncryptionInfo) throws -> InfoRecord {
        let record = try XCTUnwrap(InfoRecord.create(
            zoneID: zoneID,
            version: Info.version,
            encryption: Info.Encryption.user.rawValue,
            allowedDevices: ["none"],
            enableWatch: false,
            encryptionReference: Data([1, 2, 3]),
            encryptionInfo: encryptionInfo,
            modificationDate: Date()
        ))
        return InfoRecord(record: record)
    }

    func testInfoRecordCarriesEncryptionInfo() throws {
        let identifierKey = SyncIdentifierKey.generate()
        let encryptionInfo = SyncCloudEncryptionInfo(
            kdfSalt: Data(repeating: 9, count: 16),
            kdfParameters: SyncKDFParameters.current.encoded(),
            wrappedIdentifierKey: try identifierKey.wrapped(with: syncKey)
        )

        let info = try makeInfoRecord(encryptionInfo: encryptionInfo)

        XCTAssertEqual(info.encryptionInfo, encryptionInfo)
        let parameters = try XCTUnwrap(info.encryptionInfo.kdfParameters)
        XCTAssertEqual(SyncKDFParameters(encoded: parameters), .current)
        let wrapped = try XCTUnwrap(info.encryptionInfo.wrappedIdentifierKey)
        XCTAssertEqual(try SyncIdentifierKey.unwrap(wrapped, with: syncKey), identifierKey)
    }

    /// A record written before the Info version 4 has none of it
    func testInfoRecordWithoutEncryptionInfo() throws {
        let info = try makeInfoRecord(encryptionInfo: .empty)

        XCTAssertEqual(info.encryptionInfo, .empty)
        XCTAssertEqual(info.encryption, Info.Encryption.user.rawValue)
    }

    // MARK: - Sealed records

    private func makeServiceData(secret: String = "SERVICESECRETMARKER") -> ServiceData {
        ServiceData(
            name: "NameMarker",
            secret: secret,
            serviceTypeID: UUID(),
            additionalInfo: "InfoMarker",
            rawIssuer: "IssuerMarker",
            modifiedAt: Date(timeIntervalSinceReferenceDate: 700_000_100),
            createdAt: Date(timeIntervalSinceReferenceDate: 700_000_000),
            tokenPeriod: .period60,
            tokenLength: .digits8,
            badgeColor: .red,
            iconType: .label,
            iconTypeID: UUID(),
            labelColor: .orange,
            labelTitle: "LT",
            algorithm: .SHA256,
            isTrashed: false,
            trashingDate: nil,
            counter: nil,
            tokenType: .totp,
            source: .manual,
            otpAuth: "otpauth://totp/OtpAuthMarker",
            order: 3,
            sectionID: UUID()
        )
    }

    func testServiceRecordContentRoundTrip() {
        let service = makeServiceData()

        let content = ServiceRecordContent(serviceData: service, sectionOrder: 3)

        XCTAssertEqual(content.serviceData(createdAt: service.createdAt, modifiedAt: service.modifiedAt), service)
    }

    func testSealedServiceRecordRoundTrip() throws {
        let identifierKey = SyncIdentifierKey.generate()
        let service = makeServiceData()
        let content = ServiceRecordContent(serviceData: service, sectionOrder: 3)
        let recordName = identifierKey.recordName(of: service.secret, kind: .service)

        let record = try SealedRecord.create(
            type: .service4,
            recordName: recordName,
            zoneID: zoneID,
            content: content,
            syncKey: syncKey
        )

        XCTAssertEqual(record.recordType, "ServiceRecord4")
        XCTAssertEqual(record.recordID.recordName, recordName)
        // Nothing is said outside the sealed field
        XCTAssertEqual(record.allKeys(), [SealedRecord.contentKey])
        XCTAssertEqual(try SealedRecord.content(of: record, as: ServiceRecordContent.self, syncKey: syncKey), content)
        let sealed = try XCTUnwrap(record.encryptedValues[SealedRecord.contentKey] as? Data)
        for marker in ["SERVICESECRETMARKER", "NameMarker", "InfoMarker", "IssuerMarker", "OtpAuthMarker", "SHA256"] {
            XCTAssertNil(sealed.range(of: Data(marker.utf8)), marker)
        }
    }

    /// A record known to the server keeps its identity when its content is replaced
    func testSealedRecordIsRecreatedFromItsMetadata() throws {
        let original = try SealedRecord.create(
            type: .section2,
            recordName: "section-record",
            zoneID: zoneID,
            content: SectionRecordContent(sectionID: "id", title: "Old", order: 0),
            syncKey: syncKey
        )
        let renamed = SectionRecordContent(sectionID: "id", title: "New", order: 1)

        let record = try SealedRecord.recreate(
            with: original.encodeSystemFields(),
            type: .section2,
            content: renamed,
            syncKey: syncKey
        )

        XCTAssertEqual(record.recordID, original.recordID)
        XCTAssertEqual(try SealedRecord.content(of: record, as: SectionRecordContent.self, syncKey: syncKey), renamed)
        XCTAssertThrowsError(
            try SealedRecord.recreate(
                with: original.encodeSystemFields(),
                type: .service4,
                content: renamed,
                syncKey: syncKey
            )
        )
    }

    /// The sealed field of one record doesn't open in another one
    func testSealedContentCanNotBeMovedToAnotherRecord() throws {
        let content = DeletedServiceRecordContent(deletedAt: Date(timeIntervalSinceReferenceDate: 720_000_000))
        let record = try SealedRecord.create(
            type: .deletedService,
            recordName: "deletion-a",
            zoneID: zoneID,
            content: content,
            syncKey: syncKey
        )
        let other = CKRecord(
            recordType: RecordType.deletedService.rawValue,
            recordID: CKRecord.ID(recordName: "deletion-b", zoneID: zoneID)
        )
        other.encryptedValues[SealedRecord.contentKey] = record.encryptedValues[SealedRecord.contentKey]

        XCTAssertEqual(
            try SealedRecord.content(of: record, as: DeletedServiceRecordContent.self, syncKey: syncKey),
            content
        )
        XCTAssertThrowsError(
            try SealedRecord.content(of: other, as: DeletedServiceRecordContent.self, syncKey: syncKey)
        )
        XCTAssertThrowsError(
            try SealedRecord.content(
                of: record,
                as: DeletedServiceRecordContent.self,
                syncKey: SymmetricKey(size: .bits256)
            )
        )
    }

    func testRecordWithoutContentIsRejected() {
        let record = CKRecord(
            recordType: RecordType.section2.rawValue,
            recordID: CKRecord.ID(recordName: "empty", zoneID: zoneID)
        )

        XCTAssertThrowsError(
            try SealedRecord.content(of: record, as: SectionRecordContent.self, syncKey: syncKey)
        ) { XCTAssertEqual($0 as? SealedRecord.Failure, .missingContent) }
    }

    func testDeletionIdentifierAndRecordNameRoundTrip() {
        let identifier = SyncIdentifierKey.generate().identifier(of: "SECRET", kind: .deletedService)
        let deletion = SyncDeletion(identifier: identifier, deletedAt: Date())

        XCTAssertEqual(SyncDeletion.identifier(recordName: deletion.recordName), identifier)
        XCTAssertNil(SyncDeletion.identifier(recordName: "not-an-identifier"))
        XCTAssertNil(SyncDeletion.identifier(recordName: String(repeating: "zz", count: 32)))
    }

    func testDeletionExpiresAfterTheRetention() {
        let now = Date()
        let identifier = Data(repeating: 1, count: 32)

        XCTAssertTrue(
            SyncDeletion(identifier: identifier, deletedAt: now.addingTimeInterval(-SyncDeletion.retention - 60))
                .isExpired(now: now)
        )
        XCTAssertFalse(
            SyncDeletion(identifier: identifier, deletedAt: now.addingTimeInterval(-SyncDeletion.retention + 60))
                .isExpired(now: now)
        )
    }

    func testSealedRecordTypes() {
        for type in [RecordType.service4, .section2, .deletedService, .deletedSection] {
            XCTAssertTrue(type.isSealed, type.rawValue)
        }
        for type in [RecordType.service1, .service2, .service3, .section, .info] {
            XCTAssertFalse(type.isSealed, type.rawValue)
        }
    }

    // MARK: - Vault migration

    func testVaultFoundInTheCloud() {
        // The current vault, whatever its Info record says
        XCTAssertEqual(CloudProbe.vaultVersion(zoneName: Config.vaultV3, infoVersion: Info.version), .v4)
        XCTAssertEqual(CloudProbe.vaultVersion(zoneName: Config.vaultV2, infoVersion: 3), .v3)
        XCTAssertEqual(CloudProbe.vaultVersion(zoneName: Config.vaultV1, infoVersion: 2), .v2)
        XCTAssertEqual(CloudProbe.vaultVersion(zoneName: Config.vaultV1, infoVersion: 1), .v1)
        // A retired vault isn't one to migrate from
        XCTAssertNil(CloudProbe.vaultVersion(zoneName: Config.vaultV2, infoVersion: Info.retiredVersion))
        XCTAssertNil(CloudProbe.vaultVersion(zoneName: Config.vaultV1, infoVersion: Info.retiredVersion))
    }

    func testMigrationDecision() {
        XCTAssertEqual(VaultMigrationDecision.decide(found: []), .startClean)
        XCTAssertEqual(VaultMigrationDecision.decide(found: [.v4]), .useCurrentVault)
        // Another device migrated already – the older vaults don't matter
        XCTAssertEqual(VaultMigrationDecision.decide(found: [.v1, .v3, .v4]), .useCurrentVault)
        XCTAssertEqual(VaultMigrationDecision.decide(found: [.v3]), .migrate(from: Config.vaultV2))
        // The newest of the older vaults has the data
        XCTAssertEqual(VaultMigrationDecision.decide(found: [.v1, .v3]), .migrate(from: Config.vaultV2))
        XCTAssertEqual(VaultMigrationDecision.decide(found: [.v2]), .migrate(from: Config.vaultV1))
        XCTAssertEqual(VaultMigrationDecision.decide(found: [.v1]), .migrate(from: Config.vaultV1))
    }

    /// The Info record left in a retired vault has to make every older app version stop and ask for an update –
    /// and has to have everything those versions read from it
    func testRetiredInfoRecordStopsOlderAppVersions() {
        let oldZone = CKRecordZone.ID(zoneName: Config.vaultV2, ownerName: CKCurrentUserDefaultName)

        let record = VaultRetirement.retiredInfoRecord(zoneID: oldZone)
        let info = InfoRecord(record: record)

        XCTAssertEqual(record.recordID.recordName, Info.id)
        XCTAssertEqual(record.recordID.zoneID, oldZone)
        XCTAssertGreaterThan(info.version, Info.version)
        XCTAssertGreaterThan(info.version, 3)
        XCTAssertEqual(info.encryption, Info.Encryption.system.rawValue)
        XCTAssertEqual(info.allowedDevices, ["none"])
        XCTAssertFalse(info.enableWatch)
        XCTAssertNotNil(info.encryptionReference)
    }

    func testOnlyTheOlderVaultsAreRetired() {
        XCTAssertTrue(VaultRetirement.isOldVault(Config.vaultV1))
        XCTAssertTrue(VaultRetirement.isOldVault(Config.vaultV2))
        XCTAssertFalse(VaultRetirement.isOldVault(Config.vaultV3))
        XCTAssertFalse(VaultRetirement.isOldVault("SomethingElse"))
    }
}

// MARK: - Recovering the user's key with the password

final class SyncUserKeyRecoveryTests: XCTestCase {
    private let reference = Data("reference".utf8)
    private var suites: [String] = []
    private var devices: [SyncEncryptionHandler] = []

    override func tearDown() {
        suites.forEach { UserDefaults.standard.removePersistentDomain(forName: $0) }
        devices.forEach { $0.removeSystemEncryptionElements() }
        suites = []
        devices = []
        super.tearDown()
    }

    /// A device of its own: a keychain and defaults nothing else uses
    private func makeDevice() -> SyncEncryptionHandler {
        let name = "SyncUserKeyRecoveryTests.\(UUID().uuidString)"
        suites.append(name)
        let handler = SyncEncryptionHandler(
            reference: reference,
            localEncryptionKeyData: Data(count: 32),
            keychainService: name,
            userDefaults: UserDefaults(suiteName: name)! // swiftlint:disable:this force_unwrapping
        )
        handler.initialize()
        devices.append(handler)
        return handler
    }

    /// A device that protects the cloud with `password`, and what it leaves in the Info record
    private func makeProtectedCloud(password: String) throws -> (info: SyncCloudEncryptionInfo, reference: Data) {
        let device = makeDevice()
        guard case .success = device.create() else {
            throw XCTSkip("The keychain isn't available in this run")
        }
        guard device.hasSystemEncryptionElements else {
            throw XCTSkip("The keychain isn't available in this run")
        }
        device.setUserPassword(password)
        let info = device.cloudEncryptionInfo(cached: .empty)
        return (info, try XCTUnwrap(device.encryptionReference))
    }

    func testPasswordBringsBackTheKeyOnADeviceWithoutAnyKeys() throws {
        let cloud = try makeProtectedCloud(password: "correct horse")
        XCTAssertNotNil(cloud.info.kdfSalt)
        XCTAssertNotNil(cloud.info.kdfParameters)

        let device = makeDevice()
        XCTAssertFalse(device.hasSystemEncryptionElements)
        device.cloudEncryptionInfoFetched(cloud.info)

        XCTAssertTrue(device.recoverUserKey(password: "correct horse", cloudReference: cloud.reference))
        XCTAssertEqual(device.encryptionType, .user)
        XCTAssertTrue(device.hasCompleteEncryptionElements)
        // The same key: what one device seals, the other opens
        XCTAssertEqual(device.decrypt(cloud.reference), reference)
        XCTAssertTrue(device.verifyUserPassword("correct horse"))
    }

    func testWrongPasswordChangesNothing() throws {
        let cloud = try makeProtectedCloud(password: "correct horse")
        let device = makeDevice()
        device.cloudEncryptionInfoFetched(cloud.info)

        XCTAssertFalse(device.recoverUserKey(password: "wrong horse", cloudReference: cloud.reference))
        XCTAssertFalse(device.recoverUserKey(password: "correct horse", cloudReference: nil))
        XCTAssertEqual(device.encryptionType, .system)
        XCTAssertFalse(device.hasSystemEncryptionElements)
        XCTAssertNil(device.decrypt(cloud.reference))
    }

    /// The device has a salt of its own that isn't the one the cloud was protected with
    func testSaltOfTheCloudWinsOverTheLocalOne() throws {
        let cloud = try makeProtectedCloud(password: "correct horse")
        let device = makeDevice()
        guard case .success = device.create() else { throw XCTSkip("The keychain isn't available in this run") }
        XCTAssertNotEqual(device.cloudEncryptionInfo(cached: .empty).kdfSalt, cloud.info.kdfSalt)
        device.cloudEncryptionInfoFetched(cloud.info)

        XCTAssertTrue(device.recoverUserKey(password: "correct horse", cloudReference: cloud.reference))
        XCTAssertEqual(device.cloudEncryptionInfo(cached: .empty).kdfSalt, cloud.info.kdfSalt)
        XCTAssertEqual(device.decrypt(cloud.reference), reference)
    }

    func testCreateKeepsTheExistingSaltAndSystemKey() throws {
        let device = makeDevice()
        guard case .success = device.create() else { throw XCTSkip("The keychain isn't available in this run") }
        let exported = try XCTUnwrap(device.exportKeys())

        guard case .success = device.create() else { return XCTFail("create failed") }
        let exportedAgain = try XCTUnwrap(device.exportKeys())
        XCTAssertEqual(exported.salt, exportedAgain.salt)
        XCTAssertEqual(exported.systemKey, exportedAgain.systemKey)
    }
}

// MARK: - Measurements

/// Numbers, not assertions on time: what the sealed records and the key derivation cost. The results are printed
/// with the `SYNC-BENCHMARK` prefix.
final class SyncFormatBenchmarkTests: XCTestCase {
    private static let serviceCount = 1000
    private var suiteName = ""
    private var encryptionHandler: SyncEncryptionHandler!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "SyncFormatBenchmarkTests.\(UUID().uuidString)"
        encryptionHandler = SyncEncryptionHandler(
            reference: Data("reference".utf8),
            localEncryptionKeyData: Data(count: 32),
            keychainService: suiteName,
            userDefaults: UserDefaults(suiteName: suiteName)! // swiftlint:disable:this force_unwrapping
        )
        encryptionHandler.initialize()
        guard case .success = encryptionHandler.create(), encryptionHandler.hasSystemEncryptionElements else {
            throw XCTSkip("The keychain isn't available in this run")
        }
    }

    override func tearDown() {
        encryptionHandler?.removeSystemEncryptionElements()
        encryptionHandler = nil
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func makeServices() -> [ServiceData] {
        (0..<Self.serviceCount).map { index in
            ServiceData(
                name: "Service number \(index)",
                secret: "JBSWY3DPEHPK3PXP\(String(format: "%08d", index))",
                serviceTypeID: UUID(),
                additionalInfo: "user\(index)@example.com",
                rawIssuer: "Issuer \(index)",
                modifiedAt: Date(timeIntervalSinceReferenceDate: 700_000_100),
                createdAt: Date(timeIntervalSinceReferenceDate: 700_000_000),
                tokenPeriod: .period30,
                tokenLength: .digits6,
                badgeColor: .red,
                iconType: .label,
                iconTypeID: UUID(),
                labelColor: .orange,
                labelTitle: "LT",
                algorithm: .SHA1,
                isTrashed: false,
                trashingDate: nil,
                counter: nil,
                tokenType: .totp,
                source: .link,
                otpAuth: "otpauth://totp/Issuer%20\(index):user\(index)@example.com?secret=JBSWY3DPEHPK3PXP&issuer=I",
                order: index,
                sectionID: nil
            )
        }
    }

    private func time(_ block: () throws -> Void) rethrows -> Double {
        let start = CFAbsoluteTimeGetCurrent()
        try block()
        return (CFAbsoluteTimeGetCurrent() - start) * 1000
    }

    private func archivedSize(_ records: [CKRecord]) throws -> Int {
        try records.reduce(0) {
            $0 + (try NSKeyedArchiver.archivedData(withRootObject: $1, requiringSecureCoding: true)).count
        }
    }

    func testRecordsFieldByFieldAgainstSealed() throws {
        let services = makeServices()
        let zoneID = CKRecordZone.ID(zoneName: "Benchmark", ownerName: CKCurrentUserDefaultName)
        let syncKey = try XCTUnwrap(encryptionHandler.recordKey)
        let identifierKey = SyncIdentifierKey.generate()
        let fieldHandler = ServiceRecordEncryptionHandler(
            zoneManager: ZoneManager(),
            encryptionHandler: encryptionHandler
        )

        // Every value in a field of its own, sealed one by one (ServiceRecord3)
        var fieldRecords: [CKRecord] = []
        let fieldEncode = time {
            fieldRecords = services.compactMap {
                fieldHandler.createServiceRecord3(from: $0, metadata: nil, list: services)
            }
        }
        XCTAssertEqual(fieldRecords.count, services.count)
        var fieldDecoded = 0
        let fieldDecode = time {
            fieldDecoded = fieldRecords
                .compactMap { fieldHandler.createServiceData(from: ServiceRecord3(record: $0)) }
                .count
        }
        XCTAssertEqual(fieldDecoded, services.count)

        // Everything in one sealed field (ServiceRecord4)
        var sealedRecords: [CKRecord] = []
        let sealedEncode = try time {
            sealedRecords = try services.map {
                try SealedRecord.create(
                    type: .service4,
                    recordName: identifierKey.recordName(of: $0.secret, kind: .service),
                    zoneID: zoneID,
                    content: ServiceRecordContent(serviceData: $0, sectionOrder: $0.order ?? 0),
                    syncKey: syncKey
                )
            }
        }
        var sealedDecoded = 0
        let sealedDecode = try time {
            sealedDecoded = try sealedRecords
                .map { try SealedRecord.content(of: $0, as: ServiceRecordContent.self, syncKey: syncKey) }
                .count
        }
        XCTAssertEqual(sealedDecoded, services.count)

        let count = Self.serviceCount
        print(String(
            format: "SYNC-BENCHMARK records=%d | fields: encode %.0f ms, decode %.0f ms, %d B/record"
                + " | sealed: encode %.0f ms, decode %.0f ms, %d B/record",
            count,
            fieldEncode, fieldDecode, try archivedSize(fieldRecords) / count,
            sealedEncode, sealedDecode, try archivedSize(sealedRecords) / count
        ))
    }

    func testKeyDerivationTime() throws {
        var times: [Double] = []
        for _ in 0..<3 {
            times.append(time {
                // One derivation with the current parameters (and saving the key)
                encryptionHandler.setUserPassword("correct horse battery")
            })
        }
        let parameters = SyncKDFParameters.current
        print(String(
            format: "SYNC-BENCHMARK argon2id t=%d m=%d KiB p=%d | %.0f / %.0f / %.0f ms",
            parameters.iterations, parameters.memoryKiB, parameters.parallelism, times[0], times[1], times[2]
        ))
    }
}

