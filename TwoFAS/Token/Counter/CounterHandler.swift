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

public enum TokenCounterConsumerState {
    case locked
    case unlocked(isRefreshLocked: Bool, currentToken: TokenValue)
}

public protocol TokenCounterConsumer: AnyObject {
    func setInitial(_ state: TokenCounterConsumerState)
    func setUpdate(_ state: TokenCounterConsumerState)
    // swiftlint:disable legacy_hashing
    var hashValue: Int { get }
    // swiftlint:enable legacy_hashing
    var secret: String { get }
    var didTapRefreshCounter: ((Secret) -> Void)? { get set }
    var autoManagable: Bool { get }
}

public protocol CounterHandlerStart {
    func start(with counterSecrets: [CounterSecret], startLocked: Bool)
}

public protocol CounterHandlerTokens {
    func register(_ consumer: TokenCounterConsumer)
    func remove(_ consumer: TokenCounterConsumer, lock: Bool)
    func token(for secret: Secret) -> TokenValue?
    func unlock(for secret: Secret, counter: Int)
    func lockAllConsumers()
}

public protocol CounterHandlerStop {
    func stop()
}

public final class CounterHandler: CounterHandlerStart & CounterHandlerTokens & CounterHandlerStop {
    private let cal = Calendar.current
    private let storage = CounterStartStorage()
    
    private let timer: RefreshTimer
    private var tokens: [CounterState]
    private var seconds: Int?
    
    init() {
        timer = RefreshTimer()
        tokens = []
        
        timer.timerTicked = { [weak self] in self?.tick() }
    }
    
    public func register(_ consumer: TokenCounterConsumer) {
        guard let counterState = counterState(for: consumer.secret) else { return }
        
        counterState.registerConsumer(consumer)
    }
    
    public func remove(_ consumer: TokenCounterConsumer, lock: Bool) {
        guard let counterState = counterState(for: consumer.secret) else { return }
        
        counterState.removeConsumerIfPresent(consumer)
        
        if lock {
            storage.remove(for: consumer.secret)
            counterState.lock()
        }
    }
    
    public func start(with counterSecrets: [CounterSecret], startLocked: Bool) {
        seconds = nil
        
        var currentTokens = tokens
        let newSecrets = counterSecrets.map({ $0.secret })
        
        tokens.forEach { ts in
            if newSecrets.contains(ts.secret) {
                ts.removeAllConsumers()
            } else {
                currentTokens.removeAll(where: { $0.secret == ts.secret })
            }
        }
        
        let currentSecrets = currentTokens.map({ $0.secret })
        
        counterSecrets.forEach { ts in
            if !currentSecrets.contains(ts.secret) {
                currentTokens.append(
                    CounterState(secret: ts.secret, counter: ts.counter, digits: ts.digits, algorithm: ts.algorithm)
                )
            }
        }
        
        tokens = currentTokens
        if startLocked {
            tokens.forEach({ $0.lock() })
            storage.removeAll()
        }
        
        restartTokens()
        
        timer.start()
    }
    
    public func stop() {
        seconds = nil
        timer.stop()
        tokens.removeAll()
    }
    
    public func token(for secret: Secret) -> TokenValue? {
        counterState(for: secret)?.currentToken
    }
    
    public func unlock(for secret: Secret, counter: Int) {
        storage.register(for: secret, counter: counter)
        counterState(for: secret)?.unlock(with: counter)
    }
    
    public func lockAllConsumers() {
        storage.removeAll()
        tokens.forEach({
            $0.removeAllConsumers()
            $0.lock()
        })
    }
    
    // MARK: - Private
    
    func restartTokens() {
        tokens.forEach {
            if let value = storage.find(for: $0.secret) {
                $0.start(startTime: value.date, counter: value.counter) }
            }
        seconds = Date().seconds
    }
    
    private func counterState(for secret: Secret) -> CounterState? {
        tokens.first(where: { $0.secret == secret })
    }
    
    private func tick() {
        let currentTime = Date()
        
        // Don't call "tick" in same second as "start" otherwise counter will count two times
        if let sec = seconds {
            if sec == currentTime.seconds {
                return
            } else {
                seconds = nil
            }
        }
        
        tokens.forEach { $0.tick() }
    }
}

final class CounterStartStorage {
    typealias CounterInTime = (date: Date, counter: Int)
    private var dict: [Secret: CounterInTime] = [:]
    
    func register(for secret: Secret, counter: Int) {
        dict[secret] = (Date(), counter)
    }
    
    func find(for secret: Secret) -> CounterInTime? {
        dict[secret]
    }
    
    func remove(for secret: Secret) {
        dict[secret] = nil
    }
    
    func removeAll() {
        dict = [:]
    }
}
