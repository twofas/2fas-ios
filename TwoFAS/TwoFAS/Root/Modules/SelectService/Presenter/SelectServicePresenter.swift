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

final class SelectServicePresenter {
    weak var view: SelectServiceViewControlling?
    
    private let flowController: SelectServiceFlowControlling
    private let interactor: SelectServiceModuleInteracting
    private let authRequest: WebExtensionAwaitingAuth
    
    var browserName: String { interactor.browserName(for: authRequest.extensionID) }
    var domain: String { authRequest.domain }
    
    private var query: String?
    private var lastList
    
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
        let categoryList = interactor.listServices(filter: query, for: domain)
        guard let category = categoryList[safe: indexPath.section],
              let serviceData = category.services[safe: indexPath.row]
        else { return }
        flowController.toServiceSelection(with: serviceData, authRequest: authRequest)
    }
    
    func handleCancel() {
        flowController.toCancel(for: authRequest.tokenRequestID)
    }
}

private extension SelectServicePresenter {
    func reload() {
        let servicesWithCategories: [SelectServiceSection] = interactor
            .listServices(filter: query, for: domain)
            .map({ category -> SelectServiceSection in
                let cells = category.services.map({ serviceData in SelectServiceCell(serviceData: serviceData) })
                return SelectServiceSection(title: category.section?.title, cells: cells)
            })
        if servicesWithCategories.isEmpty || servicesWithCategories.first?.cells.isEmpty == true {
            view?.showEmptyScreen()
            return
        }
        view?.reload(with: servicesWithCategories)
    }
}
