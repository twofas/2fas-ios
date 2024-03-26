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

public protocol RootInteracting: AnyObject {
    var introductionWasShown: Bool { get }
    var isAuthenticationRequired: Bool { get }
    var storageError: ((String) -> Void)? { get set }
    
    func initializeApp()
    func applicationWillResignActive()
    func applicationWillEnterForeground()
    func applicationDidBecomeActive()
    func applicationWillTerminate()
    
    func markIntroAsShown()
    func lockApplicationIfNeeded(presentLoginImmediately: @escaping () -> Void)

    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data)
    func didFailToRegisterForRemoteNotifications(with error: Error)
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    )
}

final class RootInteractor {
    var storageError: ((String) -> Void)?
    
    private let mainRepository: MainRepository
    private let camera: CameraPermissionInteracting
    private let push: PushNotificationRegistrationInteracting
    
    init(
        mainRepository: MainRepository,
        camera: CameraPermissionInteracting,
        push: PushNotificationRegistrationInteracting
    ) {
        self.mainRepository = mainRepository
        self.camera = camera
        self.push = push
        
        mainRepository.storageError = { [weak self] error in
            self?.storageError?(error)
        }
    }
}

extension RootInteractor: RootInteracting {
    var introductionWasShown: Bool {
        mainRepository.introductionWasShown()
    }
    
    var isAuthenticationRequired: Bool {
        mainRepository.securityIsAuthenticationRequired
    }
    
    func initializeApp() {
        mainRepository.initialPermissionStateSetChildren([
            camera, push
        ])
        mainRepository.initialPermissionStateInitialize()
    }
    
    func markIntroAsShown() {
        mainRepository.setIntroductionAsShown()
        if !mainRepository.mdmIsBackupBlocked {
            mainRepository.enableCloudBackup()
        }
    }
    
    func lockApplicationIfNeeded(presentLoginImmediately: @escaping () -> Void) {
        mainRepository.securityLockApplication()
        
        if mainRepository.securityIsAuthenticationRequired {
            presentLoginImmediately()
        }
    }
    
    func applicationWillResignActive() {
        mainRepository.saveStorage()
    }
    
    func applicationWillEnterForeground() {
        mainRepository.securityApplicationWillEnterForeground()
        mainRepository.initialPermissionStateInitialize()
    }
    
    func applicationDidBecomeActive() {
        mainRepository.synchronizeBackup()
        mainRepository.timeVerificationStart()
        mainRepository.securityApplicationDidBecomeActive()
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        mainRepository.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func didFailToRegisterForRemoteNotifications(with error: Error) {
        mainRepository.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        mainRepository.syncDidReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func applicationWillTerminate() {
        mainRepository.saveStorage()
    }
}
