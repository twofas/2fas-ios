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
import FirebaseMessaging
import Common
import Data

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private lazy var readyPushInteractor: RootInteracting = InteractorFactory.shared.rootInteractor()
    /// `nil` while the local storage isn't ready (`LocalStoragePreflight`) – the app doesn't exist then. A launch
    /// in the background (no scene yet) checks it here.
    private var pushInteractor: RootInteracting? {
        guard LocalStoragePreflight.run(userVisible: false) == .ready else { return nil }
        return readyPushInteractor
    }

    private var rootViewController: RootViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0.delegate as? SceneDelegate)?.rootViewController }
            .first
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard !ProcessInfo.isSwiftUIPreview else { return true }

        DataExternalTranslations.setTranslations(serviceNameTranslation: T.Commons.service)

        application.shortcutItems = QuickAction.shortcutItems

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        rootViewController?.presenter.applicationWillTerminate()
    }
    
    // MARK: - Push Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushInteractor?.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        pushInteractor?.didFailToRegisterForRemoteNotifications(with: error)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let pushInteractor else {
            completionHandler(.failed)
            return
        }
        pushInteractor.didReceiveRemoteNotification(
            userInfo: userInfo,
            fetchCompletionHandler: completionHandler
        )
    }
}
