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

import UIKit.UITabBarItem
import Storage
import Sync

final class MainCoordinator: Coordinator {
    private enum Indexes: Int {
        case main = 0
        case settings = 1
        case news = 2
    }
    
    private let dependency: MainCoordinatorDependencies
    private let showImmidiately: Bool
    private let fileHandler: FileOpenHandler
    private var mainViewController: MainViewController!
    
    private lazy var logUploadingInteractor: LogUploadingInteracting = {
        InteractorFactory.shared.logUploadingInteractor()
    }()
    
    var mainViewIsVisible: Callback?
    
    init(dependency: MainCoordinatorDependencies, showImmidiately: Bool) {
        self.dependency = dependency
        self.showImmidiately = showImmidiately
        self.fileHandler = dependency.fileHandler
        
        super.init()
        
        fileHandler.openFileImport = { [weak self] url in
            self?.openFileImport(url: url); return self?.mainViewController != nil
        }
    }
    
    override func start() {
        mainViewController = MainViewController()
        mainViewController.mainViewIsVisible = { [weak self] in
            self?.mainViewIsVisible?()
            self?.fileHandler.viewWillAppear()
            if let self {
                DebugLog(self.logUploadingInteractor.summarize())
            }
        }
        
        let tokens = TokensNavigationFlowController.showAsATab(in: mainViewController, parent: self)
        
        let settingsTab = SettingsFlowController.showAsATab(in: mainViewController, parent: self)
        settingsTab.tabBarItem = UITabBarItem(
            title: T.Settings.settings,
            image: Asset.tabBarIconSettingsInactive.image,
            selectedImage: Asset.tabBarIconSettingsActive.image
        )
        
        let newsTab = NewsFlowController.showAsATab(in: mainViewController, parent: self)
        
        mainViewController.setViewControllers([tokens, settingsTab, newsTab], animated: false)
        if let newsVC = newsTab.viewControllers.first as? NewsViewController {
            newsVC.presenter.handleInitialLoad()
        }
        
        mainViewController.didSelectOffset = { [weak self] in self?.didSelectOffset($0) }
        
        dependency.rootViewController.present(mainViewController, immediately: showImmidiately, animationType: .alpha)
        
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
        
        dependency.sync.secretSyncError = { [weak self] in self?.secretSyncError($0) }
        
        checkIfViewSwitchIsNecessary()
    }
    
    private func secretSyncError(_ serviceName: String) {
        let alert = AlertControllerDismissFlow(
            title: T.Commons.error,
            message: T.Backup.incorrectSecret(serviceName),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        mainViewController.present(alert, animated: true, completion: nil)
    }
    
    private func openFileImport(url: URL) {
        ImporterOpenFileFlowController.present(on: mainViewController, parent: self, url: url)
    }
    
    private func enableSyncIfPossible() {
        guard dependency.initializeSyncOnFirstRun.isFirstRun else { return }
        dependency.initializeSyncOnFirstRun.markerConsumed()
        dependency.sync.enable()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainCoordinator: SettingsFlowControllerParent {}
extension MainCoordinator: NewsFlowControllerParent {}
extension MainCoordinator: ImporterOpenFileFlowControllerParent {
    func closeImporter() {
        mainViewController.dismiss(animated: true) {
            NotificationCenter.default.post(name: .servicesWereUpdated, object: nil)
        }
    }
}

extension MainCoordinator: TokensNavigationFlowControllerParent {
    func tokensSwitchToTokensTab() {
        switchToTokensTab()
    }
    
    func tokensEnableSyncIfPossible() {
        enableSyncIfPossible()
    }
}

private extension MainCoordinator {
    @objc private func switchToSetupPIN() {
        mainViewController.selectedIndex = Indexes.settings.rawValue
        guard
            let settingsVC = mainViewController.viewControllers?[
                safe: mainViewController.selectedIndex
            ] as? SettingsViewController else { return }
        // Delay so tab bar will have time to load properly the whole view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            settingsVC.switchToSetupPIN()
        }
    }
    
    @objc private func switchToBrowserExtension() {
        mainViewController.selectedIndex = Indexes.settings.rawValue
        guard
            let settingsVC = mainViewController.viewControllers?[
                safe: mainViewController.selectedIndex
            ] as? SettingsViewController else { return }
        // Delay so tab bar will have time to load properly the whole view
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            settingsVC.switchToBrowserExtension()
        }
    }
    
    private func switchToTokensTab() {
        mainViewController.selectedIndex = Indexes.main.rawValue
    }
    
    private func didSelectOffset(_ offset: Int) {
        switch offset {
        case Indexes.main.rawValue:
            dependency.viewPath.set(.main)
        case Indexes.settings.rawValue:
            dependency.viewPath.set(.settings(option: nil))
        case Indexes.news.rawValue:
            dependency.viewPath.set(.news)
        default:
            assertionFailure("UITabBarController has more options than supported for ViewPath")
        }
    }
    
    private func checkIfViewSwitchIsNecessary() {
        guard let path = dependency.viewPath.get() else { return }
        let index: Int
        switch path {
        case .main:
            index = Indexes.main.rawValue
        case .settings:
            index = Indexes.settings.rawValue
        case .news:
            index = Indexes.news.rawValue
        }
        mainViewController.previousSelectedIndex = index
        mainViewController.selectedIndex = index
    }
}
