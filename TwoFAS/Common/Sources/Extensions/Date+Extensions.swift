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

import Foundation

public extension Date {
    func secondsTillNextChange(with period: Int) -> Int {
        period - (seconds % period)
    }
        
    var seconds: Int {
        let calendar = Calendar.current
        return calendar.component(.second, from: self)
    }
    
    func minutes(to date: Date) -> Int {
        let secondsSelf = self.timeIntervalSince1970
        let secondsDate = date.timeIntervalSince1970
        
        return Int((secondsDate - secondsSelf) / 60.0)
    }
    
    func days(from date: Date) -> Int {
        let firstDate = self.extractDatePart()
        let secondDate = date.extractDatePart()
        
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!

        guard let days = cal.dateComponents([.day], from: firstDate, to: secondDate).day else { return 0 }
        
        return abs(days)
    }
    
    func extractDatePart() -> Date {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let year = cal.component(.year, from: self)
        let month = cal.component(.month, from: self)
        let day = cal.component(.day, from: self)
        let era = cal.component(.era, from: self)
        
        let dateWithoutTime = DateComponents(
            calendar: cal,
            timeZone: cal.timeZone,
            era: era,
            year: year,
            month: month,
            day: day
        )
        
        return cal.date(from: dateWithoutTime) ?? self
    }
    
    func extractYear() -> Int {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let year = cal.component(.year, from: self)
        return year
    }
    
    var isOlderThanTwoMonths: Bool {
        guard let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: Date()) else {
            return false
        }
        return self < twoMonthsAgo
    }
}
