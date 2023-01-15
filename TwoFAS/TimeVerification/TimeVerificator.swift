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
import Kronos

public final class TimeVerificator {
    private let allowedInterval: Int
    
    public typealias TimeOffset = (Bool, Int) -> Void
    
    public var savedTimeOffset: TimeOffset?
    public var fetchedTimeOffset: TimeOffset?
    public var cantFetchOffset: (() -> Void)?
    
    public init(allowedInterval: Int) {
        self.allowedInterval = allowedInterval
    }
    
    public func verify() {
        var offsetTooLarge = false
        let savedOffset = TimeOffsetStorage.offset
        
        if let savedOffset, abs(savedOffset) > allowedInterval {
            offsetTooLarge = true
            savedTimeOffset?(false, savedOffset)
        } else {
            savedTimeOffset?(true, 0)
        }
        
        Clock.sync(samples: 1, completion: { [weak self] _, timeInterval in
            guard let timeInterval else {
                self?.cantFetchOffset?()
                return
            }
            
            let timeIntervalInt = Int(timeInterval)
            
            guard let self, abs(timeIntervalInt) > self.allowedInterval else {
                TimeOffsetStorage.clearOffset()
                if offsetTooLarge {
                    self?.fetchedTimeOffset?(true, 0)
                }
                return
            }
            
            TimeOffsetStorage.setOffset(offset: timeIntervalInt)
            self.fetchedTimeOffset?(false, timeIntervalInt)
        })
    }
}
