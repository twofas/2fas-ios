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
import CryptoKit
import CommonCrypto
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

public final class ExchangeFileEncryption {
    public struct EncryptionResult {
        public let data: String
        public let reference: String
    }
    
    public init() {}
    
    public func encrypt(with password: String, data: Data) -> EncryptionResult? {
        let generatedSalt = salt()
        guard let keyPBKDF2 = pbkdf2(password: password, salt: generatedSalt) else {
            Log("Can't generate pbkdf2 key", module: .protection)
            return nil
        }
        
        let key = SymmetricKey(data: keyPBKDF2)
        let IVCypher = AES.GCM.Nonce()
        let IVReference = AES.GCM.Nonce()
        
        do {
            let encryptedData = try encrypt(with: key, salt: generatedSalt, iv: IVCypher, data: data)
            let encryptedReference = try encrypt(
                with: key,
                salt: generatedSalt,
                iv: IVReference,
                data: Keys.Reference.dataValue
            )
            
            return .init(data: encryptedData, reference: encryptedReference)
        } catch {
            Log("Can't encode data, error: \(error)", module: .protection)
        }
        return nil
    }
    
    private func encrypt(with key: SymmetricKey, salt: Data, iv: AES.GCM.Nonce, data: Data) throws -> String {
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: iv)
        let base64Cypher = (sealedBox.ciphertext + sealedBox.tag).base64EncodedString()
        let base64Salt = salt.base64EncodedString()
        let base64IV = Data(iv).base64EncodedString()
        return "\(base64Cypher):\(base64Salt):\(base64IV)"
    }
    
    public func decrypt(password: String, encodedData: String, encodedReference: String) -> Data? {
        let originalReference = Keys.Reference.dataValue
        guard let data = encodedData.splitBase64String(), let reference = encodedReference.splitBase64String() else {
            Log("Can't get data from passed arguments: \(encodedData), \(encodedReference)", module: .protection)
            return nil
        }
        
        do {
            let decodedReference = try decrypt(
                using: password,
                salt: reference.salt,
                iv: reference.IV,
                data: reference.data
            )
            guard decodedReference == originalReference else {
                Log("Decoded reference doesn't match original one", module: .protection)
                return nil
            }
            return try decrypt(using: password, salt: data.salt, iv: data.IV, data: data.data)
        } catch {
            Log("Can't decode data: \(error)", module: .protection)
        }
        return nil
    }
    
    private func decrypt(using password: String, salt: Data, iv: Data, data: Data) throws -> Data? {
        guard let keyPBKDF2 = pbkdf2(password: password, salt: salt) else {
            Log("Can't create pbkdf2", module: .protection)
            return nil
        }
        
        let key = SymmetricKey(data: keyPBKDF2)
        
        let nonce = try AES.GCM.Nonce(data: iv)
        let combined = nonce + data
        let sealedBox = try AES.GCM.SealedBox(combined: combined)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return decryptedData
    }
    
    private func salt() -> Data {
        func randomData(length: Int) -> Data {
            var data = Data(count: length)
            _ = data.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
            }
            return data
        }
        
        let salt = randomData(length: 32) // 256bits
        return salt
    }
    
    private func pbkdf2(password: String, salt: Data) -> Data? {
        guard let passwordData = password.data(using: .ascii) else { return nil }
        let rounds: UInt32 = 10_000
        let keyLenght = 32
        
        var derivedKeyData = Data(repeating: 0, count: keyLenght)
        let derivedCount = derivedKeyData.count
        
        let derivationStatus: OSStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            let derivedKeyRawBytes = derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress
            return salt.withUnsafeBytes { saltBytes in
                let rawBytes = saltBytes.bindMemory(to: UInt8.self).baseAddress
                return CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password,
                    passwordData.count,
                    rawBytes,
                    salt.count,
                    UInt32(kCCPRFHmacAlgSHA256),
                    rounds,
                    derivedKeyRawBytes,
                    derivedCount)
            }
        }
        
        return derivationStatus == kCCSuccess ? derivedKeyData : nil
    }
}

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        self = data
    }
    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        map { String(format: "%02x", $0) }
        .joined()
    }
}

extension String {
    func splitBase64String() -> (data: Data, salt: Data, IV: Data)? {
        let array = split(separator: ":")
        guard array.count == 3,
              let data = Data(base64Encoded: String(array[0])),
              let salt = Data(base64Encoded: String(array[1])),
              let IV = Data(base64Encoded: String(array[2]))
        else { return nil }
        return (data: data, salt: salt, IV: IV)
    }
}
