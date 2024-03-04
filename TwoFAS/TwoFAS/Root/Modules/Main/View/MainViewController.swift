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

import UIKit
import Common
import Data

protocol MainViewControlling: AnyObject {
    func navigateToViewPath(_ viewPath: ViewPath)
    func settingsTabActive()
}

final class MainViewController: UIViewController {
    var presenter: MainPresenter!
    
    private let settingsEventController = SettingsEventController()
    private let notificationCenter = NotificationCenter.default
        
    var splitView: MainSplitViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsEventController.setup()
        setupEvents()
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
}

extension MainViewController {
    private func setupEvents() {
        notificationCenter.addObserver(
            self,
            selector: #selector(refreshAuthList),
            name: .pushNotificationRefreshAuthList,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(refreshAuthList),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(clearAuthList),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(authorizeFromApp),
            name: .pushNotificationAuthorizeFromApp,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(switchToSetupPIN),
            name: .switchToSetupPIN,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(switchToBrowserExtension),
            name: .switchToBrowserExtension,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(fileAwaitsOpening),
            name: .fileAwaitsOpening,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(tokensVisible),
            name: .tokensScreenIsVisible,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(tokensVisible),
            name: .userLoggedIn,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(syncCompletedSuccessfuly),
            name: .syncCompletedSuccessfuly,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(clearSyncCompletedSuccessfuly),
            name: .clearSyncCompletedSuccessfuly,
            object: nil
        )
    }

    @objc
    private func clearAuthList() {
        presenter.handleClearAuthList()
    }
    
    @objc
    private func refreshAuthList() {
        presenter.handleRefreshAuthList()
    }
    
    @objc
    private func authorizeFromApp(notification: Notification) {
        guard let tokenRequestID = notification.userInfo?[
            Notification.pushNotificationAuthorizeFromAppData
        ] as? String else {
            presenter.handleRefreshAuthList()
            return
        }
        
        presenter.handleAuthorize(for: tokenRequestID)
    }
    
    @objc
    private func switchToSetupPIN() {
        presenter.handleSwitchToSetupPIN()
    }
    
    @objc
    private func switchToBrowserExtension() {
        presenter.handleSwitchToBrowserExtension()
    }
    
    @objc
    private func fileAwaitsOpening() {
        presenter.handleOpenFile()
    }
    
    @objc
    private func tokensVisible() {
        presenter.handleViewIsVisible()
    }
    
    @objc
    private func syncCompletedSuccessfuly() {
        presenter.handleSyncCompletedSuccessfuly()
    }
    
    @objc
    private func clearSyncCompletedSuccessfuly() {
        presenter.handleClearSyncCompletedSuccessfuly()
    }
}

extension MainViewController: MainViewControlling {
    func navigateToViewPath(_ viewPath: ViewPath) {
        splitView?.navigateToView(viewPath)
    }
    
    func settingsTabActive() {
        settingsEventController.tabSelected()
    }
}
