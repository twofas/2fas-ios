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

struct AppearanceSection: TableViewSection {
    let title: String?
    var cells: [AppearanceCell]
    let footer: String?
}

struct AppearanceCell: Hashable {
    enum Accessory: Hashable {
        case toggle(isOn: Bool)
        case checkmark(selected: Bool)
    }
    enum Kind: Hashable {
        case incomingToken
        case activeSearch
        case defaultList
        case compactList
        case hideTokens
    }
    
    let icon: UIImage?
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
                .init(
                    icon: Asset.settingsNextToken.image,
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
                .init(
                    icon: Asset.settingsActiveSearch.image,
                    title: T.Appearance.toggleActiveSearch,
                    accessory: .toggle(isOn: isActiveSearchEnabled),
                    kind: .activeSearch
                )
            ],
            footer: T.Appearance.activeSearchDescription
        )
        
        let selectedStyle = interactor.selectedListStyle
        let listStyle = AppearanceSection(
            title: T.Settings.listStyle,
            cells: [
                .init(
                    icon: UIImage(systemName: "rectangle.grid.1x2.fill")?
                        .apply(Theme.Colors.Fill.theme)?
                        .scalePreservingAspectRatio(targetSize: Theme.Metrics.settingsSmallIconSize),
                    title: T.Settings.listStyleOptionDefault,
                    accessory: .checkmark(selected: selectedStyle == .default),
                    kind: .defaultList
                ),
                .init(
                    icon: UIImage(systemName: "rectangle.grid.2x2.fill")?
                        .apply(Theme.Colors.Fill.theme)?
                        .scalePreservingAspectRatio(targetSize: Theme.Metrics.settingsSmallIconSize),
                    title: T.Settings.listStyleOptionCompact,
                    accessory: .checkmark(selected: selectedStyle == .compact),
                    kind: .compactList
                )
            ],
            footer: nil
        )
        
        let tokensHidden = AppearanceSection(
            title: nil,
            cells: [
                .init(
                    icon: UIImage(systemName: "eye.fill")?
                        .apply(Theme.Colors.Fill.theme)?
                        .scalePreservingAspectRatio(targetSize: Theme.Metrics.settingsSmallIconSize),
                    title: T.Settings.hideTokensTitle,
                    accessory: .toggle(isOn: interactor.areTokensHidden),
                    kind: .hideTokens
                )
            ],
            footer: T.Settings.hideTokensDescription
        )
        
        return[
            incoming,
            activeSearch,
            listStyle,
            tokensHidden
        ]
    }
}
