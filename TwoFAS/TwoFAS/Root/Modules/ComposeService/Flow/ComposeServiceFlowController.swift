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
import Storage
import Common
import SwiftUI
import Data

protocol ComposeServiceFlowControllerParent: AnyObject {
    func composeServiceDidFinish()
    func composeServiceWasCreated(serviceData: ServiceData)
    func composeServiceServiceWasModified()
    func composeServiceServiceWasDeleted()
}

protocol ComposeServiceFlowControlling: AnyObject {
    func toClose()
    func toLogin()
    func toSetPIN()
    func toBadgeEditor(currentColor: TintColor)
    func toBrandIconSelection(defaultIcon: IconTypeID?, selectedIcon: IconTypeID?, animated: Bool)
    func toLabelEditor(title: String, color: TintColor)
    func toDelete(serviceData: ServiceData)
    func toSetupPIN()
    func toAdvancedSummary(settings: ComposeServiceAdvancedSettings)
    func toAdvancedNewService(settings: ComposeServiceAdvancedSettings)
    func toAdvancedWarning()
    func toBrowserExtension(with secret: String)
    func toCategorySelection(with sectionID: SectionID?)
    func toServiceWasCreated(serviceData: ServiceData)
    func toServiceWasModified()
    func toServiceWasDeleted()
}

final class ComposeServiceFlowController: FlowController {
    private weak var parent: ComposeServiceFlowControllerParent?
    
    static func present(
        in navigationController: UINavigationController,
        parent: ComposeServiceFlowControllerParent,
        serviceData: ServiceData?,
        gotoIconEdit: Bool,
        freshlyAdded: Bool
    ) {
        let view = ComposeServiceViewController()
        let flowController = ComposeServiceFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = ModuleInteractorFactory.shared.composeServiceModuleInteractor(secret: serviceData?.secret)
        let presenter = ComposeServicePresenter(
            flowController: flowController,
            interactor: interactor,
            freshlyAdded: freshlyAdded
        )
        presenter.view = view
        
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: false)
        
        if gotoIconEdit {
            presenter.handleToIconEditFromStart()
        }
    }
}

extension ComposeServiceFlowController {
    var viewController: ComposeServiceViewController { _viewController as! ComposeServiceViewController }
}

extension ComposeServiceFlowController: ComposeServiceFlowControlling {
    func toClose() {
        UIAccessibility.post(notification: .announcement, argument: T.Voiceover.dismissing)
        parent?.composeServiceDidFinish()
    }
    
    func toLogin() {
        LoginFlowController.present(on: viewController, parent: self)
    }
    
    func toSetPIN() {
        let alert = UIAlertController(
            title: T.Commons.notice,
            message: T.Tokens.showServiceKeySetupLock,
            preferredStyle: .alert
        )
        let setPIN = UIAlertAction(title: T.Commons.set, style: .destructive) { [weak self] _ in
            self?.viewController.presenter.handleSwitchToSetupPIN()
        }
        
        let cancel = UIAlertAction(title: T.Commons.cancel, style: .cancel)
        alert.addAction(setPIN)
        alert.addAction(cancel)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toBadgeEditor(currentColor: TintColor) {
        ColorPickerFlowController.present(currentColor: currentColor, on: viewController, parent: self)
    }
    
    func toBrandIconSelection(defaultIcon: IconTypeID?, selectedIcon: IconTypeID?, animated: Bool) {
        guard let navi = viewController.navigationController else { return }
        IconSelectorFlowController.present(
            defaultIcon: defaultIcon,
            selectedIcon: selectedIcon,
            on: navi,
            parent: self,
            animated: animated
        )
    }
    
    func toLabelEditor(title: String, color: TintColor) {
        guard let navi = viewController.navigationController else { return }
        LabelComposeFlowController.present(title: title, color: color, on: navi, parent: self)
    }
    
    func toDelete(serviceData: ServiceData) {
        TrashServiceFlowController.present(on: viewController, parent: self, serviceData: serviceData)
    }
    
    func toSetupPIN() {
        parent?.composeServiceDidFinish()
        NotificationCenter.default.post(name: .switchToSetupPIN, object: nil)
    }
    
    func toAdvancedSummary(settings: ComposeServiceAdvancedSettings) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceAdvancedSummaryFlowController.present(in: navi, parent: self, settings: settings)
    }
    
    func toAdvancedNewService(settings: ComposeServiceAdvancedSettings) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceAdvancedEditFlowController.present(in: navi, parent: self, settings: settings)
    }
    
    func toAdvancedWarning() {
        AdvancedAlertFlowController.present(on: viewController, parent: self)
    }
    
    func toBrowserExtension(with secret: String) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceWebExtensionFlowController.present(in: navi, parent: self, secret: secret)
    }
    
    func toCategorySelection(with sectionID: SectionID?) {
        guard let navi = viewController.navigationController else { return }
        ComposeServiceCategorySelectionFlowController.push(on: navi, parent: self, selectedSection: sectionID)
    }
    
    func toServiceWasCreated(serviceData: ServiceData) {
        parent?.composeServiceWasCreated(serviceData: serviceData)
    }
    
    func toServiceWasModified() {
        parent?.composeServiceServiceWasModified()
    }
    
    func toServiceWasDeleted() {
        parent?.composeServiceServiceWasDeleted()
    }
}

private extension ComposeServiceFlowController {
    func dismiss(completion: (() -> Void)? = nil) {
        if let presented = viewController.presentedViewController, !presented.isBeingDismissed {
            viewController.dismiss(animated: true, completion: completion)
        }
    }
    
    func pop() {
        viewController.navigationController?.popToRootViewController(animated: true)
    }
}

extension ComposeServiceFlowController: TrashServiceFlowControllerParent {
    func didTrashService() {
        viewController.presenter.handleDeletition()
    }
    
    func closeTrashService() {
        dismiss()
    }
}

extension ComposeServiceFlowController: LoginFlowControllerParent {
    func loginClose() {
        dismiss()
    }
    
    func loginLoggedIn() {
        viewController.presenter.handleAuthorized()
        dismiss()
    }
}

extension ComposeServiceFlowController: ColorPickerFlowControllerParent {
    func colorPickerDidSelectColor(_ tintColor: TintColor) {
        dismiss { [weak self] in
            self?.viewController.presenter.handlColorPickerDidSelectColor(tintColor)
        }
    }
    func colorPickerDidClose() {
        dismiss()
    }
}

extension ComposeServiceFlowController: IconSelectorFlowControllerParent {
    func iconSelectorDidSelect(iconTypeID: IconTypeID) {
        viewController.presenter.handleIconSelectorDidSelect(selectedIconTypeID: iconTypeID)
        pop()
    }
}

extension ComposeServiceFlowController: LabelComposeFlowControllerParent {
    func labelComposeSave(title: String, color: TintColor) {
        viewController.presenter.handleLabelComposeSave(title: title, color: color)
        pop()
    }
}

extension ComposeServiceFlowController: AdvancedAlertFlowControllerParent {
    func advancedAlertContinue() {
        dismiss { [weak self] in
            self?.viewController.presenter.handleProceedToAdvanced()
        }
    }
    
    func advancedAlertCancel() {
        dismiss()
    }
}

extension ComposeServiceFlowController: ComposeServiceAdvancedSummaryFlowControllerParent {
    func advancedSummaryDidFinish() {
        toClose()
    }
}

extension ComposeServiceFlowController: ComposeServiceAdvancedEditFlowControllerParent {
    func advancedEditDidChange(settings: ComposeServiceAdvancedSettings) {
        viewController.presenter.handleSaveAdvancedSettings(settings)
    }
}

extension ComposeServiceFlowController: ComposeServiceWebExtensionFlowControllerParent {
    func webExtensionDidFinish() {
        pop()
    }
}

extension ComposeServiceFlowController: ComposeServiceCategorySelectionFlowControllerParent {
    func didChangeSectionID(_ sectionID: SectionID?) {
        viewController.presenter.handleSectionSelected(sectionID)
    }
}
