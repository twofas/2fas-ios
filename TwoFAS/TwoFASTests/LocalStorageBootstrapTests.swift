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
@testable import Common

private final class FakeCipherAdmin: LocalStorageCipherAdmin {
    var state: LocalStorageCipherState
    private(set) var createKeyCount = 0
    private(set) var discardCount = 0
    var createKeyError: Error?

    init(state: LocalStorageCipherState) {
        self.state = state
    }

    func seal(_ plaintext: Data, associatedData: Data) throws -> Data { throw LocalStorageCipherError.noKey }
    func open(_ sealed: Data, associatedData: Data) throws -> Data { throw LocalStorageCipherError.noKey }
    func lookupHash(for value: String, context: String) throws -> Data { throw LocalStorageCipherError.noKey }
    func prepareForWriting() throws { throw LocalStorageCipherError.noKey }

    func createKeyIfNeeded() throws {
        createKeyCount += 1
        if let createKeyError { throw createKeyError }
    }

    func discardLostKey() {
        discardCount += 1
        state = .noKey
    }
}

final class LocalStorageBootstrapTests: XCTestCase {
    private var directory: URL!
    private let storeNames = ["TwoFAS", "Sync"]
    private let files = ["TwoFAS.sqlite", "TwoFAS.sqlite-wal", "Sync.sqlite"]

    override func setUp() {
        super.setUp()
        directory = makeTemporaryDirectory()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    private func createFiles() {
        for file in files {
            FileManager.default.createFile(atPath: directory.appendingPathComponent(file).path, contents: Data([1]))
        }
    }

    private var counterDefaults: UserDefaults!
    private var counterSuiteName: String!

    private func makeCounter() -> LostKeyLaunchCounter {
        if counterDefaults == nil {
            counterSuiteName = "test.\(UUID().uuidString)"
            counterDefaults = UserDefaults(suiteName: counterSuiteName)
            addTeardownBlock { [counterDefaults, counterSuiteName] in
                counterDefaults?.removePersistentDomain(forName: counterSuiteName ?? "")
            }
        }
        return LostKeyLaunchCounter(defaults: counterDefaults)
    }

    /// The main app: launches are counted and the stores are asked for sealed data
    private func prepareCounting(
        _ cipher: FakeCipherAdmin,
        requiringMigration: [String] = [],
        hasSealedData: Bool = true,
        sealedDataOpens: Bool = true,
        countsLaunch: Bool = true
    ) -> LocalStorageBootstrapResult {
        LocalStorageBootstrap.prepare(
            cipher: cipher,
            storeNames: storeNames,
            storesRequiringMigration: requiringMigration,
            hasSealedData: { hasSealedData },
            sealedDataOpens: { sealedDataOpens },
            lostKeyCounter: makeCounter(),
            countsLaunch: countsLaunch,
            directory: directory
        )
    }

    private func existingFiles() -> [String] {
        files.filter { FileManager.default.fileExists(atPath: directory.appendingPathComponent($0).path) }
    }

    private func prepare(
        _ cipher: FakeCipherAdmin,
        requiringMigration: [String] = [],
        incompatible: [String] = []
    ) -> LocalStorageBootstrapResult {
        LocalStorageBootstrap.prepare(
            cipher: cipher,
            storeNames: storeNames,
            storesRequiringMigration: requiringMigration,
            incompatibleStoreNames: incompatible,
            directory: directory
        )
    }

    func testKeyLostWipesAllStoresAndDiscardsKey() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)

        XCTAssertEqual(prepare(cipher), .wipedStores)
        XCTAssertEqual(existingFiles(), [])
        XCTAssertEqual(cipher.discardCount, 1)
        XCTAssertEqual(cipher.createKeyCount, 0)
    }

    func testKeyUnavailableTouchesNothing() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyUnavailable)

        XCTAssertEqual(prepare(cipher), .ready)
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(cipher.discardCount, 0)
        XCTAssertEqual(cipher.createKeyCount, 0)
    }

    func testNoKeyWithExistingStoreWithoutMigrationDoesNotCreateKey() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .noKey)

        XCTAssertEqual(prepare(cipher), .ready)
        XCTAssertEqual(cipher.createKeyCount, 0)
        XCTAssertEqual(existingFiles(), files)
    }

    func testNoKeyWithStoreRequiringMigrationCreatesKey() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .noKey)

        XCTAssertEqual(prepare(cipher, requiringMigration: ["TwoFAS"]), .ready)
        XCTAssertEqual(cipher.createKeyCount, 1)
        XCTAssertEqual(existingFiles(), files)
    }

    func testNoKeyWithoutStoresDoesNotCreateKey() {
        let cipher = FakeCipherAdmin(state: .noKey)

        XCTAssertEqual(prepare(cipher), .ready)
        XCTAssertEqual(cipher.createKeyCount, 0)
    }

    func testNoKeyCreateKeyFailureDoesNotChangeResult() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .noKey)
        cipher.createKeyError = LocalStorageCipherError.noKey

        XCTAssertEqual(prepare(cipher, requiringMigration: ["TwoFAS"]), .ready)
        XCTAssertEqual(cipher.createKeyCount, 1)
        XCTAssertEqual(existingFiles(), files)
    }

    func testAvailableIsNoop() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .available)

        XCTAssertEqual(prepare(cipher), .ready)
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(cipher.discardCount, 0)
        XCTAssertEqual(cipher.createKeyCount, 0)
    }

    func testIncompatibleStoresAreWipedEvenWithKey() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .available)

        XCTAssertEqual(prepare(cipher, incompatible: ["TwoFAS"]), .wipedStores)
        XCTAssertEqual(existingFiles(), [])
        XCTAssertEqual(cipher.discardCount, 0)
    }

    func testIncompatibleStoresWithLostKeyDiscardKey() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)

        XCTAssertEqual(prepare(cipher, incompatible: ["TwoFAS"]), .wipedStores)
        XCTAssertEqual(existingFiles(), [])
        XCTAssertEqual(cipher.discardCount, 1)
    }

    // MARK: - Lost key with a launch counter

    func testLostKeyKeepsStoresUntilTheThirdLaunch() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)

        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 2))
        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 1))
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(cipher.discardCount, 0)

        XCTAssertEqual(prepareCounting(cipher), .wipedStores)
        XCTAssertEqual(existingFiles(), [])
        XCTAssertEqual(cipher.discardCount, 1)
        XCTAssertEqual(makeCounter().count, 0)
    }

    func testRepeatedChecksInOneLaunchAreNotCounted() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)

        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 2))
        for _ in 0..<5 {
            XCTAssertEqual(prepareCounting(cipher, countsLaunch: false), .keyLostPending(launchesLeft: 2))
        }
        XCTAssertEqual(existingFiles(), files)
    }

    /// A push or a background refresh: whatever the key store answers and however many times, nothing is
    /// counted and nothing is removed
    func testLaunchesInTheBackgroundNeverCountOrRemove() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)

        for _ in 0..<10 {
            XCTAssertEqual(prepareCounting(cipher, countsLaunch: false), .keyLostPending(launchesLeft: 3))
        }
        XCTAssertEqual(makeCounter().count, 0)
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(cipher.discardCount, 0)
    }

    /// The counter at the threshold already (left by an interrupted launch): still only a launch opened by the
    /// user removes the stores
    func testCounterAtTheThresholdDoesNotRemoveInTheBackground() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)
        let counter = makeCounter()
        (0..<LostKeyLaunchCounter.wipeThreshold + 2).forEach { _ in counter.increment() }

        XCTAssertEqual(prepareCounting(cipher, countsLaunch: false), .keyLostPending(launchesLeft: 1))
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(cipher.discardCount, 0)

        XCTAssertEqual(prepareCounting(cipher), .wipedStores)
        XCTAssertEqual(existingFiles(), [])
    }

    /// Two launches by the user with background launches in between: the third launch by the user removes
    func testBackgroundLaunchesBetweenUserLaunchesAreIgnored() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)

        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 2))
        XCTAssertEqual(prepareCounting(cipher, countsLaunch: false), .keyLostPending(launchesLeft: 2))
        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 1))
        XCTAssertEqual(prepareCounting(cipher, countsLaunch: false), .keyLostPending(launchesLeft: 1))
        XCTAssertEqual(prepareCounting(cipher, countsLaunch: false), .keyLostPending(launchesLeft: 1))
        XCTAssertEqual(existingFiles(), files)

        XCTAssertEqual(prepareCounting(cipher), .wipedStores)
    }

    /// Keychain that can't be used never leads to removing anything, however many launches
    func testUnavailableKeyNeverRemoves() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyUnavailable)

        for _ in 0..<10 {
            XCTAssertEqual(prepareCounting(cipher), .ready)
        }
        XCTAssertEqual(makeCounter().count, 0)
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(cipher.discardCount, 0)
    }

    // MARK: - A key that doesn't open the stored data

    func testKeyThatDoesNotOpenTheDataIsHandledLikeALostOne() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .available)

        XCTAssertEqual(prepareCounting(cipher, sealedDataOpens: false), .keyLostPending(launchesLeft: 2))
        XCTAssertEqual(prepareCounting(cipher, sealedDataOpens: false), .keyLostPending(launchesLeft: 1))
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(cipher.discardCount, 0)

        XCTAssertEqual(prepareCounting(cipher, sealedDataOpens: false), .wipedStores)
        XCTAssertEqual(existingFiles(), [])
        // The key goes with the stores – a new one is created for the new data
        XCTAssertEqual(cipher.discardCount, 1)
        XCTAssertEqual(makeCounter().count, 0)
    }

    func testKeyThatDoesNotOpenTheDataNeverRemovesInTheBackground() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .available)

        for _ in 0..<10 {
            XCTAssertEqual(
                prepareCounting(cipher, sealedDataOpens: false, countsLaunch: false),
                .keyLostPending(launchesLeft: 3)
            )
        }
        XCTAssertEqual(makeCounter().count, 0)
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(cipher.discardCount, 0)
    }

    func testDataThatOpensAgainResetsTheCounter() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .available)
        XCTAssertEqual(prepareCounting(cipher, sealedDataOpens: false), .keyLostPending(launchesLeft: 2))

        XCTAssertEqual(prepareCounting(cipher, sealedDataOpens: true), .ready)
        XCTAssertEqual(makeCounter().count, 0)
        XCTAssertEqual(existingFiles(), files)
    }

    /// The watch and the extensions: no counter, the check isn't made
    func testWithoutACounterTheDataIsNotChecked() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .available)

        let result = LocalStorageBootstrap.prepare(
            cipher: cipher,
            storeNames: storeNames,
            sealedDataOpens: {
                XCTFail("Not asked without a counter")
                return false
            },
            directory: directory
        )
        XCTAssertEqual(result, .ready)
        XCTAssertEqual(existingFiles(), files)
    }

    func testKeyFoundAgainResetsTheCounter() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)
        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 2))
        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 1))

        cipher.state = .available
        XCTAssertEqual(prepareCounting(cipher), .ready)
        XCTAssertEqual(makeCounter().count, 0)

        cipher.state = .keyLost
        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 2))
        XCTAssertEqual(existingFiles(), files)
    }

    func testUnavailableKeyDoesNotCount() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)
        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 2))

        cipher.state = .keyUnavailable
        XCTAssertEqual(prepareCounting(cipher), .ready)
        XCTAssertEqual(makeCounter().count, 1)
        XCTAssertEqual(existingFiles(), files)
    }

    func testLostKeyWithoutSealedDataOnlyDiscardsTheKey() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .keyLost)

        XCTAssertEqual(prepareCounting(cipher, requiringMigration: ["TwoFAS"], hasSealedData: false), .ready)
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(cipher.discardCount, 1)
        // The stores still wait for the migration, which seals the data
        XCTAssertEqual(cipher.createKeyCount, 1)
    }

    func testSealedDataWithoutKeyIDIsALostKey() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .noKey)

        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 2))
        XCTAssertEqual(prepareCounting(cipher), .keyLostPending(launchesLeft: 1))
        XCTAssertEqual(cipher.createKeyCount, 0)
        XCTAssertEqual(existingFiles(), files)

        XCTAssertEqual(prepareCounting(cipher), .wipedStores)
        XCTAssertEqual(existingFiles(), [])
    }

    func testNoKeyWithoutSealedDataIsReady() {
        createFiles()
        let cipher = FakeCipherAdmin(state: .noKey)

        XCTAssertEqual(prepareCounting(cipher, hasSealedData: false), .ready)
        XCTAssertEqual(existingFiles(), files)
        XCTAssertEqual(makeCounter().count, 0)
    }

    func testResetLocalDataRemovesStoresInAnyState() {
        for state in [LocalStorageCipherState.keyLost, .keyUnavailable, .noKey, .available] {
            createFiles()
            let cipher = FakeCipherAdmin(state: state)
            makeCounter().increment()

            LocalStorageBootstrap.resetLocalData(
                cipher: cipher,
                storeNames: storeNames,
                lostKeyCounter: makeCounter(),
                directory: directory
            )

            XCTAssertEqual(existingFiles(), [], "\(state)")
            XCTAssertEqual(cipher.discardCount, 1, "\(state)")
            XCTAssertEqual(makeCounter().count, 0, "\(state)")
        }
    }
}
