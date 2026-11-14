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

import XCTest
import CoreData
@testable import Common
@testable import Protection

final class SealedContentTests: XCTestCase {
    private let codec = SealedContentCodec<ServiceSensitiveContent>(entityName: "ServiceEntity")
    private let h1 = Data([1, 2, 3])
    private let h2 = Data([4, 5])

    private func makeContent() -> ServiceSensitiveContent {
        ServiceSensitiveContent(
            secret: "JBSWY3DPEHPK3PXP",
            name: "Account",
            additionalInfo: "info",
            rawIssuer: "Issuer",
            otpAuth: "otpauth://totp/x",
            labelTitle: "Label",
            serviceTypeID: UUID(),
            iconTypeID: UUID()
        )
    }

    func testRoundTrip() throws {
        let cipher = makeTestCipher()
        let content = makeContent()
        let sealed = try codec.seal(content, hashes: [h1, h2], cipher: cipher)
        XCTAssertEqual(try codec.open(sealed, hashes: [h1, h2], cipher: cipher), content)
    }

    func testAssociatedDataLayout() {
        XCTAssertEqual(
            codec.associatedData(hashes: [h1, h2]),
            Data("2fas.ServiceEntity.v1".utf8) + h1 + h2
        )
    }

    func testOpenWithDifferentHashesFails() throws {
        let cipher = makeTestCipher()
        let sealed = try codec.seal(makeContent(), hashes: [h1, h2], cipher: cipher)
        XCTAssertThrowsError(try codec.open(sealed, hashes: [h2, h1], cipher: cipher))
    }

    func testOpenWithOtherEntityNameFails() throws {
        let cipher = makeTestCipher()
        let sealed = try codec.seal(makeContent(), hashes: [h1], cipher: cipher)
        let other = SealedContentCodec<ServiceSensitiveContent>(entityName: "OtherEntity")
        XCTAssertThrowsError(try other.open(sealed, hashes: [h1], cipher: cipher))
    }

    func testCacheHitsOnlyForIdenticalSealedBytes() {
        let cache = SealedContentCache<ServiceSensitiveContent>()
        let content = makeContent()
        let s1 = Data([1, 1, 1])
        let s2 = Data([2, 2, 2])
        cache.store(content, sealed: s1)
        XCTAssertEqual(cache.content(forSealed: s1), content)
        XCTAssertNil(cache.content(forSealed: s2))
    }

    func testCacheClear() {
        let cache = SealedContentCache<ServiceSensitiveContent>()
        let s1 = Data([1])
        cache.store(makeContent(), sealed: s1)
        cache.clear()
        XCTAssertNil(cache.content(forSealed: s1))
    }

    func testContextCarriesCipher() {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        XCTAssertNil(context.localStorageCipher)
        let cipher = makeTestCipher()
        context.setLocalStorageCipher(cipher)
        XCTAssertTrue(context.localStorageCipher === cipher)
    }
}
