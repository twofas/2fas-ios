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

protocol ExporterPINFlowControllerParent: AnyObject {
    func closePIN()
    func showExport(with url: URL)
    func showExportError()
}

protocol ExporterPINFlowControlling: AnyObject {
    func toClose()
    func toExport(with url: URL)
    func toExportError()
}

final class ExporterPINFlowController: FlowController {
    private weak var parent: ExporterPINFlowControllerParent?
    
    static func push(
        in navigationController: UINavigationController,
        parent: ExporterPINFlowControllerParent,
        password: String?
    ) {
        let view = ExporterPINViewController()
        let flowController = ExporterPINFlowController(viewController: view)
        flowController.parent = parent
        let interactor = ModuleInteractorFactory.shared.exporterPINModuleInteractor()
        let presenter = ExporterPINPresenter(
            flowController: flowController,
            interactor: interactor,
            password: password
        )
        presenter.keyboard = view
        view.presenter = presenter
        
        navigationController.pushViewController(view, animated: true)
    }
}

extension ExporterPINFlowController: ExporterPINFlowControlling {
    func toClose() {
        parent?.closePIN()
    }
    
    func toExport(with url: URL) {
        parent?.showExport(with: url)
    }
    
    func toExportError() {
        parent?.showExportError()
    }
}
