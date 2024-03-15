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

protocol UserDefaultsRepository: AnyObject {
    var appLockAttempts: AppLockAttempts? { get }
    func setAppLockAttempts(_ value: AppLockAttempts)

    var appLockBlockTime: AppLockBlockTime? { get }
    func setAppLockBlockTime(_ value: AppLockBlockTime)
    
    var newVersionCounter: Int { get }
    func setNewVersionCounter(_ counter: Int)
    var newVersionTracked: String? { get }
    func setNewVersionTracked(_ version: String)
    var newVersionCheckDisabled: Bool { get }
    func setNewVersionCheckDisabled(_ disabled: Bool)
    var newVersionIgnored: String? { get }
    func setNewVersionIgnored(_ version: String)
    
    var sortType: SortType? { get }
    func setSortType(_ sortType: SortType)
    
    var advancedAlertShown: Bool { get }
    func markAdvancedAlertAsShown()
    
    var areExtensionKeysGenerated: Bool { get }
    func markExtensionKeysAsGenerated()
    func clearExtensionKeys()
    
    var savedDeviceName: String? { get }
    func saveNewDeviceName(_ newName: String)
    
    func obtainNextUnknownCodeCounter() -> Int
    
    var lockAppUntil: Date? { get }
    func setLockAppUntil(date: Date)
    func clearLockAppUntil()
    
    var widgetWarningShown: Bool { get }
    func markWidgetWarningAsSeen()
    
    var isNextTokenEnabled: Bool { get }
    func setNextTokenEnabled(_ state: Bool)
    
    var isActiveSearchEnabled: Bool { get }
    func setActiveSearchEnabled(_ state: Bool)
    
    var isSectionZeroCollapsed: Bool { get }
    func setSectionZeroIsCollapsed(_ collapsed: Bool)
    
    func clearViewPath()
    func saveViewPath(_ path: ViewPath)
    func viewPath() -> (viewPath: ViewPath, savedAt: Date)?
    
    func setIntroductionAsShown()
    func introductionWasShown() -> Bool
    
    func clearAll()
    
    var isCrashlyticsDisabled: Bool { get }
    func setCrashlyticsDisabled(_ disabled: Bool)
    
    var selectedListStyle: ListStyle { get }
    func setSelectListStyle(_ listStyle: ListStyle)

    var areTokensHidden: Bool { get }
    func setTokensHidden(_ hidden: Bool)
    
    var isMainMenuPortraitCollapsed: Bool { get }
    func setIsMainMenuPortraitCollapsed(_ isCollapsed: Bool)
    
    var isMainMenuLandscapeCollapsed: Bool { get }
    func setIsMainMenuLandscapeCollapsed(_ isCollapsed: Bool)
    
    var dateOfFirstRun: Date? { get }
    func saveDateOfFirstRun(_ date: Date)
    
    var exchangeToken: String? { get }
    func setExchangeToken(_ key: String)
    func clearExchangeToken()
    
    var successSyncDate: Date? { get }
    func saveSuccessSyncDate(_ date: Date?)
    
    // MARK: - Local Notifications
    
    var localNotificationPublicationDate: Date? { get }
    func saveLocalNotificationPublicationDate(_ date: Date?)
    
    var localNotificationPublicationID: String? { get }
    func saveLocalNotificationPublicationID(_ ID: String?)
    
    var localNotificationWasRead: Bool { get }
    func saveLocalNotificationWasRead(_ wasRead: Bool)
    
    var localNotificationCycle: Int { get }
    func saveLocalNotificationCycle(_ cycle: Int)
    
    var runCount: Int { get }
    func saveRunCount(_ count: Int)
}
