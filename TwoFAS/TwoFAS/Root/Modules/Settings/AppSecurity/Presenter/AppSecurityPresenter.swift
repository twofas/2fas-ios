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
import Data
import Common

final class AppSecurityPresenter {
    weak var view: AppSecurityViewControlling?
    
    private let flowController: AppSecurityFlowControlling
    let interactor: AppSecurityModuleInteracting
    
    init(flowController: AppSecurityFlowControlling, interactor: AppSecurityModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        if interactor.shouldShowInitialAuthorization {
            flowController.toInitialAuthorization()
        }
    }

    func viewWillAppear() {
        reload()
    }
        
    func handleSelection(at indexPath: IndexPath) {
        let menu = buildMenu()
        guard let section = menu[safe: indexPath.section],
              let cell = section.cells[safe: indexPath.row],
              let action = cell.action else { return }
        switch action {
        case .changePIN:
            changePIN()
        case .limit:
            flowController.toChangeLimit()
        }
    }
    
    func handleToggle(for indexPath: IndexPath) {
        let menu = buildMenu()
        guard let section = menu[safe: indexPath.section],
              let cell = section.cells[safe: indexPath.row]
            else { return }
        let accessory = cell.accessory
        switch accessory {
        case .toggle(let toggle):
            switch toggle.kind {
            case .PIN: togglePIN()
            case .biometry: interactor.toggleBiometry()
            }
        default: break
        }
    }
    
    func handleAppLockValueUpdate() {
        reload()
    }
    
    func handleBecomeActive() {
        reload()
    }
    
    func handleInitialAutorization() {
        interactor.saveInitialAuthorization()
        reload()
    }
    
    // Disable PIN
    func handleDidVerifyPINDisabled() {
        interactor.setPINOff()
        reload()
    }
    
    // Create PIN
    func handleFirstPINCreationInput(
        with PIN: String,
        typeOfPIN: PINType,
        action: AppSecurityFlowController.PINAction
    ) {
        flowController.toRepeatPassword(with: PIN, typeOfPIN: typeOfPIN, action: action)
    }
    
    func handlePINCreationInput(with PIN: String, typeOfPIN: PINType) {
        interactor.savePIN(PIN, typeOfPIN: typeOfPIN)
        reload()
    }
    
    // Change PIN
    func handleChangePINVerifiedPIN() {
        flowController.toCreatePIN(pinType: interactor.currentPINType)
    }
    
    func handleNewPINHidden() {
        reload()
    }
    
    // PIN Enabled
    func handleDidHidePINVerification() {
        reload()
    }
}

private extension AppSecurityPresenter {
    func togglePIN() {
        if interactor.isPINSet {
            flowController.toVerifyPINForDisable()
        } else {
            flowController.toCreatePIN(pinType: interactor.currentPINType)
        }
    }
    
    func changePIN() {
        flowController.toChangePIN(pinType: interactor.currentPINType)
    }
    
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
}
