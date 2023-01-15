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
import SwCrypt
import Common

public enum RSAEncryption {
    public static func generatePair() -> (privateKey: Data, publicKey: Data)? {
        var keyPair: (privateKey: Data, publicKey: Data)?
        do {
            let generated = try CC.RSA.generateKeyPair(2048)
            let publicKey = ExportPublicKey.exportRSAPublicKeyToDER(generated.1)
            keyPair = (privateKey: generated.0, publicKey: publicKey)
        } catch {
            Log("Can't generate pair of keys: \(error)", module: .protection)
        }
        return keyPair
    }
    
    public static func decrypt(data dataToDecryptInBase64String: String, using privateKey: Data) -> Data? {
        guard let dataToDecrypt = Data(base64Encoded: dataToDecryptInBase64String) else {
            Log("Can't base64 encode passed data", module: .protection)
            return nil
        }
        
        guard let pkcs1Der = PKCS8.PrivateKey.stripHeaderIfAny(privateKey) else {
            Log("Can't strip header of the privateKey", module: .protection)
            return nil
        }
        
        var decrypt: Data?
        
        do {
            decrypt = try CC.RSA.decrypt(
                dataToDecrypt,
                derKey: pkcs1Der,
                tag: Data(),
                padding: .oaep,
                digest: .sha512
            ).0
        } catch {
            Log("Problem with decrypting passed data: \(error)", module: .protection)
        }
        
        return decrypt
    }
    
    public static func encrypt(data: Data, using publicKeyInBase64String: String) -> Data? {
        guard let publicKey = Data(base64Encoded: publicKeyInBase64String) else {
            Log("Can't base64 encode passed key", module: .protection)
            return nil
        }
        var result: Data?
        do {
            result = try CC.RSA.encrypt(data, derKey: publicKey, tag: Data(), padding: .oaep, digest: .sha512)
        } catch {
            Log("Problem with encrypting passed data: \(error)", module: .protection)
        }
        return result
    }
}
