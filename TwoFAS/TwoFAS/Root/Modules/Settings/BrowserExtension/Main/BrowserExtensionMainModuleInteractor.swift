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
import Data

protocol BrowserExtensionMainModuleInteracting: AnyObject {
    var deviceNickname: String { get }
    var hasPairedServices: Bool { get }
    func listPairedServices() -> [BrowserExtensionPairedService]
    func changeDeviceNickname(
        _ newDeviceNickname: String,
        completion: @escaping (Result<Void, NetworkCallError>) -> Void
    )
    func unpairService(with extensionID: ExtensionID, completion: @escaping (Result<Void, NetworkCallError>) -> Void)
    func updatePairedServices(completion: @escaping ([BrowserExtensionPairedService]) -> Void)
    func isCameraAllowed() -> Bool
    func isCameraAvailable() -> Bool
    func registerCamera(callback: @escaping (Bool) -> Void)
}

final class BrowserExtensionMainModuleInteractor {
    private let pairingDeviceInteractor: PairingWebExtensionInteracting
    private let deviceNameInteractor: WebExtensionDeviceNameInteracting
    private let cameraPermissionInteractor: CameraPermissionInteracting
    
    init(
        pairingDeviceInteractor: PairingWebExtensionInteracting,
        deviceNameInteractor: WebExtensionDeviceNameInteracting,
        cameraPermissionInteractor: CameraPermissionInteracting
    ) {
        self.pairingDeviceInteractor = pairingDeviceInteractor
        self.deviceNameInteractor = deviceNameInteractor
        self.cameraPermissionInteractor = cameraPermissionInteractor
    }
}

extension BrowserExtensionMainModuleInteractor: BrowserExtensionMainModuleInteracting {
    var deviceNickname: String {
        deviceNameInteractor.currentDeviceName
    }
    
    var hasPairedServices: Bool {
        !pairingDeviceInteractor.listAll().isEmpty
    }
    
    func listPairedServices() -> [BrowserExtensionPairedService] {
        pairingDeviceInteractor.listAll().map { ex in
            ex.browserExtensionPairedService
        }
    }
    
    func isCameraAvailable() -> Bool {
        cameraPermissionInteractor.isCameraAvailable
    }
    
    func isCameraAllowed() -> Bool {
        cameraPermissionInteractor.isCameraAllowed
    }
    
    func registerCamera(callback: @escaping (Bool) -> Void) {
        cameraPermissionInteractor.register { status in
            callback(status == .granted)
        }
    }
    
    func changeDeviceNickname(
        _ newDeviceNickname: String,
        completion: @escaping (Result<Void, NetworkCallError>) -> Void
    ) {
        deviceNameInteractor.setNewDeviceName(newDeviceNickname, completion: completion)
    }
    
    func unpairService(with extensionID: ExtensionID, completion: @escaping (Result<Void, NetworkCallError>) -> Void) {
        pairingDeviceInteractor.unpair(for: extensionID) { result in
            switch result {
            case .success: completion(.success(Void()))
            case .failure(let error):
                switch error {
                case .noInternet: completion(.failure(.noInternet))
                default: completion(.failure(.serverError))
                }
            }
        }
    }
    
    func updatePairedServices(completion: @escaping ([BrowserExtensionPairedService]) -> Void) {
        pairingDeviceInteractor.fetchList { result in
            switch result {
            case .success(let list): completion(list.map({ $0.browserExtensionPairedService }))
            default: break
            }
        }
    }
}

private extension PairedWebExtension {
    var browserExtensionPairedService: BrowserExtensionPairedService {
        BrowserExtensionPairedService(name: name, pairingDate: createdAt, extensionID: extensionID)
    }
}
