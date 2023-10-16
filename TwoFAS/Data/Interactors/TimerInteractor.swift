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

import UIKit
import Common

public protocol TimerInteracting: AnyObject {
    var timerTicked: Callback? { get set }
    
    func destroy()
    func pause()
    func start()
    func setTickEverySecond(seconds: Int)
}

final class TimerInteractor {
    private var timer: Timer?
    private var isDestroyed = false
    private var isRunning = false
    
    var timerTicked: Callback?
    private(set) var tickTime: Int = 1
        
    init() {
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    func setTickEverySecond(seconds: Int) {
        tickTime = seconds
    }
    
    @objc
    private func applicationDidBecomeActive() {
        if isRunning {
            startTimer()
        }
    }
    
    @objc
    private func applicationDidEnterBackground() {
        clearTimer()
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

extension TimerInteractor: TimerInteracting {
    func destroy() {
        isDestroyed = true
        isRunning = false
        clearTimer()
    }
    
    func pause() {
        isRunning = false
        clearTimer()
    }
    
    func start() {
        isRunning = true
        startTimer()
    }
}

private extension TimerInteractor {
    func clearTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: Double(tickTime), repeats: true, block: { [weak self] timer in
            guard let self, !self.isDestroyed else {
                timer.invalidate()
                return
            }
            
            guard self.isRunning else { return }
            
            self.timerTicked?()
        })
    }
}
