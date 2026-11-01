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

final class AddingServiceManuallyPresenter: ObservableObject {
    enum KeyboardInitialFocus {
        case noFocus
        case name
        case secret
    }
    
    enum SecretValidationResult {
        case correct
        case duplicated
        case incorrect
        case tooShort
        case tooLong
        
        var error: String? {
            switch self {
            case .correct: return nil
            case .duplicated: return T.Tokens.duplicatedPrivateKey
            case .incorrect: return T.Tokens.incorrectServiceKey
            case .tooShort: return T.Tokens.serviceKeyToShort
            case .tooLong: return T.Commons.textLongTitle(ServiceRules.privateKeyMaxLength)
            }
        }
    }
    
    @Published var isAddServiceEnabled = false
    
    var keyboardInitialFocus: KeyboardInitialFocus {
        if isFirstAppear {
            if providedName != nil {
                return .secret
            }
            return .name
        }
        return .noFocus
    }
    
    private var isFirstAppear = true
    
    private var isCorrectServiceName = false
    private var isCorrectSecret = false
    private var isCorrectAdditionalInfo = true
    
    private var isIconTypeUserDefined = false
    private var isBrandIconUserDefined = false
    private var isLabelTitleUserDefined = false

    @Published private(set) var iconValue: IconEditorValue

    @Published var serviceName: String = "" {
        didSet { handleServiceNameChange() }
    }
    @Published var serviceNameError: String?
    @Published var secret: String = "" {
        didSet { handleSecretChange() }
    }
    @Published var secretError: String?
    @Published var additionalInfo: String = "" {
        didSet { handleAdditionalInfoChange() }
    }
    @Published var additionalInfoError: String?

    private var advancedSettings = AddingServiceAdvancedSettings()

    private let flowController: AddingServiceManuallyFlowControlling
    private let interactor: AddingServiceManuallyModuleInteracting
    private let providedName: String?
    
    init(
        flowController: AddingServiceManuallyFlowControlling,
        interactor: AddingServiceManuallyModuleInteracting,
        providedName: String?
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.providedName = providedName
        self.iconValue = IconEditorValue(
            iconType: .brand,
            iconTypeID: nil,
            labelTitle: "",
            labelColor: .random
        )
        self.serviceName = providedName ?? ""
        updateAutomaticIcon()
    }
}

extension AddingServiceManuallyPresenter {
    var algorithm: Algorithm {
        advancedSettings.tokenType == TokenType.steam ? Algorithm.SHA1 : advancedSettings.algorithm
    }
    var tokenPeriod: Period {
        advancedSettings.tokenType == TokenType.steam ? Period.period30 : advancedSettings.refreshTime
    }
    var tokenLength: Digits {
        advancedSettings.tokenType == TokenType.steam ? Digits.digits5 : advancedSettings.digits
    }

    func handleAddService() {
        validateAddService()
        guard isAddServiceEnabled else { return }
        guard let serviceData = interactor.addService(
            name: serviceName.trim(),
            secret: secret.uppercased(),
            additionalInfo: additionalInfo,
            tokenPeriod: tokenPeriod,
            tokenLength: tokenLength,
            iconType: iconValue.iconType,
            iconTypeID: iconValue.iconTypeID,
            labelTitle: iconValue.labelTitle,
            labelColor: iconValue.labelColor,
            algorithm: algorithm,
            counter: advancedSettings.initialCounter,
            tokenType: advancedSettings.tokenType
        ) else { return }
        flowController.toClose(serviceData)
    }
}

extension AddingServiceManuallyPresenter {
    func validateAddService() {
        isAddServiceEnabled = isCorrectServiceName && isCorrectSecret && isCorrectAdditionalInfo
    }
    
    enum ServiceNameValidationResult: Error {
        case correct
        case tooLong
        case tooShort
        
        var error: String? {
            switch self {
            case .correct: return nil
            case .tooLong: return T.Commons.textLongTitle(ServiceRules.serviceNameMaxLength)
            case .tooShort: return T.Tokens.serviceNameTooShort(ServiceRules.serviceNameMinLength)
            }
        }
    }
    
    func validateServiceName(_ serviceName: String) -> ServiceNameValidationResult {
        let value: ServiceNameValidationResult
        isCorrectServiceName = false
        let trimmed = serviceName.trim()
        if trimmed.count >= ServiceRules.serviceNameMinLength &&
            trimmed.count <= ServiceRules.serviceNameMaxLength {
            isCorrectServiceName = true
            value = .correct
        } else if trimmed.isEmpty {
            value = .tooShort
        } else {
            value = .tooLong
        }
        validateAddService()
        return value
    }
    
    func validateSecret(_ secret: String) -> SecretValidationResult {
        let value: SecretValidationResult
        isCorrectSecret = false
        
        if ServiceRules.isPrivateKeyTooShort(privateKey: secret) {
            value = .tooShort
        } else if ServiceRules.isPrivateKeyTooLong(privateKey: secret) {
            value = .tooLong
        } else if !ServiceRules.isPrivateKeyValid(privateKey: secret) {
            value = .incorrect
        } else if interactor.isPrivateKeyUsed(secret) {
            value = .duplicated
        } else {
            isCorrectSecret = true
            value = .correct
        }
        
        validateAddService()
        return value
    }
    
    enum AdditionalInfoValidationResult {
        case correct
        case tooLong
        
        var error: String? {
            switch self {
            case .correct: return nil
            case .tooLong: return T.Commons.textLongTitle(ServiceRules.additionalInfoMaxLength)
            }
        }
    }
    
    func validateAdditionalInfo(_ additionalInfo: String) -> AdditionalInfoValidationResult {
        let value: AdditionalInfoValidationResult
        isCorrectAdditionalInfo = false
        
        if additionalInfo.count > ServiceRules.additionalInfoMaxLength {
            value = .tooLong
        } else {
            isCorrectAdditionalInfo = true
            value = .correct
        }
        
        validateAddService()
        return value
    }

    func handleCancel() {
        flowController.toClose()
    }
    
    func handlePair() {
        guard isAddServiceEnabled else { return }
        handleAddService()
    }
    
    func viewDidAppear() {
        isFirstAppear = false
    }
    
    func handleShowAdvancedSettings() {
        flowController.toAdvancedSettings(advancedSettings)
    }

    func handleAdvancedSettings(_ settings: AddingServiceAdvancedSettings) {
        advancedSettings = settings
    }
    
    var previewIcon: IconDetails {
        iconValue.iconDetails
    }

    func handleEditIcon() {
        flowController.toIconEditor(iconValue)
    }

    func handleIconEditorSave(_ value: IconEditorValue) {
        isIconTypeUserDefined = true
        if value.iconType == .brand {
            isBrandIconUserDefined = true
        }
        if value.labelTitle != iconValue.labelTitle {
            isLabelTitleUserDefined = true
        }
        iconValue = value
    }
}

private extension AddingServiceManuallyPresenter {
    func updateAutomaticIcon() {
        let trimmed = serviceName.trim()
        if !isLabelTitleUserDefined {
            iconValue.labelTitle = trimmed.twoLetters
        }
        if !isBrandIconUserDefined {
            iconValue.iconTypeID = interactor.detectedIconTypeID(for: trimmed)
        }
        if !isIconTypeUserDefined {
            iconValue.iconType = .brand
        }
    }

    func handleServiceNameChange() {
        serviceNameError = validateServiceName(serviceName.trim()).error
        updateAutomaticIcon()
    }

    func handleSecretChange() {
        let sanitized = secret.sanitazeSecret()
        if sanitized != secret {
            secret = sanitized
            return
        }
        secretError = validateSecret(secret).error
    }

    func handleAdditionalInfoChange() {
        additionalInfoError = validateAdditionalInfo(additionalInfo).error
    }
}
