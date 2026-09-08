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

@Observable
final class NewPINPresenter {
    private let flowController: NewPINFlowControlling
    private let interactor: NewPINModuleInteracting

    let isSecond: Bool
    let action: NewPINFlowController.Action

    let title: String
    var info: String = ""
    var isError: Bool = false
    var shake: Bool = false
    var totalDigits: Int = 0
    var enteredDigitCount: Int = 0
    /// The X that abandons the whole flow, standing in for the back button on the entry step:
    /// the modal's root, or the step after verifying the current PIN. The confirmation step
    /// is pushed on the entry step and keeps the system back button instead, so a mistyped
    /// PIN can be entered again. Out while the navigation is locked.
    var showsCancelButton: Bool {
        !interactor.lockNavigation && !isSecond
    }
    var showsPinLengthButton: Bool = false

    private var pin: [Int] = [] {
        didSet {
            enteredDigitCount = pin.count
        }
    }

    private let textChangeTime: Int = 3
    private let timer = CancellableTimer()

    /// `isSecond`: this is the confirmation step, asking for the PIN gathered a step earlier.
    init(
        flowController: NewPINFlowControlling,
        interactor: NewPINModuleInteracting,
        action: NewPINFlowController.Action,
        isSecond: Bool
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.action = action
        self.isSecond = isSecond
        self.totalDigits = interactor.pinType.digits
        title = switch action {
        case .change: T.Security.changePin
        case .create: T.Security.createPin
        }
        showsPinLengthButton = !isSecond
        // The prompt is part of the first frame; set on appearance only, it would come in as
        // an animated change of the text, see `PINEntryScreen`.
        configureNormalScreen()
    }

    func viewWillAppear() {
        pin = []
        showsPinLengthButton = !isSecond
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

    func handleChangePINType() {
        flowController.toChangePINType()
    }

    func handleSelectedPINType(_ pinType: PINType) {
        interactor.setPINType(pinType)
        totalDigits = pinType.digits
        pin = []
    }
}

extension NewPINPresenter: PINEntryPresenting {}

private extension NewPINPresenter {
    func pinGathered() {
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

    var passcode: String {
        pin.concateToPositionString()
    }

    func invalidInput() {
        pin = []
        shake.toggle()
        configureErrorScreen()
    }

    func configureNormalScreen() {
        isError = false
        if isSecond {
            info = T.Security.confirmNewPin
        } else {
            info = T.Security.enterNewPin
        }
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

private extension Array where Element == Int {
    func concateToPositionString() -> String {
        self.map { String($0) }.reduce("", +)
    }
}
