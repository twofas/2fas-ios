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

protocol ComposeServiceAdvancedEditModuleInteracting: AnyObject {
    var tokenType: TokenType { get }
    var algorithm: Algorithm { get }
    var refreshTime: Period { get }
    var numberOfDigits: Digits { get }
    var counter: Int { get }
    
    var valueTokenType: TokenType? { get }
    var valueAlgorithm: Algorithm? { get }
    var valueRefreshTime: Period? { get }
    var valueNumberOfDigits: Digits? { get }
    var valueCounter: Int? { get }
    
    var settings: ComposeServiceAdvancedSettings { get }
    
    func setTokenType(_ tokenType: TokenType)
    func setAlgorithm(_ algorithm: Algorithm)
    func setRefreshTime(_ refreshTime: Period)
    func setNumberOfDigits(_ numberOfDigits: Digits)
    func setCounter(_ counter: Int)
}

final class ComposeServiceAdvancedEditModuleInteractor {
    private(set) var valueTokenType: TokenType?
    private(set) var valueAlgorithm: Algorithm?
    private(set) var valueRefreshTime: Period?
    private(set) var valueNumberOfDigits: Digits?
    private(set) var valueCounter: Int?
        
    init(settings: ComposeServiceAdvancedSettings) {        
        valueTokenType = settings.tokenType
        valueAlgorithm = settings.algorithm
        valueRefreshTime = settings.period
        valueNumberOfDigits = settings.digits
        valueCounter = settings.counter
    }
}

extension ComposeServiceAdvancedEditModuleInteractor: ComposeServiceAdvancedEditModuleInteracting {
    var tokenType: TokenType {
        valueTokenType ?? .defaultValue
    }
    
    var algorithm: Algorithm {
        valueAlgorithm ?? .defaultValue
    }
    
    var refreshTime: Period {
        valueRefreshTime ?? .defaultValue
    }
    
    var numberOfDigits: Digits {
        valueNumberOfDigits ?? .defaultValue
    }
    
    var counter: Int {
        valueCounter ?? TokenType.hotpDefaultValue
    }
    
    var settings: ComposeServiceAdvancedSettings {
        if let tokenType = valueTokenType, tokenType == .hotp {
            return .init(
                tokenType: valueTokenType,
                algorithm: nil,
                period: nil,
                digits: valueNumberOfDigits,
                counter: valueCounter
            )
        }
        return .init(
            tokenType: valueTokenType,
            algorithm: valueAlgorithm,
            period: valueRefreshTime,
            digits: valueNumberOfDigits,
            counter: nil
            )
    }
    
    func setTokenType(_ newTokenType: TokenType) {
        valueTokenType = newTokenType
    }
    
    func setAlgorithm(_ newAlgorithm: Algorithm) {
        valueAlgorithm = newAlgorithm
    }
    
    func setRefreshTime(_ newRefreshTime: Period) {
        valueRefreshTime = newRefreshTime
    }
    
    func setNumberOfDigits(_ newNumberOfDigits: Digits) {
        valueNumberOfDigits = newNumberOfDigits
    }
    
    func setCounter(_ newCounter: Int) {
        valueCounter = newCounter
    }
}
