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

protocol ExporterPasswordProtectionFlowControllerParent: AnyObject {
    func closePasswordProtection()
    func showExport(with url: URL)
    func showPINKeyboard(with password: String)
    func showExportError()
}

protocol ExporterPasswordProtectionFlowControlling: AnyObject {
    func toClose()
    func toExport(with url: URL)
    func toPINKeyboard(with password: String)
    func toExportError()
}

final class ExporterPasswordProtectionFlowController: FlowController {
    private weak var parent: ExporterPasswordProtectionFlowControllerParent?
    
    static func push(
        in navigationController: UINavigationController,
        parent: ExporterPasswordProtectionFlowControllerParent
    ) {
        let view = ExporterPasswordProtectionViewController()
        let flowController = ExporterPasswordProtectionFlowController(viewController: view)
        flowController.parent = parent
        let interactor = InteractorFactory.shared.exporterPasswordProtectionModuleInteractor()
        let presenter = ExporterPasswordProtectionPresenter(
            flowController: flowController,
            interactor: interactor
        )
        presenter.view = view
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension ExporterPasswordProtectionFlowController: ExporterPasswordProtectionFlowControlling {
    func toClose() {
        parent?.closePasswordProtection()
    }
    
    func toExport(with url: URL) {
        parent?.showExport(with: url)
    }
    
    func toPINKeyboard(with password: String) {
        parent?.showPINKeyboard(with: password)
    }
    
    func toExportError() {
        parent?.showExportError()
    }
}
