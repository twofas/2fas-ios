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

/// Timing and geometry of the hand-over from the login screen to the app: the login screen
/// grows towards the viewer and fades, while the app underneath comes into focus from a blur
/// and grows to full size.
enum UnlockTransition {
    /// How long the login screen takes to go; the window is released when this ends.
    static let loginDuration: TimeInterval = 0.2
    /// How long the app takes to settle underneath; independent of the login screen.
    static let mainDuration: TimeInterval = 0.3
    /// The login screen ends this much larger than the screen, as if it flew past the viewer.
    static let loginScale: CGFloat = 1.2
    /// The app starts this small and settles at 1; `1` keeps it still.
    static let mainScale: CGFloat = 0.8
    /// Opacity the app starts at and fades up from to 1 on the fade curve; `1` skips the fade.
    static let mainStartAlpha: CGFloat = 0.0
    /// Blur the app starts under; it clears over `mainDuration`. The style sets the radius and
    /// the haze the system lays over blurred content. `nil` leaves the app sharp throughout.
    static let mainBlur: UIBlurEffect? = UIBlurEffect(style: .regular)
    /// Curve of the login screen's fade. Ease-out is mostly done early on and ends exactly at
    /// `loginDuration`, so no half-transparent ghost trails behind. The app's fade and blur
    /// use the same shape over `mainDuration`.
    static var animation: Animation { .easeOut(duration: loginDuration) }
    /// Curve of the login screen's scale: ease-in, so it keeps gaining speed and is still
    /// accelerating when the fade has removed it, as if it flew past rather than stopped.
    /// The app's zoom underneath is the opposite, a critically damped spring settling in.
    static var scaleAnimation: Animation { .easeIn(duration: loginDuration) }
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
    
    static func setAsCover(
        in window: UIWindow,
        parent: LoginFlowControllerParent
    ) -> UIViewController {
        let flowController = LoginFlowController(viewController: UIViewController())
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.loginModuleInteractor()
        
        let presenter = LoginPresenter(
            loginType: .login,
            flowController: flowController,
            interactor: interactor
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
