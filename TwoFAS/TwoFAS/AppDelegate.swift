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

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var rootCoordinator: RootCoordinator?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        rootCoordinator = RootCoordinator()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootCoordinator!.rootViewController
        window?.makeKeyAndVisible()
        
        rootCoordinator?.start()
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard let rootCoordinator else { return false }
        return rootCoordinator.shouldHandleURL(url: url)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        rootCoordinator?.applicationWillResignActive()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        rootCoordinator?.applicationDidEnterBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        rootCoordinator?.applicationWillEnterForeground()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        rootCoordinator?.applicationDidBecomeActive()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        rootCoordinator?.applicationWillTerminate()
    }
    
    // MARK: - Push Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        rootCoordinator?.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        rootCoordinator?.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        rootCoordinator?.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
}
