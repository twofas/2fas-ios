//
//  Token.swift
//  OneTimePassword
//
//  Copyright (c) 2014-2018 Matt Rubin and the OneTimePassword authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
