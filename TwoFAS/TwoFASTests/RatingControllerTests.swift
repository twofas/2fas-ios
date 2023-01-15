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

final class RatingControllerTests: XCTestCase {
    
    func testShouldNotShowBefore14days() {
        
        let result = RatingController.shouldShowRating(
            runTimes: 100, firstRunDaysAgo: 13, lastPresentedDaysAgo: 100, presentedCount: 100
        )
        XCTAssertFalse(result)
    }
    
    func testShouldShowAfter14DaysMoreThan10runs() {
        
        let result = RatingController.shouldShowRating(
            runTimes: 100, firstRunDaysAgo: 14, lastPresentedDaysAgo: 0, presentedCount: 0
        )
        XCTAssertTrue(result)
    }
    
    func testShouldShowAfter30DaysLessThan10runs() {
        
        let result = RatingController.shouldShowRating(
            runTimes: 9, firstRunDaysAgo: 30, lastPresentedDaysAgo: 0, presentedCount: 0
        )
        XCTAssertTrue(result)
    }
    
    func testShouldNotShowAfter40Days2Presentation() {
        
        let result = RatingController.shouldShowRating(
            runTimes: 9, firstRunDaysAgo: 40, lastPresentedDaysAgo: 0, presentedCount: 2
        )
        XCTAssertFalse(result)
    }
    
    func testShouldShowAfter50Days2Presentation() {
        
        let result = RatingController.shouldShowRating(
            runTimes: 9, firstRunDaysAgo: 51, lastPresentedDaysAgo: 14, presentedCount: 2
        )
        XCTAssertTrue(result)
    }
    
    func testShouldShowAfter2PresentationAnd180DaysFromLastPresentation() {
        
        let result = RatingController.shouldShowRating(
            runTimes: 9, firstRunDaysAgo: 180, lastPresentedDaysAgo: 181, presentedCount: 5
        )
        XCTAssertTrue(result)
    }
}
