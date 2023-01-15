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
import Common

public protocol TokenTimerConsumer: AnyObject {
    func setInitial(
        _ progress: Int,
        period: Int,
        currentToken: TokenValue,
        nextToken: TokenValue,
        willChangeSoon: Bool
    )
    func setUpdate(
        _ progress: Int,
        isPlanned: Bool,
        currentToken: TokenValue,
        nextToken: TokenValue,
        willChangeSoon: Bool
    )
    // swiftlint:disable legacy_hashing
    var hashValue: Int { get }
    // swiftlint:enable legacy_hashing
    var secret: String { get }
    var autoManagable: Bool { get }
}

public protocol TimerHandlerStart {
    func start(with timedSecret: [TimedSecret])
}

public protocol TimerHandlerTokens {
    func register(_ consumer: TokenTimerConsumer)
    func remove(_ consumer: TokenTimerConsumer)
    func token(for secret: Secret) -> (current: TokenValue, next: TokenValue, willChangeSoon: Bool)?
}

public protocol TimerHandlerStop {
    func stop()
}

public final class TimerHandler: TimerHandlerStart & TimerHandlerTokens & TimerHandlerStop {
    private let cal = Calendar.current
    
    private let timer: RefreshTimer
    private var tokens: [TokenState]
    private var seconds: Int?
    
    private var offset: Int = 0
    private var isStarted = false
    
    private var currentTime: Date {
        let time = Date()
        return cal.date(byAdding: .second, value: offset, to: time) ?? time
    }
    
    init() {
        timer = RefreshTimer()
        tokens = []
        
        timer.timerTicked = { [weak self] in
            guard let self else { return }
            self.tick()
        }
    }
    
    public func register(_ consumer: TokenTimerConsumer) {
        guard let tokenState = tokenState(for: consumer.secret) else { return }
        
        tokenState.registerConsumer(consumer)
    }
    
    public func remove(_ consumer: TokenTimerConsumer) {
        guard let tokenState = tokenState(for: consumer.secret) else { return }
        
        tokenState.removeConsumerIfPresent(consumer)
    }
    
    public func start(with timedSecret: [TimedSecret]) {
        seconds = nil
        
        var currentTokens = tokens
        let newSecrets = timedSecret.map({ $0.secret })
        
        tokens.forEach { ts in
            if newSecrets.contains(ts.secret) {
                ts.removeAllConsumers()
            } else {
                currentTokens.removeAll(where: { $0.secret == ts.secret })
            }
        }
        
        let currentSecrets = currentTokens.map({ $0.secret })
        
        timedSecret.forEach { ts in
            if !currentSecrets.contains(ts.secret) {
                currentTokens.append(
                    TokenState(secret: ts.secret, period: ts.period, digits: ts.digits, algorithm: ts.algorithm)
                )
            }
        }
        
        tokens = currentTokens
        
        restartTokens()
        
        timer.start()
        isStarted = true
    }
    
    public func restartTokens() {
        let currentTime = self.currentTime
        tokens.forEach { $0.start(currentTime: currentTime) }
        seconds = currentTime.seconds
    }
    
    public func setOffset(offset: Int) {
        self.offset = offset
        if isStarted {
            restartTokens()
        }
    }
    
    public func stop() {
        isStarted = false
        seconds = nil
        timer.stop()
        tokens.removeAll()
    }
    
    public func token(for secret: Secret) -> (current: TokenValue, next: TokenValue, willChangeSoon: Bool)? {
        guard let tokenState = tokenState(for: secret) else { return nil }
        return (current: tokenState.currentToken, next: tokenState.nextToken, willChangeSoon: tokenState.willChangeSoon)
    }
    
    // MARK: - Private
    
    private func tokenState(for secret: Secret) -> TokenState? {
        guard let tokenState = tokens.first(where: { $0.secret == secret }) else { return nil }
        
        return tokenState
    }
    
    private func tick() {
        let currentTime = self.currentTime
        
        // Don't call "tick" in same second as "start" otherwise counter will count two times
        if let sec = seconds {
            if sec == currentTime.seconds {
                return
            } else {
                seconds = nil
            }
        }
        DispatchQueue.main.async {
            self.tokens.forEach { $0.tick(currentTime: currentTime) }
        }
    }
}
