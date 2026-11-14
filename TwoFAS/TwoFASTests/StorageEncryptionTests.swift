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
