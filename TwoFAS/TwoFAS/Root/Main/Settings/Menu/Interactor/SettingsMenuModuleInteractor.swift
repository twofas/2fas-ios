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

protocol SettingsMenuModuleInteracting: AnyObject {
    var isSecurityEnabled: Bool { get }
    var areWidgetsEnabled: Bool { get }
    var isNextTokenEnabled: Bool { get }
    var shouldShowWidgetWarning: Bool { get }
    var isPushNotificationDetermined: Bool { get }

    func enableWidgets()
    func disableWidgets()
        
    func toogleIncomingToken()
}

final class SettingsMenuModuleInteractor {
    private let widgetsInteractor: WidgetsInteracting
    private let pushNotifications: PushNotificationRegistrationInteracting
    private let protectionInteractor: ProtectionInteracting
    private let nextTokenInteractor: NextTokenInteracting
    
    init(
        widgetsInteractor: WidgetsInteracting,
        pushNotifications: PushNotificationRegistrationInteracting,
        protectionInteractor: ProtectionInteracting,
        nextTokenInteractor: NextTokenInteracting
    ) {
        self.widgetsInteractor = widgetsInteractor
        self.pushNotifications = pushNotifications
        self.protectionInteractor = protectionInteractor
        self.nextTokenInteractor = nextTokenInteractor
    }
}

extension SettingsMenuModuleInteractor: SettingsMenuModuleInteracting {
    var isSecurityEnabled: Bool { protectionInteractor.isPINSet }
    var areWidgetsEnabled: Bool { widgetsInteractor.areEnabled }
    var isNextTokenEnabled: Bool { nextTokenInteractor.isEnabled }
    var shouldShowWidgetWarning: Bool { widgetsInteractor.showWarning }
    var isPushNotificationDetermined: Bool { pushNotifications.wasUserAsked }
    
    func enableWidgets() {
        widgetsInteractor.enable()
    }
    
    func disableWidgets() {
        widgetsInteractor.disable()
    }
    
    func toogleIncomingToken() {
        nextTokenInteractor.toggle()
    }
}
