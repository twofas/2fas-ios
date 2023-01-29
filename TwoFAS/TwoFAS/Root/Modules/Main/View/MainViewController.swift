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

final class MainViewController: UIViewController {
    var presenter: MainPresenter!
    
    var previousSelectedIndex: Int = 0
    
    private let mainIndex: Int = 0
    private let settingsIndex: Int = 1
    private let settingsEventController = SettingsEventController()
    
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
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainViewController {
    private func setupEvents() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshAuthList),
            name: .pushNotificationRefreshAuthList,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshAuthList),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearAuthList),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authorizeFromApp),
            name: .pushNotificationAuthorizeFromApp,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(switchToSetupPIN),
            name: .switchToSetupPIN,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(switchToBrowserExtension),
            name: .switchToBrowserExtension,
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
}
