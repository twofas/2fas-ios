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
import Protection

extension MainRepositoryImpl {
    var privateRSAKey: Data? { RSAKeyStorage.privateKey }
    var publicRSAKey: Data? { RSAKeyStorage.publicKey }
    var areRSAExtensionKeysGenerated: Bool { userDefaultsRepository.areExtensionKeysGenerated }
    
    func generateRSAPair() -> (privateKey: Data, publicKey: Data)? {
        RSAEncryption.generatePair()
    }
    
    func decryptRSA(data dataToDecryptInBase64String: String, using privateKey: Data) -> Data? {
        RSAEncryption.decrypt(data: dataToDecryptInBase64String, using: privateKey)
    }
    
    func encryptRSA(data: Data, using publicKeyInBase64String: String) -> Data? {
        RSAEncryption.encrypt(data: data, using: publicKeyInBase64String)
    }
    
    func saveRSAKeys(privateKey: Data, publicKey: Data) {
        RSAKeyStorage.save(privateKey: privateKey, publicKey: publicKey)
    }
    
    func markRSAExtensionKeysAsGenerated() {
        userDefaultsRepository.markExtensionKeysAsGenerated()
    }
    
    func clearRSAExtensionKeys() {
        userDefaultsRepository.clearExtensionKeys()
    }
}
