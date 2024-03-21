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
import CoreData
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

extension StorageRepositoryImpl {
    func createPairing(name: String, extensionID: ExtensionID, publicKey: String) {
        PairingEntity.create(on: context, name: name, extensionID: extensionID, publicKey: publicKey)
        save()
    }
    
    func deletePairing(_ pairing: PairedWebExtension) {
        PairingEntity.delete(on: context, identifiedByObjectID: pairing.objectID)
        save()
    }
    
    func updatePairing(_ pairing: PairedWebExtension, name: String) {
        PairingEntity.update(on: context, identifiedByObjectID: pairing.objectID, name: name)
        save()
    }
    
    func removeAllPairings() {
        PairingEntity.removeAll(on: context)
        save()
    }
    
    func listAllPairings() -> [PairedWebExtension] {
        PairingEntity.listAll(on: context).map({
            PairedWebExtension(
                extensionID: $0.extensionID,
                name: $0.name,
                createdAt: $0.creationDate,
                modifiedAt: $0.modifcationDate,
                publicKey: $0.publicKey,
                objectID: $0.objectID
            )
        })
    }
}
