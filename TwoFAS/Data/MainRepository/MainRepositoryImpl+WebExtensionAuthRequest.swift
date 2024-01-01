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

extension MainRepositoryImpl {
    func addIgnoredTokenRequestIDs(_ id: String) {
        ignoredTokenRequestIDsList.append(id)
    }
    
    func ignoredTokenRequestIDs() -> [String] {
        ignoredTokenRequestIDsList
    }
    
    func removeAuthRequest(for extensionID: ExtensionID) {
        let requests = storageRepository.listAllAuthRequestsForExtensionID(extensionID)
        removeAuthRequests(requests)
    }
    
    func removeAuthRequest(_ authRequest: PairedAuthRequest) {
        storageRepository.removeAuthRequest(authRequest)
    }
    
    func createAuthRequest(for secret: String, extensionID: ExtensionID, domain: String) {
        storageRepository.createAuthRequest(for: secret, extensionID: extensionID, domain: domain)
    }
    
    func listAllAuthRequests(for secret: String) -> [PairedAuthRequest] {
        storageRepository.listAllAuthRequests(for: secret)
    }
    
    func listAllAuthRequests(for domain: String, extensionID: ExtensionID) -> [PairedAuthRequest] {
        storageRepository.listAllAuthRequests(for: domain, extensionID: extensionID)
    }
    
    func updateAuthRequestUsage(for authRequest: PairedAuthRequest) {
        storageRepository.updateAuthRequestUsage(for: authRequest)
    }
    
    func removeAllAuthRequests() {
        storageRepository.removeAllAuthRequests()
    }
    
    func removeAuthRequests(_ authRequests: [PairedAuthRequest]) {
        storageRepository.removeAuthRequests(authRequests)
    }
}
