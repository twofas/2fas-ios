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
import PushNotifications
import Common

enum AnalyticsEvent {
    case appUpdate(String)
    case firstCode
    case widgetEnabled
    case widgetDisabled
    case onboardingStart
    case onboardingGA
    case onboardingBackupFile
    case missingIcon(String)
    case missingIssuer(String)
    case supportedCodeAdded(String)
    case articleRead(String)
    case codeDetailsTypeAdded(String)
    case codeDetailsAlgorithmChosen(String)
    case codeDetailsRefreshTimeChosen(String)
    case codeDetailsNumberOfDigitsChosen(String)
    case codeDetailsInitialCounterChosen(String)
    case codeDetailsBadgeSet
    case codeDetailsBrandSet
    case codeDetailsLabelSet
    case backupOn
    case backupOff
    case groupAdd
    case groupRemove
    case importGoogleAuth
    case orderIconClick
    case orderIconAsUser
    case orderIconAsCompany
    case orderIconDiscord
    case orderIconShare
}

func DebugLog(_ str: String) {
    PushNotifications.logDebugInfo(str)
}

func AnalyticsLog(_ event: AnalyticsEvent) {
    AnalyticsController.log(event: event)
}

private enum AnalyticsController {
    fileprivate static let KeyType = "type"
    fileprivate static let KeyId = "id"
    fileprivate static let KeyValue = "value"
    
    static func log(event: AnalyticsEvent) {
        PushNotifications.logEvent(event.key, parameters: event.value)
        if let value = event.value {
            Log(
                "Logging analytics event: \(event.key), with parameters: \(value)",
                module: .analytics,
                severity: .trace
            )
        } else {
            Log("Logging analytics event: \(event.key)", module: .analytics, severity: .trace)
        }
    }
}

private extension AnalyticsEvent {
    var key: String {
        switch self {
        case .appUpdate: return "app_update"
        case .firstCode: return "first_code"
        case .widgetEnabled: return "widget_add_service"
        case .widgetDisabled: return "widget_remove_service"
        case .onboardingStart: return "onboarding_start"
        case .onboardingGA: return "onboarding_GA"
        case .onboardingBackupFile: return "onboarding_backup_file"
        case .missingIcon: return "missing_icon"
        case .missingIssuer: return "no_image_for_issuer_on_ios"
        case .supportedCodeAdded: return "supported_icon"
        case .articleRead: return "news_click"
        case .codeDetailsTypeAdded: return "code_type_added"
        case .codeDetailsAlgorithmChosen: return "algorithm_chosen"
        case .codeDetailsRefreshTimeChosen: return "refresh_time_chosen"
        case .codeDetailsNumberOfDigitsChosen: return "number_of_digits_chosen"
        case .codeDetailsInitialCounterChosen: return "initial_counter_chosen"
        case .codeDetailsBadgeSet: return "customization_badge_set"
        case .codeDetailsBrandSet: return "customization_brand_set"
        case .codeDetailsLabelSet: return "customization_label_set"
        case .backupOn: return "backup_on"
        case .backupOff: return "backup_off"
        case .groupAdd: return "group_add"
        case .groupRemove: return "group_remove"
        case .importGoogleAuth: return "import_google_authenticator"
        case .orderIconClick: return "request_icon_click"
        case .orderIconAsUser: return "request_icon_as_user_click"
        case .orderIconAsCompany: return "request_icon_as_company_click"
        case .orderIconDiscord: return "request_icon_discord_click"
        case .orderIconShare: return "request_icon_share_click"
        }
    }
    
    var value: [String: String]? {
        switch self {
        case .appUpdate(let string): return [AnalyticsController.KeyValue: string]
        case .missingIcon(let string): return [AnalyticsController.KeyType: string]
        case .missingIssuer(let string): return [AnalyticsController.KeyType: string]
        case .articleRead(let string): return [AnalyticsController.KeyId: string]
        case .supportedCodeAdded(let string): return [AnalyticsController.KeyType: string]
        case .codeDetailsTypeAdded(let string): return [AnalyticsController.KeyValue: string]
        case .codeDetailsAlgorithmChosen(let string): return [AnalyticsController.KeyValue: string]
        case .codeDetailsRefreshTimeChosen(let string): return [AnalyticsController.KeyValue: string]
        case .codeDetailsNumberOfDigitsChosen(let string): return [AnalyticsController.KeyValue: string]
        case .codeDetailsInitialCounterChosen(let string): return [AnalyticsController.KeyValue: string]
        default: return nil
        }
    }
}
