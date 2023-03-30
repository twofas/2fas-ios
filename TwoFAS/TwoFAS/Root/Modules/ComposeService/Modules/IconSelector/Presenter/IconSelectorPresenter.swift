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

final class IconSelectorPresenter {
    weak var view: IconSelectorViewControlling?
    
    private let flowController: IconSelectorFlowControlling
    private let interactor: IconSelectorModuleInteracting
    
    var selectedIconTypeID: IconTypeID?
    var defaultIconTypeUD: IconTypeID?
    private(set) var isSearching = false
    
    init(flowController: IconSelectorFlowControlling, interactor: IconSelectorModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension IconSelectorPresenter {
    func viewWillAppear() {
        reload()
    }
    
    func viewDidAppear() {
        setSelection()
    }
    
    func handleIndexPathForOffset(_ offset: Int) -> IndexPath {
        interactor.indexPathForIndex(offset)
    }
    
    func handleSelection(at indexPath: IndexPath) {
        guard let iconTypeID = interactor.iconTypeID(for: indexPath) else { return }
        AppEventLog(.codeDetailsBrandSet)
        flowController.toSelection(iconTypeID: iconTypeID)
    }
    
    func handleIndexTitles() -> [String] {
        interactor.indexTitles()
    }
    
    func handleSearch(_ phrase: String) {
        isSearching = true
        interactor.search(phrase)
        reload()
    }
    
    func handleSearchClearing() {
        isSearching = false
        interactor.clearSearch()
        reload()
        setSelection()
    }
    
    func handleTitle(for indexPath: IndexPath) -> String {
        let currentIcons = interactor.currentIcons
        return currentIcons[safe: indexPath.section]?.title ?? ""
    }
    
    func handleOrderIcon(sourceView: UIView) {
        flowController.toOrderIcon(sourceView: sourceView)
    }
}

private extension IconSelectorPresenter {
    func reload() {
        let currentIcons = interactor.currentIcons
        guard !currentIcons.isEmpty else {
            view?.showEmptyScreen()
            return
        }
        
        let list: [IconSelectorSection] = currentIcons.map { iconGroup -> IconSelectorSection in
            IconSelectorSection(
                title: iconGroup.title,
                cells: iconGroup.icons.map { icon -> IconSelectorCell in
                    IconSelectorCell(
                        icon: icon.icon,
                        title: icon.name,
                        iconTypeID: icon.iconTypeID,
                        showTitle: true
                    )
                }
            )
        }
        
        view?.reload(with: list)
        view?.hideEmptyScreen()
    }
    
    func setSelection() {
        guard let selectedIndex = interactor.indexPathForSelectedIcon else { return }
        view?.selectItem(at: selectedIndex, animated: true, scroll: true)
    }
}
