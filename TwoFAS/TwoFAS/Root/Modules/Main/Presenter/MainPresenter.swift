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
    weak var view: MainViewControlling?
    
    private let flowController: MainFlowControlling
    private let interactor: MainModuleInteracting
    
    private var authRequestsFetched = false
    private var appVersionFetched = false
    
    init(flowController: MainFlowControlling, interactor: MainModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        interactor.secretSyncError = { [weak flowController] in flowController?.toSecretSyncError($0) }
    }
    
    func viewDidLoad() {
        interactor.initialize()
        flowController.toSetupSplit()
    }
    
    func viewWillAppear() {
        if let url = interactor.checkForImport() {
            flowController.toOpenFileImport(url: url)
            interactor.clearImportedFileURL()
        } else if !appVersionFetched {
            appVersionFetched = true
            
            interactor.checkForNewAppVersion { [weak self] url in
                guard let url else {
                    self?.handleAuthRequest()
                    return
                }
                self?.flowController.toShowNewVersionAlert(for: url) { [weak self] in
                    self?.interactor.skipAppVersion()
                }
            }
        } else if !authRequestsFetched {
            handleAuthRequest()
        }
    }

    func handleSwitchToSetupPIN() {
        view?.navigateToViewPath(.settings(option: .security))
    }

    func handleSwitchToBrowserExtension() {
        view?.navigateToViewPath(.settings(option: .browserExtension))
    }
    
    func handleSwitchToExternalImport() {
        view?.navigateToViewPath(.settings(option: .externalImport))
    }
    
    func handleSwitchedToSettings() {
        view?.settingsTabActive()
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

private extension MainPresenter {
    func handleAuthRequest() {
        authRequestsFetched = true
        flowController.toAuthRequestFetch()
    }
}
