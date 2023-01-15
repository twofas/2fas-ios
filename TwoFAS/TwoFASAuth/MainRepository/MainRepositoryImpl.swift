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
import NetworkStack
import Protection
import Token
import Storage
import TimeVerification

final class MainRepositoryImpl {
    let network = NetworkStack(baseURL: Config.API.baseURL)
    let protectionModule = Protection()
    let storageRepository: StorageRepository
    
    private let storage: Storage
    private static var _shared: MainRepositoryImpl!
    
    static var shared: MainRepository { _shared }
    
    init() {
        EncryptionHolder.initialize(with: protectionModule.localKeyEncryption)
        storage = Storage(readOnly: false, logError: { error in
            print("Storage error: \(error)")
        })
        storageRepository = storage.storageRepository
        MainRepositoryImpl._shared = self
    }
}

extension MainRepositoryImpl: MainRepository {
    // MARK: - DeviceID
    var isDeviceIDSet: Bool {
        protectionModule.tokenStorage.deviceID != nil
    }
    
    var deviceID: String? {
        protectionModule.tokenStorage.deviceID
    }
    
    var isPINSet: Bool {
        protectionModule.codeStorage.isSet
    }
    
    // MARK: - Network
    func send2FAToken(
        for deviceID: String,
        extensionID: String,
        tokenRequestID: String,
        token: String,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        network.network.send2FAToken(
            for: deviceID,
            extensionID: extensionID,
            tokenRequestID: tokenRequestID,
            token: token,
            completion: completion
        )
    }
    
    // MARK: - Storage
    func hasAnyServices() -> Bool {
        !storageRepository.listAllNotTrashed().isEmpty
    }
    
    func listAllPairedExtensions() -> [PairedWebExtension] {
        storageRepository.listAllPairings()
    }
    
    func listAllAuthRequests(for domain: String, extensionID: ExtensionID) -> [PairedAuthRequest] {
        storageRepository.listAllAuthRequests(for: domain, extensionID: extensionID)
    }
    
    func service(for secret: String) -> ServiceData? {
        storageRepository.findService(for: secret)
    }
    
    func incrementCounter(for secret: String) {
        storageRepository.incrementCounter(for: secret)
    }
    
    func updateAuthRequestUsage(for authRequest: PairedAuthRequest) {
        storageRepository.updateAuthRequestUsage(for: authRequest)
    }
    
    // MARK: - RSA Encryption
    func encryptRSA(data: Data, using publicKeyInBase64String: String) -> Data? {
        RSAEncryption.encrypt(data: data, using: publicKeyInBase64String)
    }
    
    // MARK: - Generating Token
    func token(
        secret: Secret,
        time: Date?,
        digits: Digits,
        period: Period,
        algorithm: Common.Algorithm,
        counter: Int,
        tokenType: TokenType
    ) -> TokenValue {
        TokenHandler.generateToken(
            secret: secret,
            time: time,
            digits: digits,
            period: period,
            algorithm: algorithm,
            counter: counter,
            tokenType: tokenType
        )
    }
    
    // MARK: Time Offset
    var currentDate: Date {
        TimeOffsetStorage.currentDate
    }
}
