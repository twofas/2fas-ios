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

protocol WebExtensionDeviceNameInteracting: AnyObject {
    var currentDeviceName: String { get }
    func setNewDeviceName(_ newName: String, completion: @escaping (Result<Void, NetworkCallError>) -> Void)
}

final class WebExtensionDeviceNameInteractor {
    private let local: WebExtensionLocalDeviceNameInteracting
    private let remote: WebExtensionRemoteDeviceNameInteracting
    
    init(local: WebExtensionLocalDeviceNameInteracting, remote: WebExtensionRemoteDeviceNameInteracting) {
        self.local = local
        self.remote = remote
    }
}

extension WebExtensionDeviceNameInteractor: WebExtensionDeviceNameInteracting {
    var currentDeviceName: String {
        local.currentDeviceName
    }
    
    func setNewDeviceName(_ newName: String, completion: @escaping (Result<Void, NetworkCallError>) -> Void) {
        Log("WebExtensionDeviceNameInteractor - setNewDeviceName: \(newName)", module: .interactor)
        remote.setNewDeviceName(newName) { [weak self] result in
            switch result {
            case .success:
                Log("WebExtensionDeviceNameInteractor - setNewDeviceName. Success", module: .interactor)
                self?.local.setNewDeviceName(newName)
                completion(.success(Void()))
            case .failure(let error):
                Log("WebExtensionDeviceNameInteractor - setNewDeviceName. Failure: \(error)", module: .interactor)
                completion(.failure(error))
            }
        }
    }
}
