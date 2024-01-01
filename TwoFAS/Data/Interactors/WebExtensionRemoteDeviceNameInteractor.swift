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

protocol WebExtensionRemoteDeviceNameInteracting: AnyObject {
    func setNewDeviceName(_ newName: String, completion: @escaping (Result<Void, NetworkCallError>) -> Void)
}

final class WebExtensionRemoteDeviceNameInteractor {
    private let mainRepository: MainRepository
    private let localName: WebExtensionLocalDeviceNameInteracting
    
    init(mainRepository: MainRepository, localName: WebExtensionLocalDeviceNameInteracting) {
        self.mainRepository = mainRepository
        self.localName = localName
    }
}

extension WebExtensionRemoteDeviceNameInteractor: WebExtensionRemoteDeviceNameInteracting {
    func setNewDeviceName(_ newName: String, completion: @escaping (Result<Void, NetworkCallError>) -> Void) {
        Log(
            "WebExtensionRemoteDeviceNameInteractor - setNewDeviceName: \(newName)",
            module: .interactor
        )
        guard let deviceID = mainRepository.deviceID else {
            Log(
                "WebExtensionRemoteDeviceNameInteractor - setNewDeviceName. Failure - not paired",
                module: .interactor
            )
            completion(.failure(.notPaired))
            return
        }
        
        guard let gcmToken = mainRepository.gcmToken else {
            Log(
                "WebExtensionRemoteDeviceNameInteractor - setNewDeviceName. Updating failure! No FCM Token",
                module: .interactor
            )
            completion(.failure(.serverError))
            return
        }
        
        mainRepository.updateDeviceNameToken(newName, gcmToken: gcmToken, for: deviceID) { result in
            switch result {
            case .success:
                Log("WebExtensionRemoteDeviceNameInteractor - setNewDeviceName. Success", module: .interactor)
                completion(.success(Void()))
            case .failure(let networkError):
                Log(
                    "WebExtensionRemoteDeviceNameInteractor - setNewDeviceName. Failure: \(networkError)",
                    module: .interactor
                )
                switch networkError {
                case .noInternet: completion(.failure(.noInternet))
                case .connection: completion(.failure(.serverError))
                }
            }
        }
    }
}
