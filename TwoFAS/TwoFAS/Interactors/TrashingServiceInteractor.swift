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
import Token

protocol TrashingServiceInteracting: AnyObject {
    func trashService(_ serviceData: ServiceData)
    func untrashService(_ serviceData: ServiceData)
    func untrashService(for unencryptedSecret: Secret)
    func listTrashedServices() -> [ServiceData]
    func deleteService(_ serviceData: ServiceData)
    func deleteService(for secret: Secret)
}

final class TrashingServiceInteractor {
    private let mainRepository: MainRepository
    private let webExtensionAuthInteractor: WebExtensionAuthInteracting
    
    init(mainRepository: MainRepository, webExtensionAuthInteractor: WebExtensionAuthInteracting) {
        self.mainRepository = mainRepository
        self.webExtensionAuthInteractor = webExtensionAuthInteractor
    }
}

extension TrashingServiceInteractor: TrashingServiceInteracting {
    func trashService(_ serviceData: ServiceData) {
        Log("TrashingServiceInteractor - trashService", module: .interactor)
        mainRepository.trashService(serviceData)
    }
    
    func untrashService(_ serviceData: ServiceData) {
        Log("TrashingServiceInteractor - untrashService for service data", module: .interactor)
        mainRepository.untrashService(serviceData)
        mainRepository.synchronizeBackup()
    }
    
    func untrashService(for secret: Secret) {
        Log("TrashingServiceInteractor - untrashService for secret", module: .interactor)
        let trashedServices = mainRepository.listTrashedServices()
        guard let serviceData = trashedServices.first(where: { $0.secret == secret }) else { return }
        mainRepository.untrashService(serviceData)
        mainRepository.synchronizeBackup()
    }
    
    func listTrashedServices() -> [ServiceData] {
        mainRepository.listTrashedServices()
    }
    
    func deleteService(_ serviceData: ServiceData) {
        Log("TrashingServiceInteractor - deleteService for service data", module: .interactor)
        mainRepository.deleteService(serviceData)
        removeAuthRequests(for: serviceData.secret)
    }
    
    func deleteService(for secret: Secret) {
        Log("TrashingServiceInteractor - deleteService for secret", module: .interactor)
        let services = mainRepository.listAllExistingServices()
        guard let serviceData = services.first(where: { $0.secret == secret }) else { return }
        mainRepository.deleteService(serviceData)
        removeAuthRequests(for: secret)
    }
}

private extension TrashingServiceInteractor {
    func removeAuthRequests(for secret: String) {
        webExtensionAuthInteractor.deleteAll(for: secret)
    }
}
