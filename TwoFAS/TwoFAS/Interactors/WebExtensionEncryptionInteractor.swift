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

protocol WebExtensionEncryptionInteracting: AnyObject {
    var publicKey: String? { get }
    func prepare()
    func encrypt(data: Data, publicKey: String) -> Data?
    func decrypt(data: String) -> Data?
}

final class WebExtensionEncryptionInteractor {
    private let mainRepository: MainRepository
        
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
}

extension WebExtensionEncryptionInteractor: WebExtensionEncryptionInteracting {
    var publicKey: String? {
        mainRepository.publicRSAKey?.base64EncodedString()
    }
    
    func prepare() {
        if mainRepository.areRSAExtensionKeysGenerated {
            if mainRepository.privateRSAKey == nil || mainRepository.publicRSAKey == nil {
                generate()
            }
        } else {
            generate()
        }
    }
    
    func encrypt(data: Data, publicKey: String) -> Data? {
        mainRepository.encryptRSA(data: data, using: publicKey)
    }
    
    func decrypt(data: String) -> Data? {
        guard let privateKey = mainRepository.privateRSAKey else { return nil }
        return mainRepository.decryptRSA(data: data, using: privateKey)
    }
}

private extension WebExtensionEncryptionInteractor {
    func generate() {
        guard let keys = mainRepository.generateRSAPair() else {
            Log(
                "WebExtensionEncryptionInteractor - Can't generate pair of keys for web extension!",
                module: .interactor
            )
            return
        }
        mainRepository.saveRSAKeys(privateKey: keys.privateKey, publicKey: keys.publicKey)
        mainRepository.markRSAExtensionKeysAsGenerated()
    }
}
