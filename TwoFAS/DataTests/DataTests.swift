//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

import Foundation
import XCTest
@testable import Data
import Common

final class TOTPTests: XCTestCase {
    private let totpSecret8Bytes = "VQ6WL2PLUD5FI"
    private let totpSecret16Bytes = "44PZQ72RCU6LAJOKJT5XQHGVRQ"
    
    func testTotpTokenSha1() {
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret8Bytes,
                time: Date(timeIntervalSince1970: 1234567890), // in seconds
                digits: .digits6,
                period: .period30,
                algorithm: .SHA1,
                counter: 0,
                tokenType: .totp
            ),
            "555404"
        )
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret8Bytes,
                time: Date(timeIntervalSince1970: 1234567899),
                digits: .digits6,
                period: .period30,
                algorithm: .SHA1,
                counter: 20708,
                tokenType: .totp
            ),
            "555404"
        )
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret8Bytes,
                time: Date(timeIntervalSince1970: 821941200),
                digits: .digits6,
                period: .period30,
                algorithm: .SHA1,
                counter: 0,
                tokenType: .totp
            ),
            "889943"
        )
    }
    
    func testTotpTokenSha224() {
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret8Bytes,
                time: Date(timeIntervalSince1970: 1702184400),
                digits: .digits7,
                period: .period60,
                algorithm: .SHA224,
                counter: 0,
                tokenType: .totp
            ),
            "5912242"
        )
    }
    
    func testTotpTokenSha256() {
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret8Bytes,
                time: Date(timeIntervalSince1970: 1702184400),
                digits: .digits8,
                period: .period90,
                algorithm: .SHA256,
                counter: 0,
                tokenType: .totp
            ),
            "94444231"
        )
    }
    
    func testTotpToken384() {
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret8Bytes,
                time: Date(timeIntervalSince1970: 821941200),
                digits: .digits5,
                period: .period30,
                algorithm: .SHA384,
                counter: 0,
                tokenType: .totp
            ),
            "44314"
        )
    }
    
    func testTotpTokenSha512() {
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret8Bytes,
                time: Date(timeIntervalSince1970: 821941200),
                digits: .digits6,
                period: .period30,
                algorithm: .SHA512,
                counter: 0,
                tokenType: .totp
            ),
            "818620"
        )
    }
    
    func testTotpTokenMd5() {
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret16Bytes,
                time: Date(timeIntervalSince1970: 821941200),
                digits: .digits8,
                period: .period30,
                algorithm: .MD5,
                counter: 0,
                tokenType: .totp
            ),
            "52723142"
        )
    }
    
    func testTotpTokenSteam() {
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret16Bytes,
                time: Date(timeIntervalSince1970: 1234567890), // in seconds
                digits: .digits5,
                period: .period30,
                algorithm: .SHA1,
                counter: 0,
                tokenType: .steam
            ),
            "WT8XD"
        )
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret16Bytes,
                time: Date(timeIntervalSince1970: 1234567899),
                digits: .digits5,
                period: .period30,
                algorithm: .SHA1,
                counter: 5000,
                tokenType: .steam
            ),
            "WT8XD"
        )
        XCTAssertEqual(
            TokenHandler.generateToken(
                secret: totpSecret16Bytes,
                time: Date(timeIntervalSince1970: 821941200),
                digits: .digits5,
                period: .period30,
                algorithm: .SHA1,
                counter: 0,
                tokenType: .steam
            ),
            "H7M5F"
        )
    }
}
