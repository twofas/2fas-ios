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

final class NewPINPresenter: PINKeyboardPresenter {
    weak var view: NewPINViewControlling?
    
    private let flowController: NewPINFlowControlling
    private let interactor: NewPINModuleInteracting
    
    var isSecond = false
    var action: NewPINFlowController.Action?
    
    init(flowController: NewPINFlowControlling, interactor: NewPINModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        
        super.init()
        codeLength = interactor.pinType.digits
    }
    
    func viewDidLoad() {
        if !interactor.lockNavigation {
            view?.showCancelButton()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if !isSecond {
            keyboard?.showBottomButton(with: T.Settings.selectPinLength)
        }
        
        guard let action else { return }
        
        switch action {
        case .change: view?.setTitle(T.Security.changePin)
        case .create: view?.setTitle(T.Security.createPin)
        }
    }
    
    override func PINGathered() {
        if isSecond {
            if interactor.validatePIN(passcode) {
                flowController.toPINGathered(with: passcode, pinType: interactor.pinType)
            } else {
                invalidInput()
            }
        } else {
            flowController.toPINGathered(with: passcode, pinType: interactor.pinType)
        }
    }
    
    override func configureNormalScreen() {
        guard !isLocked else { return }
        if isSecond {
            keyboard?.prepareScreen(with: T.Security.confirmNewPin, titleType: .normal)
        } else {
            keyboard?.prepareScreen(with: T.Security.enterNewPin, titleType: .normal)
        }
    }
    
    override func configureErrorScreen() {
        super.configureErrorScreen()
        keyboard?.prepareScreen(with: T.Security.incorrectPIN, titleType: .error)
    }
    
    func handleChangePINType() {
        flowController.toChangePINType()
    }
    
    func handleSelectedPINType(_ pinType: PINType) {
        interactor.setPINType(pinType)
        setNewDotsCount(pinType.digits)
    }
}

extension NewPINPresenter {
    func handleCancel() {
        flowController.toClose()
    }
}
