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

protocol MainFlowControllerParent: AnyObject {}

protocol MainFlowControlling: AnyObject {
    func toAuthRequestFetch()
    func toClearAuthList()
    func toAuthorize(for tokenRequestID: String)
    func toSecretSyncError(_ serviceName: String)
    func toOpenFileImport(url: URL)
    func toSetupSplit()
    func toSetPIN()
    
    // MARK: - App update
    func toShowNewVersionAlert(for appStoreURL: URL, skip: @escaping Callback)
}

final class MainFlowController: FlowController {
    private var authRequestsFlowController: AuthRequestsFlowControllerChild?
    
    private weak var parent: MainFlowControllerParent?
    private weak var naviViewController: UINavigationController!
    private var galleryViewController: UIViewController?
    private var importer: ImporterOpenFileHeadlessFlowController?
    
    static func showAsRoot(
        in viewController: UIViewController,
        parent: MainFlowControllerParent,
        immediately: Bool
    ) -> MainViewController {
        let view = MainViewController()
        let flowController = MainFlowController(viewController: view)
        flowController.parent = parent
        flowController.authRequestsFlowController = AuthRequestsFlowController.create(parent: flowController)
        let interactor = ModuleInteractorFactory.shared.mainModuleInteractor()
        let presenter = MainPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view
        
        viewController.addChild(view)
        viewController.view.addSubview(view.view)
        view.view.pinToParent()
        view.didMove(toParent: viewController)
        
        if !immediately {
            view.view.alpha = 0
            UIView.animate(withDuration: Theme.Animations.Timing.quick, delay: 0, options: .curveEaseInOut) {
                view.view.alpha = 1
            }
        }
        
        return view
    }
}

extension MainFlowController {
    var viewController: MainViewController { _viewController as! MainViewController }
}

extension MainFlowController: MainFlowControlling {
    func toSetupSplit() {
        MainSplitFlowController.showAsRoot(in: viewController, parent: self)
    }
    func toAuthRequestFetch() {
        authRequestsFlowController?.refresh()
    }
    
    func toClearAuthList() {
        authRequestsFlowController?.clearList()
    }
    
    func toAuthorize(for tokenRequestID: String) {
        authRequestsFlowController?.authorizeFromApp(for: tokenRequestID)
    }

    func toSecretSyncError(_ serviceName: String) {
        let alert = AlertControllerDismissFlow(
            title: T.Commons.error,
            message: T.Backup.incorrectSecret(serviceName),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        _viewController.present(alert, animated: true, completion: nil)
    }
    
    func toOpenFileImport(url: URL) {
        importer = ImporterOpenFileHeadlessFlowController.present(on: _viewController, parent: self, url: url)
    }
    
    // MARK: - App update
    
    func toShowNewVersionAlert(for appStoreURL: URL, skip: @escaping Callback) {
        let alertTitle = T.NewVersion.newVersionTitle
        let alertMessage = T.NewVersion.newVersionMessageIos
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let updateButton = UIAlertAction(title: T.NewVersion.updateAction, style: .default) { _ in
            guard UIApplication.shared.canOpenURL(appStoreURL) else { return }
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(updateButton)
        
        let notNowButton = UIAlertAction(title: T.NewVersion.updateLater, style: .cancel)
        alertController.addAction(notNowButton)
        
        let skipButton = UIAlertAction(title: T.NewVersion.skipTitle, style: .destructive) { _ in
            skip()
        }
        alertController.addAction(skipButton)
        
        guard viewController.presentedViewController == nil else { return }

        viewController.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - MDM requriments
    
    func toSetPIN() {
        NewPINNavigationFlowController.present(on: viewController, parent: self)
    }
}

extension MainFlowController: ImporterOpenFileHeadlessFlowControllerParent {
    func importerClose() {
        viewController.dismiss(animated: true) { [weak self] in
            NotificationCenter.default.post(name: .servicesWereUpdated, object: nil)
            self?.importer = nil
        }
    }
}

extension MainFlowController: AuthRequestsFlowControllerParent {
    func authRequestAskUserForAuthorization(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        guard viewController.presentedViewController == nil else { return }
        AskForAuthFlowController.present(on: viewController, parent: self, auth: auth, pair: pair)
    }
    
    func authRequestShowServiceSelection(auth: WebExtensionAwaitingAuth) {
        guard viewController.presentedViewController == nil else { return }
        SelectServiceNavigationFlowController.present(on: viewController, parent: self, authRequest: auth)
    }
}

extension MainFlowController: SelectServiceNavigationFlowControllerParent {
    func serviceSelectionDidSelect(_ serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth, save: Bool) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.didSelectService(serviceData, auth: authRequest, save: save)
        }
    }
    
    func serviceSelectionCancelled(for tokenRequestID: String) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.didCancelServiceSelection(for: tokenRequestID)
        }
    }
}

extension MainFlowController: AskForAuthFlowControllerParent {
    func askForAuthAllow(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.authorize(auth: auth, pair: pair)
        }
    }
    
    func askForAuthDeny(tokenRequestID: String) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.skip(for: tokenRequestID)
        }
    }
}

extension MainFlowController: MainSplitFlowControllerParent {
    func navigationSwitchedToTokens() {
        toAuthRequestFetch()
    }
    
    func navigationSwitchedToSettings() {
        viewController.presenter.handleSwitchedToSettings()
    }
    
    func navigationSwitchedToSettingsExternalImport() {
        viewController.presenter.handleSwitchToExternalImport()
    }
    
    func navigationSwitchedToSettingsBackup() {
        viewController.presenter.handleSwitchToBackup()
    }
}

extension MainFlowController: NewPINNavigationFlowControllerParent {
    func pinGathered(with PIN: String, pinType: PINType) {
        viewController.presenter.handleSavePIN(PIN, pinType: pinType)
        viewController.dismiss(animated: true) { [weak viewController] in
            viewController?.presenter.handleViewIsVisible()
        }
    }
}
