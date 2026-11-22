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
