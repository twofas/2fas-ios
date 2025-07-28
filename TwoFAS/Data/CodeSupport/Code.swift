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

public enum CodeType: Hashable {
    case appStore
    case service(code: Code)
    case googleAuth(codes: [Code])
    case lastPass(codes: [Code], totalCodesCount: Int)
    case twoFASWebExtension(extensionID: String)
    case support(auditID: UUID)
    case open
    case unknown
}

public struct Code: Hashable {
    public let issuer: String?
    public let label: String?
    public let secret: String
    public let period: Period?
    public let digits: Digits?
    public let algorithm: Algorithm?
    public let tokenType: TokenType
    public let counter: Int?
    public let otpAuth: String?
    
    public init(
        issuer: String?,
        label: String?,
        secret: String,
        period: Period?,
        digits: Digits?,
        algorithm: Algorithm?,
        tokenType: TokenType,
        counter: Int?,
        otpAuth: String?
    ) {
        self.issuer = issuer
        self.label = label
        self.secret = secret
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
        self.tokenType = tokenType
        self.counter = counter
        self.otpAuth = otpAuth
    }
}

extension Code: CustomDebugStringConvertible {
    // swiftlint: disable line_length
    public var debugDescription: String {
        #if DEBUG
        "[CODE]: \n\t\tIssuer: \(String(describing: issuer)))\n\t\tlabel: \(String(describing: label))\n\t\tsecret: \(secret)\n\t\tperiod: \(String(describing: period))\n\t\tdigits: \(String(describing: digits))\n\t\talgorithm: \(String(describing: algorithm))\n\t\ttokenType: \(tokenType)\n\t\tcounter: \(String(describing: counter))\n\t\totpAuth: \(String(describing: otpAuth))"
        #else
        "[CODE]: \n\t\tIssuer: \(String(describing: issuer)))\n\t\tlabel: \(String(describing: label))\n\t\tperiod: \(String(describing: period))\n\t\tdigits: \(String(describing: digits))\n\t\talgorithm: \(String(describing: algorithm))\n\t\ttokenType: \(tokenType)\n\t\tcounter: \(String(describing: counter))\n\t\totpAuth: \(String(describing: otpAuth))"
        #endif
    }
    // swiftlint: enable line_length
}

public extension Code {
    static func parse(with data: String) -> CodeType {
        let parser = CodeParser()

        if let code = parser.parse(codeStr: data) {
            return .service(code: code)
        } else if let codes = Code.checkGoogleAuth(with: data) {
            return .googleAuth(codes: codes)
        } else if let extensionID = Code.checkTwoFASWebExtension(with: data) {
            return .twoFASWebExtension(extensionID: extensionID)
        } else if let parsedData = Code.checkLastPass(with: data) {
            return .lastPass(codes: parsedData.codes, totalCodesCount: parsedData.totalCodesCount)
        } else if Code.isAppStore(with: data) {
            return .appStore
        } else if let auditID = Code.parseSupport(with: data) {
            return .support(auditID: auditID)
        } else if Code.parseOpen(with: data) {
            return .open
        }
        return .unknown
    }
    
    static func parseURL(_ url: URL) -> Code? {
        if case CodeType.service(let code) = parse(with: url.absoluteString) {
            return code
        }
        return nil
    }
    
    var summarizeDescription: String? {
        if let issuer, let label {
            return "\(issuer), \(label)"
        }
        if let issuer {
            return "\(issuer)"
        }
        if let label {
            return "\(label)"
        }
        return otpAuth
    }
}
