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
import Data
import Common

@Observable
final class AppSecurityPresenter {
    var sections: [AppSecurityMenuSection] = []

    var isBiometryAuthenticationInProgress = false

    private let flowController: AppSecurityFlowControlling
    let interactor: AppSecurityModuleInteracting

    init(flowController: AppSecurityFlowControlling, interactor: AppSecurityModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBecomeActive),
            name: .refreshTabContent,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func viewDidLoad() {
        if interactor.shouldShowInitialAuthorization {
            flowController.toInitialAuthorization()
        }
    }

    func viewWillAppear() {
        reload()
    }

    func handleSelection(_ action: AppSecurityMenuCell.Action) {
        switch action {
        case .changePIN:
            changePIN()
        }
    }

    func handleToggle(_ kind: AppSecurityMenuCell.ToggleKind) {
        switch kind {
        case .PIN:
            togglePIN()
        case .biometry:
            handleBiometryToggle()
        }
    }

    func handlePickerSelection(_ kind: AppSecurityMenuCell.PickerKind) {
        switch kind {
        case .attempts(let value):
            interactor.setAttempts(value)
        case .blockTime(let value):
            interactor.setBlockTime(value)
        }
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

    func handleBiometryToggle() {
        if interactor.isBiometryEnabled {
            interactor.disableBiometry()
            reload()
            return
        }
        Task { @MainActor in
            let reason = interactor.biometryType == .faceID
                ? T.Settings.faceId
                : T.Settings.touchId

            isBiometryAuthenticationInProgress = true
            reload()

            _ = await interactor.requestBiometryEnable(reason: reason)

            isBiometryAuthenticationInProgress = false
            reload()
        }
    }

    func reload() {
        sections = buildMenu()
    }

    @objc func handleAppBecomeActive() {
        reload()
    }
}
