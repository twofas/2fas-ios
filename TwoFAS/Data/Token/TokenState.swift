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

final class TokenState {
    let secret: Secret
    private let period: Period
    private let digits: Digits
    private let algorithm: Algorithm
    private let tokenType: TokenType
    
    private var counter: Int
    private(set) var willChangeSoon = false
    private(set) var currentToken: TokenValue = ""
    private(set) var nextToken: TokenValue = ""
    private var consumers: [Weak] = []
    
    init(secret: Secret, period: Period, digits: Digits, algorithm: Algorithm, tokenType: TokenType) {
        self.secret = secret
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
        self.tokenType = tokenType
        counter = period.rawValue
    }
    
    func start(currentTime: Date) {
        counter = currentTime.secondsTillNextChange(with: period.rawValue)
        updateMarked()
        updateToken(currentTime: currentTime)
    }
    
    func tick(currentTime: Date) {
        counter -= 1
        
        let shouldUpdateToken = counter == 0
        
        if shouldUpdateToken {
            counter = period.rawValue
            updateToken(currentTime: currentTime)
        }
        updateMarked()
        updateConsumersProgress(plannedUpdate: true)
    }
    
    func removeConsumerIfPresent(_ consumer: TokenTimerConsumer) {
        cleanUnusedConsumers()
        guard let index = consumers.firstIndex(where: { $0.value?.hashValue == consumer.hashValue }) else { return }
        consumers.remove(at: index)
    }
    
    func removeAllConsumers() {
        consumers.removeAll(where: { $0.value?.autoManagable == true })
    }
    
    func registerConsumer(_ consumer: TokenTimerConsumer, isLocked: Bool) {
        cleanUnusedConsumers()
        consumers.append(Weak(value: consumer, isLocked: isLocked))
        if isLocked {
            consumer.setInitial(.locked)
        } else {
            setInitalUnlocked(consumer)
        }
    }
    
    func unlockConsumer(_ consumer: TokenTimerConsumer) {
        guard
            let consumerInstance = consumers.first(where: { $0.value?.hashValue == consumer.hashValue }),
            let consumerValue = consumerInstance.value
        else {
            registerConsumer(consumer, isLocked: false)
            return
        }
        consumerInstance.unlock()
        setInitalUnlocked(consumerValue)
    }
    
    func lockAllConsumers() {
        consumers.forEach({
            $0.lock()
            $0.value?.setUpdate(.locked)
        })
    }
    
    private func setInitalUnlocked(_ consumer: TokenTimerConsumer) {
        consumer.setInitial(.unlocked(
            progress: counter,
            period: period.rawValue,
            currentToken: currentToken,
            nextToken: nextToken,
            tokenType: tokenType,
            willChangeSoon: willChangeSoon
        ))
    }
    
    private func updateMarked() {
        willChangeSoon = counter <= Config.TokenConsts.formatTimerWhenSecondsOrLess + 1
    }
    
    private func updateToken(currentTime: Date) {
        currentToken = TokenGenerator.generateTOTP(
            secret: secret,
            time: currentTime,
            period: period,
            digits: digits,
            algoritm: algorithm,
            tokenType: tokenType
        )
        let nextChange = currentTime.secondsTillNextChange(with: period.rawValue)
        nextToken = TokenGenerator.generateTOTP(
            secret: secret,
            time: currentTime + Double(nextChange) + 1.0,
            period: period,
            digits: digits,
            algoritm: algorithm,
            tokenType: tokenType
        )
    }
    
    private func updateConsumersProgress(plannedUpdate: Bool) {
        for c in self.consumers {
            guard let cons = c.value else { continue }
            if c.isLocked {
                cons.setUpdate(.locked)
            } else {
                cons.setUpdate(.unlocked(
                    progress: counter,
                    isPlanned: plannedUpdate,
                    currentToken: currentToken,
                    nextToken: nextToken,
                    tokenType: tokenType,
                    willChangeSoon: willChangeSoon
                ))
            }
        }
    }
    
    private func cleanUnusedConsumers() {
        consumers = consumers.filter({ $0.hasObject })
    }
}

private final class Weak {
    private(set) weak var value: TokenTimerConsumer?
    private(set) var isLocked: Bool
    init(value: TokenTimerConsumer, isLocked: Bool = true) {
        self.value = value
        self.isLocked = isLocked
    }
    var hasObject: Bool { value != nil }
    func unlock() {
        isLocked = false
    }
    func lock() {
        isLocked = true
    }
}
