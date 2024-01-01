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

struct ComposeServiceWebExtensionModuleInteractorData {
    let extensionName: String
    let pairings: [PairedAuthRequest]
}

protocol ComposeServiceWebExtensionModuleInteracting: AnyObject {
    func hasMultipleExtensions() -> Bool
    func listAll() -> [ComposeServiceWebExtensionModuleInteractorData]
    func removePairing(_ pairing: PairedAuthRequest)
}

final class ComposeServiceWebExtensionModuleInteractor {
    private let webExtensionAuthInteracting: WebExtensionAuthInteracting
    private let pairingWebExtensionInteractor: PairingWebExtensionInteracting
    private let secret: String
    
    init(
        webExtensionAuthInteracting: WebExtensionAuthInteracting,
        pairingWebExtensionInteractor: PairingWebExtensionInteracting,
        secret: String
    ) {
        self.webExtensionAuthInteracting = webExtensionAuthInteracting
        self.pairingWebExtensionInteractor = pairingWebExtensionInteractor
        self.secret = secret
    }
}

extension ComposeServiceWebExtensionModuleInteractor: ComposeServiceWebExtensionModuleInteracting {
    func hasMultipleExtensions() -> Bool {
        let extensionIDList = webExtensionAuthInteracting.pairings(for: secret).map({ $0.extensionID })
        return Set<ExtensionID>(extensionIDList).count > 1
    }
    
    func listAll() -> [ComposeServiceWebExtensionModuleInteractorData] {
        Dictionary(grouping: webExtensionAuthInteracting.pairings(for: secret), by: { $0.extensionID })
            .map { key, value in
                let name = pairingWebExtensionInteractor.extensionData(for: key)?.name ?? ""
                return ComposeServiceWebExtensionModuleInteractorData(extensionName: name, pairings: value)
            }
    }
    
    func removePairing(_ pairing: PairedAuthRequest) {
        webExtensionAuthInteracting.delete(pairing: pairing)
    }
}
