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

public final class PushNotifications {
    public var notificationState: NotificationStateProtocol { apns }
    public var fcmHandler: FCMHandlerProtocol { fcm }
    
    private let apns: APNS
    private let fcm: FCM
    
    private var lastSavedNotification: LastSavedNotification?
    
    public var lastNotification: LastSavedNotification? {
        lastSavedNotification
    }
    
    public init(app: UIApplication) {
        fcm = FCM()
        apns = APNS(app: app)
        
        apns.saveNotification = { [weak self] in self?.lastSavedNotification = $0 }
    }

    public func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        apns.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        fcm.setDeviceToken(deviceToken)
    }
    
    public func didFailToRegisterForRemoteNotifications(with error: Error) {
        apns.didFailToRegisterForRemoteNotifications(with: error)
    }
    
    public static func logDebugInfo(_ message: String) {
        FCM.logDebugInfo(message)
    }
    
    public func clearLastNotification() {
        lastSavedNotification = nil
    }
}
