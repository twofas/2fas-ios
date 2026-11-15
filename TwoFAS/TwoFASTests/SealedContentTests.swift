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

    // MARK: - Schema

    private func json(_ plaintext: Data) throws -> [String: Any] {
        try XCTUnwrap(try JSONSerialization.jsonObject(with: plaintext) as? [String: Any])
    }

    func testContentIsSealedWithItsSchemaVersion() throws {
        let cipher = makeTestCipher()
        let sealed = try codec.seal(makeContent(), hashes: [h1], cipher: cipher)
        let plaintext = try cipher.open(sealed, associatedData: codec.associatedData(hashes: [h1]))

        let object = try json(plaintext)
        XCTAssertEqual(object["v"] as? Int, 1)
        XCTAssertEqual(object["secret"] as? String, "JBSWY3DPEHPK3PXP")
    }

    func testContentOfNewerSchemaIsRejected() {
        let plaintext = Data(#"{"v":2,"secret":"S","name":"N","labelTitle":"L","iconTypeID":"\#(UUID().uuidString)"}"#.utf8)

        XCTAssertThrowsError(try codec.decode(plaintext)) { error in
            guard case SealedEntity.Failure.unsupportedContentVersion(2) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    /// Frozen samples of what released versions sealed. A failure here means that rows already stored on devices
    /// stop decoding – a new field has to be optional (or the schema needs a new version with its own decoding).
    /// Never edit a sample to make the test pass; add a sample when the schema changes.
    func testFrozenServiceContentSamplesDecode() throws {
        let serviceTypeID = "0F6B6C3A-6D3C-4A63-9C39-3A1B5D2E7F10"
        let iconTypeID = "5B1F7B56-0E7A-4D5A-8C68-6F1C0D2A9E41"
        let full = #"""
        {"v":1,"secret":"JBSWY3DPEHPK3PXP","name":"Account","additionalInfo":"info","rawIssuer":"Issuer",\#
        "otpAuth":"otpauth://totp/x","labelTitle":"AC","serviceTypeID":"\#(serviceTypeID)",\#
        "iconTypeID":"\#(iconTypeID)"}
        """#
        // Without the optional fields and without the version (sealed before it was written)
        let minimal = #"{"secret":"JBSWY3DPEHPK3PXP","name":"Account","labelTitle":"AC","iconTypeID":"\#(iconTypeID)"}"#

        XCTAssertEqual(
            try codec.decode(Data(full.utf8)),
            ServiceSensitiveContent(
                secret: "JBSWY3DPEHPK3PXP",
                name: "Account",
                additionalInfo: "info",
                rawIssuer: "Issuer",
                otpAuth: "otpauth://totp/x",
                labelTitle: "AC",
                serviceTypeID: UUID(uuidString: serviceTypeID),
                iconTypeID: try XCTUnwrap(UUID(uuidString: iconTypeID))
            )
        )
        XCTAssertEqual(
            try codec.decode(Data(minimal.utf8)),
            ServiceSensitiveContent(
                secret: "JBSWY3DPEHPK3PXP",
                name: "Account",
                additionalInfo: nil,
                rawIssuer: nil,
                otpAuth: nil,
                labelTitle: "AC",
                serviceTypeID: nil,
                iconTypeID: try XCTUnwrap(UUID(uuidString: iconTypeID))
            )
        )
    }
}
