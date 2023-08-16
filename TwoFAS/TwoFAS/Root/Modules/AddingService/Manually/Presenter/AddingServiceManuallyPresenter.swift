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

final class AddingServiceManuallyPresenter: ObservableObject {
    @Published var isAddServiceEnabled = false
    
    private var isCorrectServiceName = false
    private var isCorrectSecret = false
    private var isCorrectAdditionalInfo = false
    
    @Published var serviceName: String = ""
    @Published var serviceIcon: UIImage?
    @Published var secret: String = ""
    @Published var advancedShown = false
    
    weak var view: AddingServiceManuallyViewControlling?
    
    private let flowController: AddingServiceManuallyFlowControlling
    private let interactor: AddingServiceManuallyModuleInteracting
    
    init(flowController: AddingServiceManuallyFlowControlling, interactor: AddingServiceManuallyModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension AddingServiceManuallyPresenter {
    func viewDidLoad() {
    }
    
    func viewWillAppear() {
    }
    
    func viewWillDisappear() {
    }
    
    func handleAddService() {
    }
    
    func handleHelp() {
    }
}

extension AddingServiceManuallyPresenter {
    func validateAddService() {
        isAddServiceEnabled = isCorrectServiceName && isCorrectSecret //&& isCorrectAdditionalInfo
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
        if serviceName.count >= ServiceRules.serviceNameMinLength &&
            serviceName.count <= ServiceRules.serviceNameMaxLength {
            isCorrectServiceName = true
            self.serviceName = serviceName
            checkForServiceIcon()
            value = .correct
        } else if serviceName.isEmpty {
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
    
    func checkForServiceIcon() {
        interactor.checkForServiceIcon(using: serviceName) { [weak self] img in
            self?.serviceIcon = img
        }
    }
}
