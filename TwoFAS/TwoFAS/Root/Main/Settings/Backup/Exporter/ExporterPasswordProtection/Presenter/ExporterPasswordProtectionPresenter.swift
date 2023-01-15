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

final class ExporterPasswordProtectionPresenter {
    weak var view: ExporterPasswordProtectionViewControlling?
    
    private enum ValueType {
        case unchecked
        case correct
        case tooShort
        case incorrectCharacter
    }
    private var isRevealed = false
    
    private var password1: String?
    private var password2: String?
    
    private var password: String? {
        guard firstState == .correct, secondState == .correct,
              password1 != nil, password2 != nil,
              password1 == password2 else { return nil }
        return password2
    }
    
    private var firstState: ValueType = .unchecked
    private var secondState: ValueType = .unchecked
    
    private let flowController: ExporterPasswordProtectionFlowControlling
    private let interactor: ExporterPasswordProtectionModuleInteracting
    
    init(
        flowController: ExporterPasswordProtectionFlowControlling,
        interactor: ExporterPasswordProtectionModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension ExporterPasswordProtectionPresenter {
    func viewWillAppear() {
        view?.disableExportButton()
        view?.setFirstInputAsFirstResponder()
    }
    
    func handleExport() {
        guard let password else { return }
        if interactor.isPINSet {
            flowController.toPINKeyboard(with: password)
        } else {
            interactor.export(with: password) { [weak self] url in
                if let url {
                    self?.flowController.toExport(with: url)
                } else {
                    self?.flowController.toExportError()
                }
            }
        }
    }
    
    func handleCancel() {
        flowController.toClose()
    }
    
    func handleReveal() {
        isRevealed.toggle()
        view?.setRevealState(isRevealed)
    }
    
    func handleFirstDone(_ str: String?) {
        firstState = .unchecked
        password1 = str
        verifyFirstValue()
        handleErrorDisplay()
        if firstState == .correct {
            view?.setSecondInputAsFirstResponder()
        }
    }
    
    func handleSecondDone(_ str: String?) {
        secondState = .unchecked
        password2 = str
        verifyValues()
    }
    
    func handleFirstChanged() {
        firstState = .unchecked
        view?.hideFirstError()
    }
    
    func handleSecondChanged() {
        secondState = .unchecked
        view?.hideSecondError()
    }
    
    func handleFirstNotAllowedCharacter() {
        firstState = .incorrectCharacter
        password1 = nil
        handleErrorDisplay()
    }
    
    func handleSecondNotAllowedCharacter() {
        secondState = .incorrectCharacter
        password2 = nil
        handleErrorDisplay()
    }
}

private extension ExporterPasswordProtectionPresenter {
    private func verifyValues() {
        verifyFirstValue()
        verifySecondValue()
        handleErrorDisplay()
        guard firstState == .correct, secondState == .correct else { return }
        
        if password1 == password2 {
            view?.setSecondInputResignAsFirstResponder()
            view?.enableExportButton()
        } else {
            view?.disableExportButton()
            view?.showErrorPasswordsDontMatch()
        }
    }
    
    private func verifyFirstValue() {
        guard let value = password1, value.count >= ExportFileRules.minLength else {
            firstState = .tooShort
            password1 = nil
            return
        }
        
        firstState = .correct
    }
    
    private func verifySecondValue() {
        guard let value = password2, value.count >= ExportFileRules.minLength else {
            secondState = .tooShort
            password2 = nil
            return
        }
        
        secondState = .correct
    }
    
    func handleErrorDisplay() {
        switch firstState {
        case .correct, .unchecked:
            view?.hideFirstError()
        case .incorrectCharacter:
            view?.showFirstIncorrectCharacterError()
        case .tooShort:
            view?.showFirstToShortError()
        }
        
        switch secondState {
        case .correct, .unchecked:
            view?.hideSecondError()
        case .incorrectCharacter:
            view?.showSecondIncorrectCharacterError()
        case .tooShort:
            view?.showSecondToShortError()
        }
    }
}
