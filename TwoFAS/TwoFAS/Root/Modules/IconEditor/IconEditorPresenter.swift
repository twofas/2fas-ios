//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

final class IconEditorPresenter: ObservableObject {
    @Published var iconType: IconType {
        didSet { handleIconTypeChange() }
    }
    @Published private(set) var selectedIconTypeID: IconTypeID?
    @Published var labelTitle: String
    @Published var labelColor: TintColor
    @Published var searchPhrase: String = "" {
        didSet { reloadSections() }
    }
    @Published private(set) var sections: [IconSelectorSection] = []

    var isSearching: Bool {
        !searchPhrase.trim().isEmpty
    }

    var previewIcon: IconDetails {
        value.iconDetails
    }

    var isSaveEnabled: Bool {
        if iconType == .label && labelTitle.isEmpty {
            return false
        }
        return !value.isEquivalent(to: initialValue)
    }

    private var value: IconEditorValue {
        IconEditorValue(
            iconType: iconType,
            iconTypeID: selectedIconTypeID,
            labelTitle: labelTitle,
            labelColor: labelColor
        )
    }

    private let initialValue: IconEditorValue
    private let flowController: IconEditorFlowControlling
    private let interactor: IconEditorModuleInteracting

    init(
        flowController: IconEditorFlowControlling,
        interactor: IconEditorModuleInteracting,
        value: IconEditorValue
    ) {
        self.flowController = flowController
        self.interactor = interactor

        var initial = value
        if initial.iconType == .brand && initial.iconTypeID == nil {
            initial.iconTypeID = interactor.defaultIconTypeID
        }
        self.initialValue = initial
        self.iconType = initial.iconType
        self.selectedIconTypeID = initial.iconTypeID
        self.labelTitle = initial.labelTitle
        self.labelColor = initial.labelColor

        reloadSections()
    }
}

extension IconEditorPresenter {
    func handleSelection(iconTypeID: IconTypeID) {
        selectedIconTypeID = iconTypeID
    }

    func handleSave() {
        guard isSaveEnabled else { return }
        switch iconType {
        case .brand: AppEventLog(.codeDetailsBrandSet)
        case .label: AppEventLog(.codeDetailsLabelSet)
        }
        flowController.toSave(value)
    }

    func sanitizeLabelTitle(_ value: String) -> String {
        interactor.sanitizeLabelTitle(value)
    }

    func handleOrderIconUser() {
        flowController.toUserIcon()
    }

    func handleOrderIconCompany() {
        flowController.toCompanyIcon()
    }
}

private extension IconEditorPresenter {
    func handleIconTypeChange() {
        guard iconType == .brand, selectedIconTypeID == nil else { return }
        selectedIconTypeID = interactor.defaultIconTypeID
    }

    func reloadSections() {
        sections = interactor.iconGroups(matching: searchPhrase).map { group in
            IconSelectorSection(
                title: group.title,
                cells: group.icons.map { icon in
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
