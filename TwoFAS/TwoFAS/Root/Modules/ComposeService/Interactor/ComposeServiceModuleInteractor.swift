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
import Storage
import Data

enum ComposeServiceModuleInteractorActionType {
    case new
    case edit
}

enum ComposeServiceModuleInteractorPrivateKeyError {
    case empty
    case incorrect
    case tooShort
    case duplicated
}

// swiftlint:disable discouraged_none_name
enum ComposeServiceModuleInteractorSectionState {
    case none
    case initial(current: SectionID?)
    case modified(previous: SectionID?, current: SectionID?)
    
    var isDifferent: Bool {
        switch self {
        case .none: return false
        case .initial: return false
        case .modified(let previous, let current): return previous != current
        }
    }
    
    var sectionID: SectionID? {
        switch self {
        case .none: return nil
        case .initial(let current): return current
        case .modified(_, let current): return current
        }
    }
}
// swiftlint:enable discouraged_none_name

protocol ComposeServiceModuleInteracting: AnyObject {
    var webExtensionActive: Bool { get }
    var serviceName: String? { get }
    var additionalInfo: String? { get }
    var privateKey: String? { get }
    
    var iconType: IconType { get }
    var iconTypeID: IconTypeID { get }
    var labelTitle: String { get }
    var labelColor: TintColor { get }
    var iconTypeName: String { get }
    
    var isBrandIconEnabled: Bool { get }
    var isLabelEnabled: Bool { get }
    
    var badgeColor: TintColor { get }
    
    var isDataValid: Bool { get }
    var isPINSet: Bool { get }
    
    var serviceData: ServiceData? { get }
    
    var actionType: ComposeServiceModuleInteractorActionType { get }
    var privateKeyError: ComposeServiceModuleInteractorPrivateKeyError? { get }
    
    var isBrowserExtensionAllowed: Bool { get }
    
    var isSecretCopyingBlocked: Bool { get }
    
    var isDataCorrectNotifier: ((Bool) -> Void)? { get set }
    var serviceWasCreated: ((ServiceData) -> Void)? { get set }
    
    func trashService()
    func copySecret()
    
    func setServiceName(_ newServiceName: String?)
    func setAdditionalInfo(_ newAdditionalInfo: String?)
    
    func setPrivateKey(_ newPrivateKey: String?)
    func setIconType(_ iconType: IconType)
    
    func save()
    func initialize()
    
    var advancedAlertShown: Bool { get }
    func markAdvancedAlertAsShown()
    
    var advancedSettings: ComposeServiceAdvancedSettings { get }
    func saveAdvancedSettings(_ advancedSettings: ComposeServiceAdvancedSettings)
    
    var isEditing: Bool { get }
    
    var sectionID: SectionID? { get }
    var selectedSectionTitle: String? { get }
    
    // MARK: - External editors
    func setIconTypeID(_ newIconTypeID: IconTypeID)
    func setLabel(_ newLabelTitle: String, labelColor newLabelColor: TintColor)
    func setBadgeColor(_ newBadgeColor: TintColor)
    func setSectionID(_ sectionID: SectionID?)
}

final class ComposeServiceModuleInteractor {
    var isDataCorrectNotifier: ((Bool) -> Void)?
    var serviceWasCreated: ((ServiceData) -> Void)?
    
    private var isServiceNameCorrect = false
    private var isAdditionalInfoCorrect = false
    
    private(set) var serviceName: String?
    private(set) var additionalInfo: String?
    private(set) var privateKey: String?
    
    private(set) var iconType: IconType = .brand
    private(set) var iconTypeID: IconTypeID = .default
    private(set) var labelTitle: String = ServiceRules.defaultTwoLetters
    private(set) var labelColor: TintColor = .lightBlue
    
    private(set) var tokenType: TokenType = .defaultValue
    private(set) var algorithm: Algorithm = .defaultValue
    private(set) var period: Period?
    private(set) var digits: Digits = .defaultValue
    private(set) var counter: Int?
    
    var isSecretCopyingBlocked: Bool {
        mdmInteractor.isBackupBlocked
    }
    
    // MARK: Section
    private var sectionState: ComposeServiceModuleInteractorSectionState = .none
    
    private(set) var badgeColor: TintColor = .default
    
    private(set) var privateKeyError: ComposeServiceModuleInteractorPrivateKeyError?
    
    private let isServiceNameValid = ServiceRules.isServiceNameValid
    private let isPrivateKeyValid = ServiceRules.isPrivateKeyValid
    private let isPrivateKeyTooShort = ServiceRules.isPrivateKeyTooShort
    
    private let modifyInteractor: ServiceModifyInteracting
    private let trashingServiceInteractor: TrashingServiceInteracting
    private let protectionInteractor: ProtectionInteracting
    private let secret: Secret?
    private let webExtensionAuthInteractor: WebExtensionAuthInteracting
    private let sectionInteractor: SectionInteracting
    private let notificationsInteractor: NotificationInteracting
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting
    private let advancedAlertInteractor: AdvancedAlertInteracting
    private let mdmInteractor: MDMInteracting
    
    private(set) var serviceData: ServiceData?
    
    init(
        modifyInteractor: ServiceModifyInteracting,
        trashingServiceInteractor: TrashingServiceInteracting,
        protectionInteractor: ProtectionInteracting,
        secret: Secret?,
        webExtensionAuthInteractor: WebExtensionAuthInteracting,
        sectionInteractor: SectionInteracting,
        notificationsInteractor: NotificationInteracting,
        serviceDefinitionInteractor: ServiceDefinitionInteracting,
        advancedAlertInteractor: AdvancedAlertInteracting,
        mdmInteractor: MDMInteracting
    ) {
        self.modifyInteractor = modifyInteractor
        self.trashingServiceInteractor = trashingServiceInteractor
        self.protectionInteractor = protectionInteractor
        self.secret = secret
        self.webExtensionAuthInteractor = webExtensionAuthInteractor
        self.sectionInteractor = sectionInteractor
        self.notificationsInteractor = notificationsInteractor
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
        self.advancedAlertInteractor = advancedAlertInteractor
        self.mdmInteractor = mdmInteractor
        
        updateValues()
    }
}

extension ComposeServiceModuleInteractor: ComposeServiceModuleInteracting {
    var webExtensionActive: Bool {
        guard let serviceData else { return false }
        return !webExtensionAuthInteractor.pairings(for: serviceData.secret).isEmpty
    }
    
    var isBrandIconEnabled: Bool {
        iconType == .brand
    }
    
    var isLabelEnabled: Bool {
        iconType == .label
    }
    
    var actionType: ComposeServiceModuleInteractorActionType {
        if isEditing {
            return .edit
        }
        return .new
    }
    
    var iconTypeName: String {
        serviceDefinitionInteractor.name(for: iconTypeID) ?? ""
    }
    
    var isBrowserExtensionAllowed: Bool {
        !mdmInteractor.isBrowserExtensionBlocked
    }
    
    func setServiceName(_ newServiceName: String?) {
        serviceName = newServiceName
        validate()
    }
    
    func setAdditionalInfo(_ newAdditionalInfo: String?) {
        additionalInfo = {
            if let newAdditionalInfo, !newAdditionalInfo.isEmpty {
                return newAdditionalInfo
            }
            return nil
        }()
        validate()
    }
    
    func setPrivateKey(_ newPrivateKey: String?) {
        guard !isEditing else { return }
        privateKey = newPrivateKey
        validate()
    }
    
    func setIconType(_ iconType: IconType) {
        guard self.iconType != iconType else { return }
        
        self.iconType = iconType
        
        validate()
    }
    
    func save() {
        validate()
        guard isDataValid else { return }
        
        if let serviceData, let serviceName, isEditing {
            modifyInteractor.updateService(
                serviceData,
                name: serviceName,
                additionalInfo: additionalInfo,
                badgeColor: badgeColor,
                iconType: iconType,
                iconTypeID: iconTypeID,
                labelColor: labelColor,
                labelTitle: labelTitle
            )
            if sectionState.isDifferent {
                sectionInteractor.moveServiceToSection(move: serviceData.secret, to: sectionID)
            }
        } else {
            guard let serviceName, let privateKey, !serviceExists(for: privateKey) else { return }
            
            modifyInteractor.addService(
                name: serviceName,
                secret: privateKey,
                serviceTypeID: nil,
                additionalInfo: additionalInfo,
                rawIssuer: nil,
                otpAuth: nil,
                tokenPeriod: period ?? .defaultValue,
                tokenLength: digits,
                badgeColor: badgeColor,
                iconType: iconType,
                iconTypeID: iconTypeID,
                labelColor: labelColor,
                labelTitle: labelTitle,
                algorithm: algorithm,
                counter: counter,
                tokenType: tokenType,
                source: .manual,
                sectionID: sectionID
            )
            
            logSave()
            
            guard let serviceData = modifyInteractor.service(for: privateKey) else { return }
            serviceWasCreated?(serviceData)
        }
    }
    
    var isDataValid: Bool {
        isServiceNameCorrect && (privateKeyError == nil) && isAdditionalInfoCorrect
    }
    
    var isPINSet: Bool {
        protectionInteractor.isPINSet
    }
    
    var selectedSectionTitle: String? {
        guard let sectionID else { return nil }
        return sectionInteractor.section(for: sectionID)?.title
    }
    
    var sectionID: SectionID? {
        sectionState.sectionID
    }
    
    func trashService() {
        guard let serviceData else { return }
        trashingServiceInteractor.trashService(serviceData)
    }
    
    func copySecret() {
        guard let privateKey else { return }
        notificationsInteractor.copyWithSuccess(value: privateKey)
    }
    
    func initialize() {
        validate()
    }
    
    var advancedSettings: ComposeServiceAdvancedSettings {
        .init(
            tokenType: tokenType,
            algorithm: algorithm,
            period: period,
            digits: digits,
            counter: counter
        )
    }
    
    func saveAdvancedSettings(_ advancedSettings: ComposeServiceAdvancedSettings) {
        guard !isEditing else { return }
        
        guard tokenType != advancedSettings.tokenType ||
                algorithm != advancedSettings.algorithm ||
                period != advancedSettings.period ||
                digits != advancedSettings.digits ||
                counter != advancedSettings.counter else { return }
        
        tokenType = advancedSettings.tokenType ?? .defaultValue
        algorithm = advancedSettings.algorithm ?? .defaultValue
        period = advancedSettings.period
        digits = advancedSettings.digits ?? .defaultValue
        counter = advancedSettings.counter
        
        validate()
    }
    
    var isEditing: Bool {
        serviceData != nil
    }
    
    // MARK: - External editors
    func setIconTypeID(_ newIconTypeID: IconTypeID) {
        guard iconTypeID != newIconTypeID else { return }
        
        iconTypeID = newIconTypeID
        
        validate()
    }
    
    func setLabel(_ newLabelTitle: String, labelColor newLabelColor: TintColor) {
        guard newLabelTitle != labelTitle || newLabelColor != labelColor else { return }
        
        labelTitle = newLabelTitle
        labelColor = newLabelColor
        
        validate()
    }
    
    func setBadgeColor(_ newBadgeColor: TintColor) {
        guard newBadgeColor != badgeColor else { return }
        
        badgeColor = newBadgeColor
        
        validate()
    }
    
    var advancedAlertShown: Bool {
        advancedAlertInteractor.wasShowed
    }
    
    func markAdvancedAlertAsShown() {
        advancedAlertInteractor.markAsShown()
    }
    
    func setSectionID(_ sectionID: SectionID?) {
        guard self.sectionID != sectionID else { return }
        
        let previousSectionID = self.sectionID
        if let serviceData, serviceData.sectionID == sectionID {
            sectionState = .initial(current: sectionID)
        } else {
            sectionState = .modified(previous: previousSectionID, current: sectionID)
        }
        
        validate()
    }
}

private extension ComposeServiceModuleInteractor {
    func validate() {
        validateServiceName()
        validatePrivateKey()
        validateAdditionalInfo()
        let correctData = isDataValid
        Log("ComposeServiceModuleInteractor - validate: \(correctData)", module: .moduleInteractor, save: false)
        isDataCorrectNotifier?(correctData)
    }
    
    func validateServiceName() {
        guard let serviceName else {
            isServiceNameCorrect = false
            return
        }
        
        isServiceNameCorrect = isServiceNameValid(serviceName)
    }
    
    func validatePrivateKey() {
        guard !isEditing else { return }
        
        guard let privateKey, !privateKey.isEmpty else {
            privateKeyError = .empty
            return
        }
        
        if isPrivateKeyValid(privateKey) {
            if serviceExists(for: privateKey) {
                privateKeyError = .duplicated
            } else {
                privateKeyError = nil
            }
        } else {
            if isPrivateKeyTooShort(privateKey) {
                privateKeyError = .tooShort
            } else {
                privateKeyError = .incorrect
            }
        }
    }
    
    func validateAdditionalInfo() {
        guard let additionalInfo else {
            isAdditionalInfoCorrect = true
            return
        }
        isAdditionalInfoCorrect = additionalInfo.count <= ServiceRules.additionalInfoMaxLength
    }
    
    func serviceExists(for secret: String) -> Bool {
        modifyInteractor.serviceExists(for: secret) == .yes
    }
    
    func updateValues() {
        guard let secret, let service = modifyInteractor.service(for: secret) else { return }
        serviceData = service
        
        guard let serviceData else { return }
        
        serviceName = serviceData.name
        additionalInfo = serviceData.additionalInfo
        privateKey = serviceData.secret
        
        iconType = serviceData.iconType
        iconTypeID = serviceData.iconTypeID
        labelTitle = serviceData.labelTitle
        labelColor = serviceData.labelColor
        if let badgeColor = serviceData.badgeColor {
            self.badgeColor = badgeColor
        }
        
        tokenType = serviceData.tokenType
        algorithm = serviceData.algorithm
        period = serviceData.tokenPeriod
        digits = serviceData.tokenLength
        
        let sectionData = sectionInteractor.section(for: secret)
        sectionState = .initial(current: sectionData?.sectionID)
        
        if let counter = serviceData.counter {
            self.counter = counter
        }
    }
    
    func logSave() {
        let codeType: String = tokenType.rawValue
        AppEventLog(.codeDetailsTypeAdded(codeType))
        
        let algorithmString: String = algorithm.rawValue
        
        AppEventLog(.codeDetailsAlgorithmChosen(algorithmString))
        
        let refreshTime: String = {
            if let period {
                return String(period.rawValue)
            }
            return String(Period.defaultValue.rawValue)
        }()
        
        AppEventLog(.codeDetailsRefreshTimeChosen(refreshTime))
        
        let digitsString = String(digits.rawValue)
        
        AppEventLog(.codeDetailsNumberOfDigitsChosen(digitsString))
        
        let counterString: String = {
            if let counter {
                return String(counter)
            }
            return String(TokenType.hotpDefaultValue)
        }()
        
        if tokenType == .hotp {
            AppEventLog(.codeDetailsInitialCounterChosen(counterString))
        }
    }
}
