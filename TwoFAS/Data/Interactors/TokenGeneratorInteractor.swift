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

public protocol TokenGeneratorInteracting: AnyObject {
    func generateToken(for secret: String) -> String?
}

final class TokenGeneratorInteractor {
    private let mainRepository: MainRepository
    private let serviceInteractor: ServiceModifyInteracting
    
    init(mainRepository: MainRepository, serviceInteractor: ServiceModifyInteracting) {
        self.mainRepository = mainRepository
        self.serviceInteractor = serviceInteractor
    }
}

extension TokenGeneratorInteractor: TokenGeneratorInteracting {
    func generateToken(for secret: String) -> String? {
        guard let serviceData = serviceInteractor.service(for: secret) else { return nil }
        if serviceData.tokenType == .hotp {
            serviceInteractor.incrementCounter(for: secret)
        }
        let counter: Int = {
            guard serviceData.tokenType == .hotp else { return TokenType.hotpDefaultValue }
            if let counter = serviceData.counter {
                return counter + 1
            }
            return TokenType.hotpDefaultValue
        }()
        return mainRepository.token(
            secret: serviceData.secret,
            time: mainRepository.currentDate,
            digits: Digits(rawValue: serviceData.digits) ?? .defaultValue,
            period: Period(rawValue: serviceData.period) ?? .defaultValue,
            algorithm: serviceData.algorithm,
            counter: counter,
            tokenType: serviceData.tokenType
        )
    }
}
