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

protocol SettingsFlowControllerParent: AnyObject {
    func settingsToUpdateCurrentPosition(_ viewPath: ViewPath.Settings?)
}

protocol SettingsFlowControlling: AnyObject {
    func toInitialConfiguration()
    func toCollapsedView()
    func toExpandedView()
    func toShowingRootMenu()
    func toSwitchToSetupPIN()
    func toSwitchToBrowserExtension()
}

final class SettingsFlowController: FlowController {
    private weak var parent: SettingsFlowControllerParent?
    
    private var navigationMenu: SettingsMenuFlowControllerChild?
    
    private var isCollapsed: Bool {
        viewController.isCollapsed
    }
    
    static func showAsATab(
        in tabBarController: UITabBarController,
        parent: SettingsFlowControllerParent
    ) {
        let view = SettingsViewController()
        let flowController = SettingsFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.settingsModuleInteractor()
        let presenter = SettingsPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        view.tabBarItem = UITabBarItem(
            title: T.Settings.settings,
            image: Asset.tabBarIconSettingsInactive.image,
            selectedImage: Asset.tabBarIconSettingsActive.image
        )
        
        tabBarController.addTab(view)
    }
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: SettingsFlowControllerParent
    ) -> SettingsViewController {
        let view = SettingsViewController()
        let flowController = SettingsFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.settingsModuleInteractor()
        let presenter = SettingsPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        view.hideNavigationBar = true
        
        navigationController.setViewControllers([view], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
        return view
    }
}

private extension SettingsFlowController {
    func setInitialMenu() {
        navigationMenu = SettingsMenuFlowController.showAsRoot(in: viewController.navigationNavi, parent: self)
    }
}

extension SettingsFlowController: SettingsFlowControlling {
    func toInitialConfiguration() {
        setInitialMenu()
    }
    
    func toCollapsedView() {
        navigationMenu?.toCollapsed()
        
        if viewController.contentNavi.viewControllers.isEmpty {
            navigationMenu?.toSelectedModule()
        } else {
            var vcs = viewController.navigationNavi.viewControllers
            vcs += viewController.contentNavi.viewControllers
            viewController.navigationNavi.setViewControllers(vcs, animated: false)
        }
    }
    
    func toExpandedView() {
        navigationMenu?.toExpanded()
        
        if let vcs = viewController.navigationNavi.popToRootViewController(animated: false), !vcs.isEmpty {
            vcs.forEach({ $0.willMove(toParent: viewController.contentNavi) })
            DispatchQueue.main.async {
                self.viewController.contentNavi.setViewControllers(vcs, animated: false)
            }
        } else {
            navigationMenu?.toSelectedModule()
        }
    }
    
    func toShowingRootMenu() {
        navigationMenu?.toShowingRoot()
    }
    
    func toSwitchToSetupPIN() {
        navigationMenu?.toSwitchToSetupPIN()
    }
    
    func toSwitchToBrowserExtension() {
        navigationMenu?.toSwitchToBrowserExtension()
    }
}

extension SettingsFlowController {
    var viewController: SettingsViewController { _viewController as! SettingsViewController }
}

extension SettingsFlowController: SettingsMenuFlowControllerParent {
    func toBackup() {
        if isCollapsed {
            BackupMenuFlowController.push(in: viewController.navigationNavi, parent: self)
        } else {
            BackupMenuFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
        }
    }
    
    func toSecurity() {
        if isCollapsed {
            AppSecurityFlowController.push(in: viewController.navigationNavi, parent: self)
        } else {
            AppSecurityFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
        }
    }
    
    func toTrash() {
        if isCollapsed {
            TrashFlowController.push(in: viewController.navigationNavi, parent: self)
        } else {
            TrashFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
        }
    }
    
    func toFAQ() {
        UIApplication.shared.open(ExternalLinks.support.url, options: [:], completionHandler: nil)
    }
    
    func toAbout() {
        if isCollapsed {
            AboutFlowController.push(in: viewController.navigationNavi, parent: self)
        } else {
            AboutFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
        }
    }
    
    func toSocialChannel(_ socialChannel: SocialChannel) {
        UIApplication.shared.open(socialChannel.url, options: [:], completionHandler: nil)
    }
    
    func toBrowserExtension() {
        if isCollapsed {
            BrowserExtensionMainFlowController.push(in: viewController.navigationNavi, parent: self)
        } else {
            BrowserExtensionMainFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
        }
    }
    
    func toDonate() {
        UIApplication.shared.open(URL(string: "https://2fas.com/donate")!, options: [:], completionHandler: nil)
    }
    
    func toUpdateCurrentPosition(_ viewPath: ViewPath.Settings?) {
        parent?.settingsToUpdateCurrentPosition(viewPath)
    }
}
extension SettingsFlowController: BackupMenuFlowControllerParent {
    func showFAQ() {
        if isCollapsed {
            viewController.navigationNavi.popToRootViewController(animated: false)
        }
        navigationMenu?.toSwitchToFAQ()
    }
}

extension SettingsFlowController: TrashFlowControllerParent {}

extension SettingsFlowController: PushNotificationPermissionFlowControllerParent {
    func pushNotificationsDidEnd() {}
}

extension SettingsFlowController: AppSecurityFlowControllerParent {
    func appSecurityChaged() {
        navigationMenu?.appSecurityChaged()
    }
}

extension SettingsFlowController: BrowserExtensionMainFlowControllerParent {}

extension SettingsFlowController: AboutFlowControllerParent {}
