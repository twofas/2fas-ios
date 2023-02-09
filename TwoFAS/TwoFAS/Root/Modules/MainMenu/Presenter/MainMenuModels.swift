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

struct MainMenuSection: Hashable {
    let section: MainContent
    let cells: [MainMenuCell]
}

struct MainMenuCell: Hashable {
    let icon: UIImage?
    let selectedIcon: UIImage?
    let title: String
    let isSelected: Bool
    let sectionOffset: Int?
}

extension MainMenuPresenter {
    var menu: [MainMenuSection] {
        [
            MainMenuSection(section: .main, cells: [
                MainMenuCell(
                    icon: Asset.tabBarIconServicesInactive.image,
                    selectedIcon: Asset.tabBarIconServicesActive.image,
                    title: T.Commons.tokens,
                    isSelected: selectedIndexPath?.section == MainContent.main.rawValue
                                && selectedIndexPath?.row == 0,
                    sectionOffset: nil
                )
            ]),
            MainMenuSection(section: .settings, cells: [
                MainMenuCell(
                    icon: Asset.tabBarIconSettingsInactive.image,
                    selectedIcon: Asset.tabBarIconSettingsActive.image,
                    title: T.Settings.settings,
                    isSelected: selectedIndexPath?.section == MainContent.settings.rawValue,
                    sectionOffset: nil
                )
            ]),
            MainMenuSection(section: .news, cells: [
                MainMenuCell(
                    icon: Asset.tabBarIconNotificationsInactive.image,
                    selectedIcon: Asset.tabBarIconNotificationsActive.image,
                    title: T.Commons.notifications,
                    isSelected: selectedIndexPath?.section == MainContent.news.rawValue,
                    sectionOffset: nil
                )
            ])
        ]
    }
    
    func serviceSections() -> [MainMenuCell] {
        interactor.sections.map { section in
            MainMenuCell(
                icon: nil,
                selectedIcon: nil,
                title: section.name,
                isSelected: selectedIndexPath?.section == MainContent.main.rawValue
                            && selectedIndexPath?.row == section.offset + 1,
                sectionOffset: section.offset
            )
        }
    }
}
