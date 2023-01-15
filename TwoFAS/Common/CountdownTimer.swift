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

public final class CountdownTimer {
    public typealias Tick = (Int) -> Void
    public typealias TimerFinished = () -> Void
    
    private let timer: RefreshTimerType
    
    private var counter: Int = 0
    private var isRunning = false
    
    public var tick: Tick?
    public var timerFinished: TimerFinished?
    
    public init() {
        timer = RefreshTimer()
        timer.timerTicked = { [weak self] in self?.timerTicked() }
    }
    
    public func start(with count: Int) {
        if isRunning {
            countdownZero()
        }
        // swiftlint:disable empty_count
        guard count > 0 else {
            Log("Count has to be > 0", module: .counter)
            return
        }
        // swiftlint:enable empty_count
        counter = count
        isRunning = true
        timer.start()
    }
    
    public func stop() {
        stopTimer()
    }
    
    private func timerTicked() {
        guard isRunning else {
            timer.stop()
            return
        }
        counter -= 1
        tick?(counter)
        if counter <= 0 {
            countdownZero()
        }
    }
    
    private func stopTimer() {
        isRunning = false
        timer.stop()
    }
    
    private func countdownZero() {
        stopTimer()
        timerFinished?()
    }
    
    deinit {
        timer.stop()
    }
}
