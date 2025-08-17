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
import Common
import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging

final class FCM: NSObject, MessagingDelegate, FCMHandlerProtocol {
    var FCMTokenObtained: FCMTokenObtainedCompletion?
    
    private var messaging: Messaging?
    private var deviceToken: Data?
    
    func initializeFCM() {
        guard messaging == nil else {
            return
        }
        messaging = Messaging.messaging()
        messaging?.delegate = self
    }
    
    func enableFCM() {
        FirebaseApp.configure()
        initializeFCM()
        
        guard let deviceToken else {
            return
        }
        messaging?.apnsToken = deviceToken
        self.deviceToken = nil
        Log("FCM - APNS Token set", module: .unknown)
        
        getToken()
    }
    
    func setDeviceToken(_ deviceToken: Data) {
        if let messaging {
            messaging.apnsToken = deviceToken
            Log("FCM - APNS Token set", module: .unknown)
            
            getToken()
        } else {
            self.deviceToken = deviceToken
        }
    }
    
    private func getToken() {
        Log("FCM - obtaining FCM Token", module: .unknown)
        Task {
            do {
                try await messaging?.token()
            } catch {
                Log("FCM Error while obtaining FCM Token: \(error)", module: .unknown, severity: .error)
            }
        }
    }
    
    func enableCrashlytics(_ enable: Bool) {
    #if !DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(enable)
    #endif
    }
    
    // MARK: - FCM Delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken GCMToken: String?) {
        guard let GCMToken else { return }
        FCMTokenObtained?(GCMToken)
    }
    
    static func logDebugInfo(_ message: String) {
        #if !DEBUG
            Crashlytics.crashlytics().log(message)
        #endif
    }
}
