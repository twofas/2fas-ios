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

extension ComposeServiceSectionCell.InputConfig.Kind {
    var title: String {
        switch self {
        case .additionalInfo: return T.Tokens.additionalInfo
        case .serviceName: return T.Tokens.serviceName
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .additionalInfo: return false
        case .serviceName: return true
        }
    }
    
    var inputConfig: ComposeServiceFormInput.InputConfig {
        switch self {
        case .additionalInfo: return .init(
            canPaste: true,
            shouldUppercase: false,
            returnKeyType: .done,
            maxLength: ServiceRules.additionalInfoMaxLenght,
            autocapitalizationType: UITextAutocapitalizationType.none
        )
        case .serviceName: return
                .init(
                    canPaste: true,
                    shouldUppercase: false,
                    returnKeyType: .next,
                    maxLength: ServiceRules.serviceNameMaxLength,
                    autocapitalizationType: UITextAutocapitalizationType.sentences
                )
        }
    }
    
    var inputKind: ComposeServiceInputKind {
        switch self {
        case .serviceName: return .serviceName
        case .additionalInfo: return .additionalInfo
        }
    }
}

extension ComposeServiceSectionCell.PrivateKeyConfig.PrivateKeyError {
    var localizedStringValue: String {
        switch self {
        case .duplicated: return T.Tokens.duplicatedPrivateKey
        case .incorrect: return T.Tokens.incorrectServiceKey
        case .tooShort: return T.Tokens.serviceKeyToShort
        }
    }
}

extension ComposeServiceSectionCell.NavigationConfig.Kind {
    var localizedStringValue: String {
        switch self {
        case .label: return T.Tokens.changeLabel
        case .advanced: return T.Tokens.advanced
        case .badgeColor: return T.Tokens.badgeColor
        case .brandIcon: return T.Tokens.changeBrandIcon
        case .browserExtension: return T.Browser.browserExtensionSettings
        case .category: return T.Tokens.group
        }
    }
}
