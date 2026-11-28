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
import SwiftUI
import Common
import Data

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private(set) var rootViewController: RootViewController?
    /// Starts the app once the local storage is ready. Set while the Local Data Unavailable screen is shown.
    private var startAppWhenReady: Callback?
    /// The local storage isn't ready and it wasn't checked as a launch opened by the user yet
    private var needsCheckOpenedByUser = false

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard !ProcessInfo.isSwiftUIPreview else { return }
        guard let windowScene = scene as? UIWindowScene else { return }

        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 480, height: 720)
        
        let window = UIWindow(windowScene: windowScene)
        if #unavailable(iOS 26.0) {
            window.tintColor = AppColor.accentsBrand.uiColor
        }
        self.window = window

        // Nothing of the app is created before the local storage is ready.
        // A scene is connected also when the system launches the app in the background (a push, a background
        // refresh), and nothing here tells such a launch from the user opening the app – the application state
        // is `.background` in both. So this check never counts towards removing the data of a lost key and never
        // removes it: that's left to the check made when the scene comes to the foreground.
        let status = LocalStoragePreflight.run(userVisible: false)
        guard status == .ready else {
            // A failed migration has nothing to count – it isn't run twice in a row
            needsCheckOpenedByUser = status != .migrationFailed
            Log("SceneDelegate: local storage isn't ready, presenting Local Data Unavailable")
            startAppWhenReady = { [weak self] in
                self?.startAppWhenReady = nil
                self?.startApp(in: window, connectionOptions: connectionOptions)
            }
            presentLocalDataUnavailable(status: status, in: window)
            window.makeKeyAndVisible()
            return
        }
        startApp(in: window, connectionOptions: connectionOptions)
    }

    private func presentLocalDataUnavailable(status: LocalStorageStatus, in window: UIWindow) {
        let unavailable = LocalDataUnavailableView(status: status) { [weak self] in
            self?.startAppWhenReady?()
        }
        window.rootViewController = UIHostingController(rootView: unavailable)
    }

    /// The scene comes to the foreground – the user sees the app – while the local storage isn't ready: checks
    /// it again, this time as a launch opened by the user (counted once per launch).
    private func recheckLocalStorage() {
        guard needsCheckOpenedByUser, let startAppWhenReady, let window else { return }
        needsCheckOpenedByUser = false
        let status = LocalStoragePreflight.run(userVisible: true)
        if status == .ready {
            startAppWhenReady()
        } else {
            presentLocalDataUnavailable(status: status, in: window)
        }
    }

    private func startApp(in window: UIWindow, connectionOptions: UIScene.ConnectionOptions) {
        rootViewController = RootFlowController.setAsRoot(in: window, parent: self)
        window.makeKeyAndVisible()

        rootViewController?.presenter.initialize()

        if let url = connectionOptions.urlContexts.first?.url {
            _ = rootViewController?.presenter.shouldHandleURL(url: url)
        }

        if let shortcutItem = connectionOptions.shortcutItem,
           let action = QuickAction(shortcutType: shortcutItem.type) {
            InteractorFactory.shared.appStateInteractor().storeQuickAction(action)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = rootViewController?.presenter.shouldHandleURL(url: url)
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        // While the local storage isn't ready the app doesn't exist yet
        guard LocalStoragePreflight.isReady, let action = QuickAction(shortcutType: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        InteractorFactory.shared.appStateInteractor().storeQuickAction(action)
        completionHandler(true)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        rootViewController?.presenter.applicationWillResignActive()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        rootViewController?.presenter.applicationDidEnterBackground()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        recheckLocalStorage()
        rootViewController?.presenter.applicationWillEnterForeground()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        rootViewController?.presenter.applicationDidBecomeActive()
    }
}

extension SceneDelegate: RootFlowControllerParent {}
