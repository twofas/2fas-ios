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

protocol IconSelectorModuleInteracting: AnyObject {
    var hasIcons: Bool { get }
    var indexPathForSelectedIcon: IndexPath? { get }
    var currentIcons: [IconDescriptionGroup] { get }
    var defaultIcon: IconTypeID? { get }

    func iconTypeID(for indexPath: IndexPath) -> IconTypeID?
    func indexTitles() -> [String]
    func indexPathForIndex(_ index: Int) -> IndexPath
    func search(_ searchText: String?)
    func clearSearch()
}

final class IconSelectorModuleInteractor {
    private let iconInteractor: IconInteracting
    private let serviceDefinitionInteractor: ServiceDefinitionInteracting
    let defaultIcon: IconTypeID?
    private let selectedIcon: IconTypeID?
    
    private var dataStore: [IconDescriptionGroup] = []
    
    init(
        iconInteractor: IconInteracting,
        serviceDefinitionInteractor: ServiceDefinitionInteracting,
        defaultIcon: IconTypeID?,
        selectedIcon: IconTypeID?
    ) {
        self.iconInteractor = iconInteractor
        self.serviceDefinitionInteractor = serviceDefinitionInteractor
        self.defaultIcon = defaultIcon
        self.selectedIcon = selectedIcon
        
        buildDataStore()
    }
}

extension IconSelectorModuleInteractor: IconSelectorModuleInteracting {
    var hasIcons: Bool {
        !dataStore.isEmpty
    }
    
    var indexPathForSelectedIcon: IndexPath? {
        guard let selectedIcon, let indexPath = findIndexPath(for: selectedIcon) else { return nil }
        return indexPath
    }
    
    var currentIcons: [IconDescriptionGroup] {
        dataStore
    }
    
    func iconTypeID(for indexPath: IndexPath) -> IconTypeID? {
        dataStore[safe: indexPath.section]?.icons[safe: indexPath.row]?.iconTypeID
    }
        
    func search(_ searchText: String?) {
        guard let searchText, !searchText.isEmpty else {
            buildDataStore()
            return
        }
        
        findServices(for: searchText)
    }
    
    func clearSearch() {
        buildDataStore()
    }
    
    func indexTitles() -> [String] {
        dataStore.map {
            if $0.title.count == 1 {
                return $0.title
            } else {
                return "#"
            }
        }
    }
    
    func indexPathForIndex(_ index: Int) -> IndexPath {
        IndexPath(row: 0, section: index)
    }
}

private extension IconSelectorModuleInteractor {
    func buildDataStore() {
        dataStore = iconInteractor.grouppedList()
    }
        
    func findIndexPath(for iconTypeID: IconTypeID) -> IndexPath? {
        let paths: [IndexPath] = dataStore.enumerated().compactMap { index, element in
            let rows: [Int] = element.icons.enumerated().compactMap { iconIndex, iconElement in
                (iconElement.iconTypeID == iconTypeID) ? iconIndex : nil
            }
            guard let row = rows.first else { return nil }
            return IndexPath(row: row, section: index)
        }
        return paths.first
    }
    
    func findServices(for searchText: String) {
        let searchTextFormatted = searchText.uppercased()
        let tags = serviceDefinitionInteractor.findServices(byTag: searchText)
            .map({ $0.iconTypeID })
        let icons = iconInteractor.grouppedList()
        let filteredIcons: [IconDescriptionGroup] = icons.enumerated().compactMap { _, element in
            let selectedIcon: [IconDescription] = element.icons.enumerated().compactMap { _, iconElement in
                if iconElement.name.uppercased().contains(searchTextFormatted)
                    || tags.contains(iconElement.iconTypeID) {
                    return iconElement
                }
                return nil
            }
            guard !selectedIcon.isEmpty else { return nil }
            return IconDescriptionGroup(title: element.title, icons: selectedIcon)
        }
        dataStore = filteredIcons
    }
}
