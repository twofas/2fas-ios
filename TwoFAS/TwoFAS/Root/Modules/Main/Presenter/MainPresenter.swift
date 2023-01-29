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

final class MainPresenter {
    private let flowController: MainFlowController
    private let interactor: MainModuleInteractor
    
    private var authRequestsFetched = false
    private var appVersionFetched = false
    
    init(flowController: MainFlowController, interactor: MainModuleInteractor) {
        self.flowController = flowController
        self.interactor = interactor
        interactor.secretSyncError = { [weak flowController] in flowController?.toSecretSyncError($0) }
    }
    
    func viewDidLoad() {
        interactor.initialize()
    }
    
    func viewWillAppear() {
        if let url = interactor.checkForImport() {
            flowController.toOpenFileImport(url: url)
            interactor.clearImportedFileURL()
        } else if !appVersionFetched {
            appVersionFetched = true
            
            interactor.checkForNewAppVersion { [weak self] url in
                self?.flowController.toShowNewVersionAlert(for: url) { [weak self] in
                    self?.interactor.skipAppVersion()
                }
            }
        } else if !authRequestsFetched {
            authRequestsFetched = true
            flowController.toAuthRequestFetch()
        }
        // restore view path
    }
    
    func handleViewPathUpdate(_ viewPath: ViewPath) {
        interactor.setViewPath(viewPath)
    }
    
    func handleSwitchToTokens() {
        //flow ->
    }
    
    func handleSwitchToSetupPIN() {
        
    }
    
    func handleSwitchToBrowserExtension() {
        
    }
    
    func handleClearAuthList() {
        flowController.toClearAuthList()
    }
    
    func handleRefreshAuthList() {
        flowController.toAuthRequestFetch()
    }
    
    func handleAuthorize(for tokenRequestID: String) {
        flowController.toAuthorize(for: tokenRequestID)
    }
}
