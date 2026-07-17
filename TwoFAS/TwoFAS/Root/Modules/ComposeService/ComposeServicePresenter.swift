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

import SwiftUI
import Common
import Storage

final class ComposeServicePresenter: ObservableObject {
    @Published var serviceName = ""
    @Published var additionalInfo = ""
    @Published var iconType: IconType = .brand
    @Published var iconTypeID: IconTypeID = .default
    @Published var labelTitle = ServiceRules.defaultTwoLetters
    @Published var labelColor: TintColor = .lightBlue
    @Published var badgeColor: TintColor = .default
    @Published var sectionTitle = ""
    @Published var iconTypeName = ""
    @Published var isSaveEnabled = false
    @Published var isWebExtensionActive = false
    @Published var revealedSecret: String?
    @Published var isSetPINAlertPresented = false
    @Published var isRevealMenuPresented = false
    @Published var serviceNameError: String?
    @Published var additionalInfoError: String?

    private var isLocked = true
    private let flowController: ComposeServiceFlowControlling
    let interactor: ComposeServiceModuleInteracting
    private let freshlyAdded: Bool

    init(
        flowController: ComposeServiceFlowControlling,
        interactor: ComposeServiceModuleInteracting,
        freshlyAdded: Bool
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.freshlyAdded = freshlyAdded

        interactor.isDataCorrectNotifier = { [weak self] _ in self?.refreshStatus() }
    }
}

extension ComposeServicePresenter {
    var secretKeyMode: ComposeServiceSecretKeyMode {
        if let revealedSecret {
            return .revealed(revealedSecret)
        }
        if interactor.privateKey == nil {
            return .empty
        }
        if interactor.isSecretCopyingBlocked {
            return .hiddenNonCopyable
        }
        return .hidden
    }

    var isBrowserExtensionAllowed: Bool {
        interactor.isBrowserExtensionAllowed
    }

    var isBrandIconRowEnabled: Bool {
        interactor.isBrandIconEnabled
    }

    var isLabelRowEnabled: Bool {
        interactor.isLabelEnabled
    }

    func viewWillAppear() {
        reload()
    }

    func handleCancel() {
        flowController.toClose()
    }

    func handleSave() {
        guard interactor.isDataValid else { return }
        interactor.save()
        flowController.toClose()
    }

    func handleServiceNameUpdate(_ value: String) {
        interactor.setServiceName(value)
        validateServiceName()
    }

    func handleAdditionalInfoUpdate(_ value: String) {
        interactor.setAdditionalInfo(value)
        validateAdditionalInfo()
    }

    func handleIconType(_ iconType: IconType) {
        interactor.setIconType(iconType)
        reload()
    }

    func handleBadgeColor(_ color: TintColor) {
        interactor.setBadgeColor(color)
        reload()
    }

    func handleLabel() {
        guard interactor.iconType == .label else { return }
        flowController.toLabelEditor(title: interactor.labelTitle, color: interactor.labelColor)
    }

    func handleBrandIcon() {
        guard interactor.iconType == .brand else { return }
        flowController.toBrandIconSelection(
            defaultIcon: .default,
            selectedIcon: interactor.iconTypeID,
            animated: true
        )
    }

    func handleAdvanced() {
        flowController.toAdvancedSummary(settings: interactor.advancedSettings)
    }

    func handleBrowserExtension() {
        guard let secret = interactor.serviceData?.secret, interactor.webExtensionActive else { return }
        flowController.toBrowserExtension(with: secret)
    }

    func handleCategory() {
        flowController.toCategorySelection(with: interactor.sectionID)
    }

    func handleAskForDeletition() {
        guard let serviceData = interactor.serviceData else { return }
        flowController.toDelete(serviceData: serviceData)
    }

    func handleReveal() {
        if interactor.isPINSet {
            if isLocked {
                flowController.toLogin()
            } else {
                isRevealMenuPresented = true
            }
        } else {
            isSetPINAlertPresented = true
        }
    }

    func handleShare() {
        isRevealMenuPresented = true
    }

    func handleServicesWereUpdated(modified: [Secret]?, deleted: [Secret]?) {
        guard let secret = interactor.serviceData?.secret else { return }
        if let deleted, deleted.first(where: { $0 == secret }) != nil {
            flowController.toServiceWasDeleted()
        } else if let modified, modified.first(where: { $0 == secret }) != nil {
            guard !freshlyAdded else { return }
            flowController.toServiceWasModified()
        }
    }

    // MARK: - External controllers

    func handleSwitchToSetupPIN() {
        flowController.toSetupPIN()
    }

    func handleAuthorized() {
        guard let privateKey = interactor.privateKey else { return }
        isLocked = false
        revealedSecret = privateKey
    }

    func handleDeletition() {
        interactor.trashService()
        flowController.toClose()
    }

    func handlColorPickerDidSelectColor(_ color: TintColor) {
        interactor.setBadgeColor(color)
        reload()
    }

    func handleIconSelectorDidSelect(selectedIconTypeID: IconTypeID) {
        interactor.setIconTypeID(selectedIconTypeID)
        reload()
    }

    func handleLabelComposeSave(title: String, color: TintColor) {
        interactor.setLabel(title, labelColor: color)
        reload()
    }

    func handleSectionSelected(_ sectionID: SectionID?) {
        interactor.setSectionID(sectionID)
        reload()
    }

    // MARK: Reveal menu
    func handleShowQRCode() {
        Task {
            guard let code = await interactor.createQRCode(size: Config.minQRCodeSize, margin: 0) else {
                Log("ComposeServicePresenter: Error while generating QR Code", severity: .error)
                return
            }
            Task { @MainActor in
                flowController.toShowQRCode(code: code)
            }
        }
    }

    func handleShareQRCode() {
        Task {
            guard let code = await interactor.createQRCode(size: Config.minQRCodeSize, margin: 0) else {
                Log("ComposeServicePresenter: Error while generating QR Code", severity: .error)
                return
            }
            Task { @MainActor in
                flowController.toShareQRCode(code: code)
            }
        }
    }

    func handleCopySecret() {
        interactor.copySecret()
        VoiceOver.say(T.Notifications.serviceKeyCopied)
        ToastPresenter.shared.presentServiceKeyCopied()
    }

    func handleCopyLink() {
        interactor.copyLink()
        VoiceOver.say(T.Notifications.linkCopied)
        ToastPresenter.shared.presentLinkCopied()
    }

    // MARK: - Start editing
    func handleToIconEditFromStart() {
        flowController.toBrandIconSelection(defaultIcon: .default, selectedIcon: interactor.iconTypeID, animated: false)
    }
}

private extension ComposeServicePresenter {
    func reload() {
        serviceName = interactor.serviceName ?? ""
        additionalInfo = interactor.additionalInfo ?? ""
        iconType = interactor.iconType
        iconTypeID = interactor.iconTypeID
        labelTitle = interactor.labelTitle
        labelColor = interactor.labelColor
        badgeColor = interactor.badgeColor
        sectionTitle = interactor.selectedSectionTitle ?? T.Tokens.myTokens
        iconTypeName = interactor.iconTypeName
        isWebExtensionActive = interactor.webExtensionActive
        refreshStatus()
    }

    func refreshStatus() {
        isSaveEnabled = interactor.isDataValid && interactor.hasChanges
    }

    func validateServiceName() {
        let trimmed = serviceName.trim()
        if trimmed.isEmpty {
            serviceNameError = T.Commons.textShortTitle(ServiceRules.serviceNameMinLength)
        } else if trimmed.count > ServiceRules.serviceNameMaxLength {
            serviceNameError = T.Commons.textLongTitle(ServiceRules.serviceNameMaxLength)
        } else {
            serviceNameError = nil
        }
    }

    func validateAdditionalInfo() {
        if additionalInfo.count > ServiceRules.additionalInfoMaxLength {
            additionalInfoError = T.Commons.textLongTitle(ServiceRules.additionalInfoMaxLength)
        } else {
            additionalInfoError = nil
        }
    }
}
