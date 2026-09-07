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
    /// `animated` brings the app in from under something flying away, see
    /// `UnlockTransition`: the lock screen or the introduction.
    func toMain(animated: Bool)
    func toStorageError(error: String)

    func toCover()
    /// `animated`: the app comes in from under the cover flying away, see `UnlockTransition`;
    /// otherwise the cover is simply gone.
    func toRemoveCover(animated: Bool)

    /// `fromColdStart`: the login screen follows the system launch screen directly.
    func toLogin(fromColdStart: Bool)
    func toRemoveLogin()

    func toDismissKeyboard()
}

final class RootFlowController: FlowController {
    private weak var parent: RootFlowControllerParent?
    /// The lock screen while it is up. `nil` from the unlock on: the departing screen still
    /// sits in the window while it flies away, but a lock that lands meanwhile puts a fresh
    /// one in its place.
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

    func toRemoveCover(animated: Bool) {
        guard animated, let cover = coverWindow.rootViewController?.view, let main = mainViewController?.view else {
            removeCover()
            return
        }
        reveal(main)
        flyAway(cover) { [weak self] in
            // A cover put up in the meantime, for a trip to the background, stays.
            guard let self, cover === coverWindow.rootViewController?.view else { return }
            removeCover()
        }
    }

    /// Sends a view off, see `UnlockTransition.Login`: it grows past the viewer and fades,
    /// taking no touches meanwhile; `completion` then takes it down.
    private func flyAway(_ view: UIView, completion: @escaping () -> Void) {
        typealias Config = UnlockTransition.Login

        view.isUserInteractionEnabled = false
        UIViewPropertyAnimator(duration: Config.duration, curve: .easeIn) {
            view.transform = CGAffineTransform(scaleX: Config.scale, y: Config.scale)
        }
        .startAnimation()

        let fade = UIViewPropertyAnimator(duration: Config.duration, curve: .easeOut) {
            view.alpha = 0
        }
        fade.addCompletion { _ in
            completion()
        }
        fade.startAnimation()
    }

    private func removeCover() {
        coverWindow.rootViewController = nil
        coverWindow.removeFromSuperview()
        coverWindow.isHidden = true
        window?.makeKey()
    }

    /// Brings the app in under the login screen flying away, see `UnlockTransition.Main`:
    /// it comes into focus, fades up and grows to full size. The blur is a visual effect view
    /// laid over the app, which blurs what is beneath it; animating its effect away takes the
    /// radius down to nothing, then the view is removed. It sits inside `main`, so it scales
    /// along with it.
    ///
    /// A screen presented over the app lives in the window, outside `main`, and would stand
    /// still while the app behind it came in; under one the app stays put and the screen on
    /// its way out flies away over it.
    private func reveal(_ main: UIView) {
        guard viewController.presentedViewController == nil else { return }
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
    
    func toLogin(fromColdStart: Bool) {
        guard loginViewController == nil else { return }
        
        // Replaces a screen still flying away, whose exit then ends without taking the window
        // down, see `loginLoggedIn`.
        let loginViewController = LoginFlowController.setAsCover(
            in: loginWindow,
            parent: self,
            fromColdStart: fromColdStart
        )
        
        self.loginViewController = loginViewController
        loginWindow.windowScene = window?.windowScene
        loginWindow.isHidden = false
        loginWindow.makeKeyAndVisible()
    }
    
    func toRemoveLogin() {
        loginViewController = nil
        loginWindow.rootViewController?.view.removeFromSuperview()
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
        // What follows comes in underneath, the way the app does from under the lock screen
        // (see `UnlockTransition`), while the introduction flies away over it.
        viewController.presenter.handleIntroHasFinished()
        viewController.view.bringSubviewToFront(introViewController.view)
        flyAway(introViewController.view) {
            introViewController.willMove(toParent: nil)
            introViewController.removeFromParent()
            introViewController.view.removeFromSuperview()
            introViewController.didMove(toParent: nil)
        }
    }
}

extension RootFlowController: MainFlowControllerParent {}

extension RootFlowController: LoginFlowControllerParent {
    func loginClose() {
        toRemoveLogin()
    }
    
    func loginLoggedIn() {
        // The app comes in underneath first; the lock screen then flies away over it, the way
        // the cover and the introduction do, and the window goes once it is out of sight.
        let login = loginViewController
        loginViewController = nil
        viewController.presenter.handleUserWasLoggedIn()
        guard let login else { return }
        flyAway(login.view) { [weak self] in
            // A lock during the exit has replaced the screen; the replacement stays.
            guard let self, login === loginWindow.rootViewController else { return }
            toRemoveLogin()
        }
    }
}
