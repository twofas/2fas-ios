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

extension ComposeServicePresenter {
    func buildMenu() -> [ComposeServiceSection] {
        let serviceName: String? = interactor.serviceName
        let additionalInfo: String? = interactor.additionalInfo
        let keyError: ComposeServiceSectionCell.PrivateKeyConfig.PrivateKeyError? = {
            switch interactor.privateKeyError {
            case .duplicated: return .duplicated
            case .incorrect: return .incorrect
            case .tooShort: return .tooShort
            case .none, .empty: return nil
            }
        }()
        let privateKeyKind: ComposeServiceSectionCell.PrivateKeyConfig.PrivateKeyKind = {
            if interactor.actionType == .edit {
                if interactor.isSecretCopyingBlocked {
                    return .hiddenNonCopyable
                }
                return .hidden
            }
            return .empty
        }()
        
        let service = ComposeServiceSection(
            title: T.Tokens.serviceInformation,
            cells: [
                .init(kind: .input(.init(kind: .serviceName, value: serviceName))),
                .init(kind: .privateKey(
                    .init(
                        value: interactor.privateKey,
                        privateKeyKind: privateKeyKind,
                        error: keyError
                    )
                )),
                .init(kind: .input(.init(kind: .additionalInfo, value: additionalInfo))),
                .init(kind: .navigate(.init(kind: .advanced, isEnabled: true, accessory: nil)))
            ]
        )

        let currentCategory = interactor.selectedSectionTitle ?? T.Tokens.myTokens
        let iconKind: IconType = interactor.iconType
        let iconTypeID: IconTypeID = interactor.iconTypeID
        let labelTitle: String = interactor.labelTitle
        let labelColor: TintColor = interactor.labelColor
        let isBrandIconEnabled: Bool = interactor.isBrandIconEnabled
        let isLabelEnabled: Bool = interactor.isLabelEnabled
        let badgeColor: TintColor = interactor.badgeColor
        let iconTypeName: String = interactor.iconTypeName
        let personalization = ComposeServiceSection(
            title: T.Tokens.personalization,
            cells: [
                .init(
                    kind: .icon(
                        .init(
                            kind: iconKind,
                            iconTypeID: iconTypeID,
                            labelTitle: labelTitle,
                            labelColor: labelColor,
                            iconTypeName: iconTypeName
                        )
                    )
                ),
                .init(
                    kind: .navigate(
                        .init(kind: .brandIcon, isEnabled: isBrandIconEnabled, accessory: nil)
                    )
                ),
                .init(
                    kind: .navigate(
                        .init(kind: .label, isEnabled: isLabelEnabled, accessory: nil)
                    )
                ),
                .init(
                    kind: .navigate(
                        .init(kind: .badgeColor, isEnabled: true, accessory: .badgeColor(badgeColor))
                    )
                ),
                .init(kind: .navigate(.init(kind: .category, isEnabled: true, accessory: .label(currentCategory))))
            ]
        )
        
        let webExtension = ComposeServiceSection(title: T.Tokens.addManualOther, cells: [
            .init(kind:
                    .navigate(.init(kind: .browserExtension, isEnabled: interactor.webExtensionActive, accessory: nil))
            )
        ])
        
        let remove = ComposeServiceSection(
            title: nil,
            cells: [
                .init(kind: .action(
                    .init(kind: .delete)
                ))
            ]
        )
        
        var array = [
            service,
            personalization
        ]
        
        if interactor.actionType == .edit {
            if interactor.isBrowserExtensionAllowed {
                array.append(webExtension)
            }
            array.append(remove)
        }
        
        return array
    }
}
