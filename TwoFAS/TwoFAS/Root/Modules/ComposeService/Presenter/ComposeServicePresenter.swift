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

final class ComposeServicePresenter {
    weak var view: ComposeServiceViewControlling?
    
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
    func viewWillAppear() {
        reload()
    }
    
    func handleSelection(at indexPath: IndexPath, cell: ComposeServiceSectionCell) {
        switch cell.kind {
        case .privateKey, .input, .icon: return
        case .action(let config):
            switch config.kind {
            case .delete: handleAskForDeletition()
            }
        case .navigate(let config):
            switch config.kind {
            case .label:
                guard interactor.iconType == .label else { return }
                flowController.toLabelEditor(title: interactor.labelTitle, color: interactor.labelColor)
            case .badgeColor: flowController.toBadgeEditor(currentColor: interactor.badgeColor)
            case .brandIcon:
                guard interactor.iconType == .brand else { return }
                flowController.toBrandIconSelection(
                    defaultIcon: .default,
                    selectedIcon: interactor.iconTypeID,
                    animated: true
                )
            case .advanced:
                flowController.toAdvancedSummary(settings: interactor.advancedSettings)
            case .browserExtension:
                guard let secret = interactor.serviceData?.secret, interactor.webExtensionActive else { return }
                flowController.toBrowserExtension(with: secret)
            case .category:
                let sectionID = interactor.sectionID
                flowController.toCategorySelection(with: sectionID)
            }
        }
    }
    
    func handleCancel() {
        flowController.toClose()
    }
    
    func handleSave() {
        guard interactor.isDataValid else { return }
        interactor.save()
        flowController.toClose()
    }
    
    func handleActionButton(for kind: ComposeServiceInputKind) {
        switch kind {
        case .serviceName:
            view?.becomeFirstResponder(for: .additionalInfo)
        case .privateKey:
            view?.becomeFirstResponder(for: .additionalInfo)
        case .additionalInfo:
            view?.endEditing()
        }
    }
    
    func handleValueUpdate(for kind: ComposeServiceInputKind, value: String?) {
        switch kind {
        case .serviceName:
            interactor.setServiceName(value)
        case .privateKey:
            return
        case .additionalInfo:
            interactor.setAdditionalInfo(value)
        }
        refreshStatus()
    }
    
    func handleReveal(shareButton: UIView) {
        if interactor.isPINSet {
            if isLocked {
                flowController.toLogin()
            } else {
                flowController.toRevealMenu(shareButton: shareButton)
            }
        } else {
            flowController.toSetPIN()
        }
    }
    
    func handleAskForDeletition() {
        guard let serviceData = interactor.serviceData else { return }
        flowController.toDelete(serviceData: serviceData)
    }
    
    func handleIconType(_ iconType: IconType) {
        interactor.setIconType(iconType)
        reload()
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
        
        view?.revealCode(privateKey)
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
            Task { @MainActor  in
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
            Task { @MainActor  in
                flowController.toShareQRCode(code: code)
            }
        }
    }
    
    func handleCopySecret() {
        interactor.copySecret()
        view?.copySecret()
    }
    
    func handleCopyLink() {
        interactor.copyLink()
        view?.copyLink()
    }
    
    // MARK: - Start editing
    func handleToIconEditFromStart() {
        flowController.toBrandIconSelection(defaultIcon: .default, selectedIcon: interactor.iconTypeID, animated: false)
    }
}

private extension ComposeServicePresenter {
    func reload() {
        let menu = buildMenu()
        view?.reload(with: menu)
    }
    
    func refreshStatus() {
        if interactor.isDataValid {
            view?.enableSave()
        } else {
            view?.disableSave()
        }
    }
}
