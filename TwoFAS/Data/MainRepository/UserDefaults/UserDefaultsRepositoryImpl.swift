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
    private struct ViewStatePath: Codable {
        let savedAt: Date
        let path: ViewPath
    }
    
    private enum Keys: String, CaseIterable {
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
        case viewPath = "ViewPathController.ViewStatePath"
        case introductionWasShown = "IntroductionWasShown"
        case crashlyticsDisabled
        case activeSearchEnabled
        case selectedListStyle
        case tokensHidden
        case mainMenuPortraitCollapsed
        case mainMenuLandscapeCollapsed
        case dateOfFirstRun
        case syncSuccessDate
        case localNotificationPublicationDate
        case localNotificationPublicationID
        case localNotificationWasRead
        case localNotificationCycle
        case runCount
    }
    private let userDefaults = UserDefaults()
    private let sharedDefaults = UserDefaults(suiteName: Config.suiteName)!
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

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
    
    var isActiveSearchEnabled: Bool {
        userDefaults.bool(forKey: Keys.activeSearchEnabled.rawValue)
    }
    
    func setActiveSearchEnabled(_ state: Bool) {
        userDefaults.set(state, forKey: Keys.activeSearchEnabled.rawValue)
        userDefaults.synchronize()
    }
    
    var selectedListStyle: ListStyle {
        let intValue = userDefaults.integer(forKey: Keys.selectedListStyle.rawValue)
        return ListStyle(rawValue: intValue) ?? .default
    }
    
    func setSelectListStyle(_ listStyle: ListStyle) {
        userDefaults.set(listStyle.rawValue, forKey: Keys.selectedListStyle.rawValue)
        userDefaults.synchronize()
    }

    var areTokensHidden: Bool {
        userDefaults.bool(forKey: Keys.tokensHidden.rawValue)
    }
    
    func setTokensHidden(_ hidden: Bool) {
        userDefaults.set(hidden, forKey: Keys.tokensHidden.rawValue)
        userDefaults.synchronize()
    }
    
    var isMainMenuPortraitCollapsed: Bool {
        userDefaults.bool(forKey: Keys.mainMenuPortraitCollapsed.rawValue)
    }
    
    func setIsMainMenuPortraitCollapsed(_ isCollapsed: Bool) {
        userDefaults.set(isCollapsed, forKey: Keys.mainMenuPortraitCollapsed.rawValue)
        userDefaults.synchronize()
    }
    
    var isMainMenuLandscapeCollapsed: Bool {
        userDefaults.bool(forKey: Keys.mainMenuLandscapeCollapsed.rawValue)
    }
    
    func setIsMainMenuLandscapeCollapsed(_ isCollapsed: Bool) {
        userDefaults.set(isCollapsed, forKey: Keys.mainMenuLandscapeCollapsed.rawValue)
        userDefaults.synchronize()
    }
    
    var dateOfFirstRun: Date? {
        guard userDefaults.object(forKey: Keys.dateOfFirstRun.rawValue) != nil else { return nil }
        let value = userDefaults.double(forKey: Keys.dateOfFirstRun.rawValue)
        let date = Date(timeIntervalSince1970: value)
        return date
    }
    
    func saveDateOfFirstRun(_ date: Date) {
        userDefaults.set(date.timeIntervalSince1970, forKey: Keys.dateOfFirstRun.rawValue)
        userDefaults.synchronize()
    }
    
    // MARK: - Introduction
    
    func setIntroductionAsShown() {
        userDefaults.set(true, forKey: Keys.introductionWasShown.rawValue)
        userDefaults.synchronize()
    }
    
    func introductionWasShown() -> Bool {
        userDefaults.bool(forKey: Keys.introductionWasShown.rawValue)
    }
    
    // MARK: - Sync success
    
    var successSyncDate: Date? {
        userDefaults.object(forKey: Keys.syncSuccessDate.rawValue) as? Date
    }
    func saveSuccessSyncDate(_ date: Date?) {
        userDefaults.set(date, forKey: Keys.syncSuccessDate.rawValue)
        userDefaults.synchronize()
    }

    // MARK: - View Path
    
    func clearViewPath() {
        userDefaults.removeObject(forKey: Keys.viewPath.rawValue)
        userDefaults.synchronize()
    }
    
    func saveViewPath(_ path: ViewPath) {
        let path = ViewStatePath(savedAt: Date(), path: path)
        do {
            let encodedNode = try encoder.encode(path)
            userDefaults.set(encodedNode, forKey: Keys.viewPath.rawValue)
            userDefaults.synchronize()
        } catch {
            Log("Can't save View State Path! Error: \(error)", severity: .error)
        }
    }
    
    func viewPath() -> (viewPath: ViewPath, savedAt: Date)? {
        guard
            let nodeData = userDefaults.object(forKey: Keys.viewPath.rawValue) as? Data,
            let node = try? decoder.decode(ViewStatePath.self, from: nodeData)
        else {
            return nil
        }
        return (viewPath: node.path, savedAt: node.savedAt)
    }
    
    // MARK: - Crashlytics
    
    var isCrashlyticsDisabled: Bool {
        userDefaults.bool(forKey: Keys.crashlyticsDisabled.rawValue)
    }
    
    func setCrashlyticsDisabled(_ disabled: Bool) {
        userDefaults.set(disabled, forKey: Keys.crashlyticsDisabled.rawValue)
        userDefaults.synchronize()
    }
    
    var exchangeToken: String? {
        sharedDefaults.string(forKey: Config.exchangeTokenKey)
    }
    
    func setExchangeToken(_ key: String) {
        sharedDefaults.set(key, forKey: Config.exchangeTokenKey)
        sharedDefaults.synchronize()
    }
    
    func clearExchangeToken() {
        sharedDefaults.set(nil, forKey: Config.exchangeTokenKey)
        sharedDefaults.synchronize()
    }
    
    // MARK: - Local Notifications
    
    var localNotificationPublicationDate: Date? {
        userDefaults.object(forKey: Keys.localNotificationPublicationDate.rawValue) as? Date
    }
    
    func saveLocalNotificationPublicationDate(_ date: Date?) {
        userDefaults.set(date, forKey: Keys.localNotificationPublicationDate.rawValue)
        userDefaults.synchronize()
    }
    
    var localNotificationPublicationID: String? {
        userDefaults.string(forKey: Keys.localNotificationPublicationID.rawValue)
    }
    
    func saveLocalNotificationPublicationID(_ ID: String?) {
        userDefaults.set(ID, forKey: Keys.localNotificationPublicationID.rawValue)
        userDefaults.synchronize()
    }
    
    var localNotificationWasRead: Bool {
        userDefaults.bool(forKey: Keys.localNotificationWasRead.rawValue)
    }
    
    func saveLocalNotificationWasRead(_ wasRead: Bool) {
        userDefaults.set(wasRead, forKey: Keys.localNotificationWasRead.rawValue)
        userDefaults.synchronize()
    }
    
    var localNotificationCycle: Int {
        userDefaults.integer(forKey: Keys.localNotificationCycle.rawValue)
    }
    
    func saveLocalNotificationCycle(_ cycle: Int) {
        userDefaults.set(cycle, forKey: Keys.localNotificationCycle.rawValue)
        userDefaults.synchronize()
    }
    
    var runCount: Int {
        userDefaults.integer(forKey: Keys.runCount.rawValue)
    }
    
    func saveRunCount(_ count: Int) {
        userDefaults.set(count, forKey: Keys.runCount.rawValue)
        userDefaults.synchronize()
    }
    
    // MARK: - Clear all
    
    func clearAll() {
        Keys.allCases.forEach { key in
            userDefaults.removeObject(forKey: key.rawValue)
            sharedDefaults.removeObject(forKey: key.rawValue)
        }
        userDefaults.synchronize()
        sharedDefaults.synchronize()
    }
}
