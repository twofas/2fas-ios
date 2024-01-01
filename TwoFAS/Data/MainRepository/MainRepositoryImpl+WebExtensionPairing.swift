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
import Storage

extension MainRepositoryImpl {
    func savePairedExtension(with extensionID: ExtensionID, name: String, publicKey: String) {
        storageRepository.createPairing(name: name, extensionID: extensionID, publicKey: publicKey)
    }
    
    func listAllPairedExtensions() -> [PairedWebExtension] {
        storageRepository.listAllPairings()
    }
    
    func deletePairedExtension(with extensionID: ExtensionID) {
        guard let pairing = listAllPairedExtensions().first(where: { $0.extensionID == extensionID }) else { return }
        storageRepository.deletePairing(pairing)
    }
    
    func updateName(for extensionID: ExtensionID, newName: String) {
        guard let pairing = listAllPairedExtensions().first(where: { $0.extensionID == extensionID }) else { return }
        storageRepository.updatePairing(pairing, name: newName)
    }
}
