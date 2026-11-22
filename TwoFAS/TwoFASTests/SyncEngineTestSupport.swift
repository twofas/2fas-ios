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
import CloudKit
import CoreData
import CryptoKit
@testable import Common
@testable import Protection
@testable import Storage
@testable import Sync

// MARK: - The cloud

/// A private CloudKit database in memory, as much of it as the sync uses: zones of records, a log of changes to
/// fetch from, and operations that are applied whole or not at all.
///
/// Like CloudKit with `.ifServerRecordUnchanged`, a save is refused when the record changed on the server since
/// the device saw it – including a record created under a name that is taken, and a record that isn't there any
/// more. Deleting a record that isn't there is refused too: the stricter of what CloudKit could do, so that the
/// sync is shown not to depend on it.
final class FakeCloud {
    struct StoredRecord {
        let record: CKRecord
        let version: Int
    }

    struct Change {
        let sequence: Int
        let zoneName: String
        let recordID: CKRecord.ID
        let recordType: String
    }

    /// CloudKit takes at most this many records in one operation
    static let operationLimit = 400

    private(set) var zones: [String: [CKRecord.ID: StoredRecord]] = [:]
    private(set) var changes: [Change] = []
    private(set) var sequence = 0

    /// Every operation that was sent, applied or not
    private(set) var operations: [(saves: Int, deletions: Int)] = []
    /// The operations that were applied
    private(set) var appliedOperations = 0
    private(set) var refusedOperations = 0
    /// Why the operations were refused, in order
    private(set) var refusals: [String] = []

    var oversizedOperations: Int {
        operations.filter { $0.saves + $0.deletions > Self.operationLimit }.count
    }

    func records(in zoneName: String, ofType type: RecordType? = nil) -> [CKRecord] {
        (zones[zoneName] ?? [:]).values
            .map(\.record)
            .filter { type == nil || $0.recordType == type?.rawValue }
    }

    /// Another device wrote the records of `type` again without changing them (a change of their order, of the
    /// password, …): every device has to fetch them before it can save them
    func resaveRecords(in zoneName: String, ofType type: RecordType) {
        for (recordID, stored) in zones[zoneName] ?? [:] where stored.record.recordType == type.rawValue {
            sequence += 1
            zones[zoneName]?[recordID] = StoredRecord(record: stored.record, version: sequence)
            changes.append(Change(
                sequence: sequence,
                zoneName: zoneName,
                recordID: recordID,
                recordType: stored.record.recordType
            ))
        }
    }

    /// - Parameter knownVersions: The version of every record as the device saw it last.
    /// - Returns: The versions the saved records got, `nil` when the operation was refused (nothing changed).
    func modify(
        saving records: [CKRecord],
        deleting recordIDs: [CKRecord.ID],
        knownVersions: [CKRecord.ID: Int]
    ) -> [CKRecord.ID: Int]? {
        operations.append((records.count, recordIDs.count))
        for record in records {
            let stored = zones[record.recordID.zoneID.zoneName]?[record.recordID]
            guard stored?.version == knownVersions[record.recordID] else {
                refusedOperations += 1
                refusals.append(
                    "save \(record.recordType): server version \(String(describing: stored?.version)), "
                    + "device knows \(String(describing: knownVersions[record.recordID]))"
                )
                return nil
            }
        }
        for recordID in recordIDs where zones[recordID.zoneID.zoneName]?[recordID] == nil {
            refusedOperations += 1
            let known = String(describing: knownVersions[recordID])
            refusals.append("delete a record that isn't there (device knows \(known))")
            return nil
        }
        var versions: [CKRecord.ID: Int] = [:]
        for record in records {
            sequence += 1
            let zoneName = record.recordID.zoneID.zoneName
            // swiftlint:disable:next force_cast
            let copy = record.copy() as! CKRecord
            zones[zoneName, default: [:]][record.recordID] = StoredRecord(record: copy, version: sequence)
            changes.append(Change(
                sequence: sequence,
                zoneName: zoneName,
                recordID: record.recordID,
                recordType: record.recordType
            ))
            versions[record.recordID] = sequence
        }
        for recordID in recordIDs {
            sequence += 1
            let zoneName = recordID.zoneID.zoneName
            let type = zones[zoneName]?[recordID]?.record.recordType ?? ""
            zones[zoneName]?[recordID] = nil
            changes.append(Change(sequence: sequence, zoneName: zoneName, recordID: recordID, recordType: type))
        }
        appliedOperations += 1
        return versions
    }

    /// What changed in `zoneName` after `token`: the records as they are now, and the ones that are gone
    func changes(
        in zoneName: String,
        after token: Int
    ) -> (changed: [StoredRecord], deleted: [(name: String, type: String)]) {
        var seen: Set<CKRecord.ID> = []
        var changed: [StoredRecord] = []
        var deleted: [(name: String, type: String)] = []
        for change in changes.reversed() where change.sequence > token && change.zoneName == zoneName {
            guard seen.insert(change.recordID).inserted else { continue }
            if let stored = zones[zoneName]?[change.recordID] {
                changed.append(stored)
            } else {
                deleted.append((change.recordID.recordName, change.recordType))
            }
        }
        return (changed.reversed(), deleted.reversed())
    }
}

/// The cloud as one device sees it
final class FakeCloudKit: CloudKitSyncing {
    var deletedEntries: CloudKit.DeletedEntries?
    var updatedEntries: CloudKit.UpdatedEntries?
    var deleteAllEntries: Callback?
    var quotaExceeded: Callback?
    var userDisablediCloud: Callback?
    var useriCloudProblem: Callback?
    var userLoggedOut: Callback?
    var resetStack: Callback?
    var abortSync: Callback?
    var fetchFinishedSuccessfuly: Callback?
    var changesSavedSuccessfuly: Callback?

    var container: CKContainer! { nil }

    private let cloud: FakeCloud
    private let zoneManager: ZoneManaging
    /// The change this device fetched up to
    private var token = 0
    private var knownVersions: [CKRecord.ID: Int] = [:]
    /// An operation that was refused makes the device forget what it cached and fetch everything again –
    /// as `CloudKit` does on `serverRecordChanged`. Counted, so that a device that never gets through is noticed.
    private(set) var refetchesAfterRefusal = 0
    /// Called when the device gave up after too many refusals in a row
    var gaveUp: Callback?
    /// Called once, right before the next operation of this device is applied – what another device does between
    /// this one's fetch and its save
    var beforeNextModification: Callback?
    /// How many more operations of this device get through. The one after them is lost and the sync ends there –
    /// the app was closed, or the connection was lost for good. `nil` – no limit.
    var modificationsToLetThrough: Int?
    var modificationLost: Callback?
    private var refusalsInARow = 0

    init(cloud: FakeCloud, zoneManager: ZoneManaging) {
        self.cloud = cloud
        self.zoneManager = zoneManager
    }

    func initialize() {}

    func cloudSync() {
        DispatchQueue.main.async { [self] in
            let fetched = cloud.changes(in: zoneManager.currentZoneID.zoneName, after: token)
            token = cloud.sequence
            for name in fetched.deleted.map(\.name) {
                knownVersions[CKRecord.ID(recordName: name, zoneID: zoneManager.currentZoneID)] = nil
            }
            for stored in fetched.changed {
                knownVersions[stored.record.recordID] = stored.version
            }
            if !fetched.deleted.isEmpty {
                deletedEntries?(fetched.deleted)
            }
            if !fetched.changed.isEmpty {
                // swiftlint:disable:next force_cast
                updatedEntries?(fetched.changed.map { $0.record.copy() as! CKRecord })
            }
            fetchFinishedSuccessfuly?()
        }
    }

    func modifyRecord(recordsToSave: [CKRecord]?, recordIDsToDelete: [CKRecord.ID]?) {
        DispatchQueue.main.async { [self] in
            let interference = beforeNextModification
            beforeNextModification = nil
            interference?()
            if let left = modificationsToLetThrough {
                guard left > 0 else {
                    modificationsToLetThrough = nil
                    abortSync?()
                    modificationLost?()
                    return
                }
                modificationsToLetThrough = left - 1
            }
            if let versions = cloud.modify(
                saving: recordsToSave ?? [],
                deleting: recordIDsToDelete ?? [],
                knownVersions: knownVersions
            ) {
                refusalsInARow = 0
                versions.forEach { knownVersions[$0.key] = $0.value }
                recordIDsToDelete?.forEach { knownVersions[$0] = nil }
                changesSavedSuccessfuly?()
            } else {
                refusalsInARow += 1
                refetchesAfterRefusal += 1
                guard refusalsInARow < 5 else {
                    abortSync?()
                    gaveUp?()
                    return
                }
                // Purge and retry
                token = 0
                knownVersions = [:]
                deleteAllEntries?()
                cloudSync()
            }
        }
    }

    func clear() {}

    func resetTokens() {
        token = 0
        knownVersions = [:]
    }
}

private final class FixedProbe: CloudProbing {
    func checkForVaults(completion: @escaping (Result<[VaultVersion], Error>) -> Void) {
        completion(.success([.v4]))
    }
}

// MARK: - A device

/// One installation of the app: its own local store, its own Sync cache and the real sync engine on top of them,
/// talking to a `FakeCloud`. The devices of one user share the keychain service (the iCloud Keychain).
final class SyncTestDevice {
    enum Outcome: Equatable {
        case finished
        case stopped(String)
    }

    let name: String
    let storage: Storage
    let cloudKit: FakeCloudKit
    let syncHandler: SyncHandler
    let logHandler: Sync.LogHandler
    let itemHandler: ItemHandler
    let encryptionHandler: SyncEncryptionHandler
    let reencryptionHandler: ReencryptionHandler
    let zoneManager = ZoneManager()

    private let directory: URL
    private let defaultsName: String
    private let syncStack: CoreDataStack
    private let log: LogDataChangeImpl
    private let requirementCheck: RequirementCheckHandler
    private var onOutcome: ((Outcome) -> Void)?
    private var reencryptionHandlerFactory: (() -> ReencryptionHandler)?

    var repo: StorageRepository { storage.storageRepository }

    init(name: String, cloud: FakeCloud, keychainService: String) {
        self.name = name
        directory = makeTemporaryDirectory()
        defaultsName = "SyncTestDevice.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsName)! // swiftlint:disable:this force_unwrapping
        let cipher = makeTestCipher()
        storage = Storage(
            storeDirectory: directory,
            initializeLogStorage: false,
            cipher: cipher,
            allowsMigration: true,
            logError: nil
        )
        syncStack = SyncInstance.makeCoreDataStack(cipher: cipher, storeDirectory: directory)
        zoneManager.setCurrentZoneID(Config.vaultV3)
        cloudKit = FakeCloudKit(cloud: cloud, zoneManager: zoneManager)
        encryptionHandler = SyncEncryptionHandler(
            reference: Data("reference".utf8),
            localEncryptionKeyData: Data(count: 32),
            keychainService: keychainService,
            userDefaults: defaults
        )
        let serviceRecordEncryptionHandler = ServiceRecordEncryptionHandler(
            zoneManager: zoneManager,
            encryptionHandler: encryptionHandler
        )
        logHandler = Sync.LogHandler(coreDataStack: syncStack)
        let sectionHandler = Sync.SectionHandler(coreDataStack: syncStack)
        let serviceHandler = Sync.ServiceHandler(
            coreDataStack: syncStack,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler
        )
        let infoHandler = InfoHandler(
            zoneManager: zoneManager,
            syncEncryptionHandler: encryptionHandler,
            userDefaults: defaults
        )
        let deletionLogger = DeletionLogger(
            logHandler: logHandler,
            zoneManager: zoneManager,
            syncEncryptionHandler: encryptionHandler
        )
        let commonItemHandler = CommonItemHandler(
            commonSectionHandler: storage.section,
            commonServiceHandler: storage.service,
            infoHandler: infoHandler,
            logHandler: logHandler,
            zoneManager: zoneManager,
            syncEncryptionHandler: encryptionHandler,
            deletionLogger: deletionLogger
        )
        itemHandler = ItemHandler(
            sectionHandler: sectionHandler,
            serviceHandler: serviceHandler,
            infoHandler: infoHandler,
            logHandler: logHandler,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler,
            syncEncryptionHandler: encryptionHandler,
            zoneManager: zoneManager,
            deletionHandler: DeletionCacheHandler(coreDataStack: syncStack)
        )
        let mergeHandler = MergeHandler(
            logHandler: logHandler,
            commonItemHandler: commonItemHandler,
            itemHandler: itemHandler,
            zoneManager: zoneManager
        )
        let modificationQueue = ModificationQueue()
        requirementCheck = RequirementCheckHandler(encryptionHandler: encryptionHandler, infoHandler: infoHandler)
        reencryptionHandler = ReencryptionHandler(
            serviceHandler: serviceHandler,
            serviceRecordEncryptionHandler: serviceRecordEncryptionHandler,
            syncEncryptionHandler: encryptionHandler,
            infoHandler: infoHandler
        )
        let stack = syncStack
        let fakeCloudKit = cloudKit
        let localReset = SyncLocalReset(
            store: stack,
            clearInfoCache: infoHandler.purge,
            clearCheckpoints: {},
            clearPendingTokens: fakeCloudKit.clear,
            clearQueue: modificationQueue.clear,
            logFirstImport: commonItemHandler.logFirstImport
        )
        syncHandler = SyncHandler(
            itemHandler: itemHandler,
            commonItemHandler: commonItemHandler,
            logHandler: logHandler,
            cloudKit: cloudKit,
            modificationQueue: modificationQueue,
            mergeHandler: mergeHandler,
            migrationHandler: MigrationHandler(zoneManager: zoneManager, cloudProbe: FixedProbe()),
            requirementCheck: requirementCheck,
            reencryptionHandler: reencryptionHandler,
            localReset: localReset,
            isSyncDeferred: false,
            syncContext: stack.context,
            infoHandler: infoHandler,
            zoneManager: zoneManager,
            syncEncryptionHandler: encryptionHandler
        )
        let reencryptionHandler = reencryptionHandler
        reencryptionHandlerFactory = { [encryptionHandler] in
            ReencryptionHandler(
                serviceHandler: serviceHandler,
                serviceRecordEncryptionHandler: serviceRecordEncryptionHandler,
                syncEncryptionHandler: encryptionHandler,
                infoHandler: infoHandler
            )
        }
        reencryptionHandler.sealedRecordsForReencryption = { [weak itemHandler, weak zoneManager] in
            guard zoneManager?.usesSealedRecords == true else { return nil }
            return itemHandler?.allSealedRecordsRecreated()
        }
        log = LogDataChangeImpl(logHandler: logHandler, deletionLogger: deletionLogger)
        encryptionHandler.initialize()
        encryptionHandler.cloudEncryptionInfoFetched(infoHandler.encryptionInfo)

        syncHandler.finishedSync = { [weak self] in self?.report(.finished) }
        syncHandler.otherError = { [weak self] in self?.report(.stopped("error \($0.code)")) }
        syncHandler.unreadableRecordsFound = { [weak self] in self?.report(.stopped("unreadable records")) }
        syncHandler.quotaExceeded = { [weak self] in self?.report(.stopped("quota")) }
        syncHandler.userDisabledCloud = { [weak self] in self?.report(.stopped("disabled")) }
        syncHandler.useriCloudProblem = { [weak self] in self?.report(.stopped("iCloud problem")) }
        requirementCheck.newerVersion = { [weak self] in self?.report(.stopped("newer version")) }
        requirementCheck.cloudEncrypted = { [weak self] _ in self?.report(.stopped("cloud encrypted")) }
        requirementCheck.encryptionError = { [weak self] in self?.report(.stopped("encryption error \($0)")) }
        cloudKit.gaveUp = { [weak self] in self?.report(.stopped("refused too many times")) }
    }

    func tearDown() {
        closeStores(of: syncStack)
        closeStores(of: storage.coreDataStack)
        encryptionHandler.removeSystemEncryptionElements()
        UserDefaults.standard.removePersistentDomain(forName: defaultsName)
        try? FileManager.default.removeItem(at: directory)
    }

    private func report(_ outcome: Outcome) {
        let handler = onOutcome
        onOutcome = nil
        handler?(outcome)
    }

    /// The backup was just turned on: everything this device has is new to the cloud
    func turnBackupOn() {
        syncHandler.firstStart()
    }

    func synchronize(completion: @escaping (Outcome) -> Void) {
        onOutcome = completion
        // What the iCloud Keychain delivered since the last time (the system key made by another device) –
        // the app reads it when it starts
        encryptionHandler.initialize()
        syncHandler.synchronize()
    }

    // MARK: What the user does (the storage is changed and the change is logged, as the app does it)

    @discardableResult
    func addService(_ secret: String, name: String? = nil, sectionID: SectionID? = nil) -> String {
        let added = repo.addService(
            name: name ?? "Service \(secret)",
            secret: secret,
            serviceTypeID: nil,
            additionalInfo: "info \(secret)",
            rawIssuer: nil,
            otpAuth: nil,
            tokenPeriod: .period30,
            tokenLength: .digits6,
            badgeColor: nil,
            iconType: .label,
            iconTypeID: .default,
            labelColor: .default,
            labelTitle: "SE",
            algorithm: .SHA1,
            counter: nil,
            tokenType: .totp,
            sectionID: sectionID,
            source: .manual
        )
        log.logNewServiceAdded(with: added)
        return added
    }

    /// A handler that knows nothing but what was saved – what the app has after it was started again
    func makeReencryptionHandler() -> ReencryptionHandler {
        // swiftlint:disable:next force_unwrapping
        reencryptionHandlerFactory!()
    }

    /// The user set another password for the backup: the key is replaced by the next sync, which seals every
    /// record again – as `SyncMigrationHandler` does it
    func changePassword(to password: String) {
        let salt = encryptionHandler.exportKeys()?.salt
        guard let key = SyncEncryptionHandler.deriveKey(for: password, parameters: .current, salt: salt) else {
            return XCTFail("\(name): no key for the password")
        }
        var isPending = true
        reencryptionHandler.isReencryptionPending = { [encryptionHandler] in
            guard isPending else { return false }
            isPending = false
            encryptionHandler.beginKeyChange()
            encryptionHandler.setUserKey(key)
            return true
        }
    }

    @discardableResult
    func addHOTPService(_ secret: String, name: String? = nil) -> String {
        let added = repo.addService(
            name: name ?? "Service \(secret)",
            secret: secret,
            serviceTypeID: nil,
            additionalInfo: "info \(secret)",
            rawIssuer: nil,
            otpAuth: nil,
            tokenPeriod: nil,
            tokenLength: .digits6,
            badgeColor: nil,
            iconType: .label,
            iconTypeID: .default,
            labelColor: .default,
            labelTitle: "SE",
            algorithm: .SHA1,
            counter: 1,
            tokenType: .hotp,
            sectionID: nil,
            source: .manual
        )
        log.logNewServiceAdded(with: added)
        return added
    }

    /// The HOTP token was used: its counter goes up
    func useHOTPService(_ secret: String) {
        guard let changed = repo.incrementCounter(for: secret) else {
            return XCTFail("\(self.name): no service \(secret)")
        }
        log.logServicesModified(with: [changed])
    }

    func counter(of secret: String) -> Int? {
        repo.findService(for: secret)?.counter
    }

    func renameService(_ secret: String, to name: String) {
        guard let service = repo.findService(for: secret) else { return XCTFail("\(self.name): no service \(secret)") }
        let changed = repo.updateService(
            service,
            name: name,
            additionalInfo: service.additionalInfo,
            badgeColor: service.badgeColor,
            iconType: service.iconType,
            iconTypeID: service.iconTypeID,
            labelColor: service.labelColor,
            labelTitle: service.labelTitle,
            counter: service.counter
        )
        log.logServicesModified(with: [changed])
    }

    func trashService(_ secret: String) {
        guard let service = repo.findService(for: secret) else { return XCTFail("\(self.name): no service \(secret)") }
        let result = repo.trashService(service)
        log.logServiceDeleted(with: result.deleted)
        log.logServicesModified(with: result.modified)
    }

    func untrashService(_ secret: String) {
        guard let service = repo.trashedService(for: secret) else {
            return XCTFail("\(self.name): no trashed service \(secret)")
        }
        let result = repo.untrashService(service)
        if let added = result.added {
            log.logNewServiceAdded(with: added)
        }
        log.logServicesModified(with: result.modified)
    }

    func moveService(_ secret: String, toSection sectionID: SectionID?) {
        let changed = repo.moveServiceToEndOfSection(secret: secret, sectionID: sectionID)
        log.logServicesModified(with: changed)
    }

    @discardableResult
    func createSection(_ title: String) -> SectionID {
        let sectionID = repo.createSection(with: title)
        log.logNewSectionAdded(with: sectionID.uuidString)
        return sectionID
    }

    func deleteSection(_ sectionID: SectionID) {
        guard let section = storage.section.listAll().first(where: { $0.sectionID == sectionID }) else {
            return XCTFail("\(self.name): no section \(sectionID)")
        }
        storage.section.delete(section)
        log.logSectionDeleted(with: sectionID.uuidString)
    }

    func save() {
        storage.save()
    }

    // MARK: What the device has

    var secrets: Set<String> { Set(repo.listAllNotTrashed().map(\.secret)) }
    var trashedSecrets: Set<String> { Set(repo.listTrashedServices().map(\.secret)) }
    var sectionTitles: Set<String> { Set(repo.listAllSections().map(\.title)) }

    func name(of secret: String) -> String? {
        repo.findService(for: secret)?.name
    }
}

// MARK: - Driving the sync

extension XCTestCase {
    @discardableResult
    func synchronize(
        _ device: SyncTestDevice,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> SyncTestDevice.Outcome {
        device.save()
        let done = expectation(description: "sync of \(device.name)")
        var outcome = SyncTestDevice.Outcome.stopped("timed out")
        device.synchronize {
            outcome = $0
            done.fulfill()
        }
        wait(for: [done], timeout: 30)
        return outcome
    }

    /// Syncs the devices in turns until a whole round changes nothing in the cloud – what they agree on then is
    /// final. Fails when they never settle (two devices undoing each other).
    func synchronizeUntilSettled(
        _ devices: [SyncTestDevice],
        cloud: FakeCloud,
        maxRounds: Int = 8,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for _ in 0..<maxRounds {
            let before = cloud.sequence
            for device in devices {
                let outcome = synchronize(device, file: file, line: line)
                XCTAssertEqual(outcome, .finished, "\(device.name)", file: file, line: line)
                if outcome != .finished { return }
            }
            if cloud.sequence == before { return }
        }
        XCTFail("The devices didn't settle in \(maxRounds) rounds", file: file, line: line)
    }
}
