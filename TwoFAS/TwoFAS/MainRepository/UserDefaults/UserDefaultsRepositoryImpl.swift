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

final class UserDefaultsRepositoryImpl: UserDefaultsRepository {
    private enum Keys: String {
        case appLockAttempts
        case appLockBlockTime
        case newVersionCounter
        case newVersionTracked
        case newVersionIgnored
        case newVersionCheckDisabled
        case sortType
        case advancedAlertShown
        case extensionKeysGenerated
        case savedDeviceName
        case unkownCodeCounter = "UnkownCodeCounter"
        case lockAppUntil
        case widgetWarning = "com.2fas.WidgetWarningStorage"
        case nextToken = "com.2fas.NextTokenStateController-TokenEnabled"
        case isSectionZeroCollapsed = "com.2fas.SectionZeroCollapsedState"
    }
    private let userDefaults = UserDefaults()
    private let sharedDefaults = UserDefaults(suiteName: Config.suiteName)!

    var appLockAttempts: AppLockAttempts? {
        guard let value = userDefaults.string(forKey: Keys.appLockAttempts.rawValue) else { return nil }
        return AppLockAttempts(rawValue: value)
    }
    
    func setAppLockAttempts(_ value: AppLockAttempts) {
        userDefaults.set(value.rawValue, forKey: Keys.appLockAttempts.rawValue)
        userDefaults.synchronize()
    }
    
    var appLockBlockTime: AppLockBlockTime? {
        guard let value = userDefaults.string(forKey: Keys.appLockBlockTime.rawValue) else { return nil }
        return AppLockBlockTime(rawValue: value)
    }
    
    func setAppLockBlockTime(_ value: AppLockBlockTime) {
        userDefaults.set(value.rawValue, forKey: Keys.appLockBlockTime.rawValue)
        userDefaults.synchronize()
    }
    
    var newVersionCounter: Int {
        userDefaults.integer(forKey: Keys.newVersionCounter.rawValue)
    }
    
    func setNewVersionCounter(_ counter: Int) {
        userDefaults.set(counter, forKey: Keys.newVersionCounter.rawValue)
        userDefaults.synchronize()
    }
    
    var newVersionTracked: String? {
        userDefaults.string(forKey: Keys.newVersionTracked.rawValue)
    }
    
    func setNewVersionTracked(_ version: String) {
        userDefaults.set(version, forKey: Keys.newVersionTracked.rawValue)
        userDefaults.synchronize()
    }
    
    var newVersionIgnored: String? {
        userDefaults.string(forKey: Keys.newVersionIgnored.rawValue)
    }
    
    func setNewVersionIgnored(_ version: String) {
        userDefaults.set(version, forKey: Keys.newVersionIgnored.rawValue)
        userDefaults.synchronize()
    }
    
    var newVersionCheckDisabled: Bool {
        userDefaults.bool(forKey: Keys.newVersionCheckDisabled.rawValue)
    }
    
    func setNewVersionCheckDisabled(_ disabled: Bool) {
        userDefaults.set(disabled, forKey: Keys.newVersionCheckDisabled.rawValue)
        userDefaults.synchronize()
    }
    
    var sortType: SortType? {
        guard let value = userDefaults.string(forKey: Keys.sortType.rawValue) else { return nil }
        return SortType(rawValue: value)
    }
    
    func setSortType(_ sortType: SortType) {
        userDefaults.set(sortType.rawValue, forKey: Keys.sortType.rawValue)
        userDefaults.synchronize()
    }
    
    var advancedAlertShown: Bool {
        userDefaults.bool(forKey: Keys.advancedAlertShown.rawValue)
    }
    
    func markAdvancedAlertAsShown() {
        userDefaults.set(true, forKey: Keys.advancedAlertShown.rawValue)
        userDefaults.synchronize()
    }
    
    var areExtensionKeysGenerated: Bool {
        sharedDefaults.bool(forKey: Keys.extensionKeysGenerated.rawValue)
    }
    
    func markExtensionKeysAsGenerated() {
        sharedDefaults.set(true, forKey: Keys.extensionKeysGenerated.rawValue)
        sharedDefaults.synchronize()
    }
    
    func clearExtensionKeys() {
        sharedDefaults.set(false, forKey: Keys.extensionKeysGenerated.rawValue)
        sharedDefaults.synchronize()
    }
    
    var savedDeviceName: String? {
        sharedDefaults.string(forKey: Keys.savedDeviceName.rawValue)
    }
    
    func saveNewDeviceName(_ newName: String) {
        sharedDefaults.set(newName, forKey: Keys.savedDeviceName.rawValue)
        sharedDefaults.synchronize()
    }
    
    func obtainNextUnknownCodeCounter() -> Int {
        let currentValue = userDefaults.integer(forKey: Keys.unkownCodeCounter.rawValue)
        let nextValue = currentValue + 1
        
        userDefaults.set(nextValue, forKey: Keys.unkownCodeCounter.rawValue)
        userDefaults.synchronize()

        return nextValue
    }
    
    var lockAppUntil: Date? {
        guard userDefaults.object(forKey: Keys.lockAppUntil.rawValue) != nil else { return nil }
        let value = userDefaults.double(forKey: Keys.lockAppUntil.rawValue)
        let date = Date(timeIntervalSince1970: value)
        return date
    }
    
    func setLockAppUntil(date: Date) {
        userDefaults.set(date.timeIntervalSince1970, forKey: Keys.lockAppUntil.rawValue)
        userDefaults.synchronize()
    }
    
    func clearLockAppUntil() {
        userDefaults.set(nil, forKey: Keys.lockAppUntil.rawValue)
        userDefaults.synchronize()
    }
    
    var widgetWarningShown: Bool {
        userDefaults.bool(forKey: Keys.widgetWarning.rawValue)
    }
    
    func markWidgetWarningAsSeen() {
        userDefaults.set(true, forKey: Keys.widgetWarning.rawValue)
        userDefaults.synchronize()
    }
    
    var isNextTokenEnabled: Bool {
        userDefaults.bool(forKey: Keys.nextToken.rawValue)
    }
    
    func setNextTokenEnabled(_ state: Bool) {
        userDefaults.set(state, forKey: Keys.nextToken.rawValue)
        userDefaults.synchronize()
    }
    
    var isSectionZeroCollapsed: Bool {
        userDefaults.bool(forKey: Keys.isSectionZeroCollapsed.rawValue)
    }
    
    func setSectionZeroIsCollapsed(_ collapsed: Bool) {
        userDefaults.set(collapsed, forKey: Keys.isSectionZeroCollapsed.rawValue)
        userDefaults.synchronize()
    }
}
