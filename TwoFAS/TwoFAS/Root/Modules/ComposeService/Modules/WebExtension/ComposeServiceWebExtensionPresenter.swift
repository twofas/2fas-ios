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

struct ComposeServiceWebExtensionSection: Identifiable, Hashable {
    struct Row: Identifiable, Hashable {
        var id: PairedAuthRequest { authRequest }
        let authRequest: PairedAuthRequest
        
        var title: String { authRequest.domain }
    }
    
    let id = UUID()
    let title: String
    let cells: [Row]
}

final class ComposeServiceWebExtensionPresenter: ObservableObject {
    @Published var sections: [ComposeServiceWebExtensionSection] = []
    @Published var pendingDeletion: ComposeServiceWebExtensionSection.Row?
    @Published var isDeleteAlertPresented: Bool = false

    private let flowController: ComposeServiceWebExtensionFlowControlling
    private let interactor: ComposeServiceWebExtensionModuleInteracting

    init(
        flowController: ComposeServiceWebExtensionFlowControlling,
        interactor: ComposeServiceWebExtensionModuleInteracting
    ) {
        self.flowController = flowController
        self.interactor = interactor
    }
}

extension ComposeServiceWebExtensionPresenter {
    func viewWillAppear() {
        reload()
    }

    func handleBack() {
        flowController.close()
    }

    func handleSelection(_ row: ComposeServiceWebExtensionSection.Row) {
        pendingDeletion = row
        isDeleteAlertPresented = true
    }

    func handleConfirmDeletion() {
        guard let row = pendingDeletion else { return }
        pendingDeletion = nil
        interactor.removePairing(row.authRequest)
        guard !interactor.listAll().isEmpty else {
            flowController.toFinish()
            return
        }
        reload()
    }
}

private extension ComposeServiceWebExtensionPresenter {
    func reload() {
        sections = interactor.listAll().map { data in
            ComposeServiceWebExtensionSection(
                title: data.extensionName,
                cells: data.pairings.map { ComposeServiceWebExtensionSection.Row(authRequest: $0) }
            )
        }
    }
}
