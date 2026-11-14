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
import Common
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
}
