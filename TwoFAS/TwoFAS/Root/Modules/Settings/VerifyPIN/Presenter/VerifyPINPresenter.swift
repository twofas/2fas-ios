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

final class VerifyPINPresenter: PINKeyboardPresenter {
    private let flowController: VerifyPINFlowControlling
    private let interactor: VerifyPINModuleInteracting
    
    private var incorrectPINCount: Int = 0
    
    init(flowController: VerifyPINFlowControlling, interactor: VerifyPINModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        super.init()
        
        interactor.unlock = { [weak self] in self?.handleUnlock() }
        interactor.updateState = { [weak self] in self?.handleUpdateState() }
        codeLength = interactor.currentCodeLength
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if interactor.isLocked {
            handleUpdateState()
        }
    }
    
    override func PINGathered() {
        if interactor.verifyPIN(passcode) {
            flowController.toPinVerifiedCorrectly()
        } else {
            incorrectPINCount += 1
            if interactor.shouldLock(attempt: incorrectPINCount) {
                interactor.lock()
                handleUpdateState()
            } else {
                invalidInput()
            }
        }
    }
    
    override func configureNormalScreen() {
        guard !isLocked else { return }
        keyboard?.prepareScreen(with: T.Security.enterCurrentPin, titleType: .normal)
    }
    
    override func configureErrorScreen() {
        super.configureErrorScreen()
        keyboard?.prepareScreen(with: T.Security.incorrectPIN, titleType: .error)
    }
}

extension VerifyPINPresenter {
    func handleCancel() {
        flowController.toClose()
    }
}

private extension VerifyPINPresenter {
    func handleUnlock() {
        unlock()
    }
    
    func handleUpdateState() {
        lockTime = interactor.secondsTillUnlock
        lock()
    }
}
