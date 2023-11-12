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
import Common

protocol RootFlowControllerParent: AnyObject {}

protocol RootFlowControlling: AnyObject {
    func toIntro()
    func toCover()
    func toMain(immediately: Bool)
    func toLogin(events: @escaping (@escaping Callback, @escaping Callback) -> Void)
    func toStorageError(error: String)
    func toRemoveCover(animated: Bool)
    func toDismissKeyboard()
}

final class RootFlowController: FlowController {
    private weak var parent: RootFlowControllerParent?
    private weak var coverView: UIView?
    private weak var window: UIWindow?
    
    private var mainViewController: MainViewController?
    
    static func setAsRoot(
        in window: UIWindow?,
        parent: RootFlowControllerParent
    ) -> RootViewController {
        let view = RootViewController()
        let flowController = RootFlowController(viewController: view)
        flowController.parent = parent
        flowController.window = window
        
        let interactor = ModuleInteractorFactory.shared.rootModuleInteractor()
        let presenter = RootPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        window?.rootViewController = view
        
        return view
    }
}

extension RootFlowController {
    var viewController: RootViewController {
        _viewController as! RootViewController
    }
}

extension RootFlowController: RootFlowControlling {
    func toIntro() {
        let navigationController = CommonNavigationController()
        let intro = IntroductionCoordinator()
        intro.markAsShownAction = { [weak self] in
            self?.viewController.presenter.handleIntroMarkAsShown()
        }
        
//        let adapter = PreviousToCurrentCoordinatorAdapter(
//            navigationController: navigationController,
//            coordinator: intro
//        )
        
        viewController.present(navigationController, immediately: false, animationType: .alpha)
        intro.start()
    }
    
    func toCover() {
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreen")
        guard let view = vc.view else { return }
        coverView = view
        window?.addSubview(view)
        view.pinToParent()
    }
    
    func toMain(immediately: Bool) {
        guard mainViewController == nil else { return }
        mainViewController = MainFlowController.showAsRoot(in: viewController, parent: self, immediately: immediately)
    }
    
    func toLogin(events: @escaping (@escaping Callback, @escaping Callback) -> Void) {
        guard let window else { return }
        if coverView != nil {
            removeCover()
        }
        let cover = LoginFlowController.setAsCover(
            in: window,
            parent: self
        )
        coverView = cover.view
        events(cover.viewWillAppear, cover.viewDidAppear)
    }
    
    func toStorageError(error: String) {
        let alert = AlertControllerDismissFlow(title: T.Commons.error, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        viewController.present(alert, animated: false, completion: nil)
    }
    
    func toRemoveCover(animated: Bool) {
        guard animated else {
            removeCover()
            return
        }
        UIView.animate(withDuration: Theme.Animations.Timing.quick, delay: 0, options: [.curveEaseInOut]) {
            self.coverView?.alpha = 0
        } completion: { _ in
            self.removeCover()
        }
    }
    
    func toDismissKeyboard() {
        window?.endEditing(true)
    }
}

extension RootFlowController { // TODO: Remove when Intro moved to proper arch
    func didFinish() {
        viewController.presenter.handleIntroHasFinished()
    }
    
    func removeCover() {
        coverView?.removeFromSuperview()
        coverView = nil
    }
}

extension RootFlowController: MainFlowControllerParent {}

extension RootFlowController: LoginFlowControllerParent {
    func loginClose() {
        removeLogin()
    }
    
    func loginLoggedIn() {
        removeLogin()
        viewController.presenter.handleUserWasLoggedIn()
    }
    
    private func removeLogin() {
        removeCover()
    }
}
