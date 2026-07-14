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

struct AppearanceSection: Identifiable {
    let id = UUID()
    let title: String?
    let cells: [AppearanceCell]
    let footer: String?
}

struct AppearanceCell: Identifiable {
    struct PickerOption: Identifiable {
        let id = UUID()
        let title: String
        let kind: Kind
        let isSelected: Bool
    }

    enum Accessory {
        case toggle(isOn: Bool)
        case picker(value: String, options: [PickerOption])
    }

    enum Kind: Hashable {
        case incomingToken
        case activeSearch
        case defaultList
        case compactList
        case hideTokens
    }

    let id = UUID()
    let title: String
    let accessory: Accessory
    let kind: Kind
}

extension AppearancePresenter {
    func buildMenu() -> [AppearanceSection] {
        let isIncomingTokenEnabled = interactor.isNextTokenEnabled
        let incoming = AppearanceSection(
            title: nil,
            cells: [
                AppearanceCell(
                    title: T.Settings.showNextToken,
                    accessory: .toggle(isOn: isIncomingTokenEnabled),
                    kind: .incomingToken
                )
            ],
            footer: T.Settings.seeIncomingTokens
        )
        let isActiveSearchEnabled = interactor.isActiveSearchEnabled

        let activeSearch = AppearanceSection(
            title: nil,
            cells: [
                AppearanceCell(
                    title: T.Appearance.toggleActiveSearch,
                    accessory: .toggle(isOn: isActiveSearchEnabled),
                    kind: .activeSearch
                )
            ],
            footer: T.Appearance.activeSearchDescription
        )

        let selectedStyle = interactor.selectedListStyle
        let selectedValue: String = selectedStyle == .default
            ? T.Settings.listStyleOptionDefault
            : T.Settings.listStyleOptionCompact
        let listStyle = AppearanceSection(
            title: nil,
            cells: [
                AppearanceCell(
                    title: T.Settings.listStyle,
                    accessory: .picker(
                        value: selectedValue,
                        options: [
                            AppearanceCell.PickerOption(
                                title: T.Settings.listStyleOptionDefault,
                                kind: .defaultList,
                                isSelected: selectedStyle == .default
                            ),
                            AppearanceCell.PickerOption(
                                title: T.Settings.listStyleOptionCompact,
                                kind: .compactList,
                                isSelected: selectedStyle == .compact
                            )
                        ]
                    ),
                    kind: .defaultList
                )
            ],
            footer: nil
        )

        let tokensHidden = AppearanceSection(
            title: nil,
            cells: [
                AppearanceCell(
                    title: T.Settings.hideTokensTitle,
                    accessory: .toggle(isOn: interactor.areTokensHidden),
                    kind: .hideTokens
                )
            ],
            footer: T.Settings.hideTokensDescription
        )

        return [
            incoming,
            activeSearch,
            listStyle,
            tokensHidden
        ]
    }
}
