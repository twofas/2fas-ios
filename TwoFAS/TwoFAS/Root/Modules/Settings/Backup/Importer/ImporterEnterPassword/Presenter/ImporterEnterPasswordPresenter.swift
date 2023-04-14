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

final class ImporterEnterPasswordPresenter {
    weak var view: ImporterEnterPasswordViewControling?
    
    private enum ValueType {
        case unchecked
        case correct
        case tooShort
        case incorrectCharacter
    }
    
    private var isRevealed = false
    private var password: String?
    private var inputState: ValueType = .unchecked {
        didSet {
            if inputState != .correct {
                password = nil
            }
        }
    }
    
    private let flowController: ImporterEnterPasswordFlowControlling
    private let interactor: ImporterEnterPasswordModuleInteracting
    private let externalImportService: ExternalImportService
    
    init(
        flowController: ImporterEnterPasswordFlowControlling,
        interactor: ImporterEnterPasswordModuleInteracting,
        externalImportService: ExternalImportService
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.externalImportService = externalImportService
    }
}

extension ImporterEnterPasswordPresenter {
    func viewDidAppear() {
        view?.inputBecomesFirstResponder()
    }
    
    func handlePreimport() {
        guard let password else {
            flowController.toFileError(error: .cantReadFile(reason: nil))
            return
        }
        switch interactor.openFile(with: password) {
        case .success(let data): parseData(data, externalImportService: externalImportService)
        case .cantReadFile: flowController.toFileError(error: .cantReadFile(reason: nil))
        case .wrongPassword: flowController.toWrongPassword()
        }
    }
    
    func handleCancel() {
        flowController.toClose()
    }
    
    func handleDone(with value: String?) {
        inputState = .unchecked
        verifyValue(with: value)
    }
    
    func handleReveal() {
        isRevealed.toggle()
        view?.setRevealState(isRevealed: isRevealed)
    }
    
    func handleNotAllowedCharacter() {
        inputState = .incorrectCharacter
        errorDisplay()
    }
    
    func handleChange() {
        inputState = .unchecked
        view?.hideError()
    }
}

private extension ImporterEnterPasswordPresenter {
    func parseData(_ data: ExchangeDataServices, externalImportService: ExternalImportService) {
        let result = interactor.parseFile(with: data)
        
        if result.count > 0 {
            flowController.toPreimportSummary(
                count: result.count,
                sections: result.sections,
                services: result.services,
                externalImportService: externalImportService
            )
        } else {
            flowController.toFileIsEmpty()
        }
    }
    
    func errorDisplay() {
        switch inputState {
        case .correct, .unchecked:
            view?.hideError()
        case .incorrectCharacter:
            view?.showErrorIncorrectCharacter()
        case .tooShort:
            view?.showErrorToShort()
        }
    }
    
    func verifyValue(with value: String?) {
        verifyFirstValue(with: value)
        errorDisplay()
        if inputState == .correct {
            view?.enableDecryptButton()
            view?.importResignsFirstResponder()
        } else {
            view?.disableDecryptButton()
        }
    }
    
    func verifyFirstValue(with value: String?) {
        guard let value, value.count >= ExportFileRules.minLength else {
            inputState = .tooShort
            password = nil
            return
        }
        
        inputState = .correct
        password = value
    }
}
