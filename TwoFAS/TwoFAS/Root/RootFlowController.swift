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

extension UIWindow.Level {
    static let toast = UIWindow.Level.normal + 4
    static let cover = UIWindow.Level.normal + 3
    static let login = UIWindow.Level.normal + 2
}

protocol RootFlowControllerParent: AnyObject {}

protocol RootFlowControlling: AnyObject {
    func toIntro()
    /// `animated` brings the app in under the departing login screen, see `UnlockTransition`.
    func toMain(animated: Bool)
    func toStorageError(error: String)

    func toCover()
    func toRemoveCover()

    func toLogin()
    func toRemoveLogin()

    func toDismissKeyboard()
}

final class RootFlowController: FlowController {
    private weak var parent: RootFlowControllerParent?
    private weak var loginViewController: UIViewController?
    private weak var window: UIWindow?
    
    private let coverWindow: UIWindow = {
        let window = UIWindow()
        window.windowLevel = .cover
        window.backgroundColor = .clear
        return window
    }()
    
    private let loginWindow: UIWindow = {
        let window = UIWindow()
        window.windowLevel = .login
        window.backgroundColor = .clear
        return window
    }()
    
    private var mainViewController: MainViewController?
    
    static func setAsRoot(
        in window: UIWindow?,
        parent: RootFlowControllerParent
    ) -> RootViewController {
        ToastPresenter.shared.windowLevel = .toast

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
        IntroductionNavigationFlowController.embedAsRoot(in: viewController, parent: self)
    }
    
    func toMain(animated: Bool) {
        if mainViewController == nil {
            mainViewController = MainFlowController.showAsRoot(in: viewController, parent: self)
        } else {
            mainViewController?.viewDidAppear(false)
        }
        if animated, let main = mainViewController?.view {
            reveal(main)
        }
    }

    /// Brings the app in under the login screen flying away, see `UnlockTransition.Main`:
    /// it comes into focus, fades up and grows to full size. The blur is a visual effect view
    /// laid over the app, which blurs what is beneath it; animating its effect away takes the
    /// radius down to nothing, then the view is removed. It sits inside `main`, so it scales
    /// along with it.
    private func reveal(_ main: UIView) {
        typealias Config = UnlockTransition.Main

        let blur = Config.blur.map { effect in
            let view = UIVisualEffectView(effect: effect)
            view.isUserInteractionEnabled = false
            main.addSubview(view)
            view.pinToParent()
            return view
        }
        main.alpha = Config.startAlpha
        main.transform = CGAffineTransform(scaleX: Config.scale, y: Config.scale)

        let focus = UIViewPropertyAnimator(duration: Config.duration, curve: .easeOut) {
            blur?.effect = nil
            main.alpha = 1
        }
        focus.addCompletion { _ in
            blur?.removeFromSuperview()
        }
        focus.startAnimation()

        UIViewPropertyAnimator(duration: Config.duration, dampingRatio: 1) {
            main.transform = .identity
        }
        .startAnimation()
    }
    
    func toStorageError(error: String) {
        let alert = AlertControllerDismissFlow(title: T.Commons.error, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        viewController.present(alert, animated: false, completion: nil)
    }
    
    func toCover() {
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        coverWindow.rootViewController = storyboard.instantiateViewController(withIdentifier: "LaunchScreen")

        coverWindow.windowScene = window?.windowScene
        coverWindow.isHidden = false
        coverWindow.makeKeyAndVisible()
    }
    
    func toRemoveCover() {
        coverWindow.rootViewController = nil
        coverWindow.removeFromSuperview()
        coverWindow.isHidden = true
    }
    
    func toLogin() {
        guard loginViewController == nil else { return }
        
        let loginViewController = LoginFlowController.setAsCover(
            in: loginWindow,
            parent: self
        )
        
        self.loginViewController = loginViewController
        loginWindow.windowScene = window?.windowScene
        loginWindow.isHidden = false
        loginWindow.makeKeyAndVisible()
    }
    
    func toRemoveLogin() {
        loginViewController?.view.removeFromSuperview()
        loginViewController = nil
        loginWindow.endEditing(true)
        loginWindow.isHidden = true
        loginWindow.rootViewController = nil
        window?.makeKey()
    }
    
    func toDismissKeyboard() {
        loginWindow.endEditing(true)
        window?.endEditing(true)
    }
}

extension RootFlowController: IntroductionNavigationFlowControllerParent {
    func introductionHasFinished(introViewController: UIViewController) {
        UIView.animate(withDuration: Theme.Animations.Timing.quick, delay: 0, options: .curveEaseInOut) {
            introViewController.view.alpha = 0
        } completion: { _ in
            introViewController.willMove(toParent: nil)
            introViewController.removeFromParent()
            introViewController.view.removeFromSuperview()
            introViewController.didMove(toParent: nil)
            self.viewController.presenter.handleIntroHasFinished()
        }
    }
}

extension RootFlowController: MainFlowControllerParent {}

extension RootFlowController: LoginFlowControllerParent {
    func loginClose() {
        toRemoveLogin()
    }
    
    func loginLoggedIn() {
        viewController.presenter.handleUserWasLoggedIn()
    }

    func loginTransitionFinished() {
        toRemoveLogin()
    }
}
