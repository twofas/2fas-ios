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
import Common
import Data

final class LoginViewModel {
    weak var delegate: LoginViewModelDelegate?
    weak var coordinatorDelegate: LoginCoordinatorDelegate?

    let codeViewModel: PINPadViewModel
    
    fileprivate let security: SecurityProtocol

    init(
        security: SecurityProtocol,
        resetApp: Callback? = nil,
        leftButtonDescription: String? = nil,
        appLockStateInteractor: AppLockStateInteracting
    ) {
        self.security = security
        
        let codeDataModel = PINPadVerifyPINDataModel(verifyType: .login, leftButtonDescription: leftButtonDescription)
        codeDataModel.setCodeLenght(security.currentCodeType.intValue)
        codeViewModel = PINPadViewModel(dataModel: codeDataModel, appLockStateInteractor: appLockStateInteractor)
        codeViewModel.resetAction = resetApp
        security.delegate = self
        codeDataModel.checkCode = { [weak self] in self?.checkCode(numbers: $0) ?? false }
        codeViewModel.cancel = { [weak self] in self?.cancel() }
    }
    
    func viewWillAppear() {
        if !security.canAuthorize {
            delegate?.lockUI()
        } else {
            delegate?.unlockUI()
        }
    }
    
    func viewDidAppear() {
        guard security.canAuthorize && UIApplication.shared.applicationState != .background else { return }
        bioAuth()
    }
    
    private func cancel() {
        coordinatorDelegate?.cancelled()
    }
    
    private func checkCode(numbers: [Int]) -> Bool {
        let code = PIN.create(with: numbers)
        let codeIsCorrect = security.verifyPIN(code)
        if codeIsCorrect {
            security.authSuccessfully()
            delegate?.userWasAuthenticated()
        } else {
            security.authFailed()
        }
        
        return codeIsCorrect
    }
    
    func userWasAuthenticated() {
        coordinatorDelegate?.authorized()
    }
    
    fileprivate func bioAuth() {
        security.authenticateUsingBioAuthIfPossible(reason: T.Security.confirmYouAreDeviceOwner)
    }
    
    func lock() {
        codeViewModel.lock()
    }
    
    func unlock() {
        codeViewModel.unlock()
    }
}

extension LoginViewModel: SecurityDelegate {
    func securityBioAuthSuccess() {
        security.authSuccessfully()
        delegate?.userWasAuthenticated()
    }
    
    func securityBioAuthFailure() {
        // use code instead. Do nothing
    }
    
    func securityLockUI() {
        delegate?.lockUI()
    }
    
    func securityUnlockUI() {
        delegate?.unlockUI()
    }
    
    func retryBioAuthIfNecessary() {
        guard security.canAuthorize else { return }
        bioAuth()
    }
}
