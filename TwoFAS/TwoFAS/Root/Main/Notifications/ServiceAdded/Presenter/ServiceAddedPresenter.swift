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

final class ServiceAddedPresenter {
    weak var view: ServiceAddedViewControlling?
    
    private let flowController: ServiceAddedFlowControlling
    private let interactor: ServiceAddedModuleInteracting
    
    init(flowController: ServiceAddedFlowControlling, interactor: ServiceAddedModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension ServiceAddedPresenter {
    func viewDidLoad() {
        view?.set(
            interactor.serviceName,
            actionText: actionText(),
            iconImage: interactor.serviceIcon,
            serviceTypeName: interactor.serviceTypeName,
            secret: interactor.secret,
            showEditIcon: interactor.showEditIcon
        )
    }
    
    func viewWillAppear() {
        interactor.start()
    }
    
    func viewWillDisappear() {
        interactor.clear()
    }
    
    func handleEditService() {
        interactor.clear()
        flowController.toEditService(interactor.serviceData)
    }
    
    func handleClose() {
        interactor.clear()
        flowController.toClose()
    }
    
    func handleCopy() {
        interactor.copyToken()
    }
    
    func handleEditIcon() {
        interactor.clear()
        flowController.toEditIcon(interactor.serviceData)
    }
    
    func handleRefresh() {
        interactor.refresh()
    }
}

private extension ServiceAddedPresenter {
    func actionText() -> String {
        switch interactor.serviceTokenType {
        case .hotp: return T.Tokens.retypeThisToken
        case .totp: return T.Tokens.unlockAndRetypeTokenTitle
        }
    }
}
