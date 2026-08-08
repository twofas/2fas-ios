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

@Observable
final class VerifyPINPresenter {
    private let flowController: VerifyPINFlowControlling
    private let interactor: VerifyPINModuleInteracting

    var info: String = ""
    var isError: Bool = false
    var isLocked: Bool = false
    var shake: Bool = false
    var totalDigits: Int = 0
    var enteredDigitCount: Int = 0
    var leadingSymbol: TFLiquidGlassSymbolButton.Symbol = .close

    private var pin: [Int] = [] {
        didSet {
            enteredDigitCount = pin.count
        }
    }

    private var incorrectPINCount: Int = 0
    private let textChangeTime: Int = 3
    private let timer = CancellableTimer()

    init(flowController: VerifyPINFlowControlling, interactor: VerifyPINModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        self.totalDigits = interactor.currentCodeLength

        interactor.unlock = { [weak self] in self?.handleUnlock() }
        interactor.updateState = { [weak self] in self?.handleUpdateState() }
    }

    func viewWillAppear() {
        if interactor.isLocked {
            handleUpdateState()
        } else {
            configureNormalScreen()
        }
    }

    func onKeyPressed(_ key: TFPinKey) {
        guard !isLocked else { return }
        if let number = key.number, pin.count < totalDigits {
            pin.append(number)
            if pin.count >= totalDigits {
                pinGathered()
            }
        } else if key.isDelete {
            _ = pin.popLast()
        }
    }

    func handleCancel() {
        flowController.toClose()
    }
}

extension VerifyPINPresenter: PINEntryPresenting {
    var isInputDisabled: Bool { isLocked }
}

private extension VerifyPINPresenter {
    var passcode: String {
        pin.concateToPositionString()
    }

    func pinGathered() {
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

    func invalidInput() {
        pin = []
        shake.toggle()
        configureErrorScreen()
    }

    func configureNormalScreen() {
        isError = false
        info = T.Security.enterCurrentPin
    }

    func configureErrorScreen() {
        isError = true
        info = T.Security.incorrectPIN
        timer.start(interval: .seconds(textChangeTime)) { [weak self] in
            self?.configureNormalScreen()
            self?.timer.cancel()
        }
    }

    func handleUnlock() {
        isLocked = false
        pin = []
        configureNormalScreen()
    }

    func handleUpdateState() {
        isLocked = true
        pin = []
        info = lockTimeMessage
        isError = true
    }

    var lockTimeMessage: String {
        let lockTime = interactor.secondsTillUnlock
        if lockTime <= 0 {
            return T.Security.tooManyAttemptsError
        }
        let minute = 60
        if lockTime < 2 * minute {
            return T.Security.tooManyAttemptsError2
        }
        return T.Security.tooManyAttemptsTryAgainAfter("\(lockTime / minute)")
    }
}

private extension Array where Element == Int {
    func concateToPositionString() -> String {
        self.map { String($0) }.reduce("", +)
    }
}
