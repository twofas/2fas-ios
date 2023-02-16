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

struct MainMenuSection: Hashable {
    enum Section {
        case main
    }
    let section: Section
    let showHeader: Bool
    let cells: [MainMenuCell]
}

struct MainMenuCell: Hashable {
    let icon: UIImage?
    let selectedIcon: UIImage?
    let title: String
    let isSelected: Bool
    let section: SectionID?
    let hasBadge: Bool
}

extension MainMenuPresenter {
    var menu: [MainMenuSection] {
        [
            MainMenuSection(
                section: .main,
                showHeader: false,
                cells: [
                MainMenuCell(
                    icon: Asset.tabBarIconServicesInactive.image,
                    selectedIcon: Asset.tabBarIconServicesActive.image,
                    title: T.Commons.tokens,
                    isSelected: selectedIndexPath?.row == 1,
                    section: nil,
                    hasBadge: false
                ),
                MainMenuCell(
                    icon: Asset.tabBarIconSettingsInactive.image,
                    selectedIcon: Asset.tabBarIconSettingsActive.image,
                    title: T.Settings.settings,
                    isSelected: selectedIndexPath?.row == 2,
                    section: nil,
                    hasBadge: false
                ),
                MainMenuCell(
                    icon: Asset.tabBarIconNotificationsInactive.image,
                    selectedIcon: Asset.tabBarIconNotificationsActive.image,
                    title: T.Commons.notifications,
                    isSelected: selectedIndexPath?.row == 3,
                    section: nil,
                    hasBadge: true
                )
            ])
        ]
    }    
}
