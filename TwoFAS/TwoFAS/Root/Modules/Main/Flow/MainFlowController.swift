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

protocol MainFlowControllerParent: AnyObject {}

protocol MainFlowControlling: AnyObject {
    func toAuthRequestFetch()
    func toClearAuthList()
    func toAuthorize(for tokenRequestID: String)
    func toSecretSyncError(_ serviceName: String)
    func toOpenFileImport(url: URL)
    func toSetupSplit()
    
    // MARK: - App update
    func toShowNewVersionAlert(for appStoreURL: URL, skip: @escaping Callback)
}

final class MainFlowController: FlowController {
    private var authRequestsFlowController: AuthRequestsFlowControllerChild?
    
    private weak var parent: MainFlowControllerParent?
    private weak var naviViewController: UINavigationController!
    private var galleryViewController: UIViewController?
    
    static func showAsRoot(
        in viewController: ContainerViewController, // TODO: Change to plain VC
        parent: MainFlowControllerParent,
        immediately: Bool
    ) {
        let view = MainViewController()
        let flowController = MainFlowController(viewController: view)
        flowController.parent = parent
        flowController.authRequestsFlowController = AuthRequestsFlowController.create(parent: flowController)
        let interactor = InteractorFactory.shared.mainModuleInteractor()
        let presenter = MainPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view

        viewController.present(view, immediately: immediately, animationType: .alpha)
        
        // TODO: Make it a child of root VC
//        viewController.addChild(view)
//        viewController.view.addSubview(view.view)
//        view.view.pinToParent()
//        view.didMove(toParent: viewController)
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
        ImporterOpenFileFlowController.present(on: _viewController, parent: self, url: url)
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
}

extension MainFlowController: ImporterOpenFileFlowControllerParent {
    func closeImporter() {
        viewController.dismiss(animated: true) {
            NotificationCenter.default.post(name: .servicesWereUpdated, object: nil)
        }
    }
}

extension MainFlowController: AuthRequestsFlowControllerParent {
    func authRequestAskUserForAuthorization(auth: WebExtensionAwaitingAuth, pair: PairedAuthRequest) {
        AskForAuthFlowController.present(on: viewController, parent: self, auth: auth, pair: pair)
    }
    
    func authRequestShowServiceSelection(auth: WebExtensionAwaitingAuth) {
        SelectServiceNavigationFlowController.present(on: viewController, parent: self, authRequest: auth)
    }
}

extension MainFlowController: SelectServiceNavigationFlowControllerParent {
    func serviceSelectionDidSelect(_ serviceData: ServiceData, authRequest: WebExtensionAwaitingAuth) {
        viewController.dismiss(animated: true) { [weak self] in
            self?.authRequestsFlowController?.didSelectService(serviceData, auth: authRequest)
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
    func navigationNeedsRestoration() {
        viewController.presenter.handleNavigationRestoration()
    }
    
    func navigatedToViewPath(_ viewPath: ViewPath) {
        viewController.presenter.handleDidChangePath(viewPath)
    }
    
    func navigationTabReady() {
        viewController.presenter.handleReady()
    }
    
    func navigationSwitchToTokens() {
        viewController.presenter.handleSwitchToTokens()
    }
}
