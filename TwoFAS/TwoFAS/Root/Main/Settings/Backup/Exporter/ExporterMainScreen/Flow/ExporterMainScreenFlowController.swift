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

protocol ExporterMainScreenFlowControllerParent: AnyObject {
    func closeExporter()
}

protocol ExporterMainScreenFlowControlling: AnyObject {
    func toClose()
    func toPasswordProtection()
    func toPINKeyboard()
    func toExport(with url: URL)
    func toExportError()
}

final class ExporterMainScreenFlowController: FlowController {
    private weak var parent: ExporterMainScreenFlowControllerParent?
    private weak var navigationController: UINavigationController!
    
    static func present(
        on viewController: UIViewController,
        parent: ExporterMainScreenFlowControllerParent
    ) {
        let view = ExporterMainScreenViewController()
        let flowController = ExporterMainScreenFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.exporterMainScreenModuleInteractor()
        let presenter = ExporterMainScreenPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        
        let navi = RootNavigationController(rootViewController: view)
        navi.configureAsModal()
        navi.rootFlowController = flowController
        navi.isNavigationBarHidden = true
        
        flowController.navigationController = navi
        
        viewController.present(navi, animated: true, completion: nil)
    }
}

extension ExporterMainScreenFlowController: ExporterMainScreenFlowControlling {
    func toClose() {
        parent?.closeExporter()
    }
    
    func toPasswordProtection() {
        ExporterPasswordProtectionFlowController.push(in: navigationController, parent: self)
    }
    
    func toPINKeyboard() {
        showPINKeyboardAuth(with: nil)
    }
    
    func toExport(with url: URL) {
        showExport(with: url)
    }
    
    func toExportError() {
        showExportError()
    }
}

private extension ExporterMainScreenFlowController {
    func showPINKeyboardAuth(with password: String?) {
        ExporterPINFlowController.push(in: navigationController, parent: self, password: password)
    }
    
    func importErrorAlert() -> UIViewController {
        let alert = AlertControllerDismissFlow(
            title: T.Commons.error,
            message: T.Backup.errorWhileExportingFile,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        alert.didDisappear = { [weak self] _ in
            self?.parent?.closeExporter()
        }
        return alert
    }
}

extension ExporterMainScreenFlowController: ExporterPasswordProtectionFlowControllerParent {
    func closePasswordProtection() {
        parent?.closeExporter()
    }
    
    func showExport(with url: URL) {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        vc.title = T.Backup.saveFile
        vc.completionWithItemsHandler = { [weak self] _, _, _, _ in self?.parent?.closeExporter() }
        vc.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .openInIBooks, .saveToCameraRoll]
        if let popover = vc.popoverPresentationController, let view = UIApplication.keyWindow {
            let bounds = view.bounds
            popover.permittedArrowDirections = .init(rawValue: 0)
            popover.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 1, height: 2)
            popover.sourceView = view
        }
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func showExportError() {
        let vc = importErrorAlert()
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func showPINKeyboard(with password: String) {
        showPINKeyboardAuth(with: password)
    }
}

extension ExporterMainScreenFlowController: ExporterPINFlowControllerParent {
    func closePIN() {
        parent?.closeExporter()
    }
}
