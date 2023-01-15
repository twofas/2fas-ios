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

import Foundation
import UserNotifications
import Common

final class APNS: NSObject, UNUserNotificationCenterDelegate, NotificationStateProtocol {
    private let center: UNUserNotificationCenter
    private let app: UIApplication
    
    private var registrationCompletion: ((NotificationRegistrationState) -> Void)?
    
    var saveNotification: ((LastSavedNotification) -> Void)?
    
    init(app: UIApplication) {
        self.center = UNUserNotificationCenter.current()
        self.app = app
        app.registerForRemoteNotifications()
        
        super.init()
        
        center.delegate = self
    }
    
    func checkStatus(completion: @escaping (NotificationState) -> Void) {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    completion(.authorized)
                    self?.clearNotifications()
                case .denied:
                    completion(.denied)
                case .notDetermined:
                    completion(.notDetermined)
                case .ephemeral:
                    completion(.notDetermined)
                    assertionFailure("This Push Notification state shouldn't be used in app!")
                @unknown default:
                        print("Unknown status for Push Notifications auth")
                }
            }
        }
    }

    func registerForPushNotifications(completion: @escaping (NotificationRegistrationState) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(.failed(error: error!))
                    return
                }
                
                guard granted else {
                    completion(.denied)
                    return
                }

#if targetEnvironment(simulator)
                completion(.succesful(deviceToken: "NO_TOKEN_FROM_SIMULATOR"))
                return
#else
                self?.registrationCompletion = completion
                self?.app.registerForRemoteNotifications()
#endif
            }
        }
    }

    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()

        Log("Did obtain Device Token")
        Log("Device Token: \(token)", save: false)
        
        registrationCompletion?(.succesful(deviceToken: token))
        registrationCompletion = nil
    }

    func didFailToRegisterForRemoteNotifications(with error: Error) {
        Log("Error registering for Push Notifications: \(error)")

        registrationCompletion?(.failed(error: error))
        registrationCompletion = nil
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        clearNotifications()

        let r = response.notification.request.content

        if r.categoryIdentifier == PushNotificationConfig.categoryID {
            if let tokenRequestID = r.userInfo["request_id"] as? String, response.actionIdentifier == "authorizeInApp" {
                notifyAboutAuthorizeWithApp(for: tokenRequestID)
            } else {
                notifyAboutRefreshAuthList()
            }
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        clearNotifications()
        
        let r = notification.request.content
        
        if r.categoryIdentifier == PushNotificationConfig.categoryID {
            notifyAboutRefreshAuthList()
        }

        completionHandler([])
    }

    private func clearNotifications() {
        center.removeAllDeliveredNotifications()
        app.applicationIconBadgeNumber = 0
    }

    private func notifyAboutRefreshAuthList() {
        saveNotification?(.refreshList)
        NotificationCenter.default.post(name: .pushNotificationRefreshAuthList, object: nil)
    }

    private func notifyAboutAuthorizeWithApp(for tokenRequestID: String) {
        saveNotification?(.authInApp(tokenRequesID: tokenRequestID))
        NotificationCenter.default.post(
            name: .pushNotificationAuthorizeFromApp,
            object: nil,
            userInfo: [Notification.pushNotificationAuthorizeFromAppData: tokenRequestID]
        )
    }
}
