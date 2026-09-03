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

import SwiftUI
import Common
import Data

final class IconSelectorPresenter: ObservableObject {
    @Published
    var sections: [IconSelectorSection] = []

    @Published
    var selectedIconTypeID: IconTypeID?

    @Published
    var searchPhrase: String = ""

    var isSearching: Bool {
        !searchPhrase.isEmpty
    }

    private let flowController: IconSelectorFlowControlling
    private let interactor: IconSelectorModuleInteracting

    init(
        flowController: IconSelectorFlowControlling,
        interactor: IconSelectorModuleInteracting,
        selectedIconTypeID: IconTypeID?
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.selectedIconTypeID = selectedIconTypeID
        reload()
    }
}

extension IconSelectorPresenter {
    func viewDidAppear() {
        reload()
    }

    func handleSelection(iconTypeID: IconTypeID) {
        AppEventLog(.codeDetailsBrandSet)
        selectedIconTypeID = iconTypeID
        flowController.toSelection(iconTypeID: iconTypeID)
    }

    func handleOrderIconUser() {
        flowController.toUserIcon()
    }

    func handleOrderIconCompany() {
        flowController.toCompanyIcon()
    }

    func handleSearchChange(_ phrase: String) {
        if phrase.isEmpty {
            interactor.clearSearch()
        } else {
            interactor.search(phrase)
        }
        reload()
    }
}

private extension IconSelectorPresenter {
    func reload() {
        sections = interactor.currentIcons.map { iconGroup in
            IconSelectorSection(
                title: iconGroup.title,
                cells: iconGroup.icons.map { icon in
                    IconSelectorCell(
                        icon: icon.icon,
                        title: icon.name,
                        iconTypeID: icon.iconTypeID,
                        showTitle: true
                    )
                }
            )
        }
    }
}
