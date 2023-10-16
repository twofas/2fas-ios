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
import CryptoKit

extension MigrationPayload.OtpParameters {
    var secretValue: String? { secret.base32EncodedString }
    
    var algorithmValue: Algorithm? {
        switch algorithm {
        case .UNRECOGNIZED, .unspecified: return nil
        case .md5: return .MD5
        case .sha1: return .SHA1
        case .sha256: return .SHA256
        case .sha512: return .SHA512
        }
    }
    
    var typeValue: TokenType? {
        switch type {
        case .unspecified, .UNRECOGNIZED: return nil
        case .totp: return .totp
        case .hotp: return .hotp
        }
    }
    
    var digitsValue: Digits? {
        switch digits {
        case .UNRECOGNIZED, .unspecified: return nil
        case .six: return .digits6
        case .eight: return .digits8
        }
    }
}
