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

/// A `Token` contains a password generator and information identifying the corresponding account.
struct Token: Equatable {
    /// A string indicating the account represented by the token.
    /// This is often an email address or username.
    let name: String

    /// A string indicating the provider or service which issued the token.
    let issuer: String

    /// A password generator containing this token's secret, algorithm, etc.
    let generator: Generator

    /// Initializes a new token with the given parameters.
    ///
    /// - parameter name:       The account name for the token (defaults to "").
    /// - parameter issuer:     The entity which issued the token (defaults to "").
    /// - parameter generator:  The password generator.
    ///
    /// - returns: A new token with the given parameters.
    init(name: String = "", issuer: String = "", generator: Generator) {
        self.name = name
        self.issuer = issuer
        self.generator = generator
    }

    // MARK: Password Generation

    /// Calculates the current password based on the token's generator. The password generated will
    /// be consistent for a counter-based token, but for a timer-based token the password will
    /// depend on the current time when this property is accessed.
    ///
    /// - returns: The current password, or `nil` if a password could not be generated.
    var currentPassword: String? {
        let currentTime = Date()
        return try? generator.password(at: currentTime)
    }

    // MARK: Update

    /// - returns: A new `Token`, configured to generate the next password.
    func updatedToken() -> Token {
        Token(name: name, issuer: issuer, generator: generator.successor())
    }
}
