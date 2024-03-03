//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2024 Two Factor Authentication Service, Inc.
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

final class MDMRepositoryImpl {
    private let mdmKey = "com.apple.configuration.managed"
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = NotificationCenter.default
    private var settings: [String: Any] = [:]
    
    private enum SettingsKeys: String {
        case isBackupBlocked = "blockBackup"
        case isBiometryBlocked = "blockBiometry"
        case isBrowserExtensionBlocked = "blockBrowserExtension"
        case lockoutAttempts = "lockoutAttempts"
        case lockoutBlockTime = "lockoutBlockTime"
        case isPasscodeRequried = "requirePasscode"
    }
    
    private let isBackupBlockedDefaultValue = false
    private let isBiometryBlockedDefaultValue = false
    private let isBrowserExtensionBlockedDefaultValue = false
    private let isPasscodeRequriedDefaultValue = false
    
    init() {
        reload()
    }

    private func reload() {
        settings = userDefaults.dictionary(forKey: mdmKey) ?? [:]
    }
}

extension MDMRepositoryImpl: MDMRepository {
    var isBackupBlocked: Bool {
        guard let value = settings[SettingsKeys.isBackupBlocked.rawValue] as? Bool else {
            return isBackupBlockedDefaultValue
        }
        return value
    }
    
    var isBiometryBlocked: Bool {
        guard let value = settings[SettingsKeys.isBiometryBlocked.rawValue] as? Bool else {
            return isBiometryBlockedDefaultValue
        }
        return value
    }
    
    var isBrowserExtensionBlocked: Bool {
        guard let value = settings[SettingsKeys.isBrowserExtensionBlocked.rawValue] as? Bool else {
            return isBrowserExtensionBlockedDefaultValue
        }
        return value
    }
    
    var lockoutAttepts: AppLockAttempts? {
        guard let value = settings[SettingsKeys.lockoutAttempts.rawValue] as? Int else {
            return nil
        }
        switch value {
        case 0: return .noLimit
        case 3: return .try3
        case 5: return .try5
        case 10: return .try10
        default: return nil
        }
    }
    
    var lockoutBlockTime: AppLockBlockTime? {
        guard let value = settings[SettingsKeys.lockoutBlockTime.rawValue] as? Int else {
            return nil
        }
        switch value {
        case 3: return .min3
        case 5: return .min5
        case 10: return .min10
        default: return nil
        }
    }
    
    var isPasscodeRequried: Bool {
        guard let value = settings[SettingsKeys.isPasscodeRequried.rawValue] as? Bool else {
            return isPasscodeRequriedDefaultValue
        }
        return value
    }
}
