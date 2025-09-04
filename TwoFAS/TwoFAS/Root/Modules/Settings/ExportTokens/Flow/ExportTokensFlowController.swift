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

protocol ExportTokensFlowControllerParent: AnyObject {}

protocol ExportTokensFlowControlling: AnyObject {
    func toCopyToClipboard()
    func toSaveOTPAuthFile()
    func toExportQRCodes()
    func toSetupPIN()
    func toShareOTPAuthFileContents(_ url: URL, completion: @escaping () -> Void)
    func toShareQRCodes(_ url: URL, completion: @escaping () -> Void)
    func toError(_ message: String)
}

final class ExportTokensFlowController: FlowController {
    private weak var parent: ExportTokensFlowControllerParent?
    private weak var navigationController: UINavigationController?
    private var pendingAction: ExportAction?
    
    enum ExportAction {
        case copyToClipboard
        case saveOTPAuthFile
        case exportQRCodes
    }
    
    static func showAsRoot(
        in navigationController: UINavigationController,
        parent: ExportTokensFlowControllerParent
    ) {
        let view = ExportTokensViewController()
        let flowController = ExportTokensFlowController(viewController: view)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let interactor = ModuleInteractorFactory.shared.exportTokensModuleInteractor()
        let presenter = ExportTokensPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    static func push(
        in navigationController: UINavigationController,
        parent: ExportTokensFlowControllerParent
    ) {
        let view = ExportTokensViewController()
        let flowController = ExportTokensFlowController(viewController: view)
        flowController.parent = parent
        flowController.navigationController = navigationController
        let interactor = ModuleInteractorFactory.shared.exportTokensModuleInteractor()
        let presenter = ExportTokensPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushRootViewController(view, animated: true)
    }
}

extension ExportTokensFlowController: ExportTokensFlowControlling {
    func toCopyToClipboard() {
        pendingAction = .copyToClipboard
        VerifyPINFlowController.present(
            on: viewController,
            parent: self
        )
    }
    
    func toSaveOTPAuthFile() {
        pendingAction = .saveOTPAuthFile
        VerifyPINFlowController.present(
            on: viewController,
            parent: self
        )
    }
    
    func toExportQRCodes() {
        pendingAction = .exportQRCodes
        VerifyPINFlowController.present(
            on: viewController,
            parent: self
        )
    }
    
    func toSetupPIN() {
        let alert = UIAlertController(
            title: T.Commons.notice,
            message: T.Settings.exportPinNeeded,
            preferredStyle: .alert
        )
        let setPIN = UIAlertAction(title: T.Commons.set, style: .destructive) { _ in
            NotificationCenter.default.post(name: .switchToSetupPIN, object: nil)
        }
        
        let cancel = UIAlertAction(title: T.Commons.cancel, style: .cancel)
        alert.addAction(setPIN)
        alert.addAction(cancel)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func toShareOTPAuthFileContents(_ url: URL, completion: @escaping () -> Void) {
        let activityVC = activityVC(
            for: url,
            title: T.Settings.exportTitleTokens,
            completion: completion
        )
        viewController.present(activityVC, animated: true, completion: nil)
    }
    
    func toShareQRCodes(_ url: URL, completion: @escaping () -> Void) {
        let activityVC = activityVC(
            for: url,
            title: T.Settings.exportTitleQrCodes,
            completion: completion
        )
        viewController.present(activityVC, animated: true, completion: nil)
    }
    
    func toError(_ message: String) {
        let alert = UIAlertController.makeSimple(with: T.Commons.error, message: message)
        viewController.present(alert, animated: true, completion: nil)
    }
}

private extension ExportTokensFlowController {
    func activityVC(for url: URL, title: String, completion: @escaping () -> Void) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.title = title
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .markupAsPDF,
            .openInIBooks,
            .postToFacebook,
            .postToVimeo,
            .postToFlickr,
            .postToTencentWeibo,
            .postToTwitter,
            .postToWeibo
        ]
        
        if let popover = activityVC.popoverPresentationController, let view = UIApplication.keyWindow {
            let bounds = view.bounds
            popover.permittedArrowDirections = .init(rawValue: 0)
            popover.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 1, height: 2)
            popover.sourceView = view
        }
        
        activityVC.completionWithItemsHandler = { _, _, _, _ in
            completion()
        }
        
        return activityVC
    }
}

extension ExportTokensFlowController: VerifyPINFlowControllerParent {
    func hideVerifyPIN() {
        pendingAction = nil
        viewController.dismiss(animated: true)
    }
    
    func pinVerifiedCorrectly(for action: VerifyPINFlowController.Action) {
        viewController.dismiss(animated: true)
        
        guard let pendingAction else { return }
        
        switch pendingAction {
        case .copyToClipboard:
            viewController.presenter.handleCopyToClipboard()
        case .saveOTPAuthFile:
            viewController.presenter.handleSaveOTPAuthFile()
        case .exportQRCodes:
            viewController.presenter.handleExportQRCodes()
        }
        
        self.pendingAction = nil
    }
}

extension ExportTokensFlowController {
    var viewController: ExportTokensViewController {
        _viewController as! ExportTokensViewController
    }
}
