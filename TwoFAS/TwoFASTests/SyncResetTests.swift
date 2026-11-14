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
@testable import Sync

final class SyncResetTests: XCTestCase {
    private var directory: URL!
    private var stack: CoreDataStack!
    private var logHandler: Sync.LogHandler!
    private var serviceHandler: Sync.ServiceHandler!
    private var sectionHandler: Sync.SectionHandler!
    /// Stored in `UserDefaults.standard` of the host app – restored after every test
    private var savedResetRequired = false

    private var context: NSManagedObjectContext { stack.context }

    override func setUp() {
        super.setUp()
        savedResetRequired = ConstStorage.syncResetRequired
        ConstStorage.syncResetRequired = false
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
        sectionHandler = nil
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        ConstStorage.syncResetRequired = savedResetRequired
        super.tearDown()
    }

    // MARK: - Integrity

    func testIntegrityPassesForReadableStore() {
        addService(secret: "AAAA")
        addService(secret: "BBBB")
        logHandler.log(entityID: "AAAA", actionType: .created, kind: .service3)
        logHandler.log(entityID: "SECTION-1", actionType: .modified, kind: .section)
        context.reset()

        XCTAssertTrue(SyncStoreIntegrity.verify(context: context))
        XCTAssertEqual(Set(serviceHandler.listAllWithMetadata().map(\.0.secret)), ["AAAA", "BBBB"])
        XCTAssertEqual(Set(logHandler.listAll().map(\.entityID)), ["AAAA", "SECTION-1"])
        XCTAssertFalse(ConstStorage.syncResetRequired)
    }

    func testIntegrityPassesForEmptyStore() {
        XCTAssertTrue(SyncStoreIntegrity.verify(context: context))
    }

    func testIntegrityFailsForRowSealedWithOtherKey() {
        addService(secret: "AAAA")

        reopenStack(cipher: makeTestCipher())

        XCTAssertFalse(SyncStoreIntegrity.verify(context: context))
    }

    func testIntegrityFailsForLogSealedWithOtherKey() {
        logHandler.log(entityID: "SECTION-1", actionType: .modified, kind: .section)

        reopenStack(cipher: makeTestCipher())

        XCTAssertFalse(SyncStoreIntegrity.verify(context: context))
    }

    func testIntegrityFailsForUndecryptableMetadata() throws {
        let cipher = makeTestCipher()
        reopenStack(cipher: cipher)
        addService(secret: "AAAA")
        let service = try XCTUnwrap(ServiceCacheEntity.listAll(on: context).first)
        service.encryptedMetadata = try cipher.seal(Data("metadata".utf8), associatedData: Data("other".utf8))
        stack.save()
        context.reset()

        XCTAssertNoThrow(try XCTUnwrap(ServiceCacheEntity.listAll(on: context).first).decryptedContent())
        XCTAssertFalse(SyncStoreIntegrity.verify(context: context))
    }

    // MARK: - Key state

    func testShouldSyncOnlyForAvailableOrNoKey() {
        XCTAssertTrue(SyncStoreIntegrity.shouldSync(cipherState: .available, isDeferred: false))
        XCTAssertTrue(SyncStoreIntegrity.shouldSync(cipherState: .noKey, isDeferred: false))
        XCTAssertFalse(SyncStoreIntegrity.shouldSync(cipherState: .keyLost, isDeferred: false))
        XCTAssertFalse(SyncStoreIntegrity.shouldSync(cipherState: .keyUnavailable, isDeferred: false))
    }

    func testShouldNotSyncWhileDeferred() {
        for state in [LocalStorageCipherState.available, .noKey, .keyLost, .keyUnavailable] {
            XCTAssertFalse(SyncStoreIntegrity.shouldSync(cipherState: state, isDeferred: true), "\(state)")
        }
    }

    // MARK: - Preflight of synchronize()

    func testPreflightBailsOnKeyStateOrDeferralBeforeAnythingElse() {
        let cases: [(LocalStorageCipherState, Bool)] = [
            (.keyUnavailable, false), (.keyLost, false), (.available, true), (.noKey, true), (.keyUnavailable, true)
        ]
        for (state, isDeferred) in cases {
            var cacheRead = false

            let preflight = SyncPreflight.decide(
                cipherState: state,
                isDeferred: isDeferred,
                isSyncing: true,
                resetRequired: true,
                isCacheReadable: { cacheRead = true; return false }
            )

            XCTAssertEqual(preflight, .notAllowed, "\(state), deferred: \(isDeferred)")
            XCTAssertFalse(cacheRead, "\(state), deferred: \(isDeferred)")
        }
        // A pending notification is completed right away
        XCTAssertEqual(SyncPreflight.notAllowed.notificationResult, .noData)
    }

    func testPreflightChecksSyncInProgressBeforeTheCache() {
        var cacheRead = false

        let preflight = SyncPreflight.decide(
            cipherState: .available,
            isDeferred: false,
            isSyncing: true,
            resetRequired: true,
            isCacheReadable: { cacheRead = true; return false }
        )

        XCTAssertEqual(preflight, .inProgress)
        XCTAssertFalse(cacheRead, "the sync in progress still uses the cache")
        XCTAssertNil(SyncPreflight.inProgress.notificationResult)
    }

    func testPreflightResetsScheduledResetWithoutReadingTheCache() {
        for state in [LocalStorageCipherState.available, .noKey] {
            var cacheRead = false

            let preflight = SyncPreflight.decide(
                cipherState: state,
                isDeferred: false,
                isSyncing: false,
                resetRequired: true,
                isCacheReadable: { cacheRead = true; return true }
            )

            XCTAssertEqual(preflight, .resetFirst, "\(state)")
            XCTAssertFalse(cacheRead, "\(state)")
        }
        XCTAssertNil(SyncPreflight.resetFirst.notificationResult)
    }

    func testPreflightResetsUndecryptableCache() {
        let preflight = SyncPreflight.decide(
            cipherState: .available,
            isDeferred: false,
            isSyncing: false,
            resetRequired: false,
            isCacheReadable: { false }
        )

        XCTAssertEqual(preflight, .resetFirst)
    }

    func testPreflightProceedsWithReadableCache() {
        var cacheRead = false

        let preflight = SyncPreflight.decide(
            cipherState: .noKey,
            isDeferred: false,
            isSyncing: false,
            resetRequired: false,
            isCacheReadable: { cacheRead = true; return true }
        )

        XCTAssertEqual(preflight, .proceed)
        XCTAssertTrue(cacheRead)
        XCTAssertNil(SyncPreflight.proceed.notificationResult)
    }

    // MARK: - Reset

    func testLocalResetEmptiesStoreAndClearsFlag() {
        addService(secret: "AAAA")
        logHandler.log(entityID: "AAAA", actionType: .created, kind: .service3)
        sectionHandler.create(
            metadata: Data(),
            sectionID: "SECTION-1",
            title: "Section",
            order: 0,
            creationDate: Date(),
            modificationDate: nil
        )
        // Rows of another key can't be decrypted – the reset has to remove them anyway
        reopenStack(cipher: makeTestCipher())
        addService(secret: "BBBB")
        ConstStorage.syncResetRequired = true
        var calls: [String] = []
        let firstImportLog = logHandler!
        let reset = SyncLocalReset(
            store: stack,
            clearInfoCache: { calls.append("clearInfoCache") },
            clearCheckpoints: { calls.append("clearCheckpoints") },
            clearPendingTokens: { calls.append("clearPendingTokens") },
            clearQueue: { calls.append("clearQueue") },
            logFirstImport: {
                calls.append("logFirstImport")
                return firstImportLog.logFirstImport(entityIDs: ["SECTION-2"], kind: .section)
            }
        )

        XCTAssertTrue(reset.perform())

        XCTAssertEqual(serviceHandler.count(), 0)
        XCTAssertEqual(sectionHandler.count(), 0)
        XCTAssertEqual(logHandler.listAll().map(\.entityID), ["SECTION-2"])
        XCTAssertFalse(ConstStorage.syncResetRequired)
        // Everything `firstStart()` clears (the Info cache with its purge of the items), also the change tokens a
        // fetch in progress would commit after the reset, the first import last
        XCTAssertEqual(
            calls,
            ["clearInfoCache", "clearCheckpoints", "clearPendingTokens", "clearQueue", "logFirstImport"]
        )
        XCTAssertTrue(SyncStoreIntegrity.verify(context: context))

        addService(secret: "CCCC")
        context.reset()
        XCTAssertEqual(serviceHandler.listAll().map(\.secret), ["CCCC"])
    }

    func testLocalResetStaysScheduledWhenFirstImportCantBeLogged() {
        addService(secret: "AAAA")
        ConstStorage.syncResetRequired = true
        let reset = SyncLocalReset(
            store: stack,
            clearInfoCache: {},
            clearCheckpoints: {},
            clearPendingTokens: {},
            clearQueue: {},
            logFirstImport: { false }
        )

        // Sync mustn't run without the first import – the services missing in the cloud would be trashed
        XCTAssertFalse(reset.perform())

        XCTAssertTrue(ConstStorage.syncResetRequired)
        XCTAssertEqual(serviceHandler.count(), 0)
    }

    func testStartFromScratchOnlySchedulesResetWhileKeyIsUnusable() {
        let core = makeTestCipher()
        reopenStack(cipher: core)
        addService(secret: "AAAA")
        logHandler.log(entityID: "AAAA", actionType: .created, kind: .service3)

        for state in [LocalStorageCipherState.keyUnavailable, .keyLost] {
            ConstStorage.syncResetRequired = false
            reopenStack(cipher: StateCipher(core: core, state: state))
            var started = false

            let didStart = startFromScratch { started = true }

            XCTAssertFalse(didStart, "\(state)")
            XCTAssertFalse(started, "\(state)")
            XCTAssertTrue(ConstStorage.syncResetRequired, "\(state)")
            context.reset()
            XCTAssertEqual(serviceHandler.listAll().map(\.secret), ["AAAA"], "\(state)")
            XCTAssertEqual(logHandler.listAll().map(\.entityID), ["AAAA"], "\(state)")
        }
    }

    func testStartFromScratchOnlySchedulesResetWhileDeferred() {
        addService(secret: "AAAA")
        logHandler.log(entityID: "AAAA", actionType: .created, kind: .service3)
        var started = false

        let didStart = startFromScratch(isDeferred: true) { started = true }

        XCTAssertFalse(didStart)
        XCTAssertFalse(started)
        XCTAssertTrue(ConstStorage.syncResetRequired)
        context.reset()
        XCTAssertEqual(serviceHandler.listAll().map(\.secret), ["AAAA"])
        XCTAssertEqual(logHandler.listAll().map(\.entityID), ["AAAA"])
    }

    func testStartFromScratchProceedsWithAvailableKey() {
        addService(secret: "AAAA")
        logHandler.log(entityID: "AAAA", actionType: .created, kind: .service3)
        var started = false

        let didStart = startFromScratch { started = true }

        XCTAssertTrue(didStart)
        XCTAssertTrue(started)
        XCTAssertFalse(ConstStorage.syncResetRequired)
        XCTAssertEqual(serviceHandler.count(), 0)
        XCTAssertTrue(logHandler.listAll().isEmpty)
    }

    func testScheduleResetSetsFlag() {
        SyncInstance.scheduleResetFromScratch()

        XCTAssertTrue(ConstStorage.syncResetRequired)
    }

    // MARK: - Accessors

    func testUndecryptableLogSetsResetFlag() throws {
        logHandler.log(entityID: "AAAA", actionType: .created, kind: .service3)

        reopenStack(cipher: makeTestCipher())

        let log = try XCTUnwrap(logHandler.listAll().first)
        XCTAssertEqual(log.entityID, "")
        XCTAssertTrue(ConstStorage.syncResetRequired)
    }

    func testUndecryptableServiceContentSetsResetFlag() throws {
        addService(secret: "AAAA")

        reopenStack(cipher: makeTestCipher())

        let service = try XCTUnwrap(ServiceCacheEntity.listAll(on: context).first)
        XCTAssertNil(service.content)
        XCTAssertTrue(ConstStorage.syncResetRequired)
    }

    func testUndecryptableServiceMetadataSetsResetFlag() throws {
        addService(secret: "AAAA")

        reopenStack(cipher: makeTestCipher())

        let service = try XCTUnwrap(ServiceCacheEntity.listAll(on: context).first)
        XCTAssertEqual(service.metadata, Data())
        XCTAssertTrue(ConstStorage.syncResetRequired)
    }

    // MARK: - Purge

    func testPurgeRemovesUndecryptableCacheRowsWithoutDecrypting() {
        addService(secret: "AAAA")
        reopenStack(cipher: makeTestCipher())
        addService(secret: "BBBB")

        serviceHandler.purge()

        context.reset()
        XCTAssertEqual(serviceHandler.count(), 0)
        XCTAssertFalse(ConstStorage.syncResetRequired, "purge mustn't open the content")
    }

    // MARK: - Helpers

    private func openStack(cipher: LocalStorageCipher) {
        stack = SyncInstance.makeCoreDataStack(cipher: cipher, storeDirectory: directory)
        logHandler = Sync.LogHandler(coreDataStack: stack)
        sectionHandler = Sync.SectionHandler(coreDataStack: stack)
        serviceHandler = Sync.ServiceHandler(
            coreDataStack: stack,
            serviceRecordEncryptionHandler: ServiceRecordEncryptionHandler(
                zoneManager: ZoneManager(),
                encryptionHandler: SyncEncryptionHandler(reference: Data(), localEncryptionKeyData: Data(count: 32))
            )
        )
    }

    /// The store part of `SyncHandler.firstStart()` (the rest – checkpoints, queue and Info cache – lives outside the
    /// store)
    @discardableResult
    private func startFromScratch(isDeferred: Bool = false, _ started: () -> Void) -> Bool {
        let logHandler = logHandler!
        let serviceHandler = serviceHandler!
        let sectionHandler = sectionHandler!
        return SyncStoreIntegrity.startFromScratch(on: context, isDeferred: isDeferred) {
            started()
            logHandler.deleteAll()
            serviceHandler.purge()
            sectionHandler.purge()
        }
    }

    private func reopenStack(cipher: LocalStorageCipher) {
        closeStores(of: stack)
        openStack(cipher: cipher)
    }

    private func addService(secret: String) {
        ServiceCacheEntity.create(
            on: context,
            metadata: Data("metadata".utf8),
            name: "Service",
            secret: secret,
            serviceTypeID: nil,
            additionalInfo: nil,
            rawIssuer: nil,
            otpAuth: nil,
            creationDate: Date(),
            modificationDate: Date(),
            tokenPeriod: Period.period30.rawValue,
            tokenLength: Digits.digits6.rawValue,
            badgeColor: nil,
            iconType: IconType.label.rawValue,
            iconTypeID: .default,
            labelColor: TintColor.default.rawValue,
            labelTitle: "SE",
            sectionID: nil,
            sectionOrder: 0,
            algorithm: Algorithm.SHA1.rawValue,
            counter: nil,
            tokenType: TokenType.totp.rawValue,
            source: ServiceSource.manual.rawValue
        )
        stack.save()
    }
}

/// Reads and writes with the wrapped cipher, but reports the given state
private final class StateCipher: LocalStorageCipher {
    private let core: LocalStorageCipherCore
    let state: LocalStorageCipherState

    init(core: LocalStorageCipherCore, state: LocalStorageCipherState) {
        self.core = core
        self.state = state
    }

    func seal(_ plaintext: Data, associatedData: Data) throws -> Data {
        try core.seal(plaintext, associatedData: associatedData)
    }

    func open(_ sealed: Data, associatedData: Data) throws -> Data {
        try core.open(sealed, associatedData: associatedData)
    }

    func lookupHash(for value: String, context: String) throws -> Data {
        try core.lookupHash(for: value, context: context)
    }

    func prepareForWriting() throws {}
}
