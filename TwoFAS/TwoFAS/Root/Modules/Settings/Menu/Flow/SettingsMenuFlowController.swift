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
import Data

protocol SettingsMenuFlowControllerChild: AnyObject {
    func toCollapsed()
    func toExpanded()
    func toSelectedModule()
    func toShowingRoot()
    func toSwitchToSetupPIN()
    func toSwitchToBrowserExtension()
    func toSwitchToFAQ()
    func appSecurityChaged()
    func toSwitchToExternlImport()
    func toSwitchToAppearance()
    func toSwitchToBackup()
}

protocol SettingsMenuFlowControllerParent: AnyObject {
    func toBackup()
    func toSecurity()
    func toFAQ()
    func toTrash()
    func toAbout()
    func toSocialChannel(_ socialChannel: SocialChannel)
    func toBrowserExtension()
    func toDonate()
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?)
    func toExternalImport()
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
    func toDonate()
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?)
    func toExternalImport()
    func toAppearance()
    func toAppleWatch()
}

final class SettingsMenuFlowController: FlowController {
    private weak var parent: SettingsMenuFlowControllerParent?
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: SettingsMenuFlowControllerParent
    ) -> (flow: SettingsMenuFlowControllerChild, view: SettingsMenuViewController) {
        let view = SettingsMenuViewController()
        let flowController = SettingsMenuFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.settingsMenuModuleInteractor()
        let presenter = SettingsMenuPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
    
        navigationController.setViewControllers([view], animated: false)
        
        return (flow: flowController, view: view)
    }
}

extension SettingsMenuFlowController {
    var viewController: SettingsMenuViewController { _viewController as! SettingsMenuViewController }
}

private extension SettingsMenuFlowController { }

extension SettingsMenuFlowController: SettingsMenuFlowControlling {
    func toBackup() { parent?.toBackup() }
    func toSecurity() { parent?.toSecurity() }
    func toFAQ() { parent?.toFAQ() }
    func toTrash() { parent?.toTrash() }
    func toAbout() { parent?.toAbout() }
    func toDonate() { parent?.toDonate() }
    func toWidgetEnablingWarning() {
        WidgetWarningFlowController.present(on: viewController, parent: self)
    }
    func toSocialChannel(_ socialChannel: SocialChannel) {
        parent?.toSocialChannel(socialChannel)
    }
    func toBrowserExtension() { parent?.toBrowserExtension() }
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?) { parent?.toUpdateCurrentPosition(viewPath) }
    func toExternalImport() { parent?.toExternalImport() }
    func toAppearance() { parent?.toAppearance() }
    func toAppleWatch() { parent?.toAppleWatch() }
}

extension SettingsMenuFlowController: SettingsMenuFlowControllerChild {
    func toCollapsed() {
        viewController.presenter.setCollapsed()
    }
    
    func toExpanded() {
        viewController.presenter.setExpanded()
    }
    
    func toSelectedModule() {
        viewController.presenter.handleShowSelected()
    }
    
    func toShowingRoot() {
        viewController.presenter.handleShowingRoot()
    }
    
    func toSwitchToSetupPIN() {
        viewController.presenter.handleToSetupPIN()
    }
    
    func toSwitchToFAQ() {
        viewController.presenter.handleToFAQ()
    }
    
    func appSecurityChaged() {
        viewController.presenter.handleAppSecurityChaged()
    }
    
    func toSwitchToBrowserExtension() {
        viewController.presenter.handleSwitchToBrowserExtension()
    }
    
    func toSwitchToExternlImport() {
        viewController.presenter.handleToExternalImport()
    }
    func toSwitchToAppearance() {
        viewController.presenter.handleSwitchToAppearance()
    }

    func toSwitchToBackup() {
        viewController.presenter.handleSwitchToBackup()
    }
}

extension SettingsMenuFlowController: WidgetWarningFlowControllerParent {
    func hideWidgetWarning() {
        viewController.dismiss(animated: true, completion: nil)
        viewController.presenter.handleWidgetsCanceledFromWarningWindow()
    }
    
    func hideWidgetWarningAndEnable() {
        viewController.dismiss(animated: true, completion: nil)
        viewController.presenter.handleEnableWidgetsFromWarningWindow()
    }
}
