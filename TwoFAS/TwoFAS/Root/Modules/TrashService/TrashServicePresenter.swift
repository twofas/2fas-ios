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

final class TrashServicePresenter: ObservableObject {
    private let serviceData: ServiceData
    private let flowController: TrashServiceFlowControlling
    private let interactor: TrashServiceInteracting
    
    @Published var serviceName: String
    
    init(
        serviceData: ServiceData,
        flowController: TrashServiceFlowControlling,
        interactor: TrashServiceInteracting
    ) {
        self.serviceData = serviceData
        self.flowController = flowController
        self.interactor = interactor
        
        self.serviceName = serviceData.name
    }
}

extension TrashServicePresenter {
    func handleCancel() {
        flowController.toClose()
    }
    
    func handleTrashing() {
        interactor.trashService(serviceData)
        flowController.toTrashService()
    }
}
