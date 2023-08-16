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

import UIKit

protocol AddingServiceManuallyModuleInteracting: AnyObject {
    func checkForServiceIcon(using str: String, callback: @escaping (UIImage?) -> Void)
    func isPrivateKeyUsed(_ privateKey: String) -> Bool
}

final class AddingServiceManuallyModuleInteractor {
    private let serviceDatabase: ServiceDefinitionInteracting
    private let serviceListingInteractor: ServiceListingInteracting
    
    init(
        serviceDatabase: ServiceDefinitionInteracting,
        serviceListingInteractor: ServiceListingInteracting
    ) {
        self.serviceDatabase = serviceDatabase
        self.serviceListingInteractor = serviceListingInteractor
    }
}

extension AddingServiceManuallyModuleInteractor: AddingServiceManuallyModuleInteracting {
    func checkForServiceIcon(using str: String, callback: @escaping (UIImage?) -> Void) {
        callback(serviceDatabase.findServicesByTagOrIssuer(str, exactMatch: true).first?.icon)
    }
    
    func isPrivateKeyUsed(_ privateKey: String) -> Bool {
        serviceListingInteractor.service(for: privateKey) != nil
    }
}
