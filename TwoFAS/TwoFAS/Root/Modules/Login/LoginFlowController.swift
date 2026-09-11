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
/// With Reduce Motion on, both halves only fade: no zoom, no blur. Resolved here, so both
/// halves follow the setting the same way. `RootFlowController` applies both with UIKit
/// animators.
enum UnlockTransition {
    private static var reducesMotion: Bool { UIAccessibility.isReduceMotionEnabled }

    /// A screen on its way out over the app: the lock screen, the cover, the introduction.
    /// The scale runs on an ease-in, which keeps gaining speed so the screen is still
    /// accelerating when the fade has removed it: a fly-past, not a stop. The fade runs on an
    /// ease-out, mostly done early on and ending exactly at `duration`, so no
    /// half-transparent ghost trails behind.
    enum Login {
        static let duration: TimeInterval = 0.2
        /// Final scale, as if the screen flew past the viewer.
        static var scale: CGFloat { reducesMotion ? 1 : 1.15 }
    }

    /// The app settling in underneath: fade and blur on an ease-out, the zoom on a critically
    /// damped spring.
    enum Main {
        static let duration: TimeInterval = 0.3
        /// Starting scale; `1` keeps the app still.
        static var scale: CGFloat { reducesMotion ? 1 : 0.8 }
        /// Starting opacity; `1` skips the fade.
        static let startAlpha: CGFloat = 0
        /// Blur the app starts under; the style sets the radius and the haze the system lays
        /// over blurred content. `nil` leaves the app sharp throughout.
        static var blur: UIBlurEffect? { reducesMotion ? nil : UIBlurEffect(style: .regular) }
    }
}

protocol LoginFlowControllerParent: AnyObject {
    func loginClose()
    /// The user is in: show the app. The lock screen's parent sends the screen off over the
    /// app and releases its window afterwards.
    func loginLoggedIn()
}

protocol LoginFlowControlling: AnyObject {
    func toClose()
    func toLoggedIn()
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
}
