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

protocol BrowserExtensionPairingModuleInteracting: AnyObject {
    func startPairing(completion: @escaping (Result<Void, PairingWebExtensionError>) -> Void)
}

final class BrowserExtensionPairingModuleInteractor {
    private let webPairing: PairingWebExtensionInteracting
    private let registerDeviceInteractor: RegisterDeviceInteracting
    private let extensionID: ExtensionID
    
    init(
        webPairing: PairingWebExtensionInteracting,
        registerDeviceInteractor: RegisterDeviceInteracting,
        extensionID: ExtensionID
    ) {
        self.webPairing = webPairing
        self.registerDeviceInteractor = registerDeviceInteractor
        self.extensionID = extensionID
    }
}

extension BrowserExtensionPairingModuleInteractor: BrowserExtensionPairingModuleInteracting {
    func startPairing(completion: @escaping (Result<Void, PairingWebExtensionError>) -> Void) {
        registerDeviceInteractor.registerDevice { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                webPairing.pair(with: extensionID, completion: completion)
            case .failure:
                completion(.failure(.notRegistered))
            }
        }
    }
}
