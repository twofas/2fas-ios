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
#if os(iOS)
import Common
#elseif os(watchOS)
import CommonWatch
#endif

extension StorageRepositoryImpl {
    func removeAuthRequest(_ authRequest: PairedAuthRequest) {
        AuthRequestEntity.delete(on: context, identifiedByObjectID: authRequest.objectID)
        save()
    }
    
    func removeAuthRequests(_ authRequests: [PairedAuthRequest]) {
        authRequests.forEach {
            AuthRequestEntity.delete(on: context, identifiedByObjectID: $0.objectID)
        }
        save()
    }
    
    func createAuthRequest(for secret: String, extensionID: ExtensionID, domain: String) {
        AuthRequestEntity.create(on: context, secret: secret.encrypt(), extensionID: extensionID, domain: domain)
        save()
    }
    
    func listAllAuthRequests(for secret: String) -> [PairedAuthRequest] {
        AuthRequestEntity
            .listAll(on: context, filterOptions: .secret(secret: secret.encrypt()))
            .map({ $0.pairedAuthRequest })
    }
    
    func listAllAuthRequests(for domain: String, extensionID: ExtensionID) -> [PairedAuthRequest] {
        AuthRequestEntity
            .listAll(on: context, filterOptions: .domainExtension(domain: domain, extensionID: extensionID))
            .map({ $0.pairedAuthRequest })
    }
    
    func listAllAuthRequestsForExtensionID(_ extensionID: ExtensionID) -> [PairedAuthRequest] {
        AuthRequestEntity
            .listAll(on: context, filterOptions: .extensionID(extensionID: extensionID))
            .map({ $0.pairedAuthRequest })
    }
    
    func updateAuthRequestUsage(for authRequest: PairedAuthRequest) {
        AuthRequestEntity.updateUsage(on: context, identifiedByObjectID: authRequest.objectID)
        save()
    }
        
    func removeAllAuthRequests() {
        AuthRequestEntity.removeAll(on: context)
        save()
    }
}
