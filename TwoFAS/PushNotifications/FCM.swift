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
import Firebase
import FirebaseCrashlytics
import FirebaseMessaging

final class FCM: NSObject, MessagingDelegate, FCMHandlerProtocol {
    var didInitialize: (() -> Void)?
    
    var FCMTokenObtained: FCMTokenObtainedCompletion?
    
    func initialize() {
        FirebaseApp.configure()
        #if !DEBUG
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
        Messaging.messaging().delegate = self
        
        didInitialize?()
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
