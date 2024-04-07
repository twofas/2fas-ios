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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public final class TimeVerificationController {
    private let timeVerificator: TimeVerificator
    
    private var isTimeValid = true
    public private(set) var offset: Int = 0
    
    public var offsetUpdated: ((Int) -> Void)?
    public var currentDate: Date { Date() + TimeInterval(offset) }
    public var log: ((String) -> Void)?
    
    public init() {
        timeVerificator = TimeVerificator(allowedInterval: Config.allowedTimeIntervalDifference)
        timeVerificator.savedTimeOffset = { [weak self] in self?.savedTimeOffset(isValid: $0, offset: $1) }
        timeVerificator.fetchedTimeOffset = { [weak self] in self?.fetchedTimeOffset(isValid: $0, offset: $1) }
        timeVerificator.cantFetchOffset = { [weak self] in self?.cantFetchOffset() }
    }
    
    public func startVerification() {
        log?("Starting time verification")
        timeVerificator.verify()
    }
    
    private func savedTimeOffset(isValid: Bool, offset: Int) {
        guard !isValid else {
            log?("Saved time offset is valid")
            timeIsValid()
            return
        }
        isTimeValid = false
        self.offset = offset
        offsetUpdated?(offset)
        log?("Saved time offset is invalid: \(offset)")
    }
    
    private func fetchedTimeOffset(isValid: Bool, offset: Int) {
        log?("Fetched time offset \(offset), isValid: \(isValid), isTimeValid: \(isTimeValid)")
        switch (isTimeValid, isValid) {
        case (true, true): return
        case (false, true):
            timeIsValid()
            isTimeValid = true
            self.offset = 0
            offsetUpdated?(0)
        case (true, false):
            isTimeValid = false
            self.offset = offset
            offsetUpdated?(offset)
        case (false, false):
            if (self.offset - offset) > Config.allowedTimeIntervalDifference {
                self.offset = offset
                offsetUpdated?(offset)
            }
        }
    }
    
    private func cantFetchOffset() {
        log?("Can't fetch offset, isTimeValid \(isTimeValid)")
    }
    
    private func timeIsValid() {
        log?("Time is valid")
    }
}
