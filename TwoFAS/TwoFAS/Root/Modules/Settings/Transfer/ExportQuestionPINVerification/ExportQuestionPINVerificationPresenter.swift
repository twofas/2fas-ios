//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2025 Two Factor Authentication Service, Inc.
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
final class ExportQuestionPINVerificationPresenter {
    private let flowController: ExportQuestionPINVerificationFlowControlling
    private let interactor: ExportQuestionPINVerificationModuleInteracting

    var info: String = ""
    var isError: Bool = false
    var shake: Bool = false
    var totalDigits: Int = 0
    var enteredDigitCount: Int = 0

    private var pin: [Int] = [] {
        didSet {
            enteredDigitCount = pin.count
        }
    }

    private let textChangeTime: Int = 3
    private let timer = CancellableTimer()

    init(
        flowController: ExportQuestionPINVerificationFlowControlling,
        interactor: ExportQuestionPINVerificationModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.totalDigits = interactor.currentCodeLength
    }

    func viewWillAppear() {
        pin = []
        configureNormalScreen()
    }

    func onKeyPressed(_ key: TFPinKey) {
        if let number = key.number, pin.count < totalDigits {
            pin.append(number)
            if pin.count >= totalDigits {
                DispatchQueue.main.asyncAfter(deadline: .now() + PINDotsAnimation.fillDuration) { [weak self] in
                    guard let self, self.pin.count >= self.totalDigits else { return }
                    self.pinGathered()
                }
            }
        } else if key.isDelete {
            _ = pin.popLast()
        }
    }

    func handleCancel() {
        flowController.toClose()
    }
}

extension ExportQuestionPINVerificationPresenter: PINEntryPresenting {}

private extension ExportQuestionPINVerificationPresenter {
    func pinGathered() {
        if interactor.verifyCode(pin) {
            flowController.toSuccess()
        } else {
            invalidInput()
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
}
