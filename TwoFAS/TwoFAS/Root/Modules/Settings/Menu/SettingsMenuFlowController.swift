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
    func appSecurityChaged()
    func toSwitchToBackup()

    func handleNavigateToViewPath(_ viewPath: ViewPath.Settings, force: Bool)
    func restoreSelection(_ viewPath: ViewPath.Settings?)
    var currentViewPath: ViewPath.Settings? { get }
    func showSidebarReveal(action: @escaping () -> Void)
}

protocol SettingsMenuFlowControllerParent: AnyObject {
    func toBackup()
    func toSecurity()
    func toFAQ()
    func toTrash()
    func toAbout()
    func toBrowserExtension()
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?)
    func toTransfer()
    func toAppearance()
    func toAppleWatch()
    func toPopDetailToRoot()
    #if DEV
    func toDebug()
    #endif
}

protocol SettingsMenuFlowControlling: AnyObject {
    func toBackup()
    func toSecurity()
    func toFAQ()
    func toTrash()
    func toWidgetEnablingWarning()
    func toBrowserExtension()
    func toAbout()
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?)
    func toTransfer()
    func toAppearance()
    func toAppleWatch()
    func toTwoPASSAppStore()
    func toOpenTwoPASS()
    func toPopDetailToRoot()
    #if DEV
    func toDebug()
    #endif
}

final class SettingsMenuFlowController: FlowController {
    private weak var parent: SettingsMenuFlowControllerParent?
    fileprivate var presenter: SettingsMenuPresenter?

    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: SettingsMenuFlowControllerParent
    ) -> (flow: SettingsMenuFlowControllerChild, view: UIViewController) {
        // Native navigation chrome: the settings list shows a native title bar
        // (the bar is never hidden).
        let hosting = UIHostingController(rootView: AnyView(EmptyView()))
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
    func toPopDetailToRoot() { parent?.toPopDetailToRoot() }
    #if DEV
    func toDebug() { parent?.toDebug() }
    #endif
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

    func appSecurityChaged() {
        presenter?.handleAppSecurityChaged()
    }

    func toSwitchToBackup() {
        presenter?.handleSwitchToBackup()
    }

    func handleNavigateToViewPath(_ viewPath: ViewPath.Settings, force: Bool) {
        presenter?.handleNavigateToViewPath(viewPath, force: force)
    }

    func restoreSelection(_ viewPath: ViewPath.Settings?) {
        presenter?.restoreSelection(viewPath)
    }

    var currentViewPath: ViewPath.Settings? {
        presenter?.currentViewPath
    }

    func showSidebarReveal(action: @escaping () -> Void) {
        presenter?.sidebarRevealAction = action
        presenter?.showsSidebarButton = true
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
