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

final class ComposeServiceCategorySelectionPresenter: ObservableObject {
    @Published var rows: [ComposeServiceCategorySelectionRow] = []
    @Published var isAddSectionAlertPresented: Bool = false
    @Published var newSectionName: String = ""

    private let flowController: ComposeServiceCategorySelectionFlowControlling
    private let interactor: ComposeServiceCategorySelectionModuleInteracting

    init(
        flowController: ComposeServiceCategorySelectionFlowControlling,
        interactor: ComposeServiceCategorySelectionModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension ComposeServiceCategorySelectionPresenter {
    var isNewSectionNameValid: Bool {
        ServiceRules.isSectionNameValid(sectionName: newSectionName.trim())
    }

    func viewWillAppear() {
        reload()
    }

    func handleBack() {
        flowController.close()
    }

    func handleSelection(_ row: ComposeServiceCategorySelectionRow) {
        interactor.setSelection(row.sectionID)
        flowController.toChangeSection(row.sectionID)
        flowController.close()
    }

    func handleShowAddSection() {
        newSectionName = ""
        isAddSectionAlertPresented = true
    }

    func handleConfirmAddSection() {
        let trimmed = newSectionName.trim()
        guard ServiceRules.isSectionNameValid(sectionName: trimmed) else { return }
        interactor.addSection(with: trimmed)
        reload()
    }
}

private extension ComposeServiceCategorySelectionPresenter {
    func reload() {
        let selectedSectionID = interactor.selectedSection
        var list: [ComposeServiceCategorySelectionRow] = interactor.listSections().map {
            ComposeServiceCategorySelectionRow(
                title: $0.title,
                sectionID: $0.sectionID,
                checkmark: $0.sectionID == selectedSectionID
            )
        }
        list.insert(
            ComposeServiceCategorySelectionRow(
                title: T.Tokens.myTokens,
                sectionID: nil,
                checkmark: selectedSectionID == nil
            ),
            at: 0
        )
        rows = list
    }
}
