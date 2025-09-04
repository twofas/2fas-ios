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
import Common
import CryptoKit

extension MainRepositoryImpl {
    var currentAppVersion: String {
        appVersion ?? "-"
    }
    
    func setIntroductionAsShown() {
        userDefaultsRepository.setIntroductionAsShown()
    }
    
    func introductionWasShown() -> Bool {
        userDefaultsRepository.introductionWasShown()
    }
    
    func setCrashlyticsDisabled(_ disabled: Bool) {
        userDefaultsRepository.setCrashlyticsDisabled(disabled)
    }
    
    var isCrashlyticsDisabled: Bool {
        userDefaultsRepository.isCrashlyticsDisabled
    }
    
    func initialPermissionStateSetChildren(_ children: [PermissionsStateChildDataControllerProtocol]) {
        initialPermissionStateDataController.set(children: children)
    }
    
    func initialPermissionStateInitialize() {
        initialPermissionStateDataController.initialize()
    }
    
    var dateOfNoCompanionApp: Date? {
        userDefaultsRepository.dateOfNoCompanionApp
    }
    
    func saveDateOfNoCompanionApp(_ date: Date) {
        userDefaultsRepository.saveDateOfNoCompanionApp(date)
    }
    
    func clearDateOfNoCompanionApp() {
        userDefaultsRepository.clearDateOfNoCompanionApp()
    }
    
    var notificationGroupID: String? {
        userDefaultsRepository.notificationGroupID
    }
    
    func createNotificationGroupID() {
        let groupID = UUID().uuidString
        let groupData = SHA256.hash(data: Data(groupID.utf8))
        let hasGroupID = String(groupData.map { String(format: "%02hhx", $0) }.joined())
        let lastTwo = String(hasGroupID.suffix(2))
        userDefaultsRepository.saveNotificationGroupID(lastTwo)
    }

    var is2FASPASSInstalled: Bool {
#if os(iOS)
        UIApplication.shared.canOpenURL(Config.twofasPassCheckLink)
#else
        false
#endif
    }
}
