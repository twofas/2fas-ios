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
import Data

final class SelectServicePresenter: ObservableObject {
    private let interactor: SelectServiceModuleInteracting
    private let flowController: SelectServiceFlowControlling
    private let authRequest: WebExtensionAwaitingAuth

    let browserName: String
    let domain: String

    @Published
    var showTableViewHeader = false

    @Published
    var saveSwitchValue = false

    @Published
    var list: [SelectServiceSection] = []

    @Published
    var searchPhrase: String = ""

    init(
        interactor: SelectServiceModuleInteracting,
        flowController: SelectServiceFlowControlling,
        authRequest: WebExtensionAwaitingAuth
    ) {
        self.interactor = interactor
        self.flowController = flowController
        self.authRequest = authRequest

        browserName = interactor.browserName(for: authRequest.extensionID)
        domain = authRequest.domain
    }
}

extension SelectServicePresenter {
    func viewWillAppear() {
        load(query: nil)
    }

    func handleSearchChange(_ query: String) {
        if query.isEmpty {
            load(query: nil)
        } else {
            load(query: query)
        }
    }

    func handleSelection(_ cell: SelectServiceCell) {
        flowController.toServiceSelection(
            with: cell.serviceData,
            authRequest: authRequest,
            save: saveSwitchValue
        )
    }

    func handleCancel() {
        flowController.toCancel(for: authRequest.tokenRequestID)
    }
}

private extension SelectServicePresenter {
    func load(query: String?) {
        list = interactor.listServices(filter: query, for: domain)
        showTableViewHeader = query == nil
    }
}
