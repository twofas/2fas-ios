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

final class DateTests: XCTestCase {
    
    private let dateFormatter = ISO8601DateFormatter()
    
    func testExtractingDatesMiddleOfDay() {
        
        let firstDate = dateFormatter.date(from: "2018-01-17T00:00:00Z+00:00")!
        let secondDate = dateFormatter.date(from: "2018-01-17T12:15:42Z+00:00")!
        
        let secondDateWithoutTime = secondDate.extractDatePart()
        
        XCTAssertEqual(firstDate, secondDateWithoutTime)
    }
    
    func testExtractingDatesBegginingOfTheDay() {
        
        let firstDate = dateFormatter.date(from: "2018-01-17T00:00:00Z+00:00")!
        let secondDate = dateFormatter.date(from: "2018-01-17T00:00:00Z+00:00")!
        
        let secondDateWithoutTime = secondDate.extractDatePart()
        
        XCTAssertEqual(firstDate, secondDateWithoutTime)
    }
    
    func testExtractingDatesEndOfDay() {
        
        let firstDate = dateFormatter.date(from: "2018-01-17T00:00:00Z+00:00")!
        let secondDate = dateFormatter.date(from: "2018-01-17T23:59:59Z+00:00")!
        
        let secondDateWithoutTime = secondDate.extractDatePart()
        
        XCTAssertEqual(firstDate, secondDateWithoutTime)
    }
    
    func testCalculateDaysMiddleOfSameDay() {
        
        let firstDate = dateFormatter.date(from: "2018-01-17T18:00:00Z+00:00")!.extractDatePart()
        let secondDate = dateFormatter.date(from: "2018-01-17T12:15:42Z+00:00")!.extractDatePart()
        
        let days = firstDate.days(from: secondDate)
        
        XCTAssertEqual(days, 0)
    }
    
    func testCalculateDaysOneDay() {
        
        let firstDate = dateFormatter.date(from: "2018-01-16T18:00:00Z+00:00")!.extractDatePart()
        let secondDate = dateFormatter.date(from: "2018-01-17T12:15:42Z+00:00")!.extractDatePart()
        
        let days = firstDate.days(from: secondDate)
        
        XCTAssertEqual(days, 1)
    }
    
    func testCalculateDays366() {
        
        let firstDate = dateFormatter.date(from: "2017-01-16T11:00:00Z+00:00")!.extractDatePart()
        let secondDate = dateFormatter.date(from: "2018-01-17T12:15:42Z+00:00")!.extractDatePart()
        
        let days = firstDate.days(from: secondDate)
        
        XCTAssertEqual(days, 366)
    }
}
