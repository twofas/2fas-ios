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
    func toBrandIconSelection(defaultIcon: IconTypeID?, selectedIcon: IconTypeID?, animated: Bool)
    func toLabelEditor(title: String, color: TintColor)
    func toDelete(serviceData: ServiceData)
    func toSetupPIN()
    func toAdvancedSummary(settings: ComposeServiceAdvancedSettings)
    func toBrowserExtension(with secret: String)
    func toCategorySelection(with sectionID: SectionID?)
    func toServiceWasCreated(serviceData: ServiceData)
    func toServiceWasModified()
    func toServiceWasDeleted()
    func toShowQRCode(code: UIImage)
    func toShareQRCode(code: UIImage)
}

final class ComposeServiceFlowController: FlowController {
    private weak var parent: ComposeServiceFlowControllerParent?
    private weak var navigationController: UINavigationController?
    private var presenter: ComposeServicePresenter?

    static func present(
        in navigationController: UINavigationController,
        parent: ComposeServiceFlowControllerParent,
        serviceData: ServiceData?,
        gotoIconEdit: Bool,
        freshlyAdded: Bool
    ) {
        let hostingController = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        let flowController = ComposeServiceFlowController(viewController: hostingController)
        flowController.parent = parent
        flowController.navigationController = navigationController

        let interactor = ModuleInteractorFactory.shared.composeServiceModuleInteractor(secret: serviceData?.secret)
        let presenter = ComposeServicePresenter(
            flowController: flowController,
            interactor: interactor,
            freshlyAdded: freshlyAdded
        )
        flowController.presenter = presenter

        hostingController.rootView = AnyView(ComposeServiceView(presenter: presenter))
        hostingController.view.backgroundColor = AppColor.backgroundsPrimaryElevated.uiColor

        navigationController.pushViewController(hostingController, animated: false)

        if gotoIconEdit {
            presenter.handleToIconEditFromStart()
        }
    }
}

extension ComposeServiceFlowController: ComposeServiceFlowControlling {
    func toClose() {
        UIAccessibility.post(notification: .announcement, argument: T.Voiceover.dismissing)
        parent?.composeServiceDidFinish()
    }

    func toLogin() {
        guard let viewController = _viewController else { return }
        LoginFlowController.present(on: viewController, parent: self)
    }

    func toBrandIconSelection(defaultIcon: IconTypeID?, selectedIcon: IconTypeID?, animated: Bool) {
        guard let navi = navigationController else { return }
        IconSelectorFlowController.present(
            defaultIcon: defaultIcon,
            selectedIcon: selectedIcon,
            on: navi,
            parent: self,
            animated: animated
        )
    }

    func toLabelEditor(title: String, color: TintColor) {
        guard let navi = navigationController else { return }
        LabelComposeFlowController.present(title: title, color: color, on: navi, parent: self)
    }

    func toDelete(serviceData: ServiceData) {
        guard let viewController = _viewController else { return }
        TrashServiceFlowController.present(on: viewController, parent: self, serviceData: serviceData)
    }

    func toSetupPIN() {
        parent?.composeServiceDidFinish()
        NotificationCenter.default.post(name: .switchToSetupPIN, object: nil)
    }

    func toAdvancedSummary(settings: ComposeServiceAdvancedSettings) {
        guard let navi = navigationController else { return }
        ComposeServiceAdvancedSummaryFlowController.present(in: navi, parent: self, settings: settings)
    }

    func toBrowserExtension(with secret: String) {
        guard let navi = navigationController else { return }
        ComposeServiceWebExtensionFlowController.present(in: navi, parent: self, secret: secret)
    }

    func toCategorySelection(with sectionID: SectionID?) {
        guard let navi = navigationController else { return }
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

    func toShowQRCode(code: UIImage) {
        guard let viewController = _viewController else { return }
        QRCodeDisplayFlowController.present(
            on: viewController,
            parent: self,
            qrCodeImage: code
        )
    }

    func toShareQRCode(code: UIImage) {
        guard let viewController = _viewController else { return }
        let activityVC = ShareActivityController.createWithQRCode(code, title: T.Tokens.qrCodeShare)
        viewController.present(activityVC, animated: true, completion: nil)
    }
}

private extension ComposeServiceFlowController {
    func dismiss(completion: (() -> Void)? = nil) {
        guard let viewController = _viewController else { return }
        if let presented = viewController.presentedViewController, !presented.isBeingDismissed {
            viewController.dismiss(animated: true, completion: completion)
        }
    }

    func pop() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension ComposeServiceFlowController: QRCodeDisplayFlowControllerParent {
    func closeQRCodeDisplay() {
        _viewController?.dismiss(animated: true)
    }
}

extension ComposeServiceFlowController: TrashServiceFlowControllerParent {
    func didTrashService() {
        presenter?.handleDeletition()
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
        presenter?.handleAuthorized()
        dismiss()
    }
}

extension ComposeServiceFlowController: IconSelectorFlowControllerParent {
    func iconSelectorDidSelect(iconTypeID: IconTypeID) {
        presenter?.handleIconSelectorDidSelect(selectedIconTypeID: iconTypeID)
        pop()
    }
}

extension ComposeServiceFlowController: LabelComposeFlowControllerParent {
    func labelComposeSave(title: String, color: TintColor) {
        presenter?.handleLabelComposeSave(title: title, color: color)
        pop()
    }
}

extension ComposeServiceFlowController: ComposeServiceAdvancedSummaryFlowControllerParent {
    func advancedSummaryDidFinish() {
        toClose()
    }
}

extension ComposeServiceFlowController: ComposeServiceWebExtensionFlowControllerParent {
    func webExtensionDidFinish() {
        pop()
    }
}

extension ComposeServiceFlowController: ComposeServiceCategorySelectionFlowControllerParent {
    func didChangeSectionID(_ sectionID: SectionID?) {
        presenter?.handleSectionSelected(sectionID)
    }
}
