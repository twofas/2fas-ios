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
        
    var splitView: (any MainNavigating)?

    /// Floating glass "+" (iOS 26). It lives here, outside the tab bar
    /// controller, because the system zoom transition used to present "add
    /// service" pushes back the view of the controller owning the zoom source;
    /// `MainView` keeps this screen still, and `UITabBarController` can't swap
    /// its own view class.
    private let addServiceButton = UIButton(type: .system)

    var onAddService: (() -> Void)?

    /// Zoom source for the "add service" presentation (iOS 26 only).
    var addServiceSourceView: UIView? {
        guard #available(iOS 26.0, *) else { return nil }
        return addServiceButton
    }

    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsEventController.setup()
        setupEvents()

        if #available(iOS 26.0, *) {
            setupAddServiceButton()
        }
        
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
    /// Pins the "+" over `slot` and keeps it above the other subviews. Call
    /// once the tab bar container's view has been added.
    @available(iOS 26.0, *)
    func attachAddServiceButton(to slot: UILayoutGuide) {
        view.bringSubviewToFront(addServiceButton)
        NSLayoutConstraint.activate([
            addServiceButton.widthAnchor.constraint(equalTo: slot.widthAnchor),
            addServiceButton.heightAnchor.constraint(equalTo: slot.heightAnchor),
            addServiceButton.centerXAnchor.constraint(equalTo: slot.centerXAnchor),
            addServiceButton.centerYAnchor.constraint(equalTo: slot.centerYAnchor)
        ])
    }

    @available(iOS 26.0, *)
    private func setupAddServiceButton() {
        var config = UIButton.Configuration.prominentGlass()
        config.image = UIImage(systemName: "plus")
        config.preferredSymbolConfigurationForImage = .init(pointSize: 22, weight: .semibold)
        // Brand-tinted glass fill with a contrasting (white) "+" glyph.
        config.baseForegroundColor = .white
        config.baseBackgroundColor = AppColor.accentsBrand.uiColor

        addServiceButton.configuration = config
        addServiceButton.accessibilityLabel = T.Voiceover.addService
        addServiceButton.addAction(UIAction { [weak self] _ in
            self?.onAddService?()
        }, for: .touchUpInside)
        addServiceButton.tintColor = AppColor.accentsBrand.uiColor
        addServiceButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addServiceButton)
    }
}

extension MainViewController: BackupSetPasswordFlowControllerParent {
    func closeSetPassword() {
        dismiss(animated: true)
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
            selector: #selector(switchToTokens),
            name: .switchToTokens,
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
        notificationCenter.addObserver(
            self,
            selector: #selector(allServicesRemoved),
            name: .allServicesRemoved,
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
            Log("MainViewController: refreshing auth list, no token request ID")
            presenter.handleRefreshAuthList()
            return
        }
        
        Log("MainViewController: handling authorization with token request ID")
        presenter.handleAuthorize(for: tokenRequestID)
    }
    
    @objc
    private func switchToSetupPIN() {
        presenter.handleSwitchToSetupPIN()
    }
    
    @objc
    private func switchToTokens() {
        presenter.handleSwitchToTokens()
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

    @objc
    private func allServicesRemoved() {
        presenter.handleAllServicesRemoved()
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
