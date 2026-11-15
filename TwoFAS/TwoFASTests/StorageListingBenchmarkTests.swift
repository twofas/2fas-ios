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
@testable import Protection
@testable import Storage

final class StorageListingBenchmarkTests: XCTestCase {
    private var directory: URL!
    private var storage: Storage!
    
    override func setUp() {
        super.setUp()
        directory = makeTemporaryDirectory()
        storage = Storage(
            storeDirectory: directory,
            initializeLogStorage: false,
            cipher: makeTestCipher(),
            allowsMigration: true,
            logError: nil
        )
        seed(count: 500)
    }
    
    override func tearDown() {
        closeStores(of: storage.coreDataStack)
        storage = nil
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        super.tearDown()
    }
    
    func testListWithPhraseWarm() {
        let repo = storage.storageRepository
        XCTAssertFalse(repo.listAllWithingCategories(for: "ser", sorting: .az, ids: []).allServices.isEmpty)
        measure {
            _ = repo.listAllWithingCategories(for: "ser", sorting: .az, ids: [])
        }
    }
    
    func testListWithPhraseCold() {
        let repo = storage.storageRepository
        XCTAssertFalse(repo.listAllWithingCategories(for: "ser", sorting: .az, ids: []).allServices.isEmpty)
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            storage.coreDataStack.context.reset()
            startMeasuring()
            _ = repo.listAllWithingCategories(for: "ser", sorting: .az, ids: [])
            stopMeasuring()
        }
    }
    
    /// Import of 500 new services into a store that already holds 500 (fresh store per iteration)
    func testImportOf500ServicesIsFast() {
        var durations: [TimeInterval] = []
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let importDirectory = makeTemporaryDirectory()
            let importStorage = Storage(
                storeDirectory: importDirectory,
                initializeLogStorage: false,
                cipher: makeTestCipher(),
                allowsMigration: true,
                logError: nil
            )
            seed(count: 500, in: importStorage)
            let services = makeImportedServices(count: 500)
            let start = Date()
            startMeasuring()
            let added = importStorage.service.addNonexistentServices(services)
            stopMeasuring()
            durations.append(Date().timeIntervalSince(start))
            XCTAssertEqual(added, 500)
            closeStores(of: importStorage.coreDataStack)
            try? FileManager.default.removeItem(at: importDirectory)
        }
        XCTAssertLessThan(durations.reduce(0, +) / Double(durations.count), 2)
    }
    
    func testCountNewServicesOf500IsFast() {
        let services = makeImportedServices(count: 500)
        var durations: [TimeInterval] = []
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            let start = Date()
            startMeasuring()
            let count = storage.service.countNewServices(from: services)
            stopMeasuring()
            durations.append(Date().timeIntervalSince(start))
            XCTAssertEqual(count, 500)
        }
        XCTAssertLessThan(durations.reduce(0, +) / Double(durations.count), 2)
    }
    
    private func makeImportedServices(count: Int) -> [ServiceData] {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
        let date = Date()
        return (0..<count).map { i in
            ServiceData(
                name: "Imported \(i)",
                secret: String((0..<32).map { _ in alphabet.randomElement()! }),
                serviceTypeID: nil,
                additionalInfo: i.isMultiple(of: 5) ? nil : "imported\(i)@example.com",
                rawIssuer: nil,
                modifiedAt: date,
                createdAt: date,
                tokenPeriod: .period30,
                tokenLength: .digits6,
                badgeColor: nil,
                iconType: .label,
                iconTypeID: .default,
                labelColor: .default,
                labelTitle: "I\(i % 10)",
                algorithm: .SHA1,
                isTrashed: false,
                trashingDate: nil,
                counter: nil,
                tokenType: .totp,
                source: .link,
                otpAuth: nil,
                order: nil,
                sectionID: nil
            )
        }
    }
    
    private func seed(count: Int) {
        seed(count: count, in: storage)
    }
    
    private func seed(count: Int, in storage: Storage) {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
        for i in 0..<count {
            let secret = String((0..<32).map { _ in alphabet.randomElement()! })
            _ = storage.storageRepository.addService(
                name: "Service \(i)",
                secret: secret,
                serviceTypeID: nil,
                additionalInfo: i.isMultiple(of: 5) ? nil : "user\(i)@example.com",
                rawIssuer: nil,
                otpAuth: nil,
                tokenPeriod: .period30,
                tokenLength: .digits6,
                badgeColor: nil,
                iconType: .label,
                iconTypeID: .default,
                labelColor: .default,
                labelTitle: "S\(i % 10)",
                algorithm: .SHA1,
                counter: nil,
                tokenType: .totp,
                source: .manual
            )
        }
        storage.save()
    }
}
