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

struct AppearanceSection: TableViewSection {
    let title: String?
    var cells: [AppearanceCell]
    let footer: String?
}

struct AppearanceCell: Hashable {
    enum AppearanceAccessory: Hashable {
        case toggle(kind: AppearanceToggle, isOn: Bool)
    }
    enum AppearanceToggle: Hashable {
        case incomingToken
        case activeSearch
    }
    
    let icon: UIImage
    let title: String
    let accessory: AppearanceAccessory
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
                            accessory: .toggle(kind: .incomingToken, isOn: isIncomingTokenEnabled)
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
                    accessory: .toggle(kind: .activeSearch, isOn: isActiveSearchEnabled)
                )
            ],
            footer: T.Appearance.activeSearchDescription
        )
        
        return[
           incoming,
           activeSearch
        ]
    }
}
