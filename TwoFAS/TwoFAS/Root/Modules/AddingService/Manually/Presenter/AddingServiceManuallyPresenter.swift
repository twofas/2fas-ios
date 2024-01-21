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
    
    private var iconTypeID: IconTypeID?
    
    @Published var serviceName: String = ""
    @Published var serviceIcon: UIImage?
    @Published var secret: String = ""
    @Published var advancedShown = false
    @Published var additionalInfo: String = ""
    @Published var selectedTokenType: TokenType = .totp
    @Published var selectedAlgorithm: Algorithm = .defaultValue
    @Published var selectedRefreshTime: Period = .defaultValue
    @Published var selectedDigits: Digits = .defaultValue
    @Published var initialCounter: Int = 0
    
    weak var view: AddingServiceManuallyViewControlling?
    
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
    }
}

extension AddingServiceManuallyPresenter {
    var algorithm: Algorithm {
        selectedTokenType == TokenType.steam ? Algorithm.SHA1 : selectedAlgorithm
    }
    var tokenPeriod: Period {
        selectedTokenType == TokenType.steam ? Period.period30 : selectedRefreshTime
    }
    var tokenLength: Digits {
        selectedTokenType == TokenType.steam ? Digits.digits5 : selectedDigits
    }
    
    func viewDidLoad() {
        serviceName = providedName ?? ""
    }
    
    func handleAddService() {
        validateAddService()
        guard isAddServiceEnabled else { return }
        guard let serviceData = interactor.addService(
            name: serviceName.trim(),
            secret: secret,
            additionalInfo: additionalInfo,
            tokenPeriod: tokenPeriod,
            tokenLength: tokenLength,
            iconTypeID: iconTypeID,
            algorithm: algorithm,
            counter: initialCounter,
            tokenType: selectedTokenType
        ) else { return }
        flowController.toClose(serviceData)
    }
}

extension AddingServiceManuallyPresenter {
    func validateAddService() {
        isAddServiceEnabled = isCorrectServiceName &&
        isCorrectSecret &&
        ((advancedShown && isCorrectAdditionalInfo) || (!advancedShown))
    }
    
    enum ServiceNameValidationResult: Error {
        case correct
        case tooLong
        case tooShort
        
        var error: String? {
            switch self {
            case .correct: return nil
            case .tooLong: return T.Commons.textLongTitle(ServiceRules.serviceNameMaxLength)
            case .tooShort: return T.Commons.textShortTitle(ServiceRules.serviceNameMinLength)
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
            self.serviceName = serviceName
            checkForServiceIcon()
            value = .correct
        } else if trimmed.isEmpty {
            self.serviceName = ""
            serviceIcon = nil
            value = .tooShort
        } else {
            self.serviceName = ""
            serviceIcon = nil
            value = .tooLong
        }
        validateAddService()
        return value
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
    
    func validateSecret(_ secret: String) -> SecretValidationResult {
        let value: SecretValidationResult
        isCorrectSecret = false
        
        if ServiceRules.isPrivateKeyTooShort(privateKey: secret) {
            value = .tooShort
            self.secret = ""
        } else if ServiceRules.isPrivateKeyTooLong(privateKey: secret) {
            value = .tooLong
            self.secret = ""
        } else if !ServiceRules.isPrivateKeyValid(privateKey: secret) {
            value = .incorrect
            self.secret = ""
        } else if interactor.isPrivateKeyUsed(secret) {
            value = .duplicated
            self.secret = ""
        } else {
            isCorrectSecret = true
            self.secret = secret
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
            self.additionalInfo = ""
        } else {
            isCorrectAdditionalInfo = true
            self.additionalInfo = additionalInfo
            value = .correct
        }
        
        validateAddService()
        return value
    }
    
    func checkForServiceIcon() {
        interactor.checkForServiceIcon(using: serviceName) { [weak self] img, iconTypeID in
            self?.serviceIcon = img
            self?.iconTypeID = iconTypeID
        }
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
    
    // MARK: - To external input
    
    func handleSelectAlgorithm() {
        flowController.toAlgorithmSelection(selectedOption: selectedAlgorithm)
    }
    
    func handleSelectRefreshTime() {
        flowController.toRefreshTimeSelection(selectedOption: selectedRefreshTime)
    }
    
    func handleSelectDigits() {
        flowController.toDigitsSelection(selectedOption: selectedDigits)
    }
    
    func handleShowInitialCounterInput() {
        flowController.toInitialCounterInput(currentValue: initialCounter)
    }
    
    // MARK: - From External input
    
    func handleAlgorithmSelection(_ algorithm: Algorithm) {
        self.selectedAlgorithm = algorithm
    }
    
    func handleRefreshTimeSelection(_ time: Period) {
        self.selectedRefreshTime = time
    }
    
    func handleDigitsSelection(_ digits: Digits) {
        self.selectedDigits = digits
    }

    func handleInitialCounter(_ counter: Int) {
        self.initialCounter = counter
    }
}
