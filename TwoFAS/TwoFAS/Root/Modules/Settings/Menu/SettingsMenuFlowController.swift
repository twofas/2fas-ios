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
import SwiftUI
import Data
import Common

protocol SettingsMenuFlowControllerChild: AnyObject {
    func toCollapsed()
    func toExpanded()
    func toSelectedModule()
    func toShowingRoot()
    func toSwitchToSetupPIN()
    func toSwitchToBrowserExtension()
    func toSwitchToFAQ()
    func appSecurityChaged()
    func toSwitchToTransfer()
    func toSwitchToAppearance()
    func toSwitchToBackup()

    func handleNavigateToViewPath(_ viewPath: ViewPath.Settings, force: Bool)
    var currentViewPath: ViewPath.Settings? { get }
    func showSidebarReveal(action: @escaping () -> Void)
    func hideSidebarReveal()
}

protocol SettingsMenuFlowControllerParent: AnyObject {
    func toBackup()
    func toSecurity()
    func toFAQ()
    func toTrash()
    func toAbout()
    func toSocialChannel(_ socialChannel: SocialChannel)
    func toBrowserExtension()
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?)
    func toTransfer()
    func toAppearance()
    func toAppleWatch()
}

protocol SettingsMenuFlowControlling: AnyObject {
    func toBackup()
    func toSecurity()
    func toFAQ()
    func toTrash()
    func toWidgetEnablingWarning()
    func toSocialChannel(_ socialChannel: SocialChannel)
    func toBrowserExtension()
    func toAbout()
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?)
    func toTransfer()
    func toAppearance()
    func toAppleWatch()
    func toTwoPASSAppStore()
    func toOpenTwoPASS()
}

final class SettingsMenuFlowController: FlowController {
    private weak var parent: SettingsMenuFlowControllerParent?
    fileprivate var presenter: SettingsMenuPresenter?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: SettingsMenuFlowControllerParent
    ) -> (flow: SettingsMenuFlowControllerChild, view: UIViewController) {
        let hosting = NavigationBarHiddenHostingController(rootView: AnyView(EmptyView()))
        hosting.hidesBottomBarWhenPushed = false
        let flowController = SettingsMenuFlowController(viewController: hosting)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.settingsMenuModuleInteractor()
        let presenter = SettingsMenuPresenter(
            flowController: flowController,
            interactor: interactor
        )
        flowController.presenter = presenter
        hosting.rootView = AnyView(SettingsMenuView(presenter: presenter))

        navigationController.setViewControllers([hosting], animated: false)

        return (flow: flowController, view: hosting)
    }
}

extension SettingsMenuFlowController: SettingsMenuFlowControlling {
    func toBackup() { parent?.toBackup() }
    func toSecurity() { parent?.toSecurity() }
    func toFAQ() { parent?.toFAQ() }
    func toTrash() { parent?.toTrash() }
    func toAbout() { parent?.toAbout() }
    func toWidgetEnablingWarning() {
        guard let vc = _viewController else { return }
        WidgetWarningFlowController.present(on: vc, parent: self)
    }
    func toSocialChannel(_ socialChannel: SocialChannel) {
        parent?.toSocialChannel(socialChannel)
    }
    func toBrowserExtension() { parent?.toBrowserExtension() }
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?) { parent?.toUpdateCurrentPosition(viewPath) }
    func toTransfer() { parent?.toTransfer() }
    func toAppearance() { parent?.toAppearance() }
    func toAppleWatch() { parent?.toAppleWatch() }
    func toTwoPASSAppStore() {
        UIApplication.shared.open(Config.twofasPassAppStoreLink, options: [:], completionHandler: nil)
    }
    func toOpenTwoPASS() {
        UIApplication.shared.open(Config.twofasPassOpenLink, options: [:], completionHandler: nil)
    }
}

extension SettingsMenuFlowController: SettingsMenuFlowControllerChild {
    func toCollapsed() {
        presenter?.setCollapsed()
    }

    func toExpanded() {
        presenter?.setExpanded()
    }

    func toSelectedModule() {
        presenter?.handleShowSelected()
    }

    func toShowingRoot() {
        presenter?.handleShowingRoot()
    }

    func toSwitchToSetupPIN() {
        presenter?.handleToSetupPIN()
    }

    func toSwitchToFAQ() {
        presenter?.handleToFAQ()
    }

    func appSecurityChaged() {
        presenter?.handleAppSecurityChaged()
    }

    func toSwitchToBrowserExtension() {
        presenter?.handleSwitchToBrowserExtension()
    }

    func toSwitchToTransfer() {
        presenter?.handleSwitchToTransfer()
    }

    func toSwitchToAppearance() {
        presenter?.handleSwitchToAppearance()
    }

    func toSwitchToBackup() {
        presenter?.handleSwitchToBackup()
    }

    func handleNavigateToViewPath(_ viewPath: ViewPath.Settings, force: Bool) {
        presenter?.handleNavigateToViewPath(viewPath, force: force)
    }

    var currentViewPath: ViewPath.Settings? {
        presenter?.currentViewPath
    }

    func showSidebarReveal(action: @escaping () -> Void) {
        presenter?.sidebarRevealAction = action
        presenter?.showsSidebarButton = true
    }

    func hideSidebarReveal() {
        presenter?.sidebarRevealAction = nil
        presenter?.showsSidebarButton = false
    }
}

extension SettingsMenuFlowController: WidgetWarningFlowControllerParent {
    func hideWidgetWarning() {
        _viewController?.dismiss(animated: true, completion: nil)
        presenter?.handleWidgetsCanceledFromWarningWindow()
    }

    func hideWidgetWarningAndEnable() {
        _viewController?.dismiss(animated: true, completion: nil)
        presenter?.handleEnableWidgetsFromWarningWindow()
    }
}
