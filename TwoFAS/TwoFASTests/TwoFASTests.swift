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
@testable import TwoFAS
import Common

final class TwoFASTests: XCTestCase {
    private let major = 75
    private let minor = 45
    private let fix = 3
    
    func testVersionStringInvalid() {
        
        let str = "test.swift"
        
        XCTAssertNil(str.splitVersion())
    }
    
    func testVersionStringOneValueNoDot() {
        
        let str = "75"
        let value = str.splitVersion()
        XCTAssertNotNil(value)
        
        XCTAssertEqual(value!, VersionDecoded(major: major, minor: 0, fix: 0))
    }
    
    func testVersionStringOneValueOneDot() {
        
        let str = "75."
        let value = str.splitVersion()
        XCTAssertNotNil(value)
        XCTAssertEqual(value!, VersionDecoded(major: major, minor: 0, fix: 0))
    }
    
    func testVersionStringTwoValues() {
        
        let str = "75.45"
        let value = str.splitVersion()
        XCTAssertNotNil(value)
        XCTAssertEqual(value!, VersionDecoded(major: major, minor: minor, fix: 0))
    }
    
    func testVersionStringThreeValues() {
        
        let str = "75.45.3"
        let value = str.splitVersion()
        XCTAssertNotNil(value)
        XCTAssertEqual(value!, VersionDecoded(major: major, minor: minor, fix: fix))
    }
}
