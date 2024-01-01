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

final class SelectServicePresenter {
    weak var view: SelectServiceViewControlling?
    
    private let flowController: SelectServiceFlowControlling
    private let interactor: SelectServiceModuleInteracting
    private let authRequest: WebExtensionAwaitingAuth
    
    var browserName: String { interactor.browserName(for: authRequest.extensionID) }
    var domain: String { authRequest.domain }
    private(set) var saveSwitchValue = false
    
    private var query: String?
    private var lastList: [SelectServiceSection]?
    
    var showTableViewHeader: Bool { query == nil }
    
    init(
        flowController: SelectServiceFlowControlling,
        interactor: SelectServiceModuleInteracting,
        authRequest: WebExtensionAwaitingAuth
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.authRequest = authRequest
    }
}

extension SelectServicePresenter {
    func viewWillAppear() {
        reload()
    }
    
    func handleSearch(_ query: String) {
        self.query = query
        reload()
    }
    
    func handleClearSearch() {
        query = nil
        reload()
    }
    
    func handleSelection(at indexPath: IndexPath) {
        guard
            let lastList,
            let category = lastList[safe: indexPath.section],
            let serviceData = category.cells[safe: indexPath.row]?.serviceData
        else { return }

        flowController.toServiceSelection(with: serviceData, authRequest: authRequest, save: saveSwitchValue)
    }
    
    func handleCancel() {
        flowController.toCancel(for: authRequest.tokenRequestID)
    }
    
    func handleSwitchAction(isOn: Bool) {
        saveSwitchValue = isOn
    }
}

private extension SelectServicePresenter {
    func reload() {
        let servicesWithCategories: [SelectServiceSection] = interactor
            .listServices(filter: query, for: domain)
        lastList = servicesWithCategories
        if servicesWithCategories.isEmpty {
            view?.showEmptyScreen()
            return
        }
        view?.reload(with: servicesWithCategories)
    }
}
