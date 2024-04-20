//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

import Foundation
import WatchKit
import CommonWatch

final class AppDelegateInteractor: NSObject, WKApplicationDelegate {
    private lazy var mainRepository: MainRepository = { MainRepositoryImpl.shared }()
    
    func applicationDidFinishLaunching() {
        if !WKApplication.shared().isRegisteredForRemoteNotifications {
            Log("Registering Push Notifications")
            WKApplication.shared().registerForRemoteNotifications()
        } else {
            Log("Push Notifications registered")
        }
        mainRepository.registerForCloudStateChanges({ [weak self] state in
            Log("Cloud state changed: \(state)")
            self?.handleCloudState(state)
        }, id: "AppDelegateInteractor")
        handleCloudState(mainRepository.currentCloudState)
        
        mainRepository.synchronizeCloudBackup()
    }

    func applicationDidBecomeActive() {
        mainRepository.synchronizeCloudBackup()
        if mainRepository.pin != nil {
            mainRepository.lockApp()
        }
    }

    func applicationWillResignActive() {
        mainRepository.saveStorage()
    }

    func applicationWillEnterForeground() {
        if mainRepository.pin != nil {
            mainRepository.lockApp()
        }
    }

    func applicationDidEnterBackground() {
        if mainRepository.pin != nil {
            mainRepository.lockApp()
        }
    }
        
    func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void
    ) {
        Log("didReceiveRemoteNotification")
        mainRepository.syncDidReceiveRemoteNotification(
            userInfo: userInfo,
            fetchCompletionHandler: completionHandler
        )
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        Log("didRegisterForRemoteNotifications")
    }

    func didFailToRegisterForRemoteNotificationsWithError(_ error: any Error) {
        Log("didFailToRegisterForRemoteNotificationsWithError \(error)")
    }
    
    private func handleCloudState(_ state: CloudState) {
        if state == .disabledAvailable {
            mainRepository.enableCloudBackup()
            mainRepository.synchronizeCloudBackup()
        }
    }
}
