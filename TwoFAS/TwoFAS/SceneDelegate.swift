//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private(set) var rootViewController: RootViewController?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard !ProcessInfo.isSwiftUIPreview else { return }
        guard let windowScene = scene as? UIWindowScene else { return }

        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 480, height: 720)
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        rootViewController = RootFlowController.setAsRoot(in: window, parent: self)
        window.makeKeyAndVisible()

        rootViewController?.presenter.initialize()

        if let url = connectionOptions.urlContexts.first?.url {
            _ = rootViewController?.presenter.shouldHandleURL(url: url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = rootViewController?.presenter.shouldHandleURL(url: url)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        rootViewController?.presenter.applicationWillResignActive()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        rootViewController?.presenter.applicationDidEnterBackground()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        rootViewController?.presenter.applicationWillEnterForeground()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        rootViewController?.presenter.applicationDidBecomeActive()
    }
}

extension SceneDelegate: RootFlowControllerParent {}
