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
    var window: UIWindow?
    private var rootViewController: RootViewController?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard !ProcessInfo.isSwiftUIPreview else { return true }
        
        DataExternalTranslations.setTranslations(serviceNameTranslation: T.Commons.service)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        rootViewController = RootFlowController.setAsRoot(
            in: window,
            parent: self
        )
        window?.makeKeyAndVisible()
        
        rootViewController?.presenter.initialize()
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        rootViewController?.presenter.shouldHandleURL(url: url) == true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        rootViewController?.presenter.applicationWillResignActive()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        rootViewController?.presenter.applicationDidEnterBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        rootViewController?.presenter.applicationWillEnterForeground()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        rootViewController?.presenter.applicationDidBecomeActive()
        
        let defaults = UserDefaults(suiteName: Config.suiteName)!
        if let key = defaults.string(forKey: Config.exchangeTokenKey) {
            rootViewController?.present(AlertController.makeSimple(with: "Key: \(key)", message: "The key! \(key)"), animated: true)
            defaults.set(nil, forKey: Config.exchangeTokenKey)
            defaults.synchronize()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        rootViewController?.presenter.applicationWillTerminate()
    }
    
    // MARK: - Push Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        rootViewController?.presenter.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        rootViewController?.presenter.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        rootViewController?.presenter.didReceiveRemoteNotification(
            userInfo: userInfo,
            fetchCompletionHandler: completionHandler
        )
    }
}

extension AppDelegate: RootFlowControllerParent {}
