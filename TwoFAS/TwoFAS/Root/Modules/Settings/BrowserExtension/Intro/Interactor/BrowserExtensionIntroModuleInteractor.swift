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

protocol BrowserExtensionIntroModuleInteracting: AnyObject {
    var isFromScanning: Bool { get }
    var shouldAskForPushNotifications: Bool { get }
    func isCameraAllowed() -> Bool
    func isCameraAvailable() -> Bool
    func registerCamera(callback: @escaping (Bool) -> Void)
}

final class BrowserExtensionIntroModuleInteractor {
    
    private let cameraPermissionInteractor: CameraPermissionInteracting
    private let pushNotificationRegistrationInteractor: PushNotificationRegistrationInteracting
    
    init(
        cameraPermissionInteractor: CameraPermissionInteracting,
        pushNotificationRegistrationInteractor: PushNotificationRegistrationInteracting
    ) {
        self.cameraPermissionInteractor = cameraPermissionInteractor
        self.pushNotificationRegistrationInteractor = pushNotificationRegistrationInteractor
    }
}

extension BrowserExtensionIntroModuleInteractor: BrowserExtensionIntroModuleInteracting {
    var isFromScanning: Bool {
        false
    }
    
    var shouldAskForPushNotifications: Bool {
        pushNotificationRegistrationInteractor.state == .notDetermined
    }
    
    func isCameraAvailable() -> Bool {
        cameraPermissionInteractor.isCameraAvailable
    }
    
    func isCameraAllowed() -> Bool {
        cameraPermissionInteractor.isCameraAllowed
    }
    
    func registerCamera(callback: @escaping (Bool) -> Void) {
        cameraPermissionInteractor.register { status in
            callback(status == .granted)
        }
    }
}
