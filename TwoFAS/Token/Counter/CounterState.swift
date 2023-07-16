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

final class CounterState {
    let secret: Secret
    private var counter: Int
    private let digits: Digits
    private let algorithm: Algorithm
    
    private var isRefreshCounterLocked = false
    private(set) var isUnlocked = false
    private var lockCounter: Int
    private(set) var currentToken: TokenValue?
    private var consumers: [Weak] = []
    
    init(secret: Secret, counter: Int, digits: Digits, algorithm: Algorithm) {
        self.secret = secret
        self.counter = counter
        self.digits = digits
        self.algorithm = algorithm
        lockCounter = Int(TokenType.hotpRefreshLockTime)
    }
    
    func start(startTime: Date?, counter: Int?) {
        guard let startTime, let counter else { return }
        self.counter = counter
        isUnlocked = true
        let difference = -Date().timeIntervalSince1970 + startTime.timeIntervalSince1970 + TokenType.hotpRefreshLockTime
        lockCounter = Int(difference)
        checkCounter()
        updateToken()
    }
    
    func tick() {
        guard isRefreshCounterLocked else { return }
        updateCounter()
        checkCounter()
        if !isRefreshCounterLocked {
            updateConsumersProgress()
        }
    }
    
    func removeConsumerIfPresent(_ consumer: TokenCounterConsumer) {
        cleanUnusedConsumers()
        guard let index = consumers.firstIndex(where: { $0.value?.hashValue == consumer.hashValue }) else { return }
        consumers.remove(at: index)
    }
    
    func removeAllConsumers() {
        consumers.removeAll { $0.value?.autoManagable == true }
    }
    
    func registerConsumer(_ consumer: TokenCounterConsumer) {
        cleanUnusedConsumers()
        consumers.append(Weak(value: consumer))
        consumer.setInitial(currentState)
    }
    
    func unlock(with counter: Int) {
        self.counter = counter
        startCounter()
    }
    
    func lock() {
        isUnlocked = false
        isRefreshCounterLocked = false
        lockCounter = Int(TokenType.hotpRefreshLockTime)
        currentToken = nil
    }
    
    // MARK: - Private
    
    private func startCounter() {
        isUnlocked = true
        isRefreshCounterLocked = true
        lockCounter = Int(TokenType.hotpRefreshLockTime)
        
        updateToken()
        updateConsumersProgress()
    }
    
    private func updateToken() {
        currentToken = TokenGenerator.generateHOTP(
            secret: secret,
            counter: counter,
            digits: digits,
            algoritm: algorithm
        )
    }
    
    private func updateCounter() {
        lockCounter -= 1
    }
    
    private func checkCounter() {
        isRefreshCounterLocked = lockCounter > 0
        
        if !isRefreshCounterLocked {
            lockCounter = Int(TokenType.hotpRefreshLockTime)
        }
    }
    
    private func updateConsumersProgress() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let state = self.currentState
            for c in self.consumers {
                guard let cons = c.value else { continue }
                cons.setUpdate(state)
            }
        }
    }
    
    private func cleanUnusedConsumers() {
        consumers = consumers.filter { $0.hasObject }
    }
    
    private var currentState: TokenCounterConsumerState {
        guard isUnlocked else {
            return .locked
        }
        return .unlocked(isRefreshLocked: isRefreshCounterLocked, currentToken: currentToken ?? "")
    }
}

private final class Weak {
    private(set) weak var value: TokenCounterConsumer?
    init (value: TokenCounterConsumer) {
        self.value = value
    }
    var hasObject: Bool { value != nil }
}
