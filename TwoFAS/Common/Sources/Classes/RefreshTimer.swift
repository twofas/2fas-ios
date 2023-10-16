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

public protocol RefreshTimerType: AnyObject {
    var timerTicked: RefreshTimerCallback? { get set }
    func start()
    func stop()
}

public typealias RefreshTimerCallback = () -> Void

public final class RefreshTimer: RefreshTimerType {
    public var timerTicked: RefreshTimerCallback?

    public init() {}
    
    let timeInterval: TimeInterval = 1
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
        t.setEventHandler(handler: { [weak self] in
            
            self?.timerTicked?()
        })
        return t
    }()

    private enum State {
        case stopped
        case started
    }

    private var state: State = .stopped

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        start()
        timerTicked = nil
    }

    public func start() {
        if state == .started { return }
        
        state = .started
        timer.resume()
    }

    public func stop() {
        if state == .stopped { return }
        
        state = .stopped
        timer.suspend()
    }
}
