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
    
    private var counter: Int
    private(set) var willChangeSoon = false
    private(set) var currentToken: TokenValue = ""
    private(set) var nextToken: TokenValue = ""
    private var consumers: [Weak] = []
    
    init(secret: Secret, period: Period, digits: Digits, algorithm: Algorithm) {
        self.secret = secret
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
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
    
    func registerConsumer(_ consumer: TokenTimerConsumer) {
        cleanUnusedConsumers()
        consumers.append(Weak(value: consumer))
        consumer.setInitial(
            counter,
            period: period.rawValue,
            currentToken: currentToken,
            nextToken: nextToken,
            willChangeSoon: willChangeSoon
        )
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
            algoritm: algorithm
        )
        let nextChange = currentTime.secondsTillNextChange(with: period.rawValue)
        nextToken = TokenGenerator.generateTOTP(
            secret: secret,
            time: currentTime + Double(nextChange) + 1.0,
            period: period,
            digits: digits,
            algoritm: algorithm
        )
    }
    
    private func updateConsumersProgress(plannedUpdate: Bool) {
        for c in self.consumers {
            guard let cons = c.value else { continue }
            cons.setUpdate(
                counter,
                isPlanned: plannedUpdate,
                currentToken: currentToken,
                nextToken: nextToken,
                willChangeSoon: willChangeSoon
            )
        }
    }
    
    private func cleanUnusedConsumers() {
        consumers = consumers.filter({ $0.hasObject })
    }
}

private final class Weak {
    private(set) weak var value: TokenTimerConsumer?
    init (value: TokenTimerConsumer) {
        self.value = value
    }
    var hasObject: Bool { value != nil }
}
