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
@testable import Protection

final class SystemKeychainItemStoreTests: XCTestCase {
    private let store = SystemKeychainItemStore()
    private var account: String!

    override func setUp() {
        super.setUp()
        account = "test.\(UUID().uuidString)"
    }

    override func tearDown() {
        store.remove(account: account)
        account = nil
        super.tearDown()
    }

    func testAddReadRemoveRoundTrip() throws {
        let data = Data("value".utf8)

        try store.add(data, account: account)
        XCTAssertEqual(try store.read(account: account), data)

        store.remove(account: account)
        XCTAssertNil(try store.read(account: account))
    }

    func testReadMissingReturnsNil() throws {
        XCTAssertNil(try store.read(account: account))
    }

    func testItemIsDeviceOnlyAndNotSynchronizable() throws {
        try store.add(Data([1]), account: account)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Config.keychain,
            kSecAttrAccount as String: account,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?

        XCTAssertEqual(SecItemCopyMatching(query as CFDictionary, &result), errSecSuccess)
        let attributes = try XCTUnwrap(result as? [String: Any])
        XCTAssertEqual(
            attributes[kSecAttrAccessible as String] as? String,
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        )
        XCTAssertEqual(attributes[kSecAttrSynchronizable as String] as? Bool ?? false, false)
    }
}
