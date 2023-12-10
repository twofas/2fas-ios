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

final class LoginPresenter {
    weak var view: LoginViewControlling?
    
    var cancel: Callback?
    var resetAction: Callback?
    
    private let twoMinutes = 120
    private let minute = 60
    
    private var isLocked = false
    
    private var screenTitle: String {
        switch loginType {
        case .verify: T.Security.enterCurrentPin
        case .login: T.Security.enterPin
        }
    }
    
    private var leftButtonTitle: String? {
        switch loginType {
        case .login: nil
        case .verify: T.Commons.cancel
        }
    }
    
    private var showReset: Bool {
        switch loginType {
        case .login: true
        case .verify: false
        }
    }
    
    private var lockTimeMessage: String {
        if let lockTime = interactor.lockTime {
            if lockTime < twoMinutes {
                return T.Security.tooManyAttemptsError2
            }
            return T.Security.tooManyAttemptsTryAgainAfter("\(lockTime / minute)")
        }
        return T.Security.tooManyAttemptsError
    }
    
    private let loginType: LoginType
    private let flowController: LoginFlowControlling
    private let interactor: LoginModuleInteracting
    
    init(loginType: LoginType, flowController: LoginFlowControlling, interactor: LoginModuleInteracting) {
        self.loginType = loginType
        self.flowController = flowController
        self.interactor = interactor
        
        interactor.updateState = { [weak self] in
            self?.updateState()
        }
        
        interactor.userWasAuthenticated = { [weak self] in
            self?.flowController.toLoggedIn()
            if loginType == .login {
                self?.view?.userLoggedIn()
            }
        }
    }
    
    // MARK: - User actions
    
    func onClose() {
        flowController.toClose()
    }
    
    func onDelete() {
        interactor.deleteNumber()
        updateState()
    }
    
    func onReset() {
        interactor.reset()
        updateState()
        view?.showAppReset()
    }
    
    func onNumberInput(_ number: Int) {
        interactor.addNumber(number)
        updateState()
    }
    
    // MARK: - VC Flow
    
    func viewDidLoad() {
        view?.setDots(number: interactor.codeLength)
    }
    
    func viewWillAppear() {
        interactor.checkState()
        updateState()
    }
    
    func viewDidAppear() {
        interactor.checkState()
        updateState()
        interactor.checkBio()
    }
}

private extension LoginPresenter {
    func updateState() {
        if interactor.isLocked {
            view?.emptyDots()
            view?.hideNavigation()
            view?.lock(with: lockTimeMessage)
            return
        }
        
        view?.unlock()
        
        if interactor.inputCount > 0 {
            view?.showDeleteButton()
            view?.fillDots(count: interactor.inputCount)
        } else {
            view?.hideDeleteButton()
            view?.emptyDots()
        }
        
        if interactor.isAfterWrongPIN {
            view?.shakeDots()
            view?.prepareScreen(
                with: T.Security.incorrectPIN,
                isError: true,
                showReset: showReset,
                leftButtonTitle: leftButtonTitle
            )
            return
        }
        
        view?.prepareScreen(
            with: screenTitle,
            isError: false,
            showReset: showReset,
            leftButtonTitle: leftButtonTitle
        )
    }
}
