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
import CommonCrypto
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

func HMAC(algorithm: Algorithm, key: Data, data: Data) -> Data {
    let (hashFunction, hashLength) = algorithm.hashInfo
    
    let macOut = UnsafeMutablePointer<UInt8>.allocate(capacity: hashLength)
    defer {
        macOut.deallocate()
    }
    
    key.withUnsafeBytes { keyBytes in
        data.withUnsafeBytes { dataBytes in
            CCHmac(hashFunction, keyBytes.baseAddress, key.count, dataBytes.baseAddress, data.count, macOut)
        }
    }
    
    return Data(bytes: macOut, count: hashLength)
}

private extension Algorithm {
    /// The corresponding CommonCrypto hash function and hash length.
    var hashInfo: (hashFunction: CCHmacAlgorithm, hashLength: Int) {
        switch self {
        case .MD5:
            return (CCHmacAlgorithm(kCCHmacAlgMD5), Int(CC_MD5_DIGEST_LENGTH))
        case .SHA1:
            return (CCHmacAlgorithm(kCCHmacAlgSHA1), Int(CC_SHA1_DIGEST_LENGTH))
        case .SHA224:
            return (CCHmacAlgorithm(kCCHmacAlgSHA224), Int(CC_SHA224_DIGEST_LENGTH))
        case .SHA256:
            return (CCHmacAlgorithm(kCCHmacAlgSHA256), Int(CC_SHA256_DIGEST_LENGTH))
        case .SHA384:
            return (CCHmacAlgorithm(kCCHmacAlgSHA384), Int(CC_SHA384_DIGEST_LENGTH))
        case .SHA512:
            return (CCHmacAlgorithm(kCCHmacAlgSHA512), Int(CC_SHA512_DIGEST_LENGTH))
        }
    }
}
