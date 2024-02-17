//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

import SwiftUI
import UIKit
import AppIntents
import Protection
import TimeVerification
import Common
import Data

struct CopyTokenIntent: AppIntent {
    static var title = LocalizedStringResource("widget__token")
    
    @Parameter(title: "Secret")
    var secret: String
    
    @Parameter(title: "Period")
    var period: Int
    
    @Parameter(title: "Digits")
    var digits: Int
    
    @Parameter(title: "Algorithm")
    var algorithm: String
    
    @Parameter(title: "TokenType")
    var tokenType: String
    
    @ObservedObject
    private var generator = Generator()
    
    init() {}
    
    init(secret: String, period: Int, digits: Int, algorithm: String, tokenType: String) {
        self.secret = secret
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
        self.tokenType = tokenType
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        generator.generate(
            secret: $secret.wrappedValue,
            period: period,
            digits: digits,
            algorithm: algorithm,
            tokenType: tokenType
        )
        let token = generator.token
        let defaults = UserDefaults(suiteName: Config.suiteName)!
        defaults.set(token, forKey: Config.exchangeTokenKey)
        defaults.synchronize()
        
        return .result()
    }
    
    static var openAppWhenRun = true
}

@available(iOSApplicationExtension, unavailable)
extension CopyTokenIntent: ForegroundContinuableIntent { }

private final class Generator: ObservableObject {
    @Published var token: String = ""
    
    func generate(secret: String, period: Int, digits: Int, algorithm: String, tokenType: String) {
        let currentDate = Date()
        let correctedDate = currentDate + Double(TimeOffsetStorage.offset ?? 0)
        
        token = TokenGenerator.generateTOTP(
            secret: secret,
            time: correctedDate,
            period: Period.create(period),
            digits: Digits.create(digits),
            algoritm: Algorithm.create(algorithm),
            tokenType: TokenType.create(tokenType)
        )
    }
}
