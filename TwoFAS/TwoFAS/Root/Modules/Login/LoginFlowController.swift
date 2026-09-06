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

import SwiftUI

/// Timing and geometry of the hand-over from the login screen to the app. The login screen
/// grows towards the viewer and fades out; the app underneath comes into focus, fades up and
/// grows to full size. The two halves live in different windows and run on their own clocks.
enum UnlockTransition {
    /// The login screen on its way out. `LoginView` applies these; `LoginPresenter` drives
    /// them and releases the window when `fade` ends.
    enum Login {
        static let duration: TimeInterval = 0.2
        /// Final scale, as if the screen flew past the viewer.
        static let scale: CGFloat = 1.15
        /// Fade curve. Ease-out is mostly done early on and ends exactly at `duration`, so no
        /// half-transparent ghost trails behind.
        static var fade: Animation { .easeOut(duration: duration) }
        /// Scale curve. Ease-in keeps gaining speed, so the screen is still accelerating when
        /// the fade has removed it: a fly-past, not a stop.
        static var zoom: Animation { .easeIn(duration: duration) }
    }

    /// The app settling in underneath. `RootFlowController` applies these with UIKit
    /// animators: fade and blur on an ease-out, the zoom on a critically damped spring.
    enum Main {
        static let duration: TimeInterval = 0.3
        /// Starting scale; `1` keeps the app still.
        static let scale: CGFloat = 0.8
        /// Starting opacity; `1` skips the fade.
        static let startAlpha: CGFloat = 0
        /// Blur the app starts under; the style sets the radius and the haze the system lays
        /// over blurred content. `nil` leaves the app sharp throughout.
        static let blur: UIBlurEffect? = UIBlurEffect(style: .regular)
    }
}

protocol LoginFlowControllerParent: AnyObject {
    func loginClose()
    /// The user is in: show the app. For the lock screen the login window is still up and
    /// animating away; it is released in `loginTransitionFinished`.
    func loginLoggedIn()
    /// The login screen has finished its exit animation and can be taken down.
    func loginTransitionFinished()
}

protocol LoginFlowControlling: AnyObject {
    func toClose()
    func toLoggedIn()
    func toLoggedInTransitionFinished()
}

final class LoginFlowController: FlowController {
    private weak var parent: LoginFlowControllerParent?
    
    /// `fromColdStart`: the screen is the first thing after the system launch screen and
    /// starts as its copy, see `LoginPresenter.showsSplash`.
    static func setAsCover(
        in window: UIWindow,
        parent: LoginFlowControllerParent,
        fromColdStart: Bool
    ) -> UIViewController {
        let flowController = LoginFlowController(viewController: UIViewController())
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.loginModuleInteractor()
        
        let presenter = LoginPresenter(
            loginType: .login,
            flowController: flowController,
            interactor: interactor,
            followsLaunchScreen: fromColdStart
        )
        
        let viewController = LoginViewController(presenter: presenter)
        window.rootViewController = viewController

        return viewController
    }
    
    static func present(
        on viewController: UIViewController,
        parent: LoginFlowControllerParent
    ) {
        let flowController = LoginFlowController(viewController: UIViewController())
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.loginModuleInteractor()
        let presenter = LoginPresenter(
            loginType: .verify,
            flowController: flowController,
            interactor: interactor
        )
        let view = LoginViewController(presenter: presenter)

        view.configureAsModal()
        viewController.present(view, animated: true, completion: nil)
    }
}

extension LoginFlowController: LoginFlowControlling {
    func toClose() {
        parent?.loginClose()
    }
    
    func toLoggedIn() {
        parent?.loginLoggedIn()
    }

    func toLoggedInTransitionFinished() {
        parent?.loginTransitionFinished()
    }
}
