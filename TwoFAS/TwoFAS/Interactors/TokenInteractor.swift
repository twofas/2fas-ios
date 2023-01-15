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
import Token
import Common

protocol TokenInteracting: AnyObject {
    func startTimer(_ tokenConsumer: TokenTimerConsumer)
    func stopTimer(_ tokenConsumer: TokenTimerConsumer)
    func stopTimers()
    
    func enableCounter(_ counterConsumer: TokenCounterConsumer)
    func disableCounter(_ counterConsumer: TokenCounterConsumer)
    func unlockCounter(for secret: String)
    
    func registerTOTP(_ consumer: TokenTimerConsumer)
    func removeTOTP(_ consumer: TokenTimerConsumer)
    func registerHOTP(_ consumer: TokenCounterConsumer)
    func removeHOTP(_ consumer: TokenCounterConsumer)
    
    func TOTPToken(for secret: Secret) -> (current: TokenValue, next: TokenValue, willChangeSoon: Bool)?
    func HOTPToken(for secret: Secret) -> TokenValue?
    
    func start(timedSecrets: [TimedSecret], counterSecrets: [CounterSecret])
}

final class TokenInteractor {
    private let timerHandler: TimerHandlerTokens & TimerHandlerStart & TimerHandlerStop
    private let counterHandler: CounterHandlerTokens & CounterHandlerStart & CounterHandlerStop
    private let serviceInteractor: ServiceModifyInteracting
    
    init(mainRepository: MainRepository, serviceInteractor: ServiceModifyInteracting) {
        timerHandler = mainRepository.timerHandler
        counterHandler = mainRepository.counterHandler
        self.serviceInteractor = serviceInteractor
    }
}

extension TokenInteractor: TokenInteracting {
    // MARK: - TOTP
    func startTimer(_ tokenConsumer: TokenTimerConsumer) {
        timerHandler.register(tokenConsumer)
    }
    
    func stopTimer(_ tokenConsumer: TokenTimerConsumer) {
        timerHandler.remove(tokenConsumer)
    }
    
    func TOTPToken(for secret: Secret) -> (current: TokenValue, next: TokenValue, willChangeSoon: Bool)? {
        timerHandler.token(for: secret)
    }
    
    func stopTimers() {
        timerHandler.stop()
    }
    
    // MARK: - HOTP
    
    func enableCounter(_ counterConsumer: TokenCounterConsumer) {
        counterHandler.register(counterConsumer)
    }
    
    func disableCounter(_ counterConsumer: TokenCounterConsumer) {
        counterHandler.remove(counterConsumer)
    }
    
    func unlockCounter(for secret: String) {
        guard
            let service = serviceInteractor.service(for: secret),
            let counter = service.counter
        else { return }
        serviceInteractor.incrementCounter(for: secret)
        
        counterHandler.unlock(for: secret, counter: counter + 1)
    }
    
    func HOTPToken(for secret: Secret) -> TokenValue? {
        counterHandler.token(for: secret)
    }
    
    // MARK: - Registration
    
    func registerTOTP(_ consumer: TokenTimerConsumer) {
        timerHandler.register(consumer)
    }
    
    func removeTOTP(_ consumer: TokenTimerConsumer) {
        timerHandler.remove(consumer)
    }
    
    func registerHOTP(_ consumer: TokenCounterConsumer) {
        counterHandler.register(consumer)
    }
    
    func removeHOTP(_ consumer: TokenCounterConsumer) {
        counterHandler.remove(consumer)
    }
    
    func start(timedSecrets: [TimedSecret], counterSecrets: [CounterSecret]) {
        timerHandler.start(with: timedSecrets)
        counterHandler.start(with: counterSecrets)
    }
}
