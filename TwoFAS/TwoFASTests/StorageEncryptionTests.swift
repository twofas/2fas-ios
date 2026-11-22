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

final class StorageEncryptionTests: XCTestCase {
    private var directory: URL!
    private var storage: Storage!
    private var keyDefaultsSuiteName: String?
    private var keychain: SystemKeychainItemStore?

    private var repo: StorageRepository { storage.storageRepository }
    private var context: NSManagedObjectContext { storage.coreDataStack.context }

    override func setUp() {
        super.setUp()
        directory = makeTemporaryDirectory()
        storage = makeStorage(cipher: makeTestCipher())
    }

    override func tearDown() {
        if let storage {
            closeStores(of: storage.coreDataStack)
        }
        storage = nil
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        removeKeyItems()
        super.tearDown()
    }

    // MARK: - Lookup and round trip

    func testServiceIsFoundBySecretInAnyCase() {
        addService(secret: "jbswy3dpehpk3pxp")

        XCTAssertEqual(repo.findService(for: "JBSWY3DPEHPK3PXP")?.secret, "JBSWY3DPEHPK3PXP")
        XCTAssertEqual(repo.serviceExists(for: "jbswy3dpehpk3pxp"), .yes)
        XCTAssertEqual(repo.serviceExists(for: "OTHERSECRET"), .no)
    }

    func testAllSensitiveFieldsRoundTrip() {
        let serviceTypeID = UUID()
        let iconTypeID = UUID()
        addService(
            name: "Account",
            secret: "JBSWY3DPEHPK3PXP",
            serviceTypeID: serviceTypeID,
            additionalInfo: "user@example.com",
            rawIssuer: "Issuer",
            otpAuth: "otpauth://totp/Issuer:user?secret=JBSWY3DPEHPK3PXP",
            labelTitle: "AC",
            iconTypeID: iconTypeID
        )
        context.reset()

        let service = repo.findService(for: "JBSWY3DPEHPK3PXP")
        XCTAssertEqual(service?.name, "Account")
        XCTAssertEqual(service?.secret, "JBSWY3DPEHPK3PXP")
        XCTAssertEqual(service?.serviceTypeID, serviceTypeID)
        XCTAssertEqual(service?.additionalInfo, "user@example.com")
        XCTAssertEqual(service?.rawIssuer, "Issuer")
        XCTAssertEqual(service?.otpAuth, "otpauth://totp/Issuer:user?secret=JBSWY3DPEHPK3PXP")
        XCTAssertEqual(service?.labelTitle, "AC")
        XCTAssertEqual(service?.iconTypeID, iconTypeID)
    }

    func testLongFieldsRoundTrip() {
        let otpAuth = String(repeating: "o", count: 4096)
        let name = String(repeating: "n", count: 1000)
        addService(name: name, secret: "JBSWY3DPEHPK3PXP", otpAuth: otpAuth)
        context.reset()

        let service = repo.findService(for: "JBSWY3DPEHPK3PXP")
        XCTAssertEqual(service?.otpAuth, otpAuth)
        XCTAssertEqual(service?.name, name)
    }

    // MARK: - Listing

    func testSearchAndSortThroughRepository() {
        let sectionID = repo.createSection(with: "Work")
        let otherSectionID = repo.createSection(with: "Empty")
        let facebookType = UUID()
        addService(name: "Google", secret: "AAAA", additionalInfo: "b@example.com")
        addService(name: "Google", secret: "BBBB")
        addService(name: "Amazon", secret: "CCCC", additionalInfo: "my GOOGLE login")
        addService(name: "Facebook", secret: "DDDD", serviceTypeID: facebookType)
        addService(name: "GOOD bank", secret: "EEEE", sectionID: sectionID)
        context.reset()

        let az = repo.listAllWithingCategories(for: "goo", sorting: .az, ids: [])
        XCTAssertEqual(az.count, 3)
        XCTAssertNil(az[safe: 0]?.section)
        XCTAssertEqual(az[safe: 0]?.services.map(\.secret), ["CCCC", "BBBB", "AAAA"])
        XCTAssertEqual(az[safe: 1]?.section?.sectionID, sectionID)
        XCTAssertEqual(az[safe: 1]?.services.map(\.secret), ["EEEE"])
        XCTAssertEqual(az[safe: 2]?.section?.sectionID, otherSectionID)
        XCTAssertEqual(az[safe: 2]?.services.map(\.secret), [])

        let za = repo.listAllWithingCategories(for: "goo", sorting: .za, ids: [])
        XCTAssertEqual(za[safe: 0]?.services.map(\.secret), ["AAAA", "BBBB", "CCCC"])

        let byType = repo.listAllWithingCategories(for: "zzz", sorting: .az, ids: [facebookType])
        XCTAssertEqual(byType.allServices.map(\.secret), ["DDDD"])

        let manual = repo.listAllWithingCategories(for: nil, sorting: .manual, ids: [])
        XCTAssertEqual(manual[safe: 0]?.services.map(\.secret), ["AAAA", "BBBB", "CCCC", "DDDD"])
    }

    func testWidgetListExcludesAndSkipsHOTP() {
        addService(name: "Alpha", secret: "AAAA")
        addService(name: "Beta", secret: "BBBB")
        addService(name: "Counter", secret: "CCCC", tokenType: .hotp)
        context.reset()

        let all = storage.widgetService.listAll(search: nil, exclude: ["BBBB"])
        XCTAssertEqual(all.flatMap(\.services).map(\.serviceID), ["AAAA"])

        let searched = storage.widgetService.listAll(search: "bet", exclude: [])
        XCTAssertEqual(searched.flatMap(\.services).map(\.serviceID), ["BBBB"])

        let selected = storage.widgetService.listServices(with: ["AAAA", "CCCC"])
        XCTAssertEqual(selected.map(\.serviceID), ["AAAA", "CCCC"])
        XCTAssertEqual(selected.first?.serviceName, "Alpha")
    }

    // MARK: - Modifications

    func testTrashAndUntrash() throws {
        addService(name: "Alpha", secret: "AAAA")
        let service = try XCTUnwrap(repo.findService(for: "AAAA"))

        _ = repo.trashService(service)
        XCTAssertEqual(repo.listTrashedServices().map(\.secret), ["AAAA"])
        XCTAssertEqual(repo.serviceExists(for: "AAAA"), .trashed)
        XCTAssertTrue(repo.listAllNotTrashed().isEmpty)

        let trashed = try XCTUnwrap(repo.trashedService(for: "AAAA"))
        let result = repo.untrashService(trashed)
        XCTAssertEqual(result.added, "AAAA")
        XCTAssertEqual(repo.serviceExists(for: "AAAA"), .yes)
        XCTAssertEqual(repo.listAllNotTrashed().map(\.secret), ["AAAA"])
    }

    func testUpdateServiceIsVisibleImmediately() throws {
        addService(name: "Old", secret: "AAAA")
        XCTAssertEqual(repo.listAllNotTrashed().first?.name, "Old")
        let service = try XCTUnwrap(repo.findService(for: "AAAA"))

        repo.updateService(
            service,
            name: "New",
            additionalInfo: "info",
            badgeColor: nil,
            iconType: .label,
            iconTypeID: .default,
            labelColor: .default,
            labelTitle: "NE",
            counter: nil
        )

        let updated = repo.listAllNotTrashed().first
        XCTAssertEqual(updated?.name, "New")
        XCTAssertEqual(updated?.additionalInfo, "info")
        XCTAssertEqual(updated?.labelTitle, "NE")
    }

    func testBackgroundChangeIsVisibleInViewContext() {
        addService(name: "Old", secret: "AAAA")
        XCTAssertEqual(repo.listAllNotTrashed().first?.name, "Old")

        storage.coreDataStack.performAndWaitInBackground { context in
            guard let entity = ServiceEntity.findService(on: context, secret: "AAAA") else {
                return XCTFail("Service not found in the background context")
            }
            do {
                try entity.updateContent { $0.name = "BG" }
            } catch {
                XCTFail("updateContent failed: \(error)")
            }
        }

        XCTAssertTrue(waitUntil { self.repo.listAllNotTrashed().first?.name == "BG" })
    }

    func testReadingContentDoesNotMarkObjectUpdated() throws {
        addService(name: "Alpha", secret: "AAAA")
        context.reset()

        let entity = try XCTUnwrap(ServiceEntity.findService(on: context, secret: "AAAA"))
        XCTAssertEqual(entity.name, "Alpha")
        XCTAssertFalse(entity.isUpdated)
        XCTAssertFalse(context.hasChanges)
    }

    /// A service that only moved wasn't changed: a deletion made elsewhere in the meantime still wins
    func testReorderingKeepsModificationDates() {
        addService(secret: "AAAA")
        addService(secret: "BBBB")
        addService(secret: "CCCC")
        storage.save()
        let before = Dictionary(uniqueKeysWithValues: repo.listAllNotTrashed().map { ($0.secret, $0.modifiedAt) })
        XCTAssertEqual(before.count, 3)

        storage.service.move(from: 0, currentSectionID: nil, to: 2, newSectionID: nil)
        storage.save()

        let after = Dictionary(uniqueKeysWithValues: repo.listAllNotTrashed().map { ($0.secret, $0.modifiedAt) })
        XCTAssertEqual(after, before)
        XCTAssertNotEqual(
            repo.listAllNotTrashed().sorted { ($0.order ?? 0) < ($1.order ?? 0) }.map(\.secret),
            ["AAAA", "BBBB", "CCCC"],
            "The order did change"
        )
    }

    func testMoveReturnsOnlyReorderedSecrets() {
        addService(name: "Alpha", secret: "AAAA")
        addService(name: "Beta", secret: "BBBB")
        addService(name: "Gamma", secret: "CCCC")
        let sectionID = repo.createSection(with: "Work")
        XCTAssertEqual(repo.listAllNotTrashed().count, 3)

        let moved = repo.moveServiceToEndOfSection(secret: "BBBB", sectionID: sectionID)

        XCTAssertEqual(Set(moved), ["BBBB", "CCCC"])
        XCTAssertEqual(repo.section(for: "BBBB")?.sectionID, sectionID)
    }

    func testCountsDoNotNeedDecryption() throws {
        addService(name: "Alpha", secret: "AAAA")
        addService(name: "Beta", secret: "BBBB")
        addService(name: "Gamma", secret: "CCCC")
        _ = repo.trashService(try XCTUnwrap(repo.findService(for: "CCCC")))
        XCTAssertEqual(repo.countServicesNotTrashed(), 2)

        reopenStorage(cipher: makeTestCipher())

        XCTAssertTrue(repo.listAllNotTrashed().isEmpty)
        XCTAssertTrue(repo.hasServices)
        XCTAssertEqual(repo.countServicesNotTrashed(), 2)
        XCTAssertEqual(storage.service.count(), 2)
        XCTAssertTrue(storage.widgetService.hasServices())
    }

    func testUndecryptableRowsAreSkipped() {
        addService(name: "Alpha", secret: "AAAA")
        addService(name: "Beta", secret: "BBBB")
        repo.createAuthRequest(for: "AAAA", extensionID: "ext", domain: "example.com")

        reopenStorage(cipher: makeTestCipher())

        XCTAssertTrue(repo.listAllNotTrashed().isEmpty)
        XCTAssertTrue(repo.listAllExistingServices().isEmpty)
        XCTAssertTrue(repo.listAllWithingCategories(for: nil, sorting: .az, ids: []).allServices.isEmpty)
        XCTAssertTrue(storage.widgetService.listAll(search: nil, exclude: []).flatMap(\.services).isEmpty)
        XCTAssertTrue(repo.listAllAuthRequestsForExtensionID("ext").isEmpty)
        XCTAssertNil(repo.findService(for: "AAAA"))

        addService(name: "Gamma", secret: "CCCC")
        XCTAssertEqual(repo.listAllNotTrashed().map(\.secret), ["CCCC"])
    }

    // MARK: - Merge

    func testSetServicesChangesNothingWhenWritingIsNotPossible() {
        let core = makeTestCipher()
        reopenStorage(cipher: core)
        addService(name: "Alpha", secret: "AAAA")
        addService(name: "Beta", secret: "BBBB")
        reopenStorage(cipher: WritingUnavailableCipher(core: core))
        let current = storage.service.getAllServices()
        XCTAssertEqual(current.count, 2)

        XCTAssertFalse(storage.service.setServices(current.filter { $0.secret == "AAAA" }))

        context.reset()
        XCTAssertEqual(Set(repo.listAllNotTrashed().map(\.secret)), ["AAAA", "BBBB"])
        XCTAssertTrue(repo.listTrashedServices().isEmpty)
    }

    /// Spec §6: rows that can't be decrypted are missing from `getAllServices()`, so the merge neither trashes them nor
    /// reports them as deleted; `removeAllNotTrashed()` removes them without decrypting and the cloud list is created
    func testSetServicesReplacesUndecryptableRowsWithoutReportingDeletions() throws {
        addService(name: "Alpha", secret: "AAAA")
        addService(name: "Beta", secret: "BBBB")
        // Another key, ready for writing – the rows of the old one can't be decrypted
        reopenStorage(cipher: makeTestCipher())
        XCTAssertTrue(storage.service.getAllServices().isEmpty)
        XCTAssertEqual(try rawServiceCount(), 2)
        var deleted: [String] = []
        var modified: [[String]] = []
        storage.service.commonDidDelete = { deleted.append($0) }
        storage.service.commonDidModify = { modified.append($0) }
        var updates: [[AnyHashable: Any]] = []
        var allRemoved = 0
        let center = NotificationCenter.default
        let observers = [
            center.addObserver(forName: .servicesWereUpdated, object: nil, queue: nil) {
                updates.append($0.userInfo ?? [:])
            },
            center.addObserver(forName: .allServicesRemoved, object: nil, queue: nil) { _ in allRemoved += 1 }
        ]
        defer { observers.forEach(center.removeObserver) }
        let cloud = [
            cloudService(name: "Alpha", secret: "AAAA", order: 0),
            cloudService(name: "Gamma", secret: "CCCC", order: 1)
        ]

        XCTAssertTrue(storage.service.setServices(cloud))

        // No deletion reported for the undecryptable rows – neither to Sync nor to the app
        XCTAssertEqual(deleted, [])
        XCTAssertEqual(modified, [])
        XCTAssertEqual(allRemoved, 0)
        XCTAssertEqual(updates.count, 1)
        XCTAssertEqual(updates.first?[Notification.UserInfoKey.deleted] as? [String], [])
        XCTAssertEqual(updates.first?[Notification.UserInfoKey.modified] as? [String], [])
        // Not trashed (counted without decrypting), but removed and replaced by the cloud list
        XCTAssertEqual(try rawServiceCount(trashed: true), 0)
        XCTAssertEqual(try rawServiceCount(), 2)
        context.reset()
        XCTAssertEqual(Set(repo.listAllNotTrashed().map(\.secret)), ["AAAA", "CCCC"])
    }

    // MARK: - Auth requests

    func testAuthRequestsRoundTripAndLookup() {
        repo.createAuthRequest(for: "bbbb", extensionID: "ext-1", domain: "other.example")
        repo.createAuthRequest(for: "aaaa", extensionID: "ext-1", domain: "domainmarker.example")
        repo.createAuthRequest(for: "CCCC", extensionID: "ext-2", domain: "domainmarker.example")
        context.reset()

        let byDomain = repo.listAllAuthRequests(for: "domainmarker.example", extensionID: "ext-1")
        XCTAssertEqual(byDomain.map(\.secret), ["AAAA"])
        XCTAssertEqual(byDomain.map(\.domain), ["domainmarker.example"])
        XCTAssertTrue(repo.listAllAuthRequests(for: "DOMAINMARKER.example", extensionID: "ext-1").isEmpty)

        let bySecret = repo.listAllAuthRequests(for: "AAAA")
        XCTAssertEqual(bySecret.map(\.domain), ["domainmarker.example"])
        XCTAssertEqual(bySecret.map(\.extensionID), ["ext-1"])

        let forExtension = repo.listAllAuthRequestsForExtensionID("ext-1")
        XCTAssertEqual(forExtension.map(\.domain), ["domainmarker.example", "other.example"])

        if let request = byDomain.first {
            repo.removeAuthRequest(request)
        }
        XCTAssertEqual(repo.listAllAuthRequestsForExtensionID("ext-1").map(\.secret), ["BBBB"])
    }

    // MARK: - Key

    func testFirstWriteCreatesKeyInMainApp() {
        let cipher = makeMainAppCipher()
        XCTAssertEqual(cipher.state, .noKey)
        reopenStorage(cipher: cipher)

        addService(name: "Alpha", secret: "AAAA")

        XCTAssertEqual(repo.findService(for: "AAAA")?.name, "Alpha")
        XCTAssertEqual(cipher.state, .available)
    }

    /// A deletion can be the first thing written – e.g. received from the cloud before any service
    func testDeletionAsFirstWriteCreatesKeyInMainApp() {
        let cipher = makeMainAppCipher()
        XCTAssertEqual(cipher.state, .noKey)
        reopenStorage(cipher: cipher)

        DeletedServiceEntity.record(on: context, secret: "FIRSTSECRET", deletedAt: Date())

        XCTAssertEqual(cipher.state, .available)
        XCTAssertEqual(DeletedServiceEntity.find(on: context, secret: "FIRSTSECRET")?.secret, "FIRSTSECRET")
    }

    // MARK: - Files

    func testNoPlaintextInStoreFiles() {
        addService(
            name: "NameMarkerXYZ",
            secret: "PLAINTEXTSECRETMARKER",
            additionalInfo: "InfoMarkerXYZ",
            otpAuth: "otpauth://totp/NameMarkerXYZ?secret=PLAINTEXTSECRETMARKER"
        )
        repo.createAuthRequest(for: "PLAINTEXTSECRETMARKER", extensionID: "ext", domain: "domainmarker.example")
        storage.save()

        let bytes = rawStoreBytes(name: Storage.storeName, in: directory)
        XCTAssertFalse(bytes.isEmpty)
        let markers = ["PLAINTEXTSECRETMARKER", "NameMarkerXYZ", "InfoMarkerXYZ", "domainmarker.example", "otpauth://"]
        for marker in markers {
            XCTAssertNil(bytes.range(of: Data(marker.utf8)), "\(marker) found in store files")
        }
    }

    func testExtensionUsesInMemoryStoreWhenMigrationIsPending() throws {
        closeStores(of: storage.coreDataStack)
        let directory = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let premigration = directory.appendingPathComponent("\(Storage.storeName).sqlite.premigration")
        try Data("pending".utf8).write(to: premigration)

        let readOnly = Storage(
            storeDirectory: directory,
            readOnly: true,
            initializeLogStorage: false,
            cipher: makeTestCipher(),
            allowsMigration: false,
            logError: nil
        )
        XCTAssertTrue(readOnly.widgetService.listAll(search: nil, exclude: []).flatMap(\.services).isEmpty)
        XCTAssertFalse(readOnly.widgetService.hasServices())

        storage = Storage(
            storeDirectory: directory,
            initializeLogStorage: false,
            cipher: makeTestCipher(),
            allowsMigration: false,
            logError: nil
        )
        addService(name: "Alpha", secret: "AAAA")

        XCTAssertEqual(repo.listAllNotTrashed().map(\.secret), ["AAAA"])
        let storeURL = CoreDataStack.storeURL(name: Storage.storeName, directory: directory)
        XCTAssertFalse(FileManager.default.fileExists(atPath: storeURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: premigration.path))
    }

    // MARK: - Helpers

    // MARK: - Does the key open what is stored

    func testStoredDataOpensWithTheKeyThatSealedIt() {
        let cipher = makeTestCipher()
        reopenStorage(cipher: cipher)
        XCTAssertTrue(Storage.storedDataOpens(with: cipher, directory: directory), "Nothing stored yet")

        addService(secret: "SECRETA")
        addService(secret: "SECRETB")
        storage.save()
        closeStores(of: storage.coreDataStack)

        XCTAssertTrue(Storage.storedDataOpens(with: cipher, directory: directory))
        storage = makeStorage(cipher: cipher)
    }

    func testStoredDataDoesNotOpenWithAnotherKey() {
        let cipher = makeTestCipher()
        reopenStorage(cipher: cipher)
        addService(secret: "SECRETA")
        addService(secret: "SECRETB")
        storage.save()
        closeStores(of: storage.coreDataStack)

        XCTAssertFalse(Storage.storedDataOpens(with: makeTestCipher(), directory: directory))
        storage = makeStorage(cipher: cipher)
    }

    /// A key that can't be used now says nothing about the stored data
    func testUnusableKeyIsNotAMismatch() {
        let cipher = makeTestCipher()
        reopenStorage(cipher: cipher)
        addService(secret: "SECRETA")
        storage.save()
        closeStores(of: storage.coreDataStack)

        let unavailable = UnusableCipher()
        XCTAssertTrue(Storage.storedDataOpens(with: unavailable, directory: directory))
        storage = makeStorage(cipher: cipher)
    }

    func testMissingStoreIsNotAMismatch() {
        let empty = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: empty) }
        XCTAssertTrue(Storage.storedDataOpens(with: makeTestCipher(), directory: empty))
    }

    private func reopenStorage(cipher: LocalStorageCipher) {
        closeStores(of: storage.coreDataStack)
        storage = makeStorage(cipher: cipher)
    }
    
    private func makeStorage(cipher: LocalStorageCipher) -> Storage {
        Storage(
            storeDirectory: directory,
            initializeLogStorage: false,
            cipher: cipher,
            allowsMigration: true,
            logError: nil
        )
    }

    @discardableResult
    private func addService(
        name: String = "Service",
        secret: String,
        serviceTypeID: ServiceTypeID? = nil,
        additionalInfo: String? = nil,
        rawIssuer: String? = nil,
        otpAuth: String? = nil,
        labelTitle: String = "SE",
        iconTypeID: IconTypeID = .default,
        tokenType: TokenType = .totp,
        sectionID: SectionID? = nil
    ) -> String {
        repo.addService(
            name: name,
            secret: secret,
            serviceTypeID: serviceTypeID,
            additionalInfo: additionalInfo,
            rawIssuer: rawIssuer,
            otpAuth: otpAuth,
            tokenPeriod: .period30,
            tokenLength: .digits6,
            badgeColor: nil,
            iconType: .label,
            iconTypeID: iconTypeID,
            labelColor: .default,
            labelTitle: labelTitle,
            algorithm: .SHA1,
            counter: tokenType == .hotp ? 0 : nil,
            tokenType: tokenType,
            sectionID: sectionID,
            source: .manual
        )
    }

    /// Rows of `ServiceEntity`, counted in SQL without decrypting. `trashed` – only trashed or not trashed ones.
    private func rawServiceCount(trashed: Bool? = nil) throws -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ServiceEntity")
        if let trashed {
            request.predicate = NSPredicate(format: "isTrashed == %@", NSNumber(value: trashed))
        }
        return try context.count(for: request)
    }

    private func cloudService(name: String, secret: String, order: Int) -> ServiceData {
        ServiceData(
            name: name,
            secret: secret,
            serviceTypeID: nil,
            additionalInfo: nil,
            rawIssuer: nil,
            modifiedAt: Date(timeIntervalSinceReferenceDate: 700_000_000),
            createdAt: Date(timeIntervalSinceReferenceDate: 700_000_000),
            tokenPeriod: .period30,
            tokenLength: .digits6,
            badgeColor: nil,
            iconType: .label,
            iconTypeID: .default,
            labelColor: .default,
            labelTitle: "SE",
            algorithm: .SHA1,
            isTrashed: false,
            trashingDate: nil,
            counter: nil,
            tokenType: .totp,
            source: .manual,
            otpAuth: nil,
            order: order,
            sectionID: nil
        )
    }

    /// A real cipher with its own defaults domain and Keychain service, removed in `tearDown`
    private func makeMainAppCipher() -> LocalStorageCipherImpl {
        let suiteName = "test.\(UUID().uuidString)"
        let keychain = SystemKeychainItemStore(service: "test.\(UUID().uuidString)")
        keyDefaultsSuiteName = suiteName
        self.keychain = keychain
        let keyStore = LocalStorageKeyStore(
            defaults: UserDefaults(suiteName: suiteName)!,
            keychain: keychain,
            protections: [PlainDataKeyProtection()]
        )
        return LocalStorageCipherImpl(keyStore: keyStore, canCreateKey: true)
    }

    private func removeKeyItems() {
        guard let suiteName = keyDefaultsSuiteName, let defaults = UserDefaults(suiteName: suiteName) else { return }
        if let keyID = defaults.string(forKey: LocalStorageKeyStore.keyIDDefaultsKey).flatMap(UUID.init) {
            keychain?.remove(account: LocalStorageKeyStore.account(for: keyID))
        }
        defaults.removePersistentDomain(forName: suiteName)
        keyDefaultsSuiteName = nil
        keychain = nil
    }

    private func waitUntil(timeout: TimeInterval = 2, _ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            guard Date() < deadline else { return false }
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }
        return true
    }
}

/// Reads and seals with the wrapped cipher, but refuses to prepare for writing like a cipher whose key is unavailable
private final class WritingUnavailableCipher: LocalStorageCipher {
    private let core: LocalStorageCipherCore

    init(core: LocalStorageCipherCore) {
        self.core = core
    }

    var state: LocalStorageCipherState { .keyUnavailable }

    func seal(_ plaintext: Data, associatedData: Data) throws -> Data {
        try core.seal(plaintext, associatedData: associatedData)
    }

    func open(_ sealed: Data, associatedData: Data) throws -> Data {
        try core.open(sealed, associatedData: associatedData)
    }

    func lookupHash(for value: String, context: String) throws -> Data {
        try core.lookupHash(for: value, context: context)
    }

    func prepareForWriting() throws {
        throw LocalStorageCipherError.keyUnavailable
    }
}

// MARK: - Deletion records and section titles

extension StorageEncryptionTests {
    private func trash(_ secret: String) throws -> ServiceData {
        let service = try XCTUnwrap(repo.findService(for: secret))
        _ = repo.trashService(service)
        return try XCTUnwrap(repo.listTrashedServices().first { $0.secret == secret })
    }

    func testTrashingServiceRecordsItsDeletion() throws {
        addService(secret: "DELETIONSECRETMARKER")
        XCTAssertNil(DeletedServiceEntity.find(on: context, secret: "DELETIONSECRETMARKER"))

        let trashed = try trash("DELETIONSECRETMARKER")

        let deletion = try XCTUnwrap(DeletedServiceEntity.find(on: context, secret: "deletionsecretmarker"))
        XCTAssertEqual(deletion.deletedAt, trashed.trashingDate)
        XCTAssertEqual(deletion.secret, "DELETIONSECRETMARKER")
        XCTAssertNil(deletion.syncID)
        XCTAssertEqual(DeletedServiceEntity.listAll(on: context).count, 1)
        storage.save()
        let bytes = rawStoreBytes(name: Storage.storeName, in: directory)
        XCTAssertNil(bytes.range(of: Data("DELETIONSECRETMARKER".utf8)))
    }

    func testRestoringServiceRemovesItsDeletionAndMakesItNewer() throws {
        addService(secret: "RESTOREDSECRET")
        let trashed = try trash("RESTOREDSECRET")
        let deletedAt = try XCTUnwrap(trashed.trashingDate)

        _ = repo.untrashService(trashed)

        XCTAssertNil(DeletedServiceEntity.find(on: context, secret: "RESTOREDSECRET"))
        let restored = try XCTUnwrap(repo.findService(for: "RESTOREDSECRET"))
        // Newer than the deletion, wherever that one is still known
        XCTAssertGreaterThanOrEqual(restored.modifiedAt, deletedAt)
    }

    func testRemovingServiceFromTrashKeepsItsDeletion() throws {
        addService(secret: "REMOVEDSECRET")
        let trashed = try trash("REMOVEDSECRET")

        repo.deleteService(trashed)

        XCTAssertEqual(try rawServiceCount(), 0)
        let deletion = try XCTUnwrap(DeletedServiceEntity.find(on: context, secret: "REMOVEDSECRET"))
        // What identifies the service elsewhere is still there
        XCTAssertEqual(deletion.secret, "REMOVEDSECRET")
    }

    func testAddingServiceAgainRemovesItsDeletion() throws {
        addService(secret: "READDEDSECRET")
        repo.deleteService(try trash("READDEDSECRET"))
        XCTAssertNotNil(DeletedServiceEntity.find(on: context, secret: "READDEDSECRET"))

        addService(secret: "READDEDSECRET")

        XCTAssertNil(DeletedServiceEntity.find(on: context, secret: "READDEDSECRET"))
    }

    /// Whatever puts a service in the trash records the deletion – also the data coming from Sync
    func testServiceTrashedBySyncGetsItsDeletion() {
        addService(secret: "KEPTSECRET")
        addService(secret: "MISSINGSECRET")

        XCTAssertTrue(storage.service.setServices([cloudService(name: "Kept", secret: "KEPTSECRET", order: 0)]))

        XCTAssertNotNil(DeletedServiceEntity.find(on: context, secret: "MISSINGSECRET"))
        XCTAssertNil(DeletedServiceEntity.find(on: context, secret: "KEPTSECRET"))
    }

    /// Once Sync gave the deletion its identifier, the secret isn't stored with it again
    func testDeletionWithSyncIdentifierDoesNotKeepTheSecret() throws {
        let later = Date()
        DeletedServiceEntity.record(on: context, secret: "SYNCEDSECRET", deletedAt: later.addingTimeInterval(-100))
        let deletion = try XCTUnwrap(DeletedServiceEntity.find(on: context, secret: "SYNCEDSECRET"))
        deletion.syncID = Data([1, 2, 3])
        deletion.encryptedContent = nil

        DeletedServiceEntity.record(on: context, secret: "SYNCEDSECRET", deletedAt: later)

        XCTAssertEqual(DeletedServiceEntity.listAll(on: context).count, 1)
        XCTAssertEqual(deletion.deletedAt, later)
        XCTAssertEqual(deletion.syncID, Data([1, 2, 3]))
        XCTAssertNil(deletion.encryptedContent)
        XCTAssertNil(deletion.secret)
    }

    func testExpiredDeletionsAreRemoved() {
        let now = Date()
        let expired = now.addingTimeInterval(-DeletionRetention.interval - 60)
        let recent = now.addingTimeInterval(-DeletionRetention.interval + 60)
        DeletedServiceEntity.record(on: context, secret: "EXPIREDSECRET", deletedAt: expired)
        DeletedServiceEntity.record(on: context, secret: "RECENTSECRET", deletedAt: recent)
        let expiredSection = UUID()
        let recentSection = UUID()
        DeletedSectionEntity.record(on: context, sectionID: expiredSection, deletedAt: expired)
        DeletedSectionEntity.record(on: context, sectionID: recentSection, deletedAt: recent)
        storage.save()

        storage.removeExpiredDeletions()

        XCTAssertNil(DeletedServiceEntity.find(on: context, secret: "EXPIREDSECRET"))
        XCTAssertNotNil(DeletedServiceEntity.find(on: context, secret: "RECENTSECRET"))
        XCTAssertNil(DeletedSectionEntity.find(on: context, sectionID: expiredSection))
        XCTAssertNotNil(DeletedSectionEntity.find(on: context, sectionID: recentSection))
    }

    func testRecordingDeletionTwiceKeepsOneRecord() {
        let later = Date()
        DeletedServiceEntity.record(on: context, secret: "TWICESECRET", deletedAt: later.addingTimeInterval(-100))
        DeletedServiceEntity.record(on: context, secret: "TWICESECRET", deletedAt: later)

        XCTAssertEqual(DeletedServiceEntity.listAll(on: context).count, 1)
        XCTAssertEqual(DeletedServiceEntity.find(on: context, secret: "TWICESECRET")?.deletedAt, later)
    }

    /// The same service deleted twice (e.g. on two devices before they synced) – the latest deletion counts,
    /// whichever is recorded first
    func testLatestDeletionOfServiceCounts() {
        let later = Date()
        DeletedServiceEntity.record(on: context, secret: "TWICESECRET", deletedAt: later)
        DeletedServiceEntity.record(on: context, secret: "TWICESECRET", deletedAt: later.addingTimeInterval(-100))

        XCTAssertEqual(DeletedServiceEntity.listAll(on: context).count, 1)
        XCTAssertEqual(DeletedServiceEntity.find(on: context, secret: "TWICESECRET")?.deletedAt, later)
    }

    func testDuplicatedDeletionsOfServiceAreMerged() throws {
        let later = Date()
        DeletedServiceEntity.record(on: context, secret: "DUPLICATEDSECRET", deletedAt: later)
        let recorded = try XCTUnwrap(DeletedServiceEntity.find(on: context, secret: "DUPLICATEDSECRET"))
        // A second record of the same service, known to Sync and without the secret
        let synced = DeletedServiceEntity(context: context)
        synced.secretHash = recorded.secretHash
        synced.deletedAt = later.addingTimeInterval(-100)
        synced.syncID = Data([1, 2, 3])
        DeletedServiceEntity.record(on: context, secret: "OTHERSECRET", deletedAt: later)
        storage.save()

        storage.removeExpiredDeletions()

        XCTAssertEqual(DeletedServiceEntity.listAll(on: context).count, 2)
        let merged = try XCTUnwrap(DeletedServiceEntity.find(on: context, secret: "DUPLICATEDSECRET"))
        XCTAssertEqual(merged.deletedAt, later)
        XCTAssertEqual(merged.syncID, Data([1, 2, 3]))
        XCTAssertNotNil(DeletedServiceEntity.find(on: context, secret: "OTHERSECRET"))
    }

    func testLatestDeletionOfSectionCounts() throws {
        let sectionID = UUID()
        let later = Date()
        DeletedSectionEntity.record(on: context, sectionID: sectionID, deletedAt: later)
        DeletedSectionEntity.record(on: context, sectionID: sectionID, deletedAt: later.addingTimeInterval(-100))
        let duplicate = DeletedSectionEntity(context: context)
        duplicate.sectionID = sectionID
        duplicate.deletedAt = later.addingTimeInterval(100)
        storage.save()

        storage.removeExpiredDeletions()

        XCTAssertEqual(DeletedSectionEntity.listAll(on: context).count, 1)
        XCTAssertEqual(
            DeletedSectionEntity.find(on: context, sectionID: sectionID)?.deletedAt,
            later.addingTimeInterval(100)
        )
    }

    func testDeletingSectionRecordsItsDeletion() throws {
        storage.section.create(with: "Section")
        let section = try XCTUnwrap(storage.section.listAll().first)

        storage.section.delete(section)

        XCTAssertTrue(storage.section.listAll().isEmpty)
        XCTAssertNotNil(DeletedSectionEntity.find(on: context, sectionID: section.sectionID))
    }

    func testSectionsRemovedBySyncGetTheirDeletions() throws {
        storage.section.create(with: "Kept")
        storage.section.create(with: "Removed")
        let sections = storage.section.listAll()
        let kept = try XCTUnwrap(sections.first { $0.title == "Kept" })
        let removed = try XCTUnwrap(sections.first { $0.title == "Removed" })

        XCTAssertTrue(storage.section.setSections([
            CommonSectionData(
                name: "Kept renamed",
                sectionID: kept.sectionID.uuidString,
                creationDate: kept.createdAt,
                modificationDate: Date(),
                isCollapsed: false
            )
        ]))

        XCTAssertEqual(storage.section.listAll().map(\.title), ["Kept renamed"])
        XCTAssertNotNil(DeletedSectionEntity.find(on: context, sectionID: removed.sectionID))
        XCTAssertNil(DeletedSectionEntity.find(on: context, sectionID: kept.sectionID))
    }

    func testSectionCreatedAgainLosesItsDeletion() throws {
        storage.section.create(with: "Section")
        let section = try XCTUnwrap(storage.section.listAll().first)
        storage.section.delete(section)

        XCTAssertTrue(storage.section.setSections([
            CommonSectionData(
                name: "Section",
                sectionID: section.sectionID.uuidString,
                creationDate: section.createdAt,
                modificationDate: nil,
                isCollapsed: false
            )
        ]))

        XCTAssertNil(DeletedSectionEntity.find(on: context, sectionID: section.sectionID))
    }

    func testResetForgetsDeletions() throws {
        addService(secret: "RESETSECRET")
        _ = try trash("RESETSECRET")
        DeletedSectionEntity.record(on: context, sectionID: UUID(), deletedAt: Date())

        storage.reset()

        XCTAssertTrue(DeletedServiceEntity.listAll(on: context).isEmpty)
        XCTAssertTrue(DeletedSectionEntity.listAll(on: context).isEmpty)
    }

    func testSectionTitleIsSealed() throws {
        storage.section.create(with: "SectionTitleMarker")
        storage.save()

        let section = try XCTUnwrap(storage.section.listAll().first)
        XCTAssertEqual(section.title, "SectionTitleMarker")
        XCTAssertNil(
            rawStoreBytes(name: Storage.storeName, in: directory).range(of: Data("SectionTitleMarker".utf8))
        )

        storage.section.update(section, with: "RenamedTitleMarker")

        XCTAssertEqual(storage.section.listAll().map(\.title), ["RenamedTitleMarker"])
        XCTAssertNil(
            rawStoreBytes(name: Storage.storeName, in: directory).range(of: Data("RenamedTitleMarker".utf8))
        )
    }

    func testSectionTitleCanNotBeReadWithAnotherKey() throws {
        storage.section.create(with: "Section")
        storage.save()

        reopenStorage(cipher: makeTestCipher())

        // The section stays – only its title can't be shown
        XCTAssertEqual(storage.section.listAll().map(\.title), [""])
    }
}

// MARK: - Browser extension data

extension StorageEncryptionTests {
    func testPairingIsSealed() throws {
        repo.createPairing(name: "PairingNameMarker", extensionID: "ExtensionIDMarker", publicKey: "PublicKeyMarker")

        let pairing = try XCTUnwrap(repo.listAllPairings().first)
        XCTAssertEqual(pairing.name, "PairingNameMarker")
        XCTAssertEqual(pairing.extensionID, "ExtensionIDMarker")
        XCTAssertEqual(pairing.publicKey, "PublicKeyMarker")
        let bytes = rawStoreBytes(name: Storage.storeName, in: directory)
        for marker in ["PairingNameMarker", "ExtensionIDMarker", "PublicKeyMarker"] {
            XCTAssertNil(bytes.range(of: Data(marker.utf8)), marker)
        }

        repo.updatePairing(pairing, name: "RenamedPairingMarker")

        let renamed = try XCTUnwrap(repo.listAllPairings().first)
        XCTAssertEqual(renamed.name, "RenamedPairingMarker")
        XCTAssertEqual(renamed.extensionID, "ExtensionIDMarker")
        XCTAssertEqual(renamed.publicKey, "PublicKeyMarker")
        XCTAssertNil(
            rawStoreBytes(name: Storage.storeName, in: directory).range(of: Data("RenamedPairingMarker".utf8))
        )
    }

    func testPairingCanNotBeReadWithAnotherKey() {
        repo.createPairing(name: "Browser", extensionID: "extension", publicKey: "key")
        XCTAssertEqual(repo.listAllPairings().count, 1)

        reopenStorage(cipher: makeTestCipher())

        XCTAssertTrue(repo.listAllPairings().isEmpty)
    }

    func testAuthRequestsAreFoundByTheSealedExtensionID() {
        repo.createAuthRequest(for: "AUTHSECRET", extensionID: "ExtensionIDMarker", domain: "a.example")
        repo.createAuthRequest(for: "AUTHSECRET", extensionID: "OtherExtensionMarker", domain: "a.example")
        repo.createAuthRequest(for: "AUTHSECRET", extensionID: "ExtensionIDMarker", domain: "b.example")

        XCTAssertEqual(
            repo.listAllAuthRequestsForExtensionID("ExtensionIDMarker").map(\.domain),
            ["a.example", "b.example"]
        )
        XCTAssertEqual(
            repo.listAllAuthRequests(for: "a.example", extensionID: "OtherExtensionMarker").map(\.extensionID),
            ["OtherExtensionMarker"]
        )
        XCTAssertTrue(repo.listAllAuthRequestsForExtensionID("extensionidmarker").isEmpty)
        let bytes = rawStoreBytes(name: Storage.storeName, in: directory)
        for marker in ["ExtensionIDMarker", "OtherExtensionMarker"] {
            XCTAssertNil(bytes.range(of: Data(marker.utf8)), marker)
        }
    }
}

// MARK: - Deletions decided by their records (sync)

extension StorageEncryptionTests {
    private static let longAgo = Date(timeIntervalSinceReferenceDate: 600_000_000)
    private var soon: Date { Date().addingTimeInterval(1000) }

    private func identifier(_ secret: String) -> Data { Data("id:\(secret.uppercased())".utf8) }

    private func synced(
        services: [String: Date] = [:],
        sections: [String: Date] = [:],
        keepsLocalOnlyItems: Bool = true
    ) -> SyncedDeletions {
        SyncedDeletions(
            services: Dictionary(uniqueKeysWithValues: services.map { (identifier($0.key), $0.value) }),
            serviceIdentifier: { self.identifier($0) },
            sections: sections,
            keepsLocalOnlyItems: keepsLocalOnlyItems
        )
    }

    private func cloud(_ secret: String, modifiedAt: Date) -> ServiceData {
        var service = cloudService(name: "Cloud \(secret)", secret: secret, order: 0)
        service = ServiceData(
            name: service.name,
            secret: service.secret,
            serviceTypeID: nil,
            additionalInfo: nil,
            rawIssuer: nil,
            modifiedAt: modifiedAt,
            createdAt: Self.longAgo,
            tokenPeriod: .period30,
            tokenLength: .digits6,
            badgeColor: nil,
            iconType: .label,
            iconTypeID: .default,
            labelColor: .default,
            labelTitle: "SE",
            algorithm: .SHA1,
            isTrashed: false,
            trashingDate: nil,
            counter: nil,
            tokenType: .totp,
            source: .manual,
            otpAuth: nil,
            order: 0,
            sectionID: nil
        )
        return service
    }

    private func captureAnnouncements() -> (created: () -> [String], deleted: () -> [String]) {
        var created: [String] = []
        var deleted: [String] = []
        storage.service.commonDidCreate = { created.append($0) }
        storage.service.commonDidDelete = { deleted.append($0) }
        return ({ created }, { deleted })
    }

    private var activeSecrets: [String] { storage.service.getAllServices().map(\.secret).sorted() }
    private var trashedSecrets: [String] { repo.listTrashedServices().map(\.secret).sorted() }

    /// What made the old sync unreliable: a service that isn't in the cloud is no longer taken for a deleted one
    func testServiceMissingInCloudWithoutDeletionIsKeptAndSent() {
        addService(secret: "KEPTSECRET")
        addService(secret: "LOCALONLYSECRET")
        let announced = captureAnnouncements()

        storage.service.setServices([cloud("KEPTSECRET", modifiedAt: soon)], deletions: synced())

        XCTAssertEqual(activeSecrets, ["KEPTSECRET", "LOCALONLYSECRET"])
        XCTAssertEqual(trashedSecrets, [])
        XCTAssertEqual(announced.created(), ["LOCALONLYSECRET"])
        XCTAssertEqual(announced.deleted(), [])
    }

    func testServiceIsDeletedOnlyByTheRecordOfItsDeletion() throws {
        addService(secret: "KEPTSECRET")
        addService(secret: "DELETEDSECRET")
        let deletedAt = soon
        let announced = captureAnnouncements()

        storage.service.setServices(
            [cloud("KEPTSECRET", modifiedAt: soon)],
            deletions: synced(services: ["DELETEDSECRET": deletedAt])
        )

        XCTAssertEqual(activeSecrets, ["KEPTSECRET"])
        XCTAssertEqual(trashedSecrets, ["DELETEDSECRET"])
        let deletion = try XCTUnwrap(DeletedServiceEntity.find(on: context, secret: "DELETEDSECRET"))
        XCTAssertEqual(deletion.deletedAt, deletedAt)
        // Known to the cloud by its identifier – the secret isn't kept with it any more
        XCTAssertEqual(deletion.syncID, identifier("DELETEDSECRET"))
        XCTAssertNil(deletion.secret)
        XCTAssertEqual(announced.created(), [])
        XCTAssertEqual(announced.deleted(), [])
    }

    func testServiceModifiedAfterItsDeletionWins() {
        addService(secret: "WINNERSECRET")
        let announced = captureAnnouncements()

        storage.service.setServices(
            [cloud("WINNERSECRET", modifiedAt: soon)],
            deletions: synced(services: ["WINNERSECRET": Self.longAgo])
        )

        XCTAssertEqual(activeSecrets, ["WINNERSECRET"])
        XCTAssertEqual(trashedSecrets, [])
        XCTAssertNil(DeletedServiceEntity.find(on: context, secret: "WINNERSECRET"))
        // The cloud is told to drop the record of the deletion
        XCTAssertEqual(announced.created(), ["WINNERSECRET"])
    }

    func testServiceInCloudOlderThanItsDeletionIsDeleted() {
        addService(secret: "LOSERSECRET")
        let announced = captureAnnouncements()

        storage.service.setServices(
            [cloud("LOSERSECRET", modifiedAt: Self.longAgo)],
            deletions: synced(services: ["LOSERSECRET": soon])
        )

        XCTAssertEqual(activeSecrets, [])
        XCTAssertEqual(trashedSecrets, ["LOSERSECRET"])
        // Its record is still in the cloud – it has to go
        XCTAssertEqual(announced.deleted(), ["LOSERSECRET"])
    }

    func testDeletionMadeHereIsSentWhenTheCloudDoesNotKnowIt() throws {
        addService(secret: "TRASHEDSECRET")
        _ = try trash("TRASHEDSECRET")
        let announced = captureAnnouncements()

        storage.service.setServices([], deletions: synced())

        XCTAssertEqual(trashedSecrets, ["TRASHEDSECRET"])
        XCTAssertEqual(announced.deleted(), ["TRASHEDSECRET"])
        XCTAssertEqual(DeletedServiceEntity.find(on: context, secret: "TRASHEDSECRET")?.secret, "TRASHEDSECRET")
    }

    func testTrashedServiceComesBackWhenTheCloudOneIsNewer() throws {
        addService(secret: "RESTOREDSECRET")
        _ = try trash("RESTOREDSECRET")

        storage.service.setServices([cloud("RESTOREDSECRET", modifiedAt: soon)], deletions: synced())

        XCTAssertEqual(activeSecrets, ["RESTOREDSECRET"])
        XCTAssertEqual(trashedSecrets, [])
        XCTAssertNil(DeletedServiceEntity.find(on: context, secret: "RESTOREDSECRET"))
    }

    func testTrashedServiceStaysDeletedWhenTheCloudOneIsOlder() throws {
        addService(secret: "STAYSSECRET")
        _ = try trash("STAYSSECRET")
        let announced = captureAnnouncements()

        storage.service.setServices([cloud("STAYSSECRET", modifiedAt: Self.longAgo)], deletions: synced())

        XCTAssertEqual(activeSecrets, [])
        XCTAssertEqual(trashedSecrets, ["STAYSSECRET"])
        XCTAssertEqual(announced.deleted(), ["STAYSSECRET"])
    }

    /// The cloud knew the deletion and doesn't have it any more: it was undone on another device
    func testDeletionUndoneElsewhereIsForgotten() throws {
        addService(secret: "UNDONESECRET")
        repo.deleteService(try trash("UNDONESECRET"))
        let deletion = try XCTUnwrap(DeletedServiceEntity.find(on: context, secret: "UNDONESECRET"))
        deletion.syncID = identifier("UNDONESECRET")
        deletion.encryptedContent = nil
        let announced = captureAnnouncements()

        storage.service.setServices([], deletions: synced())

        XCTAssertNil(DeletedServiceEntity.find(on: context, secret: "UNDONESECRET"))
        XCTAssertEqual(announced.deleted(), [])
    }

    func testLaterDeletionFromCloudReplacesTheLocalDate() throws {
        addService(secret: "TWICESECRET")
        _ = try trash("TWICESECRET")
        let later = soon

        storage.service.setServices([], deletions: synced(services: ["TWICESECRET": later]))

        XCTAssertEqual(DeletedServiceEntity.find(on: context, secret: "TWICESECRET")?.deletedAt, later)
        XCTAssertEqual(trashedSecrets, ["TWICESECRET"])
    }

    /// The watch only mirrors the cloud: what isn't there goes, and nothing is sent
    func testMirrorRemovesWhatTheCloudDoesNotHave() {
        addService(secret: "KEPTSECRET")
        addService(secret: "LOCALONLYSECRET")
        let announced = captureAnnouncements()

        storage.service.setServices(
            [cloud("KEPTSECRET", modifiedAt: soon)],
            deletions: synced(keepsLocalOnlyItems: false)
        )

        XCTAssertEqual(activeSecrets, ["KEPTSECRET"])
        XCTAssertEqual(announced.created(), [])
        XCTAssertEqual(announced.deleted(), [])
    }

    // MARK: Sections

    private func cloudSection(_ section: SectionData, name: String? = nil, modifiedAt: Date?) -> CommonSectionData {
        CommonSectionData(
            name: name ?? section.title,
            sectionID: section.sectionID.uuidString,
            creationDate: section.createdAt,
            modificationDate: modifiedAt,
            isCollapsed: false
        )
    }

    func testSectionMissingInCloudWithoutDeletionIsKeptAndSent() throws {
        storage.section.create(with: "Kept")
        storage.section.create(with: "Local only")
        let sections = storage.section.listAll()
        let kept = try XCTUnwrap(sections.first { $0.title == "Kept" })
        let localOnly = try XCTUnwrap(sections.first { $0.title == "Local only" })
        var created: [String] = []
        storage.section.commonDidCreate = { created.append($0) }

        storage.section.setSections([cloudSection(kept, modifiedAt: nil)], deletions: synced())

        XCTAssertEqual(storage.section.listAll().map(\.title).sorted(), ["Kept", "Local only"])
        XCTAssertEqual(created, [localOnly.sectionID.uuidString])
        XCTAssertTrue(DeletedSectionEntity.listAll(on: context).isEmpty)
    }

    func testSectionIsDeletedOnlyByTheRecordOfItsDeletion() throws {
        storage.section.create(with: "Kept")
        storage.section.create(with: "Deleted")
        let sections = storage.section.listAll()
        let kept = try XCTUnwrap(sections.first { $0.title == "Kept" })
        let deleted = try XCTUnwrap(sections.first { $0.title == "Deleted" })
        let deletedAt = soon

        storage.section.setSections(
            [cloudSection(kept, modifiedAt: nil)],
            deletions: synced(sections: [deleted.sectionID.uuidString: deletedAt])
        )

        XCTAssertEqual(storage.section.listAll().map(\.title), ["Kept"])
        XCTAssertEqual(DeletedSectionEntity.find(on: context, sectionID: deleted.sectionID)?.deletedAt, deletedAt)
    }

    func testSectionModifiedAfterItsDeletionWins() throws {
        storage.section.create(with: "Section")
        let section = try XCTUnwrap(storage.section.listAll().first)
        var created: [String] = []
        storage.section.commonDidCreate = { created.append($0) }

        storage.section.setSections(
            [cloudSection(section, name: "Renamed", modifiedAt: soon)],
            deletions: synced(sections: [section.sectionID.uuidString: Self.longAgo])
        )

        XCTAssertEqual(storage.section.listAll().map(\.title), ["Renamed"])
        XCTAssertNil(DeletedSectionEntity.find(on: context, sectionID: section.sectionID))
        XCTAssertEqual(created, [section.sectionID.uuidString])
    }

    func testSectionDeletionMadeHereIsSentWhenTheCloudDoesNotKnowIt() throws {
        storage.section.create(with: "Section")
        let section = try XCTUnwrap(storage.section.listAll().first)
        storage.section.delete(section)
        var deleted: [String] = []
        storage.section.commonDidDelete = { deleted.append($0) }

        storage.section.setSections([], deletions: synced())

        XCTAssertEqual(deleted, [section.sectionID.uuidString])
        XCTAssertNotNil(DeletedSectionEntity.find(on: context, sectionID: section.sectionID))
    }
}

/// A cipher whose key can't be used now
private final class UnusableCipher: LocalStorageCipher {
    var state: LocalStorageCipherState { .keyUnavailable }
    func seal(_ plaintext: Data, associatedData: Data) throws -> Data { throw LocalStorageCipherError.keyUnavailable }
    func open(_ sealed: Data, associatedData: Data) throws -> Data { throw LocalStorageCipherError.keyUnavailable }
    func lookupHash(for value: String, context: String) throws -> Data { throw LocalStorageCipherError.keyUnavailable }
    func prepareForWriting() throws { throw LocalStorageCipherError.keyUnavailable }
}
