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

public enum PairingWebExtensionError: Error {
    case notRegistered
    case alreadyPaired
    case noPublicKey
    case serverError
    case noInternet
    case blocked
}

public enum UnparingWebExtensionError: Error {
    case notRegistered
    case notPaired
    case serverError
    case noInternet
}

public enum FetchingListError: Error {
    case notRegistered
    case serverError
    case noInternet
}

public protocol PairingWebExtensionInteracting: AnyObject {
    var hasActiveBrowserExtension: Bool { get }
    func extensionData(for extensionID: ExtensionID) -> PairedWebExtension?
    func pair(with extensionID: ExtensionID, completion: @escaping (Result<Void, PairingWebExtensionError>) -> Void)
    func listAll() -> [PairedWebExtension]
    func unpair(
        for extensionID: ExtensionID,
        completion: @escaping (Result<Void, UnparingWebExtensionError>) -> Void
    )
    func fetchList(completion: @escaping (Result<[PairedWebExtension], FetchingListError>) -> Void)
    func disableExtension(completion: @escaping (Result<Void, UnparingWebExtensionError>) -> Void)
}

final class PairingWebExtensionInteractor {
    private let mainRepository: MainRepository
    private let localName: WebExtensionLocalDeviceNameInteracting
    private let encryption: WebExtensionEncryptionInteracting
    
    init(
        mainRepository: MainRepository,
        localName: WebExtensionLocalDeviceNameInteracting,
        encryption: WebExtensionEncryptionInteracting
    ) {
        self.mainRepository = mainRepository
        self.localName = localName
        self.encryption = encryption
        
        encryption.prepare()
    }
}

extension PairingWebExtensionInteractor: PairingWebExtensionInteracting {
    var hasActiveBrowserExtension: Bool { !listAll().isEmpty }
    
    func extensionData(for extensionID: ExtensionID) -> PairedWebExtension? {
        listAll().first { $0.extensionID == extensionID }
    }
    
    func pair(with extensionID: ExtensionID, completion: @escaping (Result<Void, PairingWebExtensionError>) -> Void) {
        Log("PairingWebExtensionInteractor - pair. extensionID: \(extensionID)", module: .interactor)
        guard !mainRepository.mdmIsBrowserExtensionBlocked else {
            Log("PairingWebExtensionInteractor - pair. Error: blocked!", module: .interactor)
            completion(.failure(.blocked))
            return
        }
        guard !mainRepository.listAllPairedExtensions().map({ $0.extensionID }).contains(extensionID) else {
            Log("PairingWebExtensionInteractor - failure. Already paired", module: .interactor)
            completion(.failure(.alreadyPaired))
            return
        }
        
        guard let deviceID = mainRepository.deviceID else {
            Log("PairingWebExtensionInteractor - failure. Not registered", module: .interactor)
            completion(.failure(.notRegistered))
            return
        }
        
        let deviceName = localName.currentDeviceName
        
        guard let devicePublicKey = encryption.publicKey else {
            Log("PairingWebExtensionInteractor - failure. No public key", module: .interactor)
            completion(.failure(.noPublicKey))
            return
        }
        
        mainRepository.pairWithWebExtension(
            for: deviceID,
            extensionID: extensionID,
            deviceName: deviceName,
            devicePublicKey: devicePublicKey
        ) { [weak self] result in
            switch result {
            case .success(let data):
                self?.mainRepository.savePairedExtension(
                    with: extensionID,
                    name: data.extensionName,
                    publicKey: data.extensionPublicKey
                )
                Log("PairingWebExtensionInteractor - success", module: .interactor)
                completion(.success(Void()))
            case .failure(let error):
                Log("PairingWebExtensionInteractor - failure. Error: \(error)", module: .interactor)
                switch error {
                case .noInternet: completion(.failure(.noInternet))
                case .connection(let reason):
                    switch reason {
                    case .serverHTTPError(let status, _):
                        if status == 409 {
                            completion(.failure(.alreadyPaired))
                        } else {
                            completion(.failure(.serverError))
                        }
                    default: completion(.failure(.serverError))
                    }
                }
            }
        }
    }
    
    func listAll() -> [PairedWebExtension] {
        mainRepository.listAllPairedExtensions()
    }
    
    func fetchList(completion: @escaping (Result<[PairedWebExtension], FetchingListError>) -> Void) {
        Log("PairingWebExtensionInteractor - fetch list", module: .interactor)
        guard let deviceID = mainRepository.deviceID else {
            Log("PairingWebExtensionInteractor - fetch list. Failure - not registered", module: .interactor)
            completion(.failure(.notRegistered))
            return
        }
        
        mainRepository.listAllPairings(for: deviceID) { [weak self] result in
            switch result {
            case .success(let pairings):
                Log("PairingWebExtensionInteractor - fetch list - success", module: .interactor)
                self?.updatePairings(with: pairings)
                completion(.success(self?.listAll() ?? []))
            case .failure(let error):
                Log("PairingWebExtensionInteractor - fetch list - failure. Error: \(error)", module: .interactor)
                switch error {
                case .noInternet: completion(.failure(.noInternet))
                case .connection: completion(.failure(.serverError))
                }
            }
        }
    }
    
    func unpair(
        for extensionID: ExtensionID,
        completion: @escaping (Result<Void, UnparingWebExtensionError>) -> Void
    ) {
        Log("PairingWebExtensionInteractor - unpair", module: .interactor)
        guard let deviceID = mainRepository.deviceID else {
            Log("PairingWebExtensionInteractor - unpair. Failure: not registered", module: .interactor)
            completion(.failure(.notRegistered))
            return
        }
        
        guard mainRepository.listAllPairedExtensions().map({ $0.extensionID }).contains(extensionID) else {
            Log("PairingWebExtensionInteractor - unpair. Failure: not paired", module: .interactor)
            completion(.failure(.notPaired))
            return
        }
        
        mainRepository.deletePairing(for: deviceID, extensionID: extensionID) { [weak self] result in
            switch result {
            case .success:
                Log("PairingWebExtensionInteractor - unpair. Success", module: .interactor)
                self?.mainRepository.deletePairedExtension(with: extensionID)
                self?.mainRepository.removeAuthRequest(for: extensionID)
                completion(.success(Void()))
            case .failure(let error):
                Log("PairingWebExtensionInteractor - unpair. Error: \(error)", module: .interactor)
                switch error {
                case .noInternet: completion(.failure(.noInternet))
                case .connection: completion(.failure(.serverError))
                }
            }
        }
    }
    
    func disableExtension(completion: @escaping (Result<Void, UnparingWebExtensionError>) -> Void) {
        Log("PairingWebExtensionInteractor - disableExtension", module: .interactor)
        guard let deviceID = mainRepository.deviceID else {
            Log("PairingWebExtensionInteractor - disableExtension. Failure: not registered", module: .interactor)
            completion(.failure(.notRegistered))
            return
        }
        
        let extensionIDs = mainRepository.listAllPairedExtensions().map({ $0.extensionID })
        
        guard !extensionIDs.isEmpty else {
            Log("PairingWebExtensionInteractor - disableExtension. Failure: not paired", module: .interactor)
            completion(.failure(.notPaired))
            return
        }
        
        var count = extensionIDs.count
        var errored = false
        
        for extensionID in extensionIDs {
            mainRepository.deletePairing(for: deviceID, extensionID: extensionID) { [weak self] result in
                switch result {
                case .success:
                    Log("PairingWebExtensionInteractor - disableExtension. Success", module: .interactor)
                    self?.mainRepository.deletePairedExtension(with: extensionID)
                    self?.mainRepository.removeAuthRequest(for: extensionID)

                    count -= 1
                    
                    if count == 0 && !errored {
                        completion(.success(Void()))
                    }
                case .failure(let error):
                    guard !errored else { return }
                    Log("PairingWebExtensionInteractor - disableExtension. Error: \(error)", module: .interactor)
                    errored = true
                    switch error {
                    case .noInternet: completion(.failure(.noInternet))
                    case .connection: completion(.failure(.serverError))
                    }
                }
            }
        }
    }
}

private extension PairingWebExtensionInteractor {
    func updatePairings(with fetchedList: [ListAllPairings.BrowserPairing]) {
        listAll().forEach { pairing in
            if let pairingOnServer = fetchedList.first(where: { $0.id == pairing.extensionID }) {
                if pairing.name != pairingOnServer.name {
                    mainRepository.updateName(for: pairing.extensionID, newName: pairingOnServer.name)
                }
            } else {
                mainRepository.deletePairedExtension(with: pairing.extensionID)
            }
        }
    }
}
