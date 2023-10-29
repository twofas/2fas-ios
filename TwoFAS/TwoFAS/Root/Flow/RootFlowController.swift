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

protocol RootFlowControlling: AnyObject {
    func toIntro()
    func toMain(immediately: Bool)
    func toLogin()
    func toAppLock()
    func toStorageError(error: String)
}

final class RootFlowController: FlowController {
    
    var viewController: RootViewController {
        _viewController as! RootViewController
    }
}

extension RootFlowController: RootFlowControlling {
    func toIntro(){
        let navigationController = CommonNavigationController()
        let intro = IntroductionCoordinator()
        intro.markAsShownAction = { [weak self] in
            self?.viewController.presenter.handleIntroMarkAsShown()
        }
        
        let adapter = PreviousToCurrentCoordinatorAdapter(
            navigationController: navigationController,
            coordinator: intro
        )
        
        viewController.present(navigationController, immediately: false, animationType: .alpha)
        intro.start()
    }
    
    func toMain(immediately: Bool) {
        MainFlowController.showAsRoot(in: viewController, parent: self, immediately: immediately)
    }
    
    func toLogin() {
//        let loginCoordinator = LoginCoordinator(
//            security: mainRepository.security,
//            leftButtonDescription: nil,
//            rootViewController: rootViewController,
//            showImmediately: immediately
//        )
//        loginCoordinator.parentCoordinatorDelegate = self
//        addChild(loginCoordinator)
//        loginCoordinator.start()
    }
    
    func toAppLock() {
        
    }
    
    func toStorageError(error: String) {
        let alert = AlertControllerDismissFlow(title: T.Commons.error, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        viewController.present(alert, animated: false, completion: nil)
    }
}

extension RootFlowController { // TODO: Remove when Intro moved to proper arch
    func didFinish() {
        viewController.presenter.handleIntroHasFinished()
    }
}

extension RootFlowController: MainFlowControllerParent {}
